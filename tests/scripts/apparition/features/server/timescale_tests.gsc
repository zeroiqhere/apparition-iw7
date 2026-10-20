// Timescale contracts check exact settings and rejected requesters without changing native dvars

run()
{
    menu_values_are_the_supported_half_steps();
    only_numeric_exact_menu_values_are_valid();
    malformed_and_between_step_values_are_rejected();
    invalid_requesters_cannot_read_or_change_the_world_setting();
}

menu_values_are_the_supported_half_steps()
{
    expected = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];
    actual = scripts\apparition\features\server\timescale::values();

    tests\support\checks::expect(isDefined(actual) && isArray(actual) && actual.size == expected.size,
        "Timescale exposes the ten source menu steps");
    if (!isDefined(actual) || !isArray(actual) || actual.size != expected.size)
        return;
    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(isnumber(actual[index]) && actual[index] == expected[index],
            "Timescale menu values retain their exact numeric half-step order");
    }
}

only_numeric_exact_menu_values_are_valid()
{
    values = scripts\apparition\features\server\timescale::values();
    foreach (value in values)
        tests\support\checks::expect(scripts\apparition\features\server\timescale::valid_value(value),
            "Every native menu choice is a valid numeric request");

    foreach (value in [1, 2, 3, 4, 5])
        tests\support\checks::expect(scripts\apparition\features\server\timescale::valid_value(value),
            "Whole-number timescale choices remain valid numeric requests");
}

malformed_and_between_step_values_are_rejected()
{
    tests\support\checks::expect(!scripts\apparition\features\server\timescale::valid_value(undefined),
        "An undefined timescale request is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\timescale::valid_value("1.0"),
        "A numeric-looking string is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\timescale::valid_value((1, 0, 0)),
        "A vector timescale request is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\timescale::valid_value([]),
        "An array timescale request is rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\timescale::valid_value(spawnstruct()),
        "A struct timescale request is rejected");

    foreach (value in [0, 0.49, 0.75, 1.25, 4.75, 5.5, 1000])
        tests\support\checks::expect(!scripts\apparition\features\server\timescale::valid_value(value),
            "Values outside the exact half-step choices are rejected");
}

invalid_requesters_cannot_read_or_change_the_world_setting()
{
    probe = scripts\apparition\features\server\timescale::probe(undefined);
    tests\support\checks::expect(isDefined(probe.reason) && probe.reason != "" && !isDefined(probe.current),
        "A missing requester is rejected before a current dvar value is returned");
    tests\support\checks::expect(!scripts\apparition\features\server\timescale::request(undefined, 0.5),
        "A missing requester cannot change the world timescale");

    requester = spawnstruct();
    probe = scripts\apparition\features\server\timescale::probe(requester);
    tests\support\checks::expect(isDefined(probe.reason) && probe.reason != "" && !isDefined(probe.current),
        "A nonplayer requester is rejected before a current dvar value is returned");
    tests\support\checks::expect(!scripts\apparition\features\server\timescale::request(requester, 1.0),
        "A nonplayer requester cannot change the world timescale");
}
