// A minimal Preem Weaponsmith add-on: one Mag mod, a simple Cripple Shard that costs 10% damage.
// The Hacker Mod Pack's real Cripple Shard also uploads Cripple Movement; see the README, Part 5.
// Install: copy this folder to <game>\r6\scripts\MyAddon\ and the tweaks folder to <game>\r6\tweaks\MyAddon\.
module MyAddon

// Only build this class when Preem Weaponsmith is installed, so the game still starts without it.
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Addons.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Core.*

@if(ModuleExists("PreemCrafting.Addons"))
public class MyAddon extends PreemAddon {
  // The add-on API version this was written for.
  public func RequiredApiVersion() -> Int32 {
    return 1;
  }

  // Every mod this add-on adds, by ID. Start each ID with your module name so it can't clash.
  public func GetModIds() -> array<CName> {
    return [n"MyAddon.CrippleShard"];
  }

  // What the crafting screen shows for the mod, and which slots it goes in.
  public func DefineMod(id: CName, mod: ref<PreemMod>) -> Bool {
    if NotEquals(id, n"MyAddon.CrippleShard") {
      return false;
    }
    mod.preemClassType = PreemModClassType.Mag;
    mod.SetModName(n"Cripple Shard");
    mod.SetDescription("-10% damage");
    mod.SetAdditionalDescription("\"There, gave you a handicap!\" - Capri");
    return true;
  }

  // The item record for the mod, from the .yaml file.
  public func MapItem(id: CName) -> TweakDBID {
    if Equals(id, n"MyAddon.CrippleShard") {
      return t"Items.MyAddon_CrippleShard";
    }
    return TDBID.None();
  }

  // The blueprint rarity that unlocks the mod in the Weapon Blueprints unlock mode.
  public func GetUnlockQuality(id: CName) -> gamedataQuality {
    if Equals(id, n"MyAddon.CrippleShard") {
      return gamedataQuality.Epic;
    }
    return gamedataQuality.Invalid;
  }
}
