// Starts the real, free quickhack upload a barrel's data names (SPEC §6). This is the route proved in
// notes/gris-gris.md: it needs neither the wheel controller nor the CostFreeActionID slot vanilla's
// Gris-Gris shares. Call it from the main thread.
module PreemHackerBarrels.Upload

import PreemHackerBarrels.Rules.*

public abstract class MagUpload {
  // False if it can't start, for example when the target's record has no such action.
  public static func Start(player: ref<PlayerPuppet>, target: ref<ScriptedPuppet>, effect: TweakDBID) -> Bool {
    let isChimera = Equals(target.GetNPCType(), gamedataNPCType.Chimera);
    let isBoss = StatusEffectSystem.ObjectHasStatusEffect(target, t"BaseStatusEffect.MainBossSE");
    let hack = TweakDBInterface.GetString(MagRules.HackFlat(effect, isChimera, isBoss), "");
    // CreateSimpleQuickhackData reads the record without checking it.
    let record = TweakDBInterface.GetObjectActionRecord(TDBID.Create(hack));
    if !IsDefined(record) {
      return false;
    }
    record = MagUpload.DeckOrOwn(player, record);
    let data = RPGManager.CreateSimpleQuickhackData(player, target, record);
    if !IsDefined(data) {
      return false;
    }
    let action = data.m_action as ScriptableDeviceAction;
    if !IsDefined(action) {
      return false;
    }
    action.SetCanSkipPayCost(true);
    let command = new QuickSlotCommandUsed();
    command.action = action;
    player.QueueEventForEntityID(target.GetEntityID(), command);
    return true;
  }

  // SPEC §6b: the same hack slotted in the player's cyberdeck if it's a higher level, else the barrel's
  // own. Vanilla's list holds the slotted hacks with their Boss and Chimera records.
  private static func DeckOrOwn(player: ref<PlayerPuppet>, own: wref<ObjectAction_Record>) -> wref<ObjectAction_Record> {
    let deck = RPGManager.GetPlayerQuickHackListWithQuality(player);
    let names: array<CName>;
    let levels: array<Float>;
    for data in deck {
      let defined = IsDefined(data.actionRecord);
      ArrayPush(names, defined ? data.actionRecord.ActionName() : n"None");
      ArrayPush(levels, defined ? data.actionRecord.Priority() : -1.0);
    }
    let pick = MagRules.DeckPick(own.ActionName(), own.Priority(), names, levels);
    return pick >= 0 ? deck[pick].actionRecord : own;
  }
}
