// Movement scale contracts cover configuration without invoking a native player setter

run()
{
    scale_catalog_is_the_original_half_step_range();
    scale_validation_accepts_only_finite_catalog_numbers();
    missing_and_invalid_configuration_is_reported_without_guessing();
    rejected_values_and_missing_actor_preserve_existing_configuration();
}

scale_catalog_is_the_original_half_step_range()
{
    expected = [0, 0.5, 1, 1.5, 2, 2.5, 3];
    actual = scripts\apparition\features\movement::scales();
    tests\support\checks::expect(isDefined(actual) && isarray(actual)
        && actual.size == expected.size, "Movement exposes the original seven scale choices");
    if (!isDefined(actual) || !isarray(actual) || actual.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(actual[index] == expected[index], "Movement catalog preserves each ordered half-step choice");
        tests\support\checks::expect(scripts\apparition\features\movement::valid_scale(actual[index]), "Every catalog scale is valid");
    }
}

scale_validation_accepts_only_finite_catalog_numbers()
{
    tests\support\checks::expect(!scripts\apparition\features\movement::valid_scale(undefined),
        "An undefined scale is rejected");
    foreach (invalid in ["1", [], spawnstruct(), -0.5, -0.0001, 0.25, 1.25, 2.75, 3.0001, 1000000])
        tests\support\checks::expect(!scripts\apparition\features\movement::valid_scale(invalid), "A non-catalog or nonnumeric movement scale is rejected");
}

missing_and_invalid_configuration_is_reported_without_guessing()
{
    tests\support\checks::expect(scripts\apparition\features\movement::configured_scale(undefined) == "Unknown",
        "A missing player has unknown movement configuration");
    player = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\movement::configured_scale(player) == 1,
        "A defined player without an override uses the original default scale");

    player.MovementSpeed = 2.5;
    tests\support\checks::expect(scripts\apparition\features\movement::configured_scale(player) == 2.5,
        "A valid saved movement scale is displayed directly");
    player.MovementSpeed = 1;
    tests\support\checks::expect(scripts\apparition\features\movement::configured_scale(player) == 1,
        "A defined neutral scale is reported as its numeric value");

    foreach (invalid in ["fast", 1.25, [], spawnstruct()])
    {
        player.MovementSpeed = invalid;
        tests\support\checks::expect(scripts\apparition\features\movement::configured_scale(player) == "Unknown",
            "An invalid saved movement scale is not presented as the default");
        tests\support\checks::expect(player.MovementSpeed == invalid,
            "Reading an invalid movement scale does not repair stored state");
    }
}

rejected_values_and_missing_actor_preserve_existing_configuration()
{
    player = spawnstruct();
    player.MovementSpeed = 2;

    foreach (invalid in ["1", [], -1, 1.25, 3.5])
    {
        tests\support\checks::expect(!scripts\apparition\features\movement::set_scale(player, invalid),
            "An invalid scale is rejected before actor validation");
        tests\support\checks::expect(player.MovementSpeed == 2,
            "An invalid scale leaves the existing movement setting unchanged");
    }

    tests\support\checks::expect(!scripts\apparition\features\movement::set_scale(player, undefined),
        "An undefined scale is rejected before actor validation");
    tests\support\checks::expect(player.MovementSpeed == 2,
        "An undefined scale leaves the existing movement setting unchanged");
    tests\support\checks::expect(!scripts\apparition\features\movement::set_scale(undefined, 1.5),
        "A missing player is rejected for a valid scale");
    tests\support\checks::expect(!scripts\apparition\features\movement::set_scale(undefined, 1),
        "A missing player cannot clear or set movement speed");
}
