// Spaceland's machine IDs and labels are kept in one map-specific catalog

catalog()
{
    perks = [];
    perks[perks.size] = entry("perk_machine_revive", "Up N' Atoms");
    perks[perks.size] = entry("perk_machine_tough", "Tuff Nuff");
    perks[perks.size] = entry("perk_machine_rat_a_tat", "Bang Bangs");
    perks[perks.size] = entry("perk_machine_flash", "Quickies");
    perks[perks.size] = entry("perk_machine_run", "Racin' Stripes");
    perks[perks.size] = entry("perk_machine_boom", "Bombstoppers");
    perks[perks.size] = entry("perk_machine_more", "Mule Munchies");
    perks[perks.size] = entry("perk_machine_zap", "Blue Bolts");
    perks[perks.size] = entry("perk_machine_fwoosh", "Trail Blazers");
    perks[perks.size] = entry("perk_machine_smack", "Slappy Taffy");
    return perks;
}

ids()
{
    selected = [];
    foreach (perk in catalog())
        selected[selected.size] = perk.id;
    return selected;
}

entry(id, label)
{
    perk = spawnstruct();
    perk.id = id;
    perk.label = label;
    return perk;
}
