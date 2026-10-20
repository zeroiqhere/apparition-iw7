// Setting contracts avoid native actor checks and grenade refill operations

run()
{
    undefined_and_false_flags_are_disabled();
    all_enabled_requires_every_current_setting_and_a_nonempty_roster();
    inspecting_settings_never_changes_flags_or_native_power_records();
    empty_configuration_requests_are_rejected();
    live_probe_returns_off_before_native_actor_checks();
    summary_reports_all_live_equipment_states();
    summary_groups_waiting_states_as_paused();
    summary_rejects_empty_or_unknown_probe_sets();
}

undefined_and_false_flags_are_disabled()
{
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\equipment::enabled(player), "An unset grenade refill setting is disabled");
    player.apparition_equipment = false;
    tests\support\checks::expect(!scripts\apparition\features\equipment::enabled(player), "A false grenade refill flag is disabled");
    player.apparition_equipment = true;
    tests\support\checks::expect(scripts\apparition\features\equipment::enabled(player), "A true flag configures grenade refills");
}

all_enabled_requires_every_current_setting_and_a_nonempty_roster()
{
    first = spawnstruct();
    second = spawnstruct();
    first.apparition_equipment = true;
    tests\support\checks::expect(!scripts\apparition\features\equipment::all_enabled([first, second]), "A mixed current roster is unchecked");
    second.apparition_equipment = true;
    tests\support\checks::expect(scripts\apparition\features\equipment::all_enabled([first, second]), "A uniformly configured roster is checked");
    tests\support\checks::expect(!scripts\apparition\features\equipment::all_enabled([]), "An empty roster cannot advertise a configured lobby setting");
    tests\support\checks::expect(!scripts\apparition\features\equipment::all_enabled(undefined), "An unavailable roster remains unchecked");
}

inspecting_settings_never_changes_flags_or_native_power_records()
{
    player = spawnstruct();
    player.apparition_equipment = true;
    player.powers = [];
    player.powers["power_frag"] = spawnstruct();
    player.powers["power_frag"].charges = 0;
    scripts\apparition\features\equipment::enabled(player);
    scripts\apparition\features\equipment::all_enabled([player]);
    tests\support\checks::expect(player.apparition_equipment && player.powers["power_frag"].charges == 0, "Reading configured settings cannot refill or change native ownership");
}

empty_configuration_requests_are_rejected()
{
    tests\support\checks::expect(!scripts\apparition\features\equipment::toggle([]), "An empty selection cannot configure native workers");
    tests\support\checks::expect(!scripts\apparition\features\equipment::toggle(undefined), "An unavailable selection cannot configure native workers");
}

live_probe_returns_off_before_native_actor_checks()
{
    tests\support\checks::expect(scripts\apparition\features\equipment::probe(undefined).state == "Off", "A missing player reports equipment refill off");
    player = spawnstruct();
    result = scripts\apparition\features\equipment::probe(player);
    tests\support\checks::expect(result.state == "Off" && !isDefined(result.id), "A disabled player reports off without a native inventory identity");
}

summary_reports_all_live_equipment_states()
{
    probes = [];
    probes[0] = equipment_probe("Ready");
    probes[1] = equipment_probe("Full");
    probes[2] = equipment_probe("Paused");
    probes[3] = equipment_probe("Off");
    tests\support\checks::expect(scripts\apparition\features\equipment::summary(probes) == "Ready 1, full 1, paused 1, off 1", "The summary counts each display category once per player");
}

summary_groups_waiting_states_as_paused()
{
    probes = [];
    probes[0] = equipment_probe("Waiting");
    probes[1] = equipment_probe("Unavailable");
    probes[2] = equipment_probe("Missing");
    probes[3] = equipment_probe("Paused");
    tests\support\checks::expect(scripts\apparition\features\equipment::summary(probes) == "Ready 0, full 0, paused 4, off 0", "Waiting and unavailable equipment are grouped as paused");
}

summary_rejects_empty_or_unknown_probe_sets()
{
    probes = [];
    tests\support\checks::expect(scripts\apparition\features\equipment::summary(undefined) == "Unknown", "An unavailable probe list reports unknown");
    tests\support\checks::expect(scripts\apparition\features\equipment::summary("Ready") == "Unknown", "A status string cannot substitute for a roster of probes");
    tests\support\checks::expect(scripts\apparition\features\equipment::summary(probes) == "Unknown", "An empty probe list reports unknown");
    probes[0] = equipment_probe("Unrecognized");
    tests\support\checks::expect(scripts\apparition\features\equipment::summary(probes) == "Unknown", "An unknown live state invalidates the summary");
    probes[0] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\equipment::summary(probes) == "Unknown", "A probe without a state invalidates the summary");
    probes[0] = equipment_probe(1);
    tests\support\checks::expect(scripts\apparition\features\equipment::summary(probes) == "Unknown", "A numeric state cannot imply refill readiness");
    probes[0] = 1;
    tests\support\checks::expect(scripts\apparition\features\equipment::summary(probes) == "Unknown", "A malformed probe cannot contribute a partial roster count");
}

equipment_probe(state)
{
    probe = spawnstruct();
    probe.state = state;
    return probe;
}
