// The rules that decide outcomes, as pure functions so RedTest can call them.
module PreemHackerBarrels.Rules

// What the hit hook read off one attack, for HitCounts.
public struct MagHit {
  public let targetAlive: Bool;
  public let targetHostile: Bool;
  public let instigatorIsPlayer: Bool;
  public let attackType: gamedataAttackType;
  public let isDoT: Bool;
  public let weaponHasMag: Bool;
}

// What one hit that counts does to a target's Cripple charge, from CrippleStep.
public struct CrippleResult {
  public let newStacks: Int32;
  public let cripple: Bool;
}

public abstract class MagRules {
  // SPEC §4: whether a hit can add a stack of the barrel's status effect.
  public static func HitCounts(hit: MagHit) -> Bool {
    return hit.targetAlive
      && hit.targetHostile
      && hit.instigatorIsPlayer
      && AttackData.IsRangedOrDirect(hit.attackType)
      && !hit.isDoT
      && hit.weaponHasMag;
  }

  // SPEC §4: at most one stack per target, per barrel, per stackInterval. hasStacked is false when
  // the target has no stack time for this barrel yet.
  public static func StackAllowed(hasStacked: Bool, lastStack: Float, now: Float, stackInterval: Float) -> Bool {
    return !hasStacked || now - lastStack >= stackInterval;
  }

  // SPEC §6: one hit that counts on a target holding this many stacks. cripple true means "start the
  // upload". If the upload can't start, the caller keeps maxStacks and starts no cooldown, and the
  // next hit comes back here with stacks at maxStacks.
  public static func CrippleStep(stacks: Int32, now: Float, cooldownEnd: Float, maxStacks: Int32) -> CrippleResult {
    let result: CrippleResult;
    if stacks + 1 < maxStacks {
      result.newStacks = stacks + 1;
    } else {
      if now >= cooldownEnd {
        result.cripple = true;
      } else {
        result.newStacks = maxStacks - 1;
      }
    }
    return result;
  }

  // SPEC §6: the flat naming the quickhack a barrel uploads on this kind of target.
  public static func HackFlat(effect: TweakDBID, isChimera: Bool, isBoss: Bool) -> TweakDBID {
    if isChimera {
      return effect + t".quickhackChimera";
    }
    return isBoss ? effect + t".quickhackBoss" : effect + t".quickhack";
  }

  // SPEC §6b: which of the deck's hacks (ActionName and Priority each) the barrel uploads instead of its
  // own record, or -1 for its own.
  public static func DeckPick(own: CName, ownLevel: Float, names: array<CName>, levels: array<Float>) -> Int32 {
    let pick = -1;
    let best = ownLevel;
    let i = 0;
    while i < ArraySize(names) {
      if Equals(names[i], own) && levels[i] > best {
        pick = i;
        best = levels[i];
      }
      i += 1;
    }
    return pick;
  }

  // SPEC §5: a quickhack's RAM cost on a target with this many Breach stacks.
  public static func DiscountedCost(cost: Int32, stacks: Int32, ramPerStack: Int32) -> Int32 {
    if cost < 2 {
      return cost;
    }
    return Max(2, cost - stacks * ramPerStack);
  }
}
