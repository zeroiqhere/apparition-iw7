// Retention contracts use isolated inventory and notification records

run()
{
    retention_is_disabled_without_an_owned_record();
    all_enabled_requires_every_member_and_a_nonempty_roster();
    capture_saves_only_current_supported_owned_perks();
    later_capture_replaces_the_previous_saved_selection();
    capture_does_not_create_a_disabled_setting();
    repeated_enable_preserves_the_existing_record_and_saved_selection();
    disable_discards_the_record_and_reenable_starts_without_a_stale_snapshot();
}

retention_is_disabled_without_an_owned_record()
{
    player = tests\fixtures\perks::owned_player([]);
    tests\support\checks::expect(!scripts\apparition\features\perk_retention::enabled(player), "A player without a retention record is disabled");
    tests\support\checks::expect(!scripts\apparition\features\perk_retention::enabled(undefined), "An unavailable player cannot own retention");
}

all_enabled_requires_every_member_and_a_nonempty_roster()
{
    first = tests\fixtures\perks::retaining_player([]);
    second = tests\fixtures\perks::retaining_player([]);
    tests\support\checks::expect(scripts\apparition\features\perk_retention::all_enabled([first, second]), "A uniformly enabled roster displays checked retention");
    second.apparition_perk_retention = undefined;
    tests\support\checks::expect(!scripts\apparition\features\perk_retention::all_enabled([first, second]), "A mixed roster displays unchecked retention");
    tests\support\checks::expect(!scripts\apparition\features\perk_retention::all_enabled([]), "An empty roster never displays checked retention");
    tests\support\checks::expect(!scripts\apparition\features\perk_retention::all_enabled(undefined), "A missing roster never displays checked retention");
}

capture_saves_only_current_supported_owned_perks()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    player = tests\fixtures\perks::retaining_player([ids[0], ids[4]]);
    player.zombies_perks[ids[1]] = 0;
    player.zombies_perks["unrelated_perk"] = 1;
    scripts\apparition\features\perk_retention::capture(player);
    saved = player.apparition_perk_retention.saved;
    tests\support\checks::expect(saved.size == 2 && saved[0] == ids[0] && saved[1] == ids[4], "Capture saves current supported ownership in catalog order");
    player.zombies_perks[ids[0]] = undefined;
    tests\support\checks::expect(saved.size == 2 && saved[0] == ids[0], "Native inventory removal does not alter the saved ID array");
    tests\support\checks::expect(player.zombies_perks[ids[4]] == 1 && player.zombies_perks["unrelated_perk"] == 1, "Capture does not grant, remove or rewrite live inventory");
}

later_capture_replaces_the_previous_saved_selection()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    player = tests\fixtures\perks::retaining_player([ids[0]]);
    scripts\apparition\features\perk_retention::capture(player);
    player.zombies_perks[ids[0]] = undefined;
    player.zombies_perks[ids[2]] = 1;
    scripts\apparition\features\perk_retention::capture(player);
    saved = player.apparition_perk_retention.saved;
    tests\support\checks::expect(saved.size == 1 && saved[0] == ids[2], "A later down replaces the old selection instead of merging lost perks");
    player.zombies_perks[ids[2]] = undefined;
    scripts\apparition\features\perk_retention::capture(player);
    tests\support\checks::expect(player.apparition_perk_retention.saved.size == 0, "An empty later inventory clears the previous saved selection");
}

capture_does_not_create_a_disabled_setting()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    player = tests\fixtures\perks::owned_player(ids);
    scripts\apparition\features\perk_retention::capture(player);
    tests\support\checks::expect(!isDefined(player.apparition_perk_retention), "Capture cannot silently enable a disabled player");
    tests\support\checks::expect(scripts\apparition\features\perks::all_owned([player], ids), "Disabled capture leaves native inventory unchanged");
}

repeated_enable_preserves_the_existing_record_and_saved_selection()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    player = tests\fixtures\perks::retaining_player([ids[0]]);
    scripts\apparition\features\perk_retention::capture(player);
    record = player.apparition_perk_retention;
    scripts\apparition\features\perk_retention::set_enabled(player, true);
    tests\support\checks::expect(player.apparition_perk_retention == record && record.saved.size == 1 && record.saved[0] == ids[0], "Repeated enable preserves the active record and saved perks");
    scripts\apparition\features\perk_retention::set_enabled(player, false);
}

disable_discards_the_record_and_reenable_starts_without_a_stale_snapshot()
{
    player = tests\fixtures\perks::retaining_player(["perk_machine_tough"]);
    scripts\apparition\features\perk_retention::capture(player);
    previous = player.apparition_perk_retention;
    scripts\apparition\features\perk_retention::set_enabled(player, false);
    tests\support\checks::expect(!scripts\apparition\features\perk_retention::enabled(player), "Disable removes the owned record");
    // Only an isolated notification listener starts; no spawn event is submitted
    scripts\apparition\features\perk_retention::set_enabled(player, true);
    tests\support\checks::expect(player.apparition_perk_retention != previous && player.apparition_perk_retention.saved.size == 0, "Reenable starts a fresh record without old saved perks");
    scripts\apparition\features\perk_retention::set_enabled(player, false);
    tests\support\checks::expect(player.zombies_perks["perk_machine_tough"] == 1, "Setting changes never grant or remove current perks");
}
