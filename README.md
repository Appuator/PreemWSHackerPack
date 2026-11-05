# Preem Weaponsmith - Hacker Mod Pack

Source code for **Preem Weaponsmith - Hacker Mod Pack** (https://www.nexusmods.com/cyberpunk2077/mods/37175), an add-on for [Preem Weaponsmith](https://www.nexusmods.com/cyberpunk2077/mods/9692).

This README teaches one thing: **how to make a Preem Weaponsmith add-on with a single mod that only changes stats.** It walks through the Hacker Mod Pack's own **Cripple Shard** from start to finish, using only the parts of it a stats mod needs. Then it shows how your code can tell whether a weapon has your mod on it, so you know where to start if you later want your mod to do more.

The finished files from this walkthrough are in `example/`.

- [What you need](#what-you-need)
- [Step 1: The records (.yaml)](#step-1-the-records-yaml)
- [Step 2: The add-on class (.reds)](#step-2-the-add-on-class-reds)
- [Step 3: Try it in game](#step-3-try-it-in-game)
- [Step 4: Check whether a weapon has your mod](#step-4-check-whether-a-weapon-has-your-mod)
- [License](#license)

## What you need

- **Cyberpunk 2077 on PC.** Add-ons don't work on consoles.
- **Preem Weaponsmith 2.6.0 or newer** (the first version with add-ons), and the frameworks it needs: RED4ext, redscript, Codeware and TweakXL.
- **A text editor.** Any will do; [VS Code](https://code.visualstudio.com/) colours YAML, and a redscript extension from its marketplace colours `.reds` files.
- **Optional: Cyber Engine Tweaks (CET)**, to see Preem Weaponsmith's log line that says your add-on loaded.

There's nothing to compile or build: the game reads your files each time it starts.

An add-on is two files:

| File | Goes in | Read by | Says |
|---|---|---|---|
| `.yaml` | `r6/tweaks/<YourAddon>/` | TweakXL | What the mod item is: which slots it fits and which stats it changes |
| `.reds` | `r6/scripts/<YourAddon>/` | redscript | What Preem Weaponsmith shows for it: its name, text, slot class and when it unlocks |

First pick a short name for your add-on with no spaces, such as `PlasmaMods`. Every name you make starts with it, so your add-on can't clash with anyone else's. The Hacker Mod Pack's records start with `PHB_`; this walkthrough uses `MyAddon`.

## Step 1: The records (.yaml)

Start with the item. Here are the Cripple Shard's records from the pack's `r6/tweaks/PreemWSHackerPack/mags.yaml`:

```yaml
Items.PHB_MagDamagePenalty:
  $type: gamedataConstantStatModifier_Record
  modifierType: Multiplier
  statType: BaseStats.DPS
  value: 0.9

Items.PHB_CrippleMag:
  $base: Items.SimpleWeaponMod01
  placementSlots: [AttachmentSlots.PreemMagazineMod01, AttachmentSlots.PreemMagazineMod02]
  statModifiers: [Items.PHB_MagDamagePenalty]
```

Each block is one **record**, an entry in the game's database (TweakDB). The first line of a block is the record's ID.

**The stat change, `Items.PHB_MagDamagePenalty`:**

- `$type: gamedataConstantStatModifier_Record` makes it a fixed-size stat change.
- `statType` is the stat it changes. `BaseStats.DPS` is the weapon's damage.
- `modifierType` is how: `Multiplier` multiplies the stat, and `Additive` adds to it.
- `value` is how much: `0.9` with `Multiplier` means 90%, so the mod costs 10% damage. `1.1` would be +10%.

**The mod item, `Items.PHB_CrippleMag`:**

- `$base: Items.SimpleWeaponMod01` copies a plain game weapon mod, so you only write what's different.
- `placementSlots` names the two Preem Weaponsmith slots it fits. The Cripple Shard is a Mag mod, so it fits both Mag slots. Use the pair for your mod's slot class:

  | Slot class | `placementSlots` |
  |---|---|
  | Barrel | `[AttachmentSlots.PreemBarrelMod01, AttachmentSlots.PreemBarrelMod02]` |
  | Trigger | `[AttachmentSlots.PreemTriggerMod01, AttachmentSlots.PreemTriggerMod02]` |
  | Mag | `[AttachmentSlots.PreemMagazineMod01, AttachmentSlots.PreemMagazineMod02]` |
  | Blade | `[AttachmentSlots.PreemBladeMod01, AttachmentSlots.PreemBladeMod02]` |
  | Handle | `[AttachmentSlots.PreemHandleMod01, AttachmentSlots.PreemHandleMod02]` |

- `statModifiers` lists the stat changes the mod puts on a weapon. Two of these mods on one weapon both apply, so two Cripple Shards leave it at 81% damage.

**Your version.** Make a file `r6/tweaks/MyAddon/my_addon.yaml` with the same two records under your own IDs:

```yaml
Items.MyAddon_DamagePenalty:
  $type: gamedataConstantStatModifier_Record
  modifierType: Multiplier
  statType: BaseStats.DPS
  value: 0.9

Items.MyAddon_CrippleShard:
  $base: Items.SimpleWeaponMod01
  placementSlots: [AttachmentSlots.PreemMagazineMod01, AttachmentSlots.PreemMagazineMod02]
  statModifiers: [Items.MyAddon_DamagePenalty]
```

To change more than one stat, add another stat record and list it too: `statModifiers: [Items.MyAddon_DamagePenalty, Items.MyAddon_ReloadBonus]`. To find stat names, look at the game's own weapon mods in a TweakDB browser (WolvenKit has one) and copy what they use.

Once your add-on is released, **never rename the item record** (`Items.MyAddon_CrippleShard`). Saved weapons store that ID, so a rename takes the mod off players' weapons.

## Step 2: The add-on class (.reds)

The records make the item. The class tells Preem Weaponsmith about it. Make a file `r6/scripts/MyAddon/MyAddon.reds`.

**The top of the file.** Here's the top of the pack's `HackerBarrelsAddon.reds`:

```swift
module PreemHackerBarrels

@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Addons.*
@if(ModuleExists("PreemCrafting.Addons"))
import PreemCrafting.Core.*

@if(ModuleExists("PreemCrafting.Addons"))
public class HackerBarrelsAddon extends PreemAddon {
```

- `module` names your code's home. Use your add-on's name: `module MyAddon`.
- The `import` lines bring in Preem Weaponsmith's add-on API.
- `public class ... extends PreemAddon` is your add-on. Preem Weaponsmith finds every `PreemAddon` class by itself when the game starts, so there's nothing to register. Name yours after your add-on: `public class MyAddon extends PreemAddon {`.
- `@if(ModuleExists("PreemCrafting.Addons"))` means "only build the next line when Preem Weaponsmith is installed". Without it, a player who removes Preem Weaponsmith but keeps your add-on gets a script error at startup. Keep it above each `import` and above the class.

Inside the class go five methods. The pack has 11 mods, so its methods look each one up in a table (`MagTable` in `Mags.reds`). Here's the Cripple Shard's row in that table:

```swift
MagTable.Row(n"PreemHackerBarrels.Cripple", t"Items.PHB_CrippleMag", t"BaseStatusEffect.PHB_CrippleCharge", gamedataQuality.Epic,
  n"Cripple Shard",
  "Hits apply a Cripple stack, up to 3(.2 sec cooldown).\n at 3 stacks uploads the \"Cripple Movement\" quickhack.\n -10% damage \n30 sec cooldown between uploads",
  "\"There, gave you a handicap!\" - Capri"),
```

It holds the mod's ID, its item record, a status effect (only the pack's quickhack upload uses that), its unlock rarity, name, description and flavour text. With one mod you don't need a table: each method below answers for the one mod directly.

**`RequiredApiVersion`**: the add-on API version you wrote against. It's `1`. If a player's Preem Weaponsmith is too old for your add-on, it skips your add-on and logs why instead of breaking.

```swift
public func RequiredApiVersion() -> Int32 {
  return 1;
}
```

**`GetModIds`**: every mod your add-on adds, by ID. The ID is a name (`n"..."`) that starts with your add-on's name. The pack's is `n"PreemHackerBarrels.Cripple"`.

```swift
public func GetModIds() -> array<CName> {
  return [n"MyAddon.CrippleShard"];
}
```

**`DefineMod`**: Preem Weaponsmith calls this once for each of your IDs, with a blank `mod` to fill in. Here's the pack's:

```swift
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
```

With one mod, check the ID, then fill in the mod's text in place of `row.name` and the rest:

```swift
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
```

- `preemClassType` is the slot class: `Barrel`, `Trigger`, `Mag`, `Blade` or `Handle`. It has to match the `placementSlots` in your `.yaml`.
- `SetModName` is the name in the crafting screen. `SetDescription` says what it does, and `SetAdditionalDescription` is the flavour text under it. Without them, the mod shows Preem Weaponsmith's placeholder text.
- Inside the quotes, `\"` puts a quotation mark in the text and `\n` starts a new line.
- `return true` adds the mod. `return false` leaves an ID out.

Give your mod its own name before you release it: this one shares the pack's Cripple Shard name.

**`MapItem`**: the item record from Step 1, for your ID. The pack returns `row.item`, which for the Cripple Shard is `t"Items.PHB_CrippleMag"`. It must be the exact ID from your `.yaml`.

```swift
public func MapItem(id: CName) -> TweakDBID {
  if Equals(id, n"MyAddon.CrippleShard") {
    return t"Items.MyAddon_CrippleShard";
  }
  return TDBID.None();
}
```

**`GetUnlockQuality`**: when the mod unlocks in Preem Weaponsmith's Weapon Blueprints mode. A weapon can take it once its blueprint is this rarity or better. The pack's Cripple Shard unlocks at `Epic`. The choices are `Common`, `Uncommon`, `Rare`, `Epic` and `Legendary`. In Sandbox mode everything is unlocked anyway.

```swift
public func GetUnlockQuality(id: CName) -> gamedataQuality {
  if Equals(id, n"MyAddon.CrippleShard") {
    return gamedataQuality.Epic;
  }
  return gamedataQuality.Invalid;
}
```

Close the class with a `}` after the last method. The whole file is `example/r6/scripts/MyAddon/MyAddon.reds`.

## Step 3: Try it in game

1. Find your game folder: the one holding the `bin` and `r6` folders (for Steam, usually `...\steamapps\common\Cyberpunk 2077`).
2. Put your files in it: `r6/tweaks/MyAddon/my_addon.yaml` and `r6/scripts/MyAddon/MyAddon.reds`. (To try the finished example, copy the two `MyAddon` folders from `example/r6/` into the game's `r6/`.)
3. Start the game and load a save.
4. Open the crafting screen and go to Preem Weaponsmith's **Mag** page: your mod is there. Craft it, slot it, and the weapon's damage drops by 10%.

With CET installed, its log (`bin/x64/plugins/cyber_engine_tweaks/gamelog.log`, written when the game closes) has the line `[PreemWeaponsmith] add-on MyAddon.MyAddon: 1 mods`.

The game only reads these files when it starts, so restart it after every change. If something's wrong:

| Symptom | Look here |
|---|---|
| A popup at startup about script errors | `r6/logs/redscript_rCURRENT.log` has the file, line and error. Usually a typo, a missing `;` or a missing `}`. |
| The mod isn't in the crafting screen | CET's `gamelog.log`. No `add-on` line: the class didn't load (check the redscript log). `0 mods`: `GetModIds` or `DefineMod` didn't match your ID. |
| The mod is there but changes no stats | `red4ext/plugins/TweakXL/TweakXL.log` for a mistake in your `.yaml`, and check that `MapItem` returns the exact record ID. |

To release it, zip the two folders so the zip holds `r6/scripts/MyAddon/` and `r6/tweaks/MyAddon/`, and list Preem Weaponsmith 2.6.0 or newer as a requirement on your mod page.

## Step 4: Check whether a weapon has your mod

A stats mod needs nothing more. But if you later want your mod to do something when, say, a bullet hits, your code first has to know whether the weapon has your mod on it.

A slotted mod is a **part** in one of the weapon's slots, and the part is your item record from Step 1. So you check the weapon's two slots for your mod's slot class, and compare what's in them with your record. Here's how the pack does it, from `r6/scripts/PreemWSHackerPack/Hits.reds`:

```swift
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
```

- `weapon.GetItemData()` gets the weapon as an item, which holds its parts.
- `HasPartInSlot(slot)` says whether anything is in that slot.
- `GetItemPart(part, slot)` fills `part` with what's in it, and `ItemID.GetTDBID(InnerItemData.GetItemID(part))` is that part's record ID.
- The `IsDefined` checks stop the code if there's no weapon or no item data, which would otherwise crash the game.

For your add-on, the same check with your record and slots built in looks like this. Put it in your `.reds` file, outside the class:

```swift
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
```

For another slot class, swap in its two slot IDs from the table in Step 1.

**Where the weapon comes from** depends on where your code runs:

- In a hit, the attack carries the weapon that made it. The pack's hit hook in `Hits.reds` reads it with `evt.attackData.GetWeapon()`.
- For the weapon the player is holding, `ScriptedPuppet.GetWeaponRight(player)`.

Then `if MyAddonWeapon.HasCrippleShard(weapon) { ... }` is where your mod's own behaviour goes. To run code when the game does something, you wrap one of the game's functions with `@wrapMethod`, the way `Hits.reds` wraps `ScriptedPuppet.DamagePipelineFinalized` (which runs after every hit on an NPC). Two rules for that: always call `wrappedMethod(...)` inside it so the game and other mods still get their turn, and wrap only the game's own classes, since redscript can't wrap Preem Weaponsmith's.

## License

MIT, see [LICENSE](LICENSE). You're free to copy, change and build on this code, including the example, for your own add-ons.
