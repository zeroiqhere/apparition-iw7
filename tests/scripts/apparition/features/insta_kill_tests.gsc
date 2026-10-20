// These contracts cover mode and damage-math decisions without native agent writes
// Game callback delivery, health changes and kill bookkeeping remain unexecuted here

run()
{
    modes_keep_source_order_and_reject_unknown_values();
    absent_and_malformed_records_resolve_safely();
    all_mode_raises_a_valid_reached_hit_to_lethal_damage();
    melee_mode_requires_the_exact_native_means_string();
    brute_and_grey_damage_are_never_modified();
    suicide_bomber_scale_must_still_leave_lethal_native_damage();
    malformed_damage_state_passes_through_unchanged();
    invalid_and_denied_actions_preserve_the_existing_record();
    println("Apparition Insta-Kill feature contracts completed");
}

modes_keep_source_order_and_reject_unknown_values()
{
    actual = scripts\apparition\features\insta_kill::modes();
    expected = ["Disable", "All", "Melee"];
    tests\support\checks::expect(actual.size == expected.size, "The mode list has all three source choices");
    if (actual.size == expected.size)
    {
        for (index = 0; index < expected.size; index++)
        {
            tests\support\checks::expect(actual[index] == expected[index], "The mode order matches Apparition");
            tests\support\checks::expect(scripts\apparition\features\insta_kill::valid_mode(expected[index]), "Each source mode is accepted");
        }
    }

    tests\support\checks::expect(!scripts\apparition\features\insta_kill::valid_mode(undefined), "An absent mode cannot be selected");
    foreach (invalid in ["unknown", "", 0, [], spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\features\insta_kill::valid_mode(invalid), "A value outside the source mode list is rejected");
}

absent_and_malformed_records_resolve_safely()
{
    tests\support\checks::expect(scripts\apparition\features\insta_kill::record_mode(undefined) == "Disable",
        "An absent per-target record means Disable");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::record_mode("invalid") == "Unknown",
        "A scalar record cannot select a damage mode");

    missing_owner = spawnstruct();
    missing_owner.mode = "All";
    tests\support\checks::expect(scripts\apparition\features\insta_kill::record_mode(missing_owner) == "Unknown",
        "A record without its owner is malformed");

    owner = spawnstruct();
    valid = spawnstruct();
    valid.owner = owner;
    valid.mode = "All";
    tests\support\checks::expect(scripts\apparition\features\insta_kill::record_mode(valid) == "All",
        "A complete All record resolves to its saved mode");
    valid.mode = "Melee";
    tests\support\checks::expect(scripts\apparition\features\insta_kill::record_mode(valid) == "Melee",
        "A complete Melee record resolves to its saved mode");
    valid.mode = "Disable";
    tests\support\checks::expect(scripts\apparition\features\insta_kill::record_mode(valid) == "Unknown",
        "Disable is represented by clearing the record rather than storing a live hook mode");
    valid.mode = 7;
    tests\support\checks::expect(scripts\apparition\features\insta_kill::record_mode(valid) == "Unknown",
        "A non-string saved mode is malformed");
}

all_mode_raises_a_valid_reached_hit_to_lethal_damage()
{
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_RIFLE_BULLET", "zombie", false, 1, 120, 120, undefined) == 120,
        "All mode returns max health for an ordinary accepted bullet hit");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_GRENADE_SPLASH", "zombie_clown", false, 0, 80, 200, undefined) == 200,
        "All mode can upgrade a zero amount after the native callback reaches the modifier");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", undefined, "zombie", false, 3, 100, 100, undefined) == 100,
        "All mode does not require a damage-method string");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "Disable", "MOD_MELEE", "zombie", false, 9, 100, 100, undefined) == 9,
        "Disable leaves the native amount unchanged");
}

melee_mode_requires_the_exact_native_means_string()
{
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "Melee", "MOD_MELEE", "zombie", false, 4, 60, 60, undefined) == 60,
        "Melee mode raises the exact native melee method to max health");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "Melee", "MOD_RIFLE_BULLET", "zombie", false, 4, 60, 60, undefined) == 4,
        "Melee mode preserves a bullet amount");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "Melee", undefined, "zombie", false, 4, 60, 60, undefined) == 4,
        "Melee mode preserves a hit with no means value");
}

brute_and_grey_damage_are_never_modified()
{
    foreach (mode in ["All", "Melee"])
    {
        tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
            mode, "MOD_MELEE", "zombie_brute", false, 19, 3000, 3000, undefined) == 19,
            "The Brute amount is unchanged in either mode");
        tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
            mode, "MOD_MELEE", "zombie_grey", false, 23, 5000, 5000, undefined) == 23,
            "The Grey amount is unchanged in either mode");
    }
}

suicide_bomber_scale_must_still_leave_lethal_native_damage()
{
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_RIFLE_BULLET", "zombie", true, 3, 100, 200, 0.5) == 200,
        "A bomber's positive half-scale still reaches its current health after the native cap");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_RIFLE_BULLET", "zombie", true, 3, 101, 200, 0.5) == 3,
        "A bomber keeps the original amount when native scaling would fall short");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_RIFLE_BULLET", "zombie", true, 3, 1, 200, 0) == 3,
        "A zero native multiplier prevents a false lethal claim");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_RIFLE_BULLET", "zombie", true, 3, 1, 200, "bad") == 3,
        "A malformed native multiplier cannot support a lethal claim");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_RIFLE_BULLET", "zombie", true, 3, 100, 200, undefined) == 200,
        "An absent native special multiplier leaves the ordinary max-health result");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_RIFLE_BULLET", "zombie", false, 3, 100, 200, 0) == 200,
        "Special scaling on non-bombers does not change the native target path");
}

malformed_damage_state_passes_through_unchanged()
{
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "Unknown", "MOD_MELEE", "zombie", false, 9, 100, 100, undefined) == 9,
        "A malformed mode passes through the native amount");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", false, "bad", 100, 100, undefined) == "bad",
        "A malformed amount is not replaced");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", false, 9, undefined, 100, undefined) == 9,
        "Missing current health passes through");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", false, 9, 101, 100, undefined) == 9,
        "Health above maximum is rejected as malformed native state");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", false, 9, 1, 2147483648, undefined) == 9,
        "A maximum outside the native integer range passes through");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", false, 9, 1, 2147483648.0, undefined) == 9,
        "The first float above the safe native integer range passes through before int conversion");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", false, 2147483648.0, 1, 100, undefined) == 2147483648.0,
        "An amount above the safe native integer range is preserved");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", false, -1, 1, 100, undefined) == -1,
        "A negative amount fails the bounded nonnegative range check");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", false, 9, 100.5, 100.5, undefined) == 9,
        "A fractional maximum whose native integer cap is not lethal passes through");
    tests\support\checks::expect(scripts\apparition\features\insta_kill::damage_amount(
        "All", "MOD_MELEE", "zombie", true, 9, 101, 200, 0.5) == 9,
        "A malformed downstream result cannot be reported as lethal");
}

invalid_and_denied_actions_preserve_the_existing_record()
{
    target = spawnstruct();
    existing = spawnstruct();
    target.apparition_insta_kill = existing;
    tests\support\checks::expect(!scripts\apparition\features\insta_kill::set_mode(undefined, target, "invalid"),
        "An unsupported choice is rejected before actor admission");
    tests\support\checks::expect(!scripts\apparition\features\insta_kill::set_mode(undefined, target, "Disable"),
        "An unauthorized Disable action cannot mutate the selected player");
    tests\support\checks::expect(target.apparition_insta_kill == existing,
        "Rejected actions preserve the existing per-target record");

    snapshot = scripts\apparition\features\insta_kill::probe(undefined, target);
    tests\support\checks::expect(snapshot.reason != "" && snapshot.mode == "Unknown",
        "A missing requester is rejected before the target setting is inspected");
    tests\support\checks::expect(target.apparition_insta_kill == existing,
        "A rejected probe preserves the selected player's record");
}
