// Keyboard model contracts preserve the source catalog and editing behavior

run()
{
    catalog_matches_the_source_order_and_characters();
    valid_text_accepts_only_source_characters_and_spaces();
    valid_text_enforces_nonempty_text_and_the_character_limit();
    valid_text_rejects_missing_wrong_type_and_disallowed_values();
    create_starts_at_the_first_character_in_editing_state();
    cursor_wraps_at_each_source_boundary();
    selection_uses_the_current_column_and_row();
    space_appends_one_literal_space();
    navigation_does_not_change_entered_text();
    backspace_and_confirmation_set_the_expected_status();
    the_character_limit_reports_overflow_and_backspace_recovers();
    action_delays_include_branch_and_shared_waits();
    terminal_states_ignore_later_actions();
}

valid_text_accepts_only_source_characters_and_spaces()
{
    // Every source keyboard character and a literal space can form valid input
    columns = scripts\apparition\menu\keyboard_model::columns();
    all_source_characters_are_valid = true;
    for (column = 0; column < columns.size; column++)
    {
        for (row = 0; row < columns[column].size; row++)
        {
            if (!scripts\apparition\menu\keyboard_model::valid_text(columns[column][row]))
                all_source_characters_are_valid = false;
        }
    }

    tests\support\checks::expect(all_source_characters_are_valid
        && scripts\apparition\menu\keyboard_model::valid_text(" ")
        && scripts\apparition\menu\keyboard_model::valid_text("0 A?"),
        "Source keyboard characters and literal spaces are valid text");
}

valid_text_enforces_nonempty_text_and_the_character_limit()
{
    // The accepted boundary is one through forty-five characters
    forty_five_characters = "";
    for (index = 0; index < 45; index++)
        forty_five_characters += "0";
    forty_six_characters = forty_five_characters + "0";

    tests\support\checks::expect(!scripts\apparition\menu\keyboard_model::valid_text("")
        && scripts\apparition\menu\keyboard_model::valid_text("0")
        && scripts\apparition\menu\keyboard_model::valid_text(forty_five_characters)
        && !scripts\apparition\menu\keyboard_model::valid_text(forty_six_characters),
        "Valid text is nonempty and cannot exceed forty-five characters");
}

valid_text_rejects_missing_wrong_type_and_disallowed_values()
{
    // Only visible characters from the source keyboard or a space are admitted
    tests\support\checks::expect(!scripts\apparition\menu\keyboard_model::valid_text(undefined)
        && !scripts\apparition\menu\keyboard_model::valid_text(7),
        "Missing and non-string values are rejected");
    tests\support\checks::expect(!scripts\apparition\menu\keyboard_model::valid_text("0\nA")
        && !scripts\apparition\menu\keyboard_model::valid_text("0\tA")
        && !scripts\apparition\menu\keyboard_model::valid_text("~"),
        "Newlines, tabs, and characters outside the keyboard are rejected");
}

catalog_matches_the_source_order_and_characters()
{
    // Keep the full source alphabet as the single explicit catalog fixture
    expected = ["0ANan=", "1BObo.", "2CPcp<", "3DQdq$", "4ERer#", "5FSfs-",
        "6GTgt{", "7HUhu}", "8IViv@", "9JWjw/", "^KXkx_", "!LYly[", "?MZmz]"];
    actual = scripts\apparition\menu\keyboard_model::columns();

    tests\support\checks::expect(actual.size == expected.size,
        "Keyboard exposes the thirteen source columns in order");
    if (actual.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(actual[index] == expected[index],
            "Each keyboard column exactly matches the source characters");
}

create_starts_at_the_first_character_in_editing_state()
{
    // The source cursor begins at the first row and first column
    state = scripts\apparition\menu\keyboard_model::create();
    tests\support\checks::expect(state.x == 0 && state.y == 0 && state.text == ""
        && state.status == "Editing", "A new keyboard starts empty at the origin");
}

cursor_wraps_at_each_source_boundary()
{
    // Horizontal movement wraps across the thirteen source columns
    state = scripts\apparition\menu\keyboard_model::create();
    scripts\apparition\menu\keyboard_model::apply(state, "left");
    tests\support\checks::expect(state.x == 12, "Moving left from column zero wraps to column twelve");
    scripts\apparition\menu\keyboard_model::apply(state, "right");
    tests\support\checks::expect(state.x == 0, "Moving right from column twelve wraps to column zero");

    // Vertical movement wraps across the six characters in each column
    scripts\apparition\menu\keyboard_model::apply(state, "up");
    tests\support\checks::expect(state.y == 5, "Moving up from row zero wraps to row five");
    scripts\apparition\menu\keyboard_model::apply(state, "down");
    tests\support\checks::expect(state.y == 0, "Moving down from row five wraps to row zero");
}

selection_uses_the_current_column_and_row()
{
    // The final source cell is the closing bracket in column twelve
    state = scripts\apparition\menu\keyboard_model::create();
    scripts\apparition\menu\keyboard_model::apply(state, "left");
    scripts\apparition\menu\keyboard_model::apply(state, "up");
    overflow = scripts\apparition\menu\keyboard_model::apply(state, "select");
    tests\support\checks::expect(!overflow && state.x == 12 && state.y == 5
        && state.text == "]" && state.status == "Editing",
        "Selection appends the character at the current source coordinates");
}

space_appends_one_literal_space()
{
    // The original Frag control remains the keyboard space action
    state = scripts\apparition\menu\keyboard_model::create();
    scripts\apparition\menu\keyboard_model::apply(state, "select");
    overflow = scripts\apparition\menu\keyboard_model::apply(state, "space");
    tests\support\checks::expect(!overflow && state.text == "0 " && state.text.size == 2,
        "The space action appends one literal space");
}

navigation_does_not_change_entered_text()
{
    // Directional actions move the cursor without selecting a character
    state = scripts\apparition\menu\keyboard_model::create();
    scripts\apparition\menu\keyboard_model::apply(state, "select");
    original_text = state.text;
    actions = ["up", "down", "left", "right"];

    foreach (action in actions)
    {
        overflow = scripts\apparition\menu\keyboard_model::apply(state, action);
        tests\support\checks::expect(!overflow && state.text == original_text,
            "Directional actions do not select or alter entered text");
    }
}

backspace_and_confirmation_set_the_expected_status()
{
    // Backspace removes one character while editing and cancels on empty input
    state = scripts\apparition\menu\keyboard_model::create();
    scripts\apparition\menu\keyboard_model::apply(state, "select");
    scripts\apparition\menu\keyboard_model::apply(state, "select");
    overflow = scripts\apparition\menu\keyboard_model::apply(state, "back");
    tests\support\checks::expect(!overflow && state.text == "0" && state.status == "Editing",
        "Backspace removes exactly the final character and keeps editing");
    scripts\apparition\menu\keyboard_model::apply(state, "back");
    tests\support\checks::expect(state.text == "" && state.status == "Editing",
        "Removing the last character leaves the keyboard in editing state");
    overflow = scripts\apparition\menu\keyboard_model::apply(state, "back");
    tests\support\checks::expect(!overflow && state.text == "" && state.status == "Cancelled",
        "Backspace on empty input cancels the keyboard");

    // Confirmation uses the entered text to choose its terminal status
    state = scripts\apparition\menu\keyboard_model::create();
    overflow = scripts\apparition\menu\keyboard_model::apply(state, "confirm");
    tests\support\checks::expect(!overflow && state.text == "" && state.status == "Cancelled",
        "Confirming empty input cancels the keyboard");
    state = scripts\apparition\menu\keyboard_model::create();
    scripts\apparition\menu\keyboard_model::apply(state, "select");
    overflow = scripts\apparition\menu\keyboard_model::apply(state, "confirm");
    tests\support\checks::expect(!overflow && state.text == "0" && state.status == "Confirmed",
        "Confirming nonempty input preserves text and confirms the keyboard");
}

the_character_limit_reports_overflow_and_backspace_recovers()
{
    // Filling to forty-five characters is allowed without a limit report
    state = scripts\apparition\menu\keyboard_model::create();
    reported_before_limit = false;
    for (index = 0; index < 44; index++)
    {
        if (scripts\apparition\menu\keyboard_model::apply(state, "select"))
            reported_before_limit = true;
    }
    final_character_overflow = scripts\apparition\menu\keyboard_model::apply(state, "select");
    tests\support\checks::expect(!reported_before_limit && !final_character_overflow
        && state.text.size == 45 && state.status == "Editing",
        "The forty-fifth character is accepted without a limit report");

    // Both append actions report overflow and leave the full value untouched
    text_at_limit = state.text;
    select_overflow = scripts\apparition\menu\keyboard_model::apply(state, "select");
    space_overflow = scripts\apparition\menu\keyboard_model::apply(state, "space");
    tests\support\checks::expect(select_overflow && space_overflow
        && state.text == text_at_limit && state.status == "Editing",
        "Only over-limit selections and spaces report feedback without changing state");

    // Removing one character permits a new append at the same limit
    back_overflow = scripts\apparition\menu\keyboard_model::apply(state, "back");
    space_after_back_overflow = scripts\apparition\menu\keyboard_model::apply(state, "space");
    tests\support\checks::expect(!back_overflow && !space_after_back_overflow
        && state.text.size == 45 && state.text[state.text.size - 1] == " "
        && state.status == "Editing",
        "Backspace frees one character slot for a later space action");
}

action_delays_include_branch_and_shared_waits()
{
    // Each branch delay includes the common fifty millisecond loop wait
    tests\support\checks::expect(scripts\apparition\menu\keyboard_model::delay_ms("up") == 100
        && scripts\apparition\menu\keyboard_model::delay_ms("down") == 100
        && scripts\apparition\menu\keyboard_model::delay_ms("left") == 100
        && scripts\apparition\menu\keyboard_model::delay_ms("right") == 100,
        "Directional actions retain the source branch and shared waits");
    tests\support\checks::expect(scripts\apparition\menu\keyboard_model::delay_ms("select") == 200
        && scripts\apparition\menu\keyboard_model::delay_ms("space") == 150
        && scripts\apparition\menu\keyboard_model::delay_ms("back") == 150,
        "Selection, space, and nonempty backspace retain their source branch and shared waits");
    tests\support\checks::expect(scripts\apparition\menu\keyboard_model::delay_ms("none") == 50
        && scripts\apparition\menu\keyboard_model::delay_ms("confirm") == 0,
        "Idle input keeps the shared wait while confirmation exits immediately");
}

terminal_states_ignore_later_actions()
{
    // Confirmed and cancelled states each ignore every later model action
    actions = ["up", "down", "left", "right", "select", "space", "back", "confirm"];
    for (terminal_index = 0; terminal_index < 2; terminal_index++)
    {
        state = scripts\apparition\menu\keyboard_model::create();
        if (terminal_index == 0)
        {
            scripts\apparition\menu\keyboard_model::apply(state, "select");
            scripts\apparition\menu\keyboard_model::apply(state, "confirm");
            expected_status = "Confirmed";
        }
        else
        {
            scripts\apparition\menu\keyboard_model::apply(state, "confirm");
            expected_status = "Cancelled";
        }

        foreach (action in actions)
        {
            previous_x = state.x;
            previous_y = state.y;
            previous_text = state.text;
            overflow = scripts\apparition\menu\keyboard_model::apply(state, action);
            tests\support\checks::expect(!overflow && state.x == previous_x && state.y == previous_y
                && state.text == previous_text && state.status == expected_status,
                "Terminal keyboard states ignore later actions without feedback");
        }
    }
}
