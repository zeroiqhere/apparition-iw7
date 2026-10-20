// Movement setting contracts pin the two exact global dvars without writing them

run()
{
    catalog_keeps_the_two_source_controls_and_native_types();
    gravity_values_stay_inside_the_native_float_domain();
    speed_values_use_the_native_integer_reader_domain();
    source_toggle_uses_the_immutable_startup_baseline();
    iw7_gravity_preserves_a_fractional_native_startup_value();
    unknown_and_fixed_point_baselines_do_not_invent_an_alternative();
    initialize_keeps_the_startup_snapshot_immutable();
    invalid_owners_and_control_ids_return_before_native_reads();
}

catalog_keeps_the_two_source_controls_and_native_types()
{
    controls = scripts\apparition\features\server\movement::catalog();
    tests\support\checks::expect(isDefined(controls) && isArray(controls) && controls.size == 2,
        "The movement catalog exposes exactly Low Gravity and Super Speed");
    if (!isDefined(controls) || !isArray(controls) || controls.size != 2)
        return;

    low_gravity = controls[0];
    super_speed = controls[1];
    tests\support\checks::expect(isDefined(low_gravity.id) && low_gravity.id == "low_gravity"
        && low_gravity.dvar == "bg_gravity"
        && low_gravity.kind == "float" && low_gravity.target == 200.0,
        "Low Gravity maps only to float bg_gravity at the source target 200");
    tests\support\checks::expect(isDefined(super_speed.id) && super_speed.id == "super_speed"
        && super_speed.dvar == "g_speed"
        && super_speed.kind == "int" && super_speed.target == 500,
        "Super Speed maps only to integer g_speed at the source target 500");
}

gravity_values_stay_inside_the_native_float_domain()
{
    foreach (value in [1.0, 200.0, 800.0, 800.5, 1000.0])
        tests\support\checks::expect(scripts\apparition\features\server\movement::valid_native_value(
            "low_gravity", value), "A native-range gravity value remains restorable");

    foreach (value in [0.0, 1000.1, -1.0])
        tests\support\checks::expect(!scripts\apparition\features\server\movement::valid_native_value(
            "low_gravity", value), "A gravity value outside the registered float range is rejected");

    tests\support\checks::expect(!scripts\apparition\features\server\movement::valid_native_value(
        "low_gravity", undefined), "An undefined gravity value is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\movement::valid_native_value(
        "low_gravity", "200"), "A string gravity value is rejected");
}

speed_values_use_the_native_integer_reader_domain()
{
    foreach (value in [-2147483648, 0, 190, 500, 2147483647])
        tests\support\checks::expect(scripts\apparition\features\server\movement::valid_native_value(
            "super_speed", value), "A value returned by the native integer reader stays representable");

    tests\support\checks::expect(!scripts\apparition\features\server\movement::valid_native_value(
        "super_speed", undefined), "An undefined speed value is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\movement::valid_native_value(
        "super_speed", "500"), "A string speed value is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\movement::valid_native_value(
        "super_speed", (1, 0, 0)), "A vector speed value is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\movement::valid_native_value(
        "super_speed", []), "An array speed value is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\movement::valid_native_value(
        "super_speed", spawnstruct()), "A struct speed value is rejected");
}

source_toggle_uses_the_immutable_startup_baseline()
{
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "low_gravity", 800.0, 800.0) == 200.0,
        "Gravity at its startup baseline selects the source target");
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "low_gravity", 200.0, 800.0) == 800.0,
        "Gravity at its target selects the captured startup baseline");
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "low_gravity", 333.0, 800.0) == 800.0,
        "An externally changed gravity value follows the source non-baseline branch");

    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "super_speed", 190, 190) == 500,
        "Speed at its startup baseline selects the source target");
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "super_speed", 500, 190) == 190,
        "Speed at its target selects the captured startup baseline");
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "super_speed", 205, 190) == 190,
        "An externally changed speed value follows the source non-baseline branch");
}

iw7_gravity_preserves_a_fractional_native_startup_value()
{
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "low_gravity", 800.5, 800.5) == 200.0,
        "The IW7 float gravity baseline selects the preset without integer truncation");
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "low_gravity", 200.0, 800.5) == 800.5,
        "The IW7 adaptation restores the exact captured fractional gravity value");
}

unknown_and_fixed_point_baselines_do_not_invent_an_alternative()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\features\server\movement::next_value(
        "low_gravity", 800.0, undefined)),
        "Gravity cannot invent a default when startup capture was unavailable");
    tests\support\checks::expect(!isDefined(scripts\apparition\features\server\movement::next_value(
        "super_speed", 190, undefined)),
        "Speed cannot invent a default when startup capture was unavailable");
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "low_gravity", 200.0, 200.0) == 200.0,
        "A gravity startup baseline equal to the target is a fixed point, not a toggle");
    tests\support\checks::expect(scripts\apparition\features\server\movement::next_value(
        "super_speed", 500, 500) == 500,
        "A speed startup baseline equal to the target is a fixed point, not a toggle");
    tests\support\checks::expect(!isDefined(scripts\apparition\features\server\movement::next_value(
        "low_gravity", 200.0, 1001.0)),
        "An invalid gravity startup baseline cannot authorize a write");
}

initialize_keeps_the_startup_snapshot_immutable()
{
    had_snapshot = isDefined(level.apparition_server_movement_baselines);
    previous_snapshot = undefined;
    if (had_snapshot)
        previous_snapshot = level.apparition_server_movement_baselines;

    // An existing empty snapshot means startup capture already happened
    level.apparition_server_movement_baselines = [];
    scripts\apparition\features\server\movement::initialize();
    tests\support\checks::expect(isarray(level.apparition_server_movement_baselines)
        && level.apparition_server_movement_baselines.size == 0,
        "Initialization does not fill values missing from an existing startup snapshot");

    // A malformed defined snapshot stays unavailable instead of being replaced by a late capture
    malformed_snapshot = spawnstruct();
    malformed_snapshot.marker = "preserve";
    level.apparition_server_movement_baselines = malformed_snapshot;
    scripts\apparition\features\server\movement::initialize();
    tests\support\checks::expect(isDefined(level.apparition_server_movement_baselines.marker)
        && level.apparition_server_movement_baselines.marker == "preserve",
        "Initialization does not repair or recapture a defined malformed snapshot");

    if (had_snapshot)
        level.apparition_server_movement_baselines = previous_snapshot;
    else
        level.apparition_server_movement_baselines = undefined;
}

invalid_owners_and_control_ids_return_before_native_reads()
{
    missing_owner = scripts\apparition\features\server\movement::probe(undefined, "low_gravity");
    tests\support\checks::expect(isDefined(missing_owner.reason) && missing_owner.reason != ""
        && !isDefined(missing_owner.current) && !isDefined(missing_owner.checked),
        "A missing owner is rejected before a native movement value is read");
    tests\support\checks::expect(!scripts\apparition\features\server\movement::toggle(
        undefined, "low_gravity"), "A missing owner cannot change a movement dvar");

    nonplayer_owner = scripts\apparition\features\server\movement::probe(spawnstruct(), "super_speed");
    tests\support\checks::expect(isDefined(nonplayer_owner.reason) && nonplayer_owner.reason != ""
        && !isDefined(nonplayer_owner.current) && !isDefined(nonplayer_owner.checked),
        "A nonplayer owner is rejected before a native movement value is read");
    tests\support\checks::expect(!scripts\apparition\features\server\movement::toggle(
        spawnstruct(), "super_speed"), "A nonplayer owner cannot change a movement dvar");

    invalid_id = scripts\apparition\features\server\movement::probe(undefined, "g_speed");
    tests\support\checks::expect(isDefined(invalid_id.reason) && invalid_id.reason != ""
        && !isDefined(invalid_id.current), "Native dvar names are not accepted as control IDs");
    tests\support\checks::expect(!scripts\apparition\features\server\movement::toggle(
        undefined, "arbitrary_dvar"), "An arbitrary control ID cannot select a native dvar");
}
