// Parameter contracts preserve the source request without invoking native camera effects

run()
{
    the_source_strength_duration_center_and_radius_are_preserved();
    only_vector_positions_can_produce_native_request_parameters();
    zero_and_negative_world_positions_remain_valid_centers();
}

the_source_strength_duration_center_and_radius_are_preserved()
{
    plan = scripts\apparition\features\earthquake::parameters((12, 34, 56));
    tests\support\checks::expect(plan.reason == "" && plan.strength == 1
        && plan.duration == 15 && plan.radius == 750 && plan.origin == (12, 34, 56),
        "The source quake requests strength one for fifteen seconds around the selected position with radius 750");
}

only_vector_positions_can_produce_native_request_parameters()
{
    plan = scripts\apparition\features\earthquake::parameters(undefined);
    tests\support\checks::expect(plan.reason == "Wait for the selected player's current position"
        && !isDefined(plan.origin) && !isDefined(plan.strength) && !isDefined(plan.duration) && !isDefined(plan.radius),
        "An absent position cannot publish native quake parameters");
    foreach (invalid in [0, "position", [], spawnstruct(), ::the_source_strength_duration_center_and_radius_are_preserved])
    {
        plan = scripts\apparition\features\earthquake::parameters(invalid);
        tests\support\checks::expect(plan.reason == "Wait for the selected player's current position"
            && !isDefined(plan.origin) && !isDefined(plan.strength) && !isDefined(plan.duration) && !isDefined(plan.radius),
            "Scalar, array, object and function values cannot replace a native world vector");
    }
}

zero_and_negative_world_positions_remain_valid_centers()
{
    foreach (origin in [(0, 0, 0), (-10, -20, -30)])
    {
        plan = scripts\apparition\features\earthquake::parameters(origin);
        tests\support\checks::expect(plan.reason == "" && plan.origin == origin,
            "A valid world vector is not rejected merely because its coordinates are zero or negative");
    }
}
