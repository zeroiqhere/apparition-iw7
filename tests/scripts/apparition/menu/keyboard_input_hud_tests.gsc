// Keyboard input and HUD contracts preserve source priorities and geometry

run()
{
    vertical_commands_keep_source_priority();
    horizontal_commands_follow_keyboard_and_gamepad_directions();
    later_commands_follow_the_source_priority_order();
    ads_and_attack_are_inactive_keyboard_commands();
    geometry_centers_the_keyboard_and_uses_the_design_offset();
    cursor_projection_tracks_model_coordinates();
    first_cursor_position_uses_the_main_scroller_origin();
    column_text_matches_source_characters_with_line_breaks();
}

vertical_commands_keep_source_priority()
{
    // Action slot one is Up and action slot two is Down
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 1"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "up",
        "Keyboard action slot one moves up");
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 2"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, true) == "down",
        "Gamepad action slot two moves down");

    // Simultaneous vertical inputs resolve to slot one before every later action
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 1"] = true;
    buttons["+actionslot 2"] = true;
    buttons["+actionslot 3"] = true;
    buttons["+activate"] = true;
    buttons["+frag"] = true;
    buttons["+gostand"] = true;
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "up",
        "Slot one wins when both vertical and lower-priority commands are held");
}

horizontal_commands_follow_keyboard_and_gamepad_directions()
{
    // Keyboard and gamepad assign opposite horizontal directions to the same slots
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 3"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "right"
        && scripts\apparition\menu\input::keyboard_command(buttons, true) == "left",
        "Slot three moves right on keyboard and left on gamepad");

    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 4"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "left"
        && scripts\apparition\menu\input::keyboard_command(buttons, true) == "right",
        "Slot four moves left on keyboard and right on gamepad");

    // When both horizontal slots are held, the source direction check resolves right
    buttons["+actionslot 3"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "right"
        && scripts\apparition\menu\input::keyboard_command(buttons, true) == "right",
        "Simultaneous horizontal slots resolve right on both input devices");
}

later_commands_follow_the_source_priority_order()
{
    // Movement precedes selection, space, confirmation, and back
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 3"] = true;
    buttons["+activate"] = true;
    buttons["+frag"] = true;
    buttons["+gostand"] = true;
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "right",
        "Horizontal movement wins over every later keyboard action");

    // Removing each earlier action reveals the next source command
    buttons["+actionslot 3"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "select",
        "Activate wins over space, confirmation, and back");
    buttons["+activate"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "space",
        "Frag space wins over confirmation and back");
    buttons["+frag"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "confirm",
        "Go stand confirmation wins over back");
    buttons["+gostand"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "back",
        "Melee maps to back when no earlier keyboard action is held");
    buttons["+melee"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "none",
        "No active keyboard command produces none");
}

ads_and_attack_are_inactive_keyboard_commands()
{
    // ADS and Attack are not keyboard actions in the source flow
    buttons = tests\fixtures\input::buttons();
    buttons["+speed_throw"] = true;
    buttons["+attack"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::keyboard_command(buttons, false) == "none"
        && scripts\apparition\menu\input::keyboard_command(buttons, true) == "none",
        "ADS and Attack do not create keyboard actions on either input device");
}

geometry_centers_the_keyboard_and_uses_the_design_offset()
{
    // Ordinary designs use twelve pixels below the background origin
    layout = spawnstruct();
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    layout.design = "Apparition";
    geometry = scripts\apparition\menu\keyboard_hud::geometry(layout);
    tests\support\checks::expect(geometry.center_x == 217 && geometry.input_y == 53
        && geometry.keys_y == 73 && geometry.first_x == 127,
        "The ordinary keyboard centers its input and thirteen columns on the panel");

    // Basic design uses the source twenty-eight pixel input offset
    layout.x = -10;
    layout.y = 70;
    layout.width = 200;
    layout.design = "Basic";
    geometry = scripts\apparition\menu\keyboard_hud::geometry(layout);
    tests\support\checks::expect(geometry.center_x == 90 && geometry.input_y == 98
        && geometry.keys_y == 118 && geometry.first_x == 0,
        "Basic design applies its distinct input offset and centered column origin");
}

cursor_projection_tracks_model_coordinates()
{
    // The first cursor position sits eight pixels above and left of the first key
    layout = spawnstruct();
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    layout.design = "Apparition";
    geometry = scripts\apparition\menu\keyboard_hud::geometry(layout);
    model = scripts\apparition\menu\keyboard_model::create();
    cursor = scripts\apparition\menu\keyboard_hud::cursor(model.x, model.y, geometry);
    tests\support\checks::expect(cursor.x == 119 && cursor.y == 65,
        "The origin cursor uses the first source key position");

    // Wrapped model coordinates keep the source horizontal and vertical spacing
    scripts\apparition\menu\keyboard_model::apply(model, "left");
    scripts\apparition\menu\keyboard_model::apply(model, "up");
    cursor = scripts\apparition\menu\keyboard_hud::cursor(model.x, model.y, geometry);
    tests\support\checks::expect(cursor.x == 299 && cursor.y == 137.5,
        "The last source cell uses fifteen-pixel columns and fourteen-point-five-pixel rows");
}

first_cursor_position_uses_the_main_scroller_origin()
{
    // The modal starts on the first key using the existing main-HUD scroller
    // Its top-left corner keeps the source eight-pixel inset from that key
    layout = spawnstruct();
    layout.x = 0;
    layout.y = 0;
    layout.width = 210;
    layout.design = "Basic";
    shape = scripts\apparition\menu\keyboard_hud::geometry(layout);
    position = scripts\apparition\menu\keyboard_hud::cursor(0, 0, shape);
    tests\support\checks::expect(position.x == shape.first_x - 8
        && position.y == shape.keys_y - 8,
        "Keyboard starts the borrowed scroller at the first source key origin");
}

column_text_matches_source_characters_with_line_breaks()
{
    // Each column shows one source character per line, including the final newline
    columns = scripts\apparition\menu\keyboard_model::columns();
    tests\support\checks::expect(isDefined(columns) && isarray(columns) && columns.size == 13,
        "Keyboard HUD receives the thirteen source columns");
    if (!isDefined(columns) || !isarray(columns) || columns.size != 13)
        return;

    for (column = 0; column < columns.size; column++)
    {
        expected = "";
        for (row = 0; row < columns[column].size; row++)
            expected += columns[column][row] + "\n";
        actual = scripts\apparition\menu\keyboard_hud::column_text(column);
        tests\support\checks::expect(actual == expected,
            "Keyboard HUD preserves each source column and one trailing newline per character");
    }
}
