// A minimal Preem Weaponsmith add-on: one Mag mod, a simple Cripple Shard that costs 10% damage.
// The README walks through this file, step by step, beside the Hacker Mod Pack's own code.
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

// Whether a weapon has the Cripple Shard on it (README, Step 4). Call it from your own code.
public abstract class MyAddonWeapon {
  // True when the weapon has the Cripple Shard in either Mag slot.
  public static func HasCrippleShard(weapon: wref<WeaponObject>) -> Bool {
    if !IsDefined(weapon) {
      return false;
    }
    let itemData = weapon.GetItemData();
    if !IsDefined(itemData) {
      return false;
    }
    return MyAddonWeapon.SlotHolds(itemData, t"AttachmentSlots.PreemMagazineMod01", t"Items.MyAddon_CrippleShard")
      || MyAddonWeapon.SlotHolds(itemData, t"AttachmentSlots.PreemMagazineMod02", t"Items.MyAddon_CrippleShard");
  }

  private static func SlotHolds(itemData: ref<gameItemData>, slot: TweakDBID, item: TweakDBID) -> Bool {
    if !itemData.HasPartInSlot(slot) {
      return false;
    }
    let part: InnerItemData;
    itemData.GetItemPart(part, slot);
    return ItemID.GetTDBID(InnerItemData.GetItemID(part)) == item;
  }
}
