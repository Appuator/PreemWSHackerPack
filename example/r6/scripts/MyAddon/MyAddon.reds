// A minimal Preem Weaponsmith add-on: one barrel mod that adds 10% damage.
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
    return [n"MyAddon.PowerBarrel"];
  }

  // What the crafting screen shows for the mod, and which slots it goes in.
  public func DefineMod(id: CName, mod: ref<PreemMod>) -> Bool {
    if NotEquals(id, n"MyAddon.PowerBarrel") {
      return false;
    }
    mod.preemClassType = PreemModClassType.Barrel;
    mod.SetModName(n"Power Barrel");
    mod.SetDescription("+10% damage");
    mod.SetAdditionalDescription("An example mod from MyAddon.");
    return true;
  }

  // The item record for the mod, from the .yaml file.
  public func MapItem(id: CName) -> TweakDBID {
    if Equals(id, n"MyAddon.PowerBarrel") {
      return t"Items.MyAddon_PowerBarrel";
    }
    return TDBID.None();
  }

  // The blueprint rarity that unlocks the mod in the Weapon Blueprints unlock mode.
  public func GetUnlockQuality(id: CName) -> gamedataQuality {
    if Equals(id, n"MyAddon.PowerBarrel") {
      return gamedataQuality.Uncommon;
    }
    return gamedataQuality.Invalid;
  }
}
