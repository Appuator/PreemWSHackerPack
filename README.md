# Preem Weaponsmith - Hacker Mod Pack

Source code for **Preem Weaponsmith - Hacker Mod Pack**, a Cyberpunk 2077 mod on Nexus: https://www.nexusmods.com/cyberpunk2077/mods/37175

It's an **add-on** for [Preem Weaponsmith](https://www.nexusmods.com/cyberpunk2077/mods/9692): it adds 11 new mods that you craft and slot into a weapon's Mag slots. This README explains how the add-on works, and how to **make your own add-on with your own mods**, even if you haven't written much code before. The `example/` folder holds a complete, tiny add-on to start from.

- [What's in this repo](#whats-in-this-repo)
- [What an add-on is](#what-an-add-on-is)
- [What you need](#what-you-need)
- [Part 1: Install the example and see it in game](#part-1-install-the-example-and-see-it-in-game)
- [Part 2: Make it yours](#part-2-make-it-yours)
- [Part 3: Change what the mod does to stats](#part-3-change-what-the-mod-does-to-stats)
- [Part 4: More than one mod](#part-4-more-than-one-mod)
- [Part 5: Mods that do something new (hooks)](#part-5-mods-that-do-something-new-hooks)
- [Reference: the add-on class](#reference-the-add-on-class)
- [Rules that keep your add-on working](#rules-that-keep-your-add-on-working)
- [When something goes wrong](#when-something-goes-wrong)
- [Releasing your add-on](#releasing-your-add-on)
- [How the Hacker Mod Pack works](#how-the-hacker-mod-pack-works)
- [License](#license)

## What's in this repo

The folders mirror the game's own folders, so you can see exactly where each file goes when installed.

| Path | What it is |
|---|---|
| `r6/scripts/PreemWSHackerPack/` | The Hacker Mod Pack's code (`.reds` files, written in redscript) |
| `r6/tweaks/PreemWSHackerPack/` | Its game records (`.yaml` files, read by TweakXL) |
| `example/r6/scripts/MyAddon/` | The example add-on's code: one file |
| `example/r6/tweaks/MyAddon/` | The example add-on's records: one file |

Comments in the Hacker Mod Pack's code mention design notes (`SPEC`, `notes/...`) from the author's private working copy. You don't need them to read the code.

## What an add-on is

Preem Weaponsmith adds a crafting system for weapon mods: barrels, triggers, mags, blades and handles, each with two slots on a weapon. An **add-on** is a separate mod that adds **its own** mods to that system. Its mods appear in the crafting screen, unlock, craft, slot into weapons and save exactly like Preem Weaponsmith's own, and you never edit Preem Weaponsmith's files.

An add-on is made of two kinds of file:

1. **A `.yaml` file** (records). Each mod is an *item record*: an entry in the game's database (TweakDB) that says "this is a weapon mod, it fits these slots, and it changes these stats". TweakXL reads these files when the game starts.
2. **A `.reds` file** (code). One small class tells Preem Weaponsmith which mods your add-on has, what they're called and when they unlock. redscript compiles these files when the game starts.

A mod that only changes stats (more damage, faster reload) needs nothing else. A mod that does something new (like this pack uploading quickhacks) also needs code that reacts to the game: see Part 5.

## What you need

- **Cyberpunk 2077 on PC** (patch 2.5). Add-ons don't work on consoles.
- **Preem Weaponsmith 2.6.0 or newer**, and what it needs:

  | Framework | Version |
  |---|---|
  | RED4ext | 1.31.0 or newer |
  | redscript | 0.5.32 or newer |
  | Codeware | 1.21.0 or newer |
  | TweakXL | 1.12.0 or newer |

- **A text editor.** Any will do. [VS Code](https://code.visualstudio.com/) is a good free one: it colours YAML, and a redscript extension from its marketplace can colour `.reds` files and point out mistakes.
- **Optional: Cyber Engine Tweaks (CET).** Preem Weaponsmith writes a line to CET's log when it finds your add-on, which is a quick way to check it loaded.

You don't need to install a compiler or build anything: the game compiles your files itself every time it starts.

## Part 1: Install the example and see it in game

The example adds one Mag mod, a simple **Cripple Shard**. It's the pack's Cripple Shard with only its records: it costs a weapon 10% damage, like the real one, but it doesn't build stacks or upload Cripple Movement. Part 5 shows where the real one does that. Because it shares the real mod's name, give yours a different one before you release anything.

1. Find your game folder: the one holding the `bin` and `r6` folders (for Steam, usually `...\steamapps\common\Cyberpunk 2077`).
2. Copy `example/r6/scripts/MyAddon` into the game's `r6/scripts/` folder, so you have `r6/scripts/MyAddon/MyAddon.reds`.
3. Copy `example/r6/tweaks/MyAddon` into the game's `r6/tweaks/` folder, so you have `r6/tweaks/MyAddon/my_addon.yaml`.
4. Start the game and load a save.
5. Open the crafting screen and go to Preem Weaponsmith's **Mag** page: **Cripple Shard** is there. With the Weapon Blueprints unlock mode, it unlocks with an Epic or better weapon blueprint, because the example says `Epic`.

If you have CET, its log file (`bin/x64/plugins/cyber_engine_tweaks/gamelog.log`, written when the game closes) has the line:

```
[PreemWeaponsmith] add-on MyAddon.MyAddon: 1 mods
```

To remove the example, delete the two `MyAddon` folders.

## Part 2: Make it yours

Every name in the example says `MyAddon`. Before you change anything else, pick a short name for your add-on with no spaces, such as `PlasmaMods`, and replace `MyAddon` with it everywhere:

| Where | Example | Becomes |
|---|---|---|
| Folder names | `r6/scripts/MyAddon/`, `r6/tweaks/MyAddon/` | `r6/scripts/PlasmaMods/`, `r6/tweaks/PlasmaMods/` |
| `module` line at the top of the `.reds` file | `module MyAddon` | `module PlasmaMods` |
| The class name | `class MyAddon extends PreemAddon` | `class PlasmaMods extends PreemAddon` |
| Mod IDs | `n"MyAddon.CrippleShard"` | `n"PlasmaMods.CrippleShard"` |
| Record IDs in the `.yaml` and in `MapItem` | `Items.MyAddon_CrippleShard`, `Items.MyAddon_DamagePenalty` | `Items.PlasmaMods_CrippleShard`, `Items.PlasmaMods_DamagePenalty` |

The name keeps your add-on from clashing with anyone else's: two add-ons can't both use `Items.CrippleShard`, but `Items.PlasmaMods_CrippleShard` is yours alone. (The Hacker Mod Pack's own records start `Items.PHB_`, which is why the example and the real Cripple Shard can be installed together.)

Then change what players see, in `DefineMod`:

```swift
mod.preemClassType = PreemModClassType.Mag;                             // which slots: Barrel, Trigger, Mag, Blade or Handle
mod.SetModName(n"Cripple Shard");                                       // the mod's name
mod.SetDescription("-10% damage");                                      // what it does
mod.SetAdditionalDescription("\"There, gave you a handicap!\" - Capri"); // flavour text
```

A `\"` inside the quotes puts a quotation mark in the text, and `\n` starts a new line.

If you change `preemClassType`, change the record's `placementSlots` in the `.yaml` to match:

| Slot class | `placementSlots` |
|---|---|
| Barrel | `[AttachmentSlots.PreemBarrelMod01, AttachmentSlots.PreemBarrelMod02]` |
| Trigger | `[AttachmentSlots.PreemTriggerMod01, AttachmentSlots.PreemTriggerMod02]` |
| Mag | `[AttachmentSlots.PreemMagazineMod01, AttachmentSlots.PreemMagazineMod02]` |
| Blade | `[AttachmentSlots.PreemBladeMod01, AttachmentSlots.PreemBladeMod02]` |
| Handle | `[AttachmentSlots.PreemHandleMod01, AttachmentSlots.PreemHandleMod02]` |

And choose when it unlocks, in `GetUnlockQuality`: `gamedataQuality.Common`, `Uncommon`, `Rare`, `Epic` or `Legendary`. In Preem Weaponsmith's Weapon Blueprints unlock mode, a weapon can take the mod when its blueprint is that rarity or better; in Sandbox mode everything is unlocked.

Restart the game after every change: the game only reads `.reds` and `.yaml` files when it starts.

## Part 3: Change what the mod does to stats

A mod's stat changes are records listed under `statModifiers` in its item record. The example has one:

```yaml
Items.MyAddon_DamagePenalty:
  $type: gamedataConstantStatModifier_Record
  modifierType: Multiplier
  statType: BaseStats.DPS
  value: 0.9
```

- `statType` is the stat to change. `BaseStats.DPS` is the weapon's damage.
- `modifierType` is how: `Multiplier` multiplies the stat (`0.9` = -10%, `1.1` = +10%), `Additive` adds to it (`5` = +5).
- `value` is the amount.

Every mod in the Hacker Mod Pack uses this exact record (as `Items.PHB_MagDamagePenalty` in `mags.yaml`): the -10% is the price of its quickhack effect. Two of them on one weapon multiply, so the weapon does 81% damage.

To change something else, add another record like this one with a different `statType`, and list it too: `statModifiers: [Items.MyAddon_DamagePenalty, Items.MyAddon_OtherChange]`. To find stat names, look at the game's own weapon mods in a TweakDB browser such as WolvenKit's, or at Preem Weaponsmith's own records, and copy what they use. The [Cyberpunk 2077 modding wiki](https://wiki.redmodding.org/cyberpunk-2077-modding) explains TweakXL and its YAML format in depth.

If a record has a mistake, TweakXL writes it to `red4ext/plugins/TweakXL/TweakXL.log` and skips it: check that file whenever a change doesn't show up.

## Part 4: More than one mod

Each mod needs three things: an ID, an item record, and answers in each method of your class. With two or three mods, add each one to every method:

```swift
public func GetModIds() -> array<CName> {
  return [n"MyAddon.CrippleShard", n"MyAddon.OverheatShard"];
}

public func MapItem(id: CName) -> TweakDBID {
  if Equals(id, n"MyAddon.CrippleShard") {
    return t"Items.MyAddon_CrippleShard";
  }
  if Equals(id, n"MyAddon.OverheatShard") {
    return t"Items.MyAddon_OverheatShard";
  }
  return TDBID.None();
}
```

Each new mod also needs its own item record in the `.yaml` (`Items.MyAddon_OverheatShard`, set up like `Items.MyAddon_CrippleShard`). `DefineMod` and `GetUnlockQuality` follow the same pattern. With many mods that gets long, so the Hacker Mod Pack keeps every mod in one table instead: see `r6/scripts/PreemWSHackerPack/Mags.reds`, where each row holds a mod's ID, item, unlock rarity, name and text, and `HackerBarrelsAddon.reds`, whose methods just look the row up. Adding a mod there is one new row plus its records.

## Part 5: Mods that do something new (hooks)

Stats only go so far. To make a mod *do* something, such as react when a bullet hits, your add-on needs code that runs when the game does something. redscript calls that a **hook**: you wrap one of the game's own functions, so your code runs every time the game calls it.

```swift
@wrapMethod(BaseScriptableAction)
public func GetCost() -> Int32 {
  let cost = wrappedMethod();   // run the game's own version first
  // ...change cost here...
  return cost;
}
```

`@wrapMethod(ClassName)` says which game class, and the function below it has to match the game's function exactly (name, parameters, return type). `wrappedMethod()` runs the game's original, so other mods that wrap the same function keep working. Always call it.

The Hacker Mod Pack has three hooks you can learn from:

| File | Wraps | What for |
|---|---|---|
| `Hits.reds` | `ScriptedPuppet.DamagePipelineFinalized` (runs after every hit on an NPC) | Notices the player's hits, checks whether the weapon carries one of the pack's mods, and adds a stack |
| `Discount.reds` | `BaseScriptableAction.GetCost` (a quickhack's RAM cost) | Lowers the cost while the target has Breach stacks |
| `Discount.reds` | `ScriptedPuppet.OnStatusEffectRemoved` | Refreshes the quickhack menu when Breach runs out |

`Hits.reds` also shows how to tell whether a weapon carries your mod: read the weapon's item data and check its two slots for your item record (`WeaponHasMag` and `SlotHoldsItem`).

### How the real Cripple Shard works

The example stops at the records. Here's what the pack adds on top to make the Cripple Shard upload Cripple Movement, file by file:

1. **Its row in `Mags.reds`** ties the mod ID `PreemHackerBarrels.Cripple` to its item `Items.PHB_CrippleMag` and to a status effect, `BaseStatusEffect.PHB_CrippleCharge`. The status effect is what holds the stacks on the enemy.
2. **Its status effect in `status_effects.yaml`** sets the stacks: at most 3, gone 8 seconds after the last one. Small extra values sit beside it, which the code reads by name:

   ```yaml
   BaseStatusEffect.PHB_CrippleCharge.stackInterval: 0.2       # seconds between stacks
   BaseStatusEffect.PHB_CrippleCharge.uploadCooldown: 30.0     # seconds before the same enemy can be crippled again
   BaseStatusEffect.PHB_CrippleCharge.quickhack: "QuickHack.LocomotionMalfunctionHack"   # the quickhack to upload
   ```

3. **`Hits.reds`** runs on every hit. If the player's weapon carries the Cripple Shard, it adds a stack of `PHB_CrippleCharge` to the enemy, no more often than `stackInterval`.
4. **At the third stack**, `Hits.reds` sees that the effect names a `quickhack`, takes the stacks off, and calls `MagUpload.Start` in **`Upload.reds`**, which starts the game's own Cripple Movement upload on that enemy with its RAM cost skipped. Then it starts the `uploadCooldown`.

Every upload mag in the pack works this way; only the numbers and the quickhack in `status_effects.yaml` differ. So once you understand the Cripple Shard, adding another one is a new row in `Mags.reds`, an item in `mags.yaml` and a status effect in `status_effects.yaml`, with no new code.

To find which game function to wrap, read the game's own scripts. The redscript and modding communities publish them (search for "Cyberpunk 2077 script dump"), and the modding wiki above covers redscript.

One limit: **you can wrap the game's classes, but not Preem Weaponsmith's** (or any other mod's). redscript only finds the game's own classes. Talk to Preem Weaponsmith only through the add-on class below.

## Reference: the add-on class

Your class extends `PreemAddon` (module `PreemCrafting.Addons`). Preem Weaponsmith finds it by itself when the game starts: there's nothing to register and no load order. Every method has a default that does nothing, so write only the ones you need.

| Method | What to return |
|---|---|
| `RequiredApiVersion() -> Int32` | The add-on API version you wrote against: `1`. If Preem Weaponsmith is older, your add-on is skipped and it logs why. |
| `GetModIds() -> array<CName>` | Every mod ID your add-on owns. |
| `DefineMod(id: CName, mod: ref<PreemMod>) -> Bool` | For one of your IDs: fill in `mod` and return `true`. Return `false` to leave that mod out. |
| `MapItem(id: CName) -> TweakDBID` | The mod's item record, or `TDBID.None()`. |
| `GetUnlockQuality(id: CName) -> gamedataQuality` | The blueprint rarity that unlocks the mod. `gamedataQuality.Invalid` (the default) keeps it locked in Weapon Blueprints mode. |

In `DefineMod`, set at least `mod.preemClassType`, `mod.SetModName(...)`, `mod.SetDescription(...)` and `mod.SetAdditionalDescription(...)`. Optionally:

- `mod.AddRequiredMod(style)`: the mod needs another mod slotted first.
- `mod.AddIncompatMod(style)`: the mod can't be on one weapon with another.
- `mod.SetRequiredEvolution(gamedataWeaponEvolution.Smart)`: only Smart weapons (or Power, Tech, ...) can take it.

Those take a *style*, Preem Weaponsmith's number for a mod. For one of Preem Weaponsmith's own mods use its name, such as `PreemModStyleType.Barrel_Smart`. For one of yours, ask for it by ID: `PreemAddons.StyleOf(n"MyAddon.CrippleShard")`. Don't set `mod.modStyleType` yourself: Preem Weaponsmith does.

The `@if(ModuleExists("PreemCrafting.Addons"))` lines in the example mean "only build this when Preem Weaponsmith is installed". Without them, a player who removes Preem Weaponsmith but keeps your add-on would get a script error at startup. Keep them on the `import` lines and on your class.

## Rules that keep your add-on working

- **Start every ID with your add-on's name** (`MyAddon.`, `Items.MyAddon_`). That's what keeps add-ons from clashing.
- **Never rename an item record once your add-on is released.** Saved weapons store it, so a rename takes the mod off players' weapons.
- **Never write a style as a number, and never save one.** Add-on styles are handed out when the game starts and change when add-ons are added or removed. Save the mod ID, and call `PreemAddons.StyleOf(id)` when you need the style.
- **Use only the add-on API**: the `PreemAddon` methods, `PreemAddons.ApiVersion()`, `StyleOf` and `IdOf`. Everything else inside Preem Weaponsmith may change in any update.
- **In a hook, always call `wrappedMethod(...)`**, so the game and other mods still get their turn.

## When something goes wrong

| Symptom | Look here |
|---|---|
| A popup at startup about script errors | `r6/logs/redscript_rCURRENT.log`: the file, line and error. Usually a typo, a missing `;` or a wrong type. |
| The mod isn't in the crafting screen | CET's `gamelog.log` for the `add-on ... mods` line. No line: the class didn't load (check the redscript log). A line with 0 mods: `GetModIds` or `DefineMod` returned nothing. |
| The mod is there but changes nothing | `red4ext/plugins/TweakXL/TweakXL.log` for errors in your `.yaml`, and check that `MapItem` returns the exact record ID from the `.yaml`. |
| The mod shows a placeholder description | `DefineMod` didn't set `SetDescription` / `SetAdditionalDescription`. |

## Releasing your add-on

Players install an add-on the same way you installed the example. Zip your two folders so the zip holds `r6/scripts/<YourAddon>/` and `r6/tweaks/<YourAddon>/`; extracting it into the game folder puts them in the right place. On your mod page, list Preem Weaponsmith 2.6.0 or newer as a requirement, and say it's PC only.

## How the Hacker Mod Pack works

Every mod in the pack is a Mag mod that costs 10% damage. Hits with the weapon build stacks of a status effect on the enemy, at most one stack per 0.2 seconds. The Hacker mag's stacks (Breach) make quickhacks on that enemy cheaper. Each other mag, at full stacks, uploads a quickhack to the enemy for free, then waits out a cooldown for that enemy.

| File | Does |
|---|---|
| `HackerBarrelsAddon.reds` | The add-on class: reads the table in `Mags.reds` and answers Preem Weaponsmith's questions. |
| `Mags.reds` | One row per mod: ID, item record, status effect, unlock rarity, name and text. |
| `Hits.reds` | The hit hook, and `MagHitSystem`, which adds stacks and decides when to upload. |
| `Rules.reds` | The rules as small functions with no game state: does a hit count, is a new stack allowed yet, how much a quickhack costs with Breach. |
| `Upload.reds` | Starts a quickhack upload for free, using the player's cyberdeck version of the same hack when it's a higher level. |
| `Discount.reds` | Breach's RAM discount on quickhack costs. |
| `mags.yaml` | The 11 mod items and their -10% damage. |
| `status_effects.yaml` | The status effects that hold the stacks, and the tuning: max stacks, duration, time between stacks, upload cooldown and which quickhack each mag uploads. |

Most tuning lives in `status_effects.yaml` rather than in code, so you can change the numbers without touching redscript.

## License

MIT, see [LICENSE](LICENSE). You're free to copy, change and build on this code, including the example, for your own add-ons.
