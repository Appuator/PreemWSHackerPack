// The barrels, one row each (SPEC §6a). HackerBarrelsAddon tells core about them, and MagHitSystem
// adds their stacks. A barrel's numbers are flats on its status effect's path, in tweaks/status_effects.yaml.
module PreemHackerBarrels.Mags

public struct MagRow {
  public let id: CName;
  public let item: TweakDBID;
  public let effect: TweakDBID;
  public let unlock: gamedataQuality;
  // The user's text (CLAUDE.md "Text rule"). It repeats tuning numbers, so a tuning change means asking
  // the user to update it.
  public let name: CName;
  public let description: String;
  public let flavour: String;
}

public abstract class MagTable {
  public final static func Rows() -> array<MagRow> {
    return [
      MagTable.Row(n"PreemHackerBarrels.Hacker", t"Items.PHB_HackerMag", t"BaseStatusEffect.PHB_Breach", gamedataQuality.Rare,
        n"Breach Shard",
        "Hits apply a Breach stack, max 5 stacks(.2 sec cooldown).\n Each stack of Breach reduces quickhack costs by 1 RAM.\n -10% damage",
        "\"Mighty nifty system breach.\" - D"),
      MagTable.Row(n"PreemHackerBarrels.Cripple", t"Items.PHB_CrippleMag", t"BaseStatusEffect.PHB_CrippleCharge", gamedataQuality.Epic,
        n"Cripple Shard",
        "Hits apply a Cripple stack, up to 3(.2 sec cooldown).\n at 3 stacks uploads the \"Cripple Movement\" quickhack.\n -10% damage \n30 sec cooldown between uploads",
        "\"There, gave you a handicap!\" - Capri"),
      MagTable.Row(n"PreemHackerBarrels.Overheat", t"Items.PHB_OverheatMag", t"BaseStatusEffect.PHB_OverheatCharge", gamedataQuality.Uncommon,
        n"Overheat Shard",
        "Hits apply an Overheat stack, up to 3 (.2 sec cooldown).\n at 3 stacks uploads the \"Overheat\" quickhack.\n -10% damage \n15 sec cooldown between uploads",
        "\"What's life without a little give and take?\" - Capri"),
      MagTable.Row(n"PreemHackerBarrels.ShortCircuit", t"Items.PHB_ShortCircuitMag", t"BaseStatusEffect.PHB_ShortCircuitCharge", gamedataQuality.Uncommon,
        n"Overload Shard",
        "Hits apply a Short Circuit stack, up to 3 (.2 sec cooldown).\n at 3 stacks uploads the \"Short Circuit\" quickhack.\n -10% damage \n15 sec cooldown between uploads",
        "\"Now I can finally do things my way\" - Capri"),
      MagTable.Row(n"PreemHackerBarrels.Contagion", t"Items.PHB_ContagionMag", t"BaseStatusEffect.PHB_ContagionCharge", gamedataQuality.Rare,
        n"Contagion Shard",
        "Hits apply a Contagion stack, up to 5 (.2 sec cooldown).\n at 5 stacks uploads the \"Contagion\" quickhack.\n -10% damage \n15 sec cooldown between uploads",
        "\"Come on, let's play!\" - Capri"),
      MagTable.Row(n"PreemHackerBarrels.RebootOptic", t"Items.PHB_RebootOpticMag", t"BaseStatusEffect.PHB_RebootOpticCharge", gamedataQuality.Rare,
        n"Blinding Shard",
        "Hits apply a Reboot Optic stack, up to 3 (.2 sec cooldown).\n at 3 stacks uploads the \"Reboot Optic\" quickhack.\n -10% damage \n30 sec cooldown between uploads",
        "\"It's like we really are invisible.\" - Roman"),
      MagTable.Row(n"PreemHackerBarrels.SonicShock", t"Items.PHB_SonicShockMag", t"BaseStatusEffect.PHB_SonicShockCharge", gamedataQuality.Rare,
        n"Deafening Shard",
        "Hits apply a Sonic Shock stack, up to 3 (.2 sec cooldown).\n at 3 stacks uploads the \"Sonic Shock\" quickhack.\n -10% damage \n15 sec cooldown between uploads",
        "\"I'll give you three minutes, better run!'\" - Capri"),
      MagTable.Row(n"PreemHackerBarrels.CyberwareMalfunction", t"Items.PHB_CyberwareMalfunctionMag", t"BaseStatusEffect.PHB_CyberwareMalfunctionCharge", gamedataQuality.Epic,
        n"Malfunction Shard",
        "Hits apply a Cyberware Malfunction stack, up to 3 (.2 sec cooldown).\n at 3 stacks uploads the \"Cyberware Malfunction\" quickhack.\n -10% damage \n8 sec cooldown between uploads",
        "\"Shouldn't ya have a little more pep in your step?\" - Capri"),
      MagTable.Row(n"PreemHackerBarrels.WeaponGlitch", t"Items.PHB_WeaponGlitchMag", t"BaseStatusEffect.PHB_WeaponGlitchCharge", gamedataQuality.Epic,
        n"Glitch Shard",
        "Hits apply a Weapon Glitch stack, up to 5 (.2 sec cooldown).\n at 5 stacks uploads the \"Weapon Glitch\" quickhack.\n -10% damage \n30 sec cooldown between uploads",
        "\"Go on, don't be shy!\" - Capri"),
      MagTable.Row(n"PreemHackerBarrels.DetonateGrenade", t"Items.PHB_DetonateGrenadeMag", t"BaseStatusEffect.PHB_DetonateGrenadeCharge", gamedataQuality.Legendary,
        n"Detonator Shard",
        "Hits apply a Detonate Grenade stack, up to 12 (.2 sec cooldown).\n at 12 stacks uploads the \"Detonate Grenade\" quickhack.\n -10% damage \n60 sec cooldown between uploads",
        "\"Bye-bye, Choomba.\" - Capri"),
      MagTable.Row(n"PreemHackerBarrels.Cyberpsychosis", t"Items.PHB_CyberpsychosisMag", t"BaseStatusEffect.PHB_CyberpsychosisCharge", gamedataQuality.Legendary,
        n"Psycho Shard",
        "Hits apply a Cyberpsychosis stack, up to 12 (.2 sec cooldown).\n at 12 stacks uploads the \"Cyberpsychosis\" quickhack.\n -10% damage \n60 sec cooldown between uploads",
        "\"(maniacal laughter)\" - Capri")
    ];
  }

  // A row with no ID, no item and an Invalid unlock when the ID isn't ours.
  public final static func Find(id: CName) -> MagRow {
    for row in MagTable.Rows() {
      if Equals(row.id, id) {
        return row;
      }
    }
    let none: MagRow;
    none.unlock = gamedataQuality.Invalid;
    return none;
  }

  private final static func Row(id: CName, item: TweakDBID, effect: TweakDBID, unlock: gamedataQuality, name: CName, description: String, flavour: String) -> MagRow {
    let row: MagRow;
    row.id = id;
    row.item = item;
    row.effect = effect;
    row.unlock = unlock;
    row.name = name;
    row.description = description;
    row.flavour = flavour;
    return row;
  }
}
