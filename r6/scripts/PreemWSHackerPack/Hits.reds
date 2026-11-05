// The shared hit hook (SPEC §4). DamagePipelineFinalized runs on worker threads, so the wrap only
// copies what it needs into a request; MagHitSystem handles it next frame on the main thread,
// one at a time, which is why its state needs no lock (notes/npc-spawn-and-hit.md).
module PreemHackerBarrels.Hits

import PreemHackerBarrels.Mags.*
import PreemHackerBarrels.Rules.*
import PreemHackerBarrels.Upload.*

public class MagHitRequest extends ScriptableSystemRequest {
  public let target: wref<ScriptedPuppet>;
  public let attackType: gamedataAttackType;
  public let isDoT: Bool;
  public let weapon: wref<WeaponObject>;
}

// When a target last got a stack of one status effect, and when its upload cooldown ends. Dropped
// once both have passed, since an entry that old can't stop anything.
class MagStackTime {
  public let targetID: EntityID;
  public let effectID: TweakDBID;
  public let lastStack: Float;
  public let stackInterval: Float;
  public let cooldownEnd: Float;
}

public class MagHitSystem extends ScriptableSystem {
  private let m_stackTimes: array<ref<MagStackTime>>;

  private final func OnMagHitRequest(request: ref<MagHitRequest>) -> Void {
    let target = request.target;
    let player = GetPlayer(this.GetGameInstance());
    if !IsDefined(target) || !IsDefined(player) {
      return;
    }
    let hit: MagHit;
    hit.targetAlive = ScriptedPuppet.IsAlive(target);
    hit.targetHostile = Equals(GameObject.GetAttitudeTowards(target, player), EAIAttitude.AIA_Hostile);
    // The wrap only sends the player's attacks.
    hit.instigatorIsPlayer = true;
    hit.attackType = request.attackType;
    hit.isDoT = request.isDoT;
    for barrel in MagTable.Rows() {
      hit.weaponHasMag = MagHitSystem.WeaponHasMag(request.weapon, barrel.item);
      if MagRules.HitCounts(hit) {
        this.TryAddStack(target, player, barrel.effect);
      }
    }
  }

  private final func TryAddStack(target: ref<ScriptedPuppet>, player: ref<PlayerPuppet>, effect: TweakDBID) -> Void {
    let game = this.GetGameInstance();
    let targetID = target.GetEntityID();
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(game));
    let stackInterval = TweakDBInterface.GetFloat(effect + t".stackInterval", 0.0);
    let stackTime = this.FindStackTime(targetID, effect);
    let hasStacked = IsDefined(stackTime);
    let lastStack = hasStacked ? stackTime.lastStack : 0.0;
    if !MagRules.StackAllowed(hasStacked, lastStack, now, stackInterval) {
      return;
    }
    if !hasStacked {
      stackTime = new MagStackTime();
      stackTime.targetID = targetID;
      stackTime.effectID = effect;
      ArrayPush(this.m_stackTimes, stackTime);
    }
    stackTime.lastStack = now;
    stackTime.stackInterval = stackInterval;
    this.DropExpired(now);
    // A barrel whose data names a quickhack charges toward an upload (SPEC §6).
    if NotEquals(TweakDBInterface.GetString(effect + t".quickhack", ""), "") {
      this.StepCharge(target, player, effect, stackTime, now);
      return;
    }
    StatusEffectHelper.ApplyStatusEffect(target, effect, player.GetEntityID());
    // An open wheel keeps the old cost until it's told to redraw (SPEC §5).
    QuickhackModule.RequestRefreshQuickhackMenu(game, targetID);
  }

  private final func StepCharge(target: ref<ScriptedPuppet>, player: ref<PlayerPuppet>, effect: TweakDBID, stackTime: ref<MagStackTime>, now: Float) -> Void {
    let charge = StatusEffectHelper.GetStatusEffectByID(target, effect);
    let stacks = IsDefined(charge) ? Cast<Int32>(charge.GetStackCount()) : 0;
    let step = MagRules.CrippleStep(stacks, now, stackTime.cooldownEnd, MagHitSystem.MaxStacks(effect));
    if step.cripple {
      if MagUpload.Start(player, target, effect) {
        if stacks > 0 {
          StatusEffectHelper.RemoveStatusEffect(target, effect, Cast<Uint32>(stacks));
        }
        stackTime.cooldownEnd = now + TweakDBInterface.GetFloat(effect + t".uploadCooldown", 0.0);
      } else {
        // Can't start: hold the full charge with no cooldown, and the next hit retries.
        StatusEffectHelper.ApplyStatusEffect(target, effect, player.GetEntityID());
      }
      return;
    }
    // At the hold during a cooldown there's no new stack, so nothing refreshes the duration either.
    if step.newStacks > stacks {
      StatusEffectHelper.ApplyStatusEffect(target, effect, player.GetEntityID());
    }
  }

  private final static func MaxStacks(effect: TweakDBID) -> Int32 {
    let modifier = TweakDBInterface.GetStatusEffectRecord(effect).MaxStacks().GetStatModifiersItem(0) as ConstantStatModifier_Record;
    return Cast<Int32>(modifier.Value());
  }

  private final func FindStackTime(targetID: EntityID, effect: TweakDBID) -> ref<MagStackTime> {
    for stackTime in this.m_stackTimes {
      if stackTime.targetID == targetID && stackTime.effectID == effect {
        return stackTime;
      }
    }
    return null;
  }

  private final func DropExpired(now: Float) -> Void {
    let i = ArraySize(this.m_stackTimes) - 1;
    while i >= 0 {
      if now - this.m_stackTimes[i].lastStack >= this.m_stackTimes[i].stackInterval && now >= this.m_stackTimes[i].cooldownEnd {
        ArrayErase(this.m_stackTimes, i);
      }
      i -= 1;
    }
  }

  private final static func WeaponHasMag(weapon: wref<WeaponObject>, item: TweakDBID) -> Bool {
    if !IsDefined(weapon) {
      return false;
    }
    let itemData = weapon.GetItemData();
    if !IsDefined(itemData) {
      return false;
    }
    return MagHitSystem.SlotHoldsItem(itemData, t"AttachmentSlots.PreemMagazineMod01", item)
      || MagHitSystem.SlotHoldsItem(itemData, t"AttachmentSlots.PreemMagazineMod02", item);
  }

  private final static func SlotHoldsItem(itemData: ref<gameItemData>, slot: TweakDBID, item: TweakDBID) -> Bool {
    if !itemData.HasPartInSlot(slot) {
      return false;
    }
    let part: InnerItemData;
    itemData.GetItemPart(part, slot);
    return ItemID.GetTDBID(InnerItemData.GetItemID(part)) == item;
  }
}

@wrapMethod(ScriptedPuppet)
protected func DamagePipelineFinalized(evt: ref<gameHitEvent>) -> Void {
  wrappedMethod(evt);
  let instigator = evt.attackData.GetInstigator();
  if !IsDefined(instigator) || !instigator.IsPlayer() {
    return;
  }
  let request = new MagHitRequest();
  request.target = this;
  request.attackType = evt.attackData.GetAttackType();
  request.isDoT = AttackData.IsDoT(evt.attackData);
  request.weapon = evt.attackData.GetWeapon();
  GameInstance.GetDelaySystem(this.GetGame()).DelayScriptableSystemRequestNextFrame(n"PreemHackerBarrels.Hits.MagHitSystem", request);
}
