// The Hacker barrel's RAM discount (SPEC §5). GetCost is what the wheel shows and what PayCost
// charges, so this one wrap covers both; GetBaseCost stays as it was, which is how the wheel knows
// to mark the cost as reduced.
module PreemHackerBarrels.Discount

import PreemHackerBarrels.Rules.*

@wrapMethod(BaseScriptableAction)
public func GetCost() -> Int32 {
  let cost = wrappedMethod();
  let executor = this.GetExecutor();
  if !IsDefined(executor) {
    return cost;
  }
  // The same target vanilla's GetCost uses.
  let targetID = this.GetRequesterID();
  if !EntityID.IsDefined(targetID) {
    targetID = PersistentID.ExtractEntityID(this.GetPersistentID());
  }
  let target = GameInstance.FindEntityByID(executor.GetGame(), targetID) as GameObject;
  if !IsDefined(target) {
    return cost;
  }
  let breach = StatusEffectHelper.GetStatusEffectByID(target, t"BaseStatusEffect.PHB_Breach");
  if !IsDefined(breach) {
    return cost;
  }
  let ramPerStack = TweakDBInterface.GetInt(t"BaseStatusEffect.PHB_Breach.ramPerStack", 0);
  return MagRules.DiscountedCost(cost, Cast<Int32>(breach.GetStackCount()), ramPerStack);
}

// Breach running out changes the cost too, so an open wheel has to redraw.
@wrapMethod(ScriptedPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
  let result = wrappedMethod(evt);
  if evt.staticData.GetID() == t"BaseStatusEffect.PHB_Breach" {
    QuickhackModule.RequestRefreshQuickhackMenu(this.GetGame(), this.GetEntityID());
  }
  return result;
}
