// Number-pad contracts preserve the source editing states and digit limit

run()
{
    initial_zero_and_horizontal_wrap_match_the_source();
    selecting_replaces_the_initial_zero_and_keeps_ten_digits();
    backspace_returns_to_zero_before_canceling();
    confirming_zero_is_distinct_from_canceling();
    terminal_and_unhandled_actions_do_not_edit_text();
}

initial_zero_and_horizontal_wrap_match_the_source()
{
    state = scripts\apparition\menu\numberpad_model::create();
    tests\support\checks::expect(state.cursor == 0 && state.text == "0" && state.status == "Editing",
        "The number pad starts at digit zero with a visible zero value");
    scripts\apparition\menu\numberpad_model::apply(state, "left");
    tests\support\checks::expect(state.cursor == 9,
        "Moving left from zero wraps to the final source digit");
    scripts\apparition\menu\numberpad_model::apply(state, "right");
    tests\support\checks::expect(state.cursor == 0,
        "Moving right from nine wraps to the first source digit");
}

selecting_replaces_the_initial_zero_and_keeps_ten_digits()
{
    state = scripts\apparition\menu\numberpad_model::create();
    scripts\apparition\menu\numberpad_model::apply(state, "select");
    scripts\apparition\menu\numberpad_model::apply(state, "select");
    tests\support\checks::expect(state.text == "0",
        "Repeated zero selection replaces the initial zero instead of accumulating padding");
    state.cursor = 1;
    scripts\apparition\menu\numberpad_model::apply(state, "select");
    tests\support\checks::expect(state.text == "1",
        "The first nonzero selection replaces the default zero");
    state.cursor = 9;
    for (index = 0; index < 9; index++)
        scripts\apparition\menu\numberpad_model::apply(state, "select");
    tests\support\checks::expect(state.text == "1999999999",
        "Ten source digits remain editable without numeric conversion");
    scripts\apparition\menu\numberpad_model::apply(state, "select");
    tests\support\checks::expect(state.text == "1999999999",
        "Selection at the source ten-digit limit leaves the value unchanged");
}

backspace_returns_to_zero_before_canceling()
{
    state = scripts\apparition\menu\numberpad_model::create();
    state.text = "12";
    scripts\apparition\menu\numberpad_model::apply(state, "back");
    tests\support\checks::expect(state.text == "1" && state.status == "Editing",
        "Backspace removes the final digit while more than one remains");
    scripts\apparition\menu\numberpad_model::apply(state, "back");
    tests\support\checks::expect(state.text == "0" && state.status == "Editing",
        "Backspace on one nonzero digit restores the default zero");
    scripts\apparition\menu\numberpad_model::apply(state, "back");
    tests\support\checks::expect(state.text == "0" && state.status == "Canceled",
        "Backspace on the default zero cancels rather than confirming zero");
}

confirming_zero_is_distinct_from_canceling()
{
    state = scripts\apparition\menu\numberpad_model::create();
    scripts\apparition\menu\numberpad_model::apply(state, "confirm");
    tests\support\checks::expect(state.text == "0" && state.status == "Confirmed",
        "Jump confirms the default numeric zero in the source number pad");
}

terminal_and_unhandled_actions_do_not_edit_text()
{
    state = scripts\apparition\menu\numberpad_model::create();
    foreach (action in ["up", "down", "space", "none", "unknown"])
        scripts\apparition\menu\numberpad_model::apply(state, action);
    tests\support\checks::expect(state.cursor == 0 && state.text == "0" && state.status == "Editing",
        "Vertical, Frag, idle and unknown actions have no number-pad edit");
    foreach (status in ["Confirmed", "Canceled", "Retired"])
    {
        state.status = status;
        scripts\apparition\menu\numberpad_model::apply(state, "right");
        scripts\apparition\menu\numberpad_model::apply(state, "select");
        tests\support\checks::expect(state.cursor == 0 && state.text == "0" && state.status == status,
            "A terminal model cannot resume editing");
    }
}
