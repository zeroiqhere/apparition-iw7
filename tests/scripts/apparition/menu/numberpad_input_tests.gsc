// Numeric input ignores vertical and Frag buttons before selecting a source action

run()
{
    source_horizontal_direction_depends_on_the_current_input_device();
    horizontal_select_confirm_and_back_keep_the_source_priority();
    ignored_buttons_cannot_hide_a_valid_numeric_action();
}

buttons()
{
    result = [];
    foreach (name in ["+actionslot 1", "+actionslot 2", "+actionslot 3", "+actionslot 4",
        "+activate", "+frag", "+gostand", "+melee"])
        result[name] = false;
    return result;
}

source_horizontal_direction_depends_on_the_current_input_device()
{
    input = buttons();
    input["+actionslot 3"] = true;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "right"
        && scripts\apparition\menu\numberpad_input::command(input, true) == "left",
        "Action slot three follows the original keyboard/gamepad direction mapping");
    input["+actionslot 3"] = false;
    input["+actionslot 4"] = true;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "left"
        && scripts\apparition\menu\numberpad_input::command(input, true) == "right",
        "Action slot four reverses with the active input device");
}

horizontal_select_confirm_and_back_keep_the_source_priority()
{
    input = buttons();
    foreach (name in ["+actionslot 3", "+actionslot 4", "+activate", "+gostand", "+melee"])
        input[name] = true;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "right"
        && scripts\apparition\menu\numberpad_input::command(input, true) == "right",
        "The source chooses horizontal movement before edit actions even with both directions held");
    input["+actionslot 3"] = false;
    input["+actionslot 4"] = false;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "select",
        "Use has priority over simultaneous Jump and Melee");
    input["+activate"] = false;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "confirm",
        "Jump confirms before a simultaneous Melee cancellation");
    input["+gostand"] = false;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "back",
        "Melee is used when no higher source action is held");
}

ignored_buttons_cannot_hide_a_valid_numeric_action()
{
    input = buttons();
    foreach (name in ["+actionslot 1", "+actionslot 2", "+frag"])
        input[name] = true;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "none",
        "Vertical and Frag input have no numeric edit");
    input["+activate"] = true;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "select",
        "Ignoring vertical and Frag does not swallow a simultaneous Use press");
    input["+activate"] = false;
    input["+gostand"] = true;
    tests\support\checks::expect(scripts\apparition\menu\numberpad_input::command(input, false) == "confirm",
        "Ignored buttons cannot swallow a numeric zero confirmation");
}
