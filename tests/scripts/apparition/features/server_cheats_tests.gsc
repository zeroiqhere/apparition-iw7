// These contracts reject bad input without changing the live server setting

run()
{
    native_boolean_strings_are_accepted();
    missing_or_malformed_native_readings_are_rejected();
    invalid_owners_cannot_read_or_toggle_native_cheats();
}

native_boolean_strings_are_accepted()
{
    foreach (value in ["0", "1"])
        tests\support\checks::expect(scripts\apparition\features\server_cheats::valid_value(value),
            "A native boolean string supplies readable SV Cheats state");
}

missing_or_malformed_native_readings_are_rejected()
{
    tests\support\checks::expect(!scripts\apparition\features\server_cheats::valid_value(undefined),
        "An absent native reading cannot invent disabled SV Cheats");
    foreach (value in ["", "2", "true", "false", "01", " 1", 0, 1, [], spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\features\server_cheats::valid_value(value),
            "Only the registered native boolean string domain supplies SV Cheats state");
}

invalid_owners_cannot_read_or_toggle_native_cheats()
{
    snapshot = scripts\apparition\features\server_cheats::probe(undefined);
    tests\support\checks::expect(snapshot.reason != "" && !isDefined(snapshot.current),
        "A missing owner is denied before native SV Cheats state is read");
    tests\support\checks::expect(!scripts\apparition\features\server_cheats::toggle(undefined),
        "A missing owner cannot reach the native server setting writer");
    actor = spawnstruct();
    snapshot = scripts\apparition\features\server_cheats::probe(actor);
    tests\support\checks::expect(snapshot.reason != "" && !isDefined(snapshot.current),
        "A non-player owner cannot supply a native SV Cheats reading");
    tests\support\checks::expect(!scripts\apparition\features\server_cheats::toggle(actor),
        "A non-player owner cannot toggle the server setting");
}
