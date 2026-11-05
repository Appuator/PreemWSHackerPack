// The add-on's registration with Preem Weaponsmith (docs/ADDONS.md in core). Core finds this
// subclass by reflection and asks it about the mod IDs it owns (SPEC §3), which come from MagTable.
// Guarded so that without core installed the class is left out instead of breaking the game's script
// compile.
module PreemHackerBarrels

@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Addons.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Core.*
import PreemHackerBarrels.Mags.*

@if(ModuleExists("PreemCrafting.Addons"))
public class HackerBarrelsAddon extends PreemAddon {
  public func RequiredApiVersion() -> Int32 {
    return 1;
  }

  public func GetModIds() -> array<CName> {
    let ids: array<CName>;
    for row in MagTable.Rows() {
      ArrayPush(ids, row.id);
    }
    return ids;
  }

  public func DefineMod(id: CName, mod: ref<PreemMod>) -> Bool {
    let row = MagTable.Find(id);
    if !IsNameValid(row.id) {
      return false;
    }
    mod.preemClassType = PreemModClassType.Mag;
    mod.SetModName(row.name);
    mod.SetDescription(row.description);
    mod.SetAdditionalDescription(row.flavour);
    return true;
  }

  public func MapItem(id: CName) -> TweakDBID {
    let row = MagTable.Find(id);
    return row.item;
  }

  public func GetUnlockQuality(id: CName) -> gamedataQuality {
    let row = MagTable.Find(id);
    return row.unlock;
  }
}
