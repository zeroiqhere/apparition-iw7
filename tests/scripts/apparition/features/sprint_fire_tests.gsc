// Sprint-fire contracts inspect the CP perk mirror without native perk writes

run()
{
    missing_player_and_mirror_entries_are_not_configured();
    a_present_mirror_entry_is_configured();
    a_zero_value_mirror_entry_is_still_present();
    configured_reads_preserve_perk_and_machine_inventory();
    a_missing_actor_is_rejected_before_toggle_work();
}

missing_player_and_mirror_entries_are_not_configured()
{
    tests\support\checks::expect(!scripts\apparition\features\sprint_fire::configured(undefined),
        "A missing player has no configured sprint-fire perk");

    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\sprint_fire::configured(player),
        "A missing CP perk mirror is not configured");

    player.perks = [];
    player.perks["unrelated_perk"] = 1;
    tests\support\checks::expect(!scripts\apparition\features\sprint_fire::configured(player),
        "An unrelated CP perk does not report sprint-fire as configured");
}

a_present_mirror_entry_is_configured()
{
    player = spawnstruct();
    player.perks = [];
    player.perks["specialty_sprintfire"] = 1;

    tests\support\checks::expect(scripts\apparition\features\sprint_fire::configured(player),
        "A present sprint-fire mirror entry is configured");
}

a_zero_value_mirror_entry_is_still_present()
{
    player = spawnstruct();
    player.perks = [];
    player.perks["specialty_sprintfire"] = 0;

    // The native CP helper tests entry presence rather than value truthiness
    tests\support\checks::expect(scripts\apparition\features\sprint_fire::configured(player),
        "A defined zero-valued perk entry is still present");
}

configured_reads_preserve_perk_and_machine_inventory()
{
    player = spawnstruct();
    player.perks = [];
    player.perks["specialty_sprintfire"] = 1;
    player.perks["unrelated_perk"] = 2;
    player.zombies_perks = [];
    player.zombies_perks["perk_machine_run"] = 1;
    player.zombies_perks["unrelated_machine"] = 3;
    perk_count = player.perks.size;
    machine_count = player.zombies_perks.size;

    configured = scripts\apparition\features\sprint_fire::configured(player);

    tests\support\checks::expect(configured, "Configured reads report the CP mirror entry");
    tests\support\checks::expect(player.perks.size == perk_count
        && player.perks["specialty_sprintfire"] == 1
        && player.perks["unrelated_perk"] == 2,
        "Configured reads preserve the CP perk mirror");
    tests\support\checks::expect(player.zombies_perks.size == machine_count
        && player.zombies_perks["perk_machine_run"] == 1
        && player.zombies_perks["unrelated_machine"] == 3,
        "Configured reads preserve native perk-machine inventory");
}

a_missing_actor_is_rejected_before_toggle_work()
{
    // Missing actor admission returns before context or native perk wrappers
    tests\support\checks::expect(!scripts\apparition\features\sprint_fire::toggle(undefined),
        "A missing actor cannot toggle sprint-fire");
}
