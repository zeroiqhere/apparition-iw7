// Score contracts cover literal selections and bounded balance arithmetic

run()
{
    original_selection_order_is_preserved();
    selection_requires_a_supported_string();
    validation_does_not_change_the_selection_catalog();
    literal_deltas_and_zero_clear_balance();
    saturation_avoids_signed_integer_overflow();
    valid_balance_and_cap_values_are_admitted();
    malformed_balances_and_caps_are_rejected();
    missing_player_reads_and_writes_are_rejected();
}

original_selection_order_is_preserved()
{
    expected = ["1000000", "100000", "10000", "1000", "100", "10", "0",
        "-10", "-100", "-1000", "-10000", "-100000", "-1000000"];
    actual = scripts\apparition\features\score::selections();
    tests\support\checks::expect(isDefined(actual) && isarray(actual)
        && actual.size == expected.size, "Score exposes all original slider choices");
    if (!isDefined(actual) || !isarray(actual) || actual.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(isstring(actual[index]) && actual[index] == expected[index],
            "Score choices retain their exact strings and original order");
        tests\support\checks::expect(scripts\apparition\features\score::valid_selection(actual[index]),
            "Every original score choice is accepted");
    }
}

selection_requires_a_supported_string()
{
    tests\support\checks::expect(!scripts\apparition\features\score::valid_selection(undefined),
        "An undefined score choice is rejected");
    foreach (invalid in [1, 0, true, false, [], spawnstruct(), "1", "-0", "1000001", "1000000.0"])
    {
        tests\support\checks::expect(!scripts\apparition\features\score::valid_selection(invalid),
            "Numeric aliases and unsupported score choices are rejected");
    }
}

validation_does_not_change_the_selection_catalog()
{
    selected = scripts\apparition\features\score::selections();
    selected[0] = "10";
    tests\support\checks::expect(scripts\apparition\features\score::valid_selection("1000000"),
        "Changing a returned catalog copy does not change supported choices");
}

literal_deltas_and_zero_clear_balance()
{
    // Zero is a clear command rather than an unchanged delta
    tests\support\checks::expect(scripts\apparition\features\score::next_balance(500, 999999, "10") == 510,
        "A positive score choice adds its literal amount");
    tests\support\checks::expect(scripts\apparition\features\score::next_balance(500, 999999, "-10") == 490,
        "A negative score choice subtracts its literal magnitude");
    tests\support\checks::expect(scripts\apparition\features\score::next_balance(500, 999999, "0") == 0,
        "The zero choice clears the current balance");
    tests\support\checks::expect(scripts\apparition\features\score::next_balance(0, 999999, "0") == 0,
        "Clearing an already empty balance remains zero");
}

saturation_avoids_signed_integer_overflow()
{
    // Boundary cases require saturation before addition or subtraction
    tests\support\checks::expect(scripts\apparition\features\score::next_balance(999990, 999999, "10") == 999999,
        "A positive delta saturates at the queried cap");
    tests\support\checks::expect(scripts\apparition\features\score::next_balance(0, 999999, "-10") == 0,
        "A negative delta saturates at zero");
    tests\support\checks::expect(scripts\apparition\features\score::next_balance(2147483640, 2147483647, "1000000") == 2147483647,
        "Large positive deltas saturate without overflowing a signed integer");
    tests\support\checks::expect(scripts\apparition\features\score::next_balance(2147483647, 2147483647, "-1000000") == 2146483647,
        "Large negative deltas compare magnitude before subtraction");
    tests\support\checks::expect(int(scripts\apparition\features\score::next_balance(134217728.0, 2147483647, "10")) == 134217738,
        "A whole-valued floating balance preserves a literal delta beyond float precision");
}

valid_balance_and_cap_values_are_admitted()
{
    tests\support\checks::expect(scripts\apparition\features\score::balance_reason(500, 999999) == "",
        "A normal native balance and cap are ready");
    tests\support\checks::expect(scripts\apparition\features\score::balance_reason(0, 1) == "",
        "A zero balance and minimum positive cap are ready");
    tests\support\checks::expect(scripts\apparition\features\score::balance_reason(2147483647, 2147483647) == "",
        "The signed integer limit is accepted when balance does not exceed cap");
}

malformed_balances_and_caps_are_rejected()
{
    tests\support\checks::expect(scripts\apparition\features\score::balance_reason(undefined, 999999) != "",
        "A missing native balance is unavailable");
    tests\support\checks::expect(scripts\apparition\features\score::balance_reason(500, undefined) != "",
        "A missing native cap is unavailable");

    foreach (invalid_balance in ["500", [], spawnstruct(), -1, 0.5, 1000000, 2147483648])
    {
        tests\support\checks::expect(scripts\apparition\features\score::balance_reason(invalid_balance, 999999) != "",
            "A malformed, fractional, negative, over-cap, or out-of-range balance is rejected");
    }

    foreach (invalid_cap in ["999999", [], spawnstruct(), 0, -1, 1.5, 2147483648])
    {
        tests\support\checks::expect(scripts\apparition\features\score::balance_reason(500, invalid_cap) != "",
            "A malformed, nonpositive, fractional, or out-of-range cap is rejected");
    }

    tests\support\checks::expect(scripts\apparition\features\score::balance_reason(501, 500) != "",
        "A balance above its queried cap is rejected");
}

missing_player_reads_and_writes_are_rejected()
{
    // Missing actors cannot reach native currency reads or writes
    result = scripts\apparition\features\score::probe(undefined);
    tests\support\checks::expect(isDefined(result) && isDefined(result.reason) && result.reason != "",
        "A missing player reports a live balance read as unavailable");
    tests\support\checks::expect(!isDefined(result.balance) && !isDefined(result.cap),
        "An unavailable balance read does not invent native values");
    tests\support\checks::expect(!scripts\apparition\features\score::modify(undefined, "1000000"),
        "A valid score choice cannot write for a missing player");
    tests\support\checks::expect(!scripts\apparition\features\score::modify(undefined, "unknown"),
        "An invalid score choice cannot write for a missing player");
}
