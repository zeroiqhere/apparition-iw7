// Balloon aiming contracts keep native pop state outside the provider

run()
{
    only_native_spawn_balloon_stage_is_admitted();
    selection_tracks_a_captured_scriptable_reference_across_array_reordering();
    invalid_or_incomplete_point_lists_fail_closed();
    aim_requires_a_valid_nonzero_direction();
    missing_and_nonplayer_owners_are_rejected_before_native_reads();
}

only_native_spawn_balloon_stage_is_admitted()
{
    state = tests\fixtures\ghosts::quest(0);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::stage_reason(state) == "", "The canonical native spawn-balloon stage admits the aiming request");

    state._id_13F1B["ghost"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::stage_reason(state) != "", "A later Ghosts stage cannot reuse spawn-balloon targeting");

    state = tests\fixtures\ghosts::quest(0);
    state._id_13F4D["ghost"][0]._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::stage_reason(state) != "", "A foreign stage-zero body cannot authorize balloon aiming");

    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::stage_reason(spawnstruct()) != "", "Missing native quest registration is unavailable");
}

selection_tracks_a_captured_scriptable_reference_across_array_reordering()
{
    first = balloon_ref((1, 2, 3));
    second = balloon_ref((4, 5, 6));
    original = [point_record(first), point_record(second)];
    reordered = [original[1], original[0]];

    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::select(original, first) == first, "The exact captured scriptable reference is selectable");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::select(reordered, first) == first, "Fresh list ordering cannot retarget the selected scriptable");

    first.origin = (8, 9, 10);
    selected = scripts\apparition\maps\spaceland\balloons::select([point_record(first)], first);
    tests\support\checks::expect(selected == first && selected.origin == (8, 9, 10), "A moved selected scriptable exposes its current origin instead of a cached point");
}

invalid_or_incomplete_point_lists_fail_closed()
{
    captured = balloon_ref((1, 2, 3));
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([], captured)), "An empty list has no selectable balloon");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select(undefined, captured)), "A missing list cannot authorize a stale selection");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([undefined], captured)), "A sparse list cannot authorize a partial scan");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([7], captured)), "A scalar row cannot be read as a point record");

    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([point_record(captured)], "spawn balloon")), "A string cannot stand in for the captured native scriptable reference");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([point_record(captured)], 7)), "A number cannot stand in for the captured native scriptable reference");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([point_record(captured)], captured.origin)),
        "A cached coordinate vector cannot stand in for its native object reference");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([point_record(captured), point_record(7)], captured)),
        "A malformed later reference prevents a valid prefix from authorizing a request");

    malformed = point_record(undefined);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([malformed], captured)), "An incomplete point record invalidates the list");

    same_location = balloon_ref((1, 2, 3));
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\balloons::select([point_record(same_location)], captured)), "A removed scriptable cannot retarget to another object at the same coordinates");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::select([point_record(captured), point_record(same_location)], captured) == captured, "Distinct scriptables at duplicate locations remain separate identities");
}

aim_requires_a_valid_nonzero_direction()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::aim_reason((0, 0, 0), (0, 0, 1)) == "", "A valid nonzero aim vector is accepted");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::aim_reason((0, 0, 0), (0, 0, 0)) != "", "A zero-length aim vector is rejected");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::aim_reason(undefined, (0, 0, 1)) != "", "A missing eye position is rejected");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::aim_reason((0, 0, 0), undefined) != "", "A missing native point is rejected");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\balloons::aim_reason(7, (0, 0, 1)) != "", "Malformed eye data is rejected before angle conversion");
}

missing_and_nonplayer_owners_are_rejected_before_native_reads()
{
    missing = scripts\apparition\maps\spaceland\balloons::probe(undefined);
    tests\support\checks::expect(isDefined(missing.reason) && missing.reason != "", "A missing owner is rejected before a native balloon query");
    tests\support\checks::expect(isarray(missing.entries) && missing.entries.size == 0, "A rejected owner receives no scriptable references or partial points");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\balloons::face(undefined, (1, 2, 3)), "A missing owner cannot issue an angle request");

    nonplayer = scripts\apparition\maps\spaceland\balloons::probe(spawnstruct());
    tests\support\checks::expect(isDefined(nonplayer.reason) && nonplayer.reason != "", "A nonplayer is rejected before native player fields or balloon references are read");
    tests\support\checks::expect(isarray(nonplayer.entries) && nonplayer.entries.size == 0, "A nonplayer receives no native balloon points");
}

point_record(point)
{
    record = spawnstruct();
    record.point = point;
    return record;
}

balloon_ref(origin)
{
    balloon = spawnstruct();
    balloon.origin = origin;
    return balloon;
}
