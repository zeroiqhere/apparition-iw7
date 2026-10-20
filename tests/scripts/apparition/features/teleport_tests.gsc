// Teleport contracts preserve source destinations without claiming safe landings

run()
{
    continuous_grants_reject_missing_or_nonplayer_actors_before_native_access();
    entity_offsets_retain_the_source_side_and_distance();
    entity_facing_uses_the_machine_height_and_current_eye();
    movement_only_snapshot_rejects_missing_actors_without_extra_destination_work();
    original_modes_keep_their_exact_order();
    malformed_modes_are_rejected_before_destination_lookup();
    source_destinations_preserve_exact_coordinates();
    each_mode_requires_only_its_own_destination_input();
    saved_positions_require_both_origin_and_angles();
    native_movement_owners_block_custom_travel();
    cleared_native_markers_allow_the_remaining_checks();
    remote_authority_rejects_missing_and_nonplayer_actors();
    missing_actors_cannot_read_save_or_move();
}

movement_only_snapshot_rejects_missing_actors_without_extra_destination_work()
{
    result = scripts\apparition\features\teleport::probe_movement(undefined, undefined);
    tests\support\checks::expect(isDefined(result.actor_reason) && isstring(result.actor_reason)
        && result.actor_reason != "" && result.reason == result.actor_reason,
        "Missing actors return a blocked movement snapshot before native player reads");
    tests\support\checks::expect(!isDefined(result.aim_reason)
        && !isDefined(result.random_reason) && !isDefined(result.load_reason),
        "The entity page requests movement readiness without unrelated destination data");
}

entity_offsets_retain_the_source_side_and_distance()
{
    origin = (10, 20, 30);
    wheel = scripts\apparition\features\teleport::entity_origin("wheel", origin, (0, 0, 0));
    perk = scripts\apparition\features\teleport::entity_origin("perk", origin, (0, 0, 0));
    tests\support\checks::expect(distanceSquared(wheel, (10, 90, 30)) < 0.001,
        "The Mystery Box uses Apparition's negative-right 70-unit offset");
    tests\support\checks::expect(distanceSquared(perk, (10, -50, 30)) < 0.001,
        "Perk destinations use Apparition's positive-right 70-unit offset");
    rotated = scripts\apparition\features\teleport::entity_origin("perk", origin, (0, 90, 0));
    tests\support\checks::expect(distanceSquared(rotated, (80, 20, 30)) < 0.001,
        "The offset follows the selected native point's angle frame");
    tests\support\checks::expect(!isDefined(scripts\apparition\features\teleport::entity_origin(
        "crafting", origin, (0, 0, 0))), "An unmapped target kind has no fallback direction");
}

entity_facing_uses_the_machine_height_and_current_eye()
{
    angles = scripts\apparition\features\teleport::entity_angles((10, 20, 30), (10, -50, 85));
    tests\support\checks::expect(distanceSquared(anglesToForward(angles), (0, 1, 0)) < 0.001,
        "The post-move eye faces the native origin plus the source 55-unit height");
    angles = scripts\apparition\features\teleport::entity_angles((10, 20, 30), (10, 90, 85));
    tests\support\checks::expect(distanceSquared(anglesToForward(angles), (0, -1, 0)) < 0.001,
        "The wheel's opposite side still faces the same native height");
    tests\support\checks::expect(!scripts\apparition\features\teleport::entity(undefined, undefined, undefined),
        "Missing actors cannot reach a native entity query or movement write");
}

original_modes_keep_their_exact_order()
{
    actual = scripts\apparition\features\teleport::modes();
    expected = ["Crosshairs", "Sky", "Random Player"];
    tests\support\checks::expect(actual.size == 3, "Teleport retains the three source choices");
    if (actual.size != 3)
        return;
    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(actual[index] == expected[index],
            "Teleport choices retain source order and spelling");
        tests\support\checks::expect(scripts\apparition\features\teleport::valid_mode(expected[index]),
            "Each source teleport mode is admitted");
    }
}

malformed_modes_are_rejected_before_destination_lookup()
{
    tests\support\checks::expect(!scripts\apparition\features\teleport::valid_mode(undefined),
        "A missing mode is rejected before native reads");
    foreach (invalid in ["crosshairs", "Random", "", 0, [], spawnstruct()])
    {
        tests\support\checks::expect(!scripts\apparition\features\teleport::valid_mode(invalid),
            "Only exact source teleport strings are accepted");
    }
}

source_destinations_preserve_exact_coordinates()
{
    tests\support\checks::expect(scripts\apparition\features\teleport::destination(
        "Crosshairs", (1, 2, 3), (4, 5, 6), (7, 8, 9)) == (4, 5, 6),
        "Crosshairs uses the supplied menu-owner ray endpoint without offsets");
    tests\support\checks::expect(scripts\apparition\features\teleport::destination(
        "Sky", (1, 2, 3), (4, 5, 6), (7, 8, 9)) == (1, 2, 35003),
        "Sky adds exactly 35000 to the selected player's current Z");
    tests\support\checks::expect(scripts\apparition\features\teleport::destination(
        "Random Player", (1, 2, 3), (4, 5, 6), (7, 8, 9)) == (7, 8, 9),
        "Random Player uses the chosen current peer's origin without angle changes");
}

each_mode_requires_only_its_own_destination_input()
{
    tests\support\checks::expect(scripts\apparition\features\teleport::destination(
        "Crosshairs", undefined, (4, 5, 6), undefined) == (4, 5, 6),
        "A crosshair move needs its ray endpoint only");
    tests\support\checks::expect(scripts\apparition\features\teleport::destination(
        "Sky", (1, 2, 3), undefined, undefined) == (1, 2, 35003),
        "A sky move needs the current player origin only");
    tests\support\checks::expect(scripts\apparition\features\teleport::destination(
        "Random Player", undefined, undefined, (7, 8, 9)) == (7, 8, 9),
        "A peer move needs the current peer origin only");
    foreach (invalid in ["origin", 0, [], spawnstruct()])
    {
        tests\support\checks::expect(!isDefined(scripts\apparition\features\teleport::destination(
            "Crosshairs", (1, 2, 3), invalid, (7, 8, 9))), "A malformed ray endpoint is rejected");
        tests\support\checks::expect(!isDefined(scripts\apparition\features\teleport::destination(
            "Sky", invalid, (4, 5, 6), (7, 8, 9))), "A malformed sky origin is rejected");
        tests\support\checks::expect(!isDefined(scripts\apparition\features\teleport::destination(
            "Random Player", (1, 2, 3), (4, 5, 6), invalid)), "A malformed peer origin is rejected");
    }
    foreach (mode in scripts\apparition\features\teleport::modes())
        tests\support\checks::expect(!isDefined(scripts\apparition\features\teleport::destination(
            mode, undefined, undefined, undefined)), "A missing destination cannot become a native write");
}

saved_positions_require_both_origin_and_angles()
{
    record = spawnstruct();
    record.origin = (1, 2, 3);
    record.angles = (4, 5, 6);
    tests\support\checks::expect(scripts\apparition\features\teleport::saved_reason(record) == "",
        "A saved position contains the complete origin and angle pair");
    tests\support\checks::expect(scripts\apparition\features\teleport::saved_reason(undefined) != "",
        "Loading requires an existing saved record");
    foreach (invalid in ["position", [], 0, spawnstruct()])
        tests\support\checks::expect(scripts\apparition\features\teleport::saved_reason(invalid) != "",
            "Malformed saved positions are unavailable");
    record.angles = undefined;
    tests\support\checks::expect(scripts\apparition\features\teleport::saved_reason(record) != "",
        "A partial save cannot change origin before discovering missing angles");
    record.angles = "angles";
    tests\support\checks::expect(scripts\apparition\features\teleport::saved_reason(record) != "",
        "A non-vector angle cannot reach the native setter");
    record.angles = (4, 5, 6);
    record.origin = undefined;
    tests\support\checks::expect(scripts\apparition\features\teleport::saved_reason(record) != "",
        "A saved view without a location remains unavailable");
}

native_movement_owners_block_custom_travel()
{
    player = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, true) != "",
        "The Ghosts N Skulls arena keeps ownership of player placement");
    player.linked_to_coaster = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "A coaster ride keeps native movement ownership");
    player.linked_to_coaster = undefined;
    player.linked_to_player = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "A player link keeps native movement ownership");
    player.linked_to_player = undefined;
    player.playing_game = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "An arcade game keeps native movement ownership");
    player.playing_game = undefined;
    player.in_afterlife_arcade = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "Afterlife arcade keeps native movement ownership");
    player.in_afterlife_arcade = undefined;
    player.is_fast_traveling = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "Fast travel keeps native movement ownership");
    player.is_fast_traveling = undefined;
    player.is_in_pap = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "The Pack-a-Punch room keeps native travel ownership");
    player.is_in_pap = undefined;
    player.teleporting = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "A placed portal keeps native movement ownership");
    player.teleporting = undefined;
    player.onslide = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "A slide keeps native movement ownership");
    player.onslide = undefined;
    player.flung = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "A launch keeps native movement ownership");
    player.flung = undefined;
    player.isrewinding = true;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) != "",
        "A native rewind signal blocks a custom move");
}

cleared_native_markers_allow_the_remaining_checks()
{
    player = spawnstruct();
    player.linked_to_coaster = false;
    player.linked_to_player = false;
    player.playing_game = false;
    player.in_afterlife_arcade = false;
    player.is_fast_traveling = false;
    player.is_in_pap = false;
    player.teleporting = false;
    player.onslide = false;
    player.flung = false;
    player.isrewinding = false;
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(player, false) == "",
        "Cleared native owner markers leave life, phase, links and permission checks to runtime admission");
    tests\support\checks::expect(scripts\apparition\features\teleport::ownership_reason(spawnstruct(), undefined) == "",
        "Absent native flags do not invent an active movement owner");
}

missing_actors_cannot_read_save_or_move()
{
    snapshot = scripts\apparition\features\teleport::probe(undefined, undefined);
    tests\support\checks::expect(snapshot.actor_reason != "" && snapshot.reason != ""
        && snapshot.aim_reason != "" && snapshot.random_reason != "" && snapshot.load_reason != "",
        "Missing actors leave every teleport action unavailable");
    tests\support\checks::expect(!scripts\apparition\features\teleport::save(undefined, undefined),
        "A missing player cannot store a position");
    tests\support\checks::expect(!scripts\apparition\features\teleport::load(undefined, undefined),
        "A missing player cannot load a position");
    tests\support\checks::expect(!scripts\apparition\features\teleport::official(undefined, undefined, undefined),
        "A missing player cannot reach an official spawn write");
    tests\support\checks::expect(!scripts\apparition\features\teleport::official(undefined, undefined, 7),
        "Actor admission precedes reading an arbitrary point's fields");
    tests\support\checks::expect(!scripts\apparition\features\teleport::request(undefined, undefined, "Crosshairs"),
        "A missing menu owner cannot supply an aim endpoint");
    tests\support\checks::expect(!scripts\apparition\features\teleport::request(undefined, undefined, "Crosshairs", true),
        "Target-aim firing requests still require both current actors");
    tests\support\checks::expect(!scripts\apparition\features\teleport::request(undefined, undefined, "invalid"),
        "An invalid choice cannot reach an actor read");
    tests\support\checks::expect(!scripts\apparition\features\teleport::exchange(undefined, undefined, true)
        && !scripts\apparition\features\teleport::exchange(undefined, undefined, false),
        "Neither remote-player direction can move missing actors");
}

continuous_grants_reject_missing_or_nonplayer_actors_before_native_access()
{
    foreach (invalid in [7, [], spawnstruct()])
    {
        tests\support\checks::expect(scripts\apparition\features\teleport::grant_reason(invalid, invalid, undefined)
            == "Wait for a valid player roster",
            "Continuous travel grants reject nonplayers before querying menu access or native state");
    }
    tests\support\checks::expect(scripts\apparition\features\teleport::grant_reason(undefined, undefined, undefined) != "",
        "A missing requester and target cannot keep a continuous travel grant active");
}

remote_authority_rejects_missing_and_nonplayer_actors()
{
    tests\support\checks::expect(scripts\apparition\features\teleport::authority_reason(undefined, undefined) != "",
        "Remote travel authority rejects missing actors before native role checks");
    tests\support\checks::expect(scripts\apparition\features\teleport::authority_reason(spawnstruct(), spawnstruct()) != "",
        "Remote travel authority rejects fixtures before native role checks");
}
