// Crosshair contracts cover saved text and choice handling without native HUD calls

run()
{
    choices_keep_the_source_order_and_append_a_clean_player_name();
    choice_validation_requires_an_exact_current_string();
    configured_reports_saved_text_and_rejects_malformed_records();
    operation_uses_one_record_and_repairs_missing_elements();
    retiring_an_old_record_does_not_clear_a_new_record();
    a_missing_or_fixture_actor_cannot_change_crosshair_state();
}

choices_keep_the_source_order_and_append_a_clean_player_name()
{
    expected = ["Disable", "+", "@", "x", "o", "> <", "CF4_99", "Extinct",
        "Daltax", "GBP", "AOC", "Apparition", "discord.gg/apparitionbo3", "TestPlayer"];
    actual = scripts\apparition\features\crosshairs::choices("TestPlayer");
    tests\support\checks::expect(isDefined(actual) && isarray(actual)
        && actual.size == expected.size, "Crosshair choices retain every source option and append the player name");
    if (!isDefined(actual) || !isarray(actual) || actual.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(isstring(actual[index]) && actual[index] == expected[index],
            "Crosshair choices preserve their exact source order");
    }

    without_name = scripts\apparition\features\crosshairs::choices(undefined);
    tests\support\checks::expect(isDefined(without_name) && isarray(without_name)
        && without_name.size == 13, "Crosshair choices omit an unavailable player name");
    tests\support\checks::expect(scripts\apparition\features\crosshairs::choices("^A^Bj=").size == 13,
        "A player name cleaned to empty is omitted");
}

choice_validation_requires_an_exact_current_string()
{
    tests\support\checks::expect(scripts\apparition\features\crosshairs::valid_choice("Disable", "Player"),
        "Disable is a valid crosshair selection");
    tests\support\checks::expect(scripts\apparition\features\crosshairs::valid_choice("+", "Player"),
        "A source glyph is a valid crosshair selection");
    tests\support\checks::expect(scripts\apparition\features\crosshairs::valid_choice("Player", "Player"),
        "The cleaned current player name is a valid selection");
    tests\support\checks::expect(!scripts\apparition\features\crosshairs::valid_choice("OtherPlayer", "Player"),
        "Another player's name is not a current selection");
    tests\support\checks::expect(!scripts\apparition\features\crosshairs::valid_choice(undefined, "Player"),
        "An undefined choice is rejected");
    foreach (invalid in [1, true, [], spawnstruct(), "disable", "-"])
    {
        tests\support\checks::expect(!scripts\apparition\features\crosshairs::valid_choice(invalid, "Player"),
            "A non-string, alias, or unsupported value is rejected");
    }
}

configured_reports_saved_text_and_rejects_malformed_records()
{
    tests\support\checks::expect(scripts\apparition\features\crosshairs::configured(undefined) == "Disable",
        "A missing player reports the disabled default");
    player = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\crosshairs::configured(player) == "Disable",
        "A player without a saved crosshair record reports disabled");

    record = spawnstruct();
    record.text = "@";
    record.element = undefined;
    player.apparition_crosshair = record;
    tests\support\checks::expect(scripts\apparition\features\crosshairs::configured(player) == "@",
        "Saved text remains available when its native element needs repair");
    tests\support\checks::expect(record.text == "@" && !isDefined(record.element),
        "Reading saved text does not modify the record or try to repair its handle");

    record.text = "stale selection";
    tests\support\checks::expect(scripts\apparition\features\crosshairs::configured(player) == "stale selection",
        "Configuration reads saved text without silently rewriting it");
    player.apparition_crosshair = 7;
    tests\support\checks::expect(scripts\apparition\features\crosshairs::configured(player) == "Unknown",
        "A non-record crosshair value is reported as unknown");
    player.apparition_crosshair = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\crosshairs::configured(player) == "Unknown",
        "A record without string text is reported as unknown");
}

operation_uses_one_record_and_repairs_missing_elements()
{
    tests\support\checks::expect(scripts\apparition\features\crosshairs::operation(undefined, "Disable") == "Disable",
        "Disable remains the explicit operation when no record exists");
    tests\support\checks::expect(scripts\apparition\features\crosshairs::operation(undefined, "@") == "Create",
        "An enabled selection without a record creates one element");
    tests\support\checks::expect(scripts\apparition\features\crosshairs::operation(7, "+") == "Create",
        "A malformed old record is replaced through the create path");

    record = spawnstruct();
    record.text = "+";
    record.element = undefined;
    tests\support\checks::expect(scripts\apparition\features\crosshairs::operation(record, "@") == "Create",
        "A saved record with a missing native element is eligible for repair");

    record.element = "defined handle marker";
    tests\support\checks::expect(scripts\apparition\features\crosshairs::operation(record, "@") == "Update",
        "A live record updates text without allocating a second element");
    tests\support\checks::expect(scripts\apparition\features\crosshairs::operation(record, "Disable") == "Disable",
        "Disable takes precedence over an existing element");
}

retiring_an_old_record_does_not_clear_a_new_record()
{
    player = spawnstruct();
    current = spawnstruct();
    current.text = "@";
    current.element = undefined;
    player.apparition_crosshair = current;

    stale = spawnstruct();
    stale.text = "+";
    stale.element = undefined;
    scripts\apparition\features\crosshairs::retire(player, stale);
    tests\support\checks::expect(player.apparition_crosshair == current,
        "Retiring an older worker record does not clear the current record");
    tests\support\checks::expect(!isDefined(stale.element),
        "Retiring a record with no native handle remains safe");

    scripts\apparition\features\crosshairs::retire(player, current);
    tests\support\checks::expect(!isDefined(player.apparition_crosshair),
        "Retiring the current record clears its player field");

    player.apparition_crosshair = 7;
    scripts\apparition\features\crosshairs::retire(player, 7);
    tests\support\checks::expect(!isDefined(player.apparition_crosshair),
        "Retiring a matching malformed value clears stale saved state without touching a HUD handle");
}

a_missing_or_fixture_actor_cannot_change_crosshair_state()
{
    tests\support\checks::expect(!scripts\apparition\features\crosshairs::set(undefined, "+"),
        "A missing player cannot create or update a crosshair");
    player = spawnstruct();
    record = spawnstruct();
    record.text = "@";
    record.element = undefined;
    player.apparition_crosshair = record;
    tests\support\checks::expect(!scripts\apparition\features\crosshairs::set(player, "+"),
        "A fixture struct is rejected before renderer calls");
    tests\support\checks::expect(player.apparition_crosshair == record && record.text == "@",
        "Actor rejection preserves the prior record and saved text");
}
