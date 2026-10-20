// The numeric catalog captures native identities rather than mutable active-list indices

run()
{
    the_full_authored_registry_keeps_its_order();
    native_indices_are_not_sorted_or_deduplicated();
    captured_indices_do_not_follow_later_array_replacement();
    captured_entries_keep_live_native_vector_fields();
    missing_and_empty_catalogs_remain_distinct();
    malformed_registries_never_publish_partial_points();
    malformed_point_vectors_reject_the_complete_catalog();
    selections_require_numeric_integral_indices_in_range();
    replaced_equal_coordinate_objects_do_not_match_old_identities();
}

the_full_authored_registry_keeps_its_order()
{
    state = tests\fixtures\spawn_points::ready_state();
    authored = state.struct_class_names["targetname"]["player_respawn_loc"];
    state.active_player_respawn_locs = [authored[1]];
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.points.size == 2,
        "The catalog includes all authored respawn points instead of the active subset");
    if (result.points.size != 2)
        return;
    tests\support\checks::expect(result.points[0] == authored[0] && result.points[1] == authored[1],
        "Numeric choices preserve native classified-struct order");
    tests\support\checks::expect(state.active_player_respawn_locs.size == 1,
        "Catalog inspection never activates additional spawn volumes");
}

native_indices_are_not_sorted_or_deduplicated()
{
    state = tests\fixtures\spawn_points::ready_state();
    authored = state.struct_class_names["targetname"]["player_respawn_loc"];
    first = authored[0];
    second = authored[1];
    state.struct_class_names["targetname"]["player_respawn_loc"] = [second, first, second];
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.points.size == 3,
        "A captured catalog preserves every native numeric position");
    if (result.points.size != 3)
        return;
    tests\support\checks::expect(result.points[0] == second && result.points[1] == first && result.points[2] == second,
        "The adapter neither sorts nor deduplicates the current native registry");
}

captured_indices_do_not_follow_later_array_replacement()
{
    state = tests\fixtures\spawn_points::ready_state();
    original = state.struct_class_names["targetname"]["player_respawn_loc"][0];
    snapshot = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    replacement = tests\fixtures\spawn_points::point((13, 14, 15), (16, 17, 18));
    state.struct_class_names["targetname"]["player_respawn_loc"][0] = replacement;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\spawn_points::select(snapshot.points, 0) == original,
        "A displayed numeric selection keeps the original object after registry replacement");
    current = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(current.points[0] == replacement && snapshot.points[0] == original,
        "A fresh catalog observes replacements without mutating the captured identity list");
}

captured_entries_keep_live_native_vector_fields()
{
    state = tests\fixtures\spawn_points::ready_state();
    snapshot = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    point = state.struct_class_names["targetname"]["player_respawn_loc"][0];
    point.origin = (20, 21, 22);
    tests\support\checks::expect(snapshot.points[0] == point && snapshot.points[0].origin == (20, 21, 22),
        "The snapshot retains an identity reference without copying or freezing coordinates");
}

missing_and_empty_catalogs_remain_distinct()
{
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(undefined);
    tests\support\checks::expect(result.reason != "" && result.points.size == 0,
        "Missing loader state is pending rather than a known empty catalog");
    state = tests\fixtures\spawn_points::ready_state();
    state.struct_class_names["targetname"]["player_respawn_loc"] = undefined;
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.points.size == 0,
        "An initialized registry without the native tag is known empty");
    state.struct_class_names["targetname"]["player_respawn_loc"] = [];
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.points.size == 0,
        "An explicit empty native list is also known empty");
}

malformed_registries_never_publish_partial_points()
{
    state = tests\fixtures\spawn_points::ready_state();
    state.struct_class_names = "invalid";
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.points.size == 0,
        "A malformed classification table is rejected before indexing");
    state = tests\fixtures\spawn_points::ready_state();
    state.struct_class_names["targetname"] = "invalid";
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.points.size == 0,
        "A malformed target-name table is rejected before lookup");
    foreach (invalid in ["invalid", 0, spawnstruct()])
    {
        state = tests\fixtures\spawn_points::ready_state();
        state.struct_class_names["targetname"]["player_respawn_loc"] = invalid;
        result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
        tests\support\checks::expect(result.reason != "" && result.points.size == 0,
            "Only an array can provide the native numeric point list");
    }
    state = tests\fixtures\spawn_points::ready_state();
    points = [];
    points[4] = tests\fixtures\spawn_points::point((1, 2, 3), (4, 5, 6));
    state.struct_class_names["targetname"]["player_respawn_loc"] = points;
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.points.size == 0,
        "A sparse list cannot silently change native numeric indexing");
}

malformed_point_vectors_reject_the_complete_catalog()
{
    foreach (invalid in ["point", [], spawnstruct(), 7])
    {
        state = tests\fixtures\spawn_points::ready_state();
        state.struct_class_names["targetname"]["player_respawn_loc"][1] = invalid;
        result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
        tests\support\checks::expect(result.reason != "" && result.points.size == 0,
            "An invalid later entry cannot publish a usable prefix of the catalog");
    }
    state = tests\fixtures\spawn_points::ready_state();
    state.struct_class_names["targetname"]["player_respawn_loc"][1].angles = "angles";
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.points.size == 0,
        "A malformed angle rejects the catalog before any movement can start");
    state.struct_class_names["targetname"]["player_respawn_loc"][1].angles = (10, 11, 12);
    state.struct_class_names["targetname"]["player_respawn_loc"][1].origin = undefined;
    result = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.points.size == 0,
        "A missing origin cannot be filled with a guessed coordinate");
}

selections_require_numeric_integral_indices_in_range()
{
    state = tests\fixtures\spawn_points::ready_state();
    snapshot = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\spawn_points::select(snapshot.points, 0) == snapshot.points[0]
        && scripts\apparition\maps\spaceland\spawn_points::select(snapshot.points, 1) == snapshot.points[1],
        "Both endpoint indices select their exact captured reference");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\spawn_points::select(snapshot.points, undefined)),
        "A missing selection cannot resolve a point");
    foreach (invalid in [-1, 2, 0.5, "0", [], spawnstruct(), 2147483648])
        tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\spawn_points::select(snapshot.points, invalid)),
            "Fractional, nonnumeric and out-of-range indices are rejected before indexing");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\spawn_points::select(undefined, 0))
        && !isDefined(scripts\apparition\maps\spaceland\spawn_points::select("invalid", 0))
        && !isDefined(scripts\apparition\maps\spaceland\spawn_points::select([], 0)),
        "Missing, malformed and empty captured lists cannot produce a selection");
}

replaced_equal_coordinate_objects_do_not_match_old_identities()
{
    state = tests\fixtures\spawn_points::ready_state();
    snapshot = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    old_point = scripts\apparition\maps\spaceland\spawn_points::select(snapshot.points, 0);
    state.struct_class_names["targetname"]["player_respawn_loc"][0] = tests\fixtures\spawn_points::point(old_point.origin, old_point.angles);
    current = scripts\apparition\maps\spaceland\spawn_points::inspect(state);
    tests\support\checks::expect(!scripts\engine\utility::array_contains(current.points, old_point),
        "Matching coordinates do not authorize an old point after its native identity is removed");
}
