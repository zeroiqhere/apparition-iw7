// Native held input is sampled once and translated to one menu command

read()
{
    buttons = [];
    foreach (command in scripts\apparition\menu\customization\bindings::catalog())
        buttons[command] = self held(command);
    return buttons;
}

held(command)
{
    // Keep native held queries where IW7 provides the original button operation
    switch (command)
    {
        case "+speed_throw": return self adsButtonPressed();
        case "+attack": return self attackButtonPressed();
        case "+melee": return self meleeButtonPressed();
        case "+activate": return self useButtonPressed();
        case "+smoke": return self secondaryOffhandButtonPressed();
        case "+frag": return self fragButtonPressed();
    }
    // Stock IW7 resolves command bindings before querying each physical key
    keys = getKeyBinding(command);
    for (index = 1; index <= keys["count"]; index++)
    {
        if (self buttonPressed(keys["key" + index]))
            return true;
    }
    // An unbound command or released alternatives cannot retain stale held state
    return false;
}

command(buttons, open, slider, layout, alive)
{
    if (!open)
    {
        if (alive && scripts\apparition\menu\customization\bindings::matches(buttons, layout.open_controls))
            return "open";
        // The source uses a fixed chord while dead and saved controls while alive
        quick = alive ? scripts\apparition\menu\customization\bindings::matches(buttons, layout.quick_controls)
            : scripts\apparition\menu\customization\bindings::matches(buttons, scripts\apparition\menu\customization\bindings::dead_controls());
        if (!layout.disable_quick_menu && quick)
            return "quick";
        return "none";
    }
    up = buttons["+speed_throw"] || buttons["+actionslot 1"];
    down = buttons["+attack"] || buttons["+actionslot 2"];
    if (up != down)
        return up ? "up" : "down";
    // The controller applies the source repeat delay to held commands
    if (buttons["+activate"])
        return "select";
    if (slider && buttons["+actionslot 3"] != buttons["+actionslot 4"])
        return buttons["+actionslot 3"] ? "left" : "right";
    if (buttons["+melee"] || (!alive && buttons["+gostand"]))
        return "back";
    return "none";
}

keyboard_command(buttons, gamepad)
{
    // Keep the source's vertical, horizontal, select, space, confirm and back priority
    if (buttons["+actionslot 1"] || buttons["+actionslot 2"])
        return buttons["+actionslot 1"] ? "up" : "down";
    if (buttons["+actionslot 3"] || buttons["+actionslot 4"])
    {
        right = gamepad ? buttons["+actionslot 4"] : buttons["+actionslot 3"];
        return right ? "right" : "left";
    }
    if (buttons["+activate"])
        return "select";
    if (buttons["+frag"])
        return "space";
    if (buttons["+gostand"])
        return "confirm";
    if (buttons["+melee"])
        return "back";
    return "none";
}

editor_command(buttons, mode)
{
    if (mode == "width")
    {
        // Width editing keeps the original if/else priority for simultaneous inputs
        if (buttons["+attack"])
            return "width_increase";
        else if (buttons["+speed_throw"])
            return "width_decrease";
        else if (buttons["+actionslot 3"])
            return "offset_decrease";
        else if (buttons["+actionslot 4"])
            return "offset_increase";
        else if (buttons["+melee"])
            return "exit";
    }
    else if (mode == "reposition" || mode == "instructions")
    {
        // Reposition keeps the source vertical, horizontal and step-control priority
        if (buttons["+actionslot 1"] || buttons["+actionslot 2"])
            return buttons["+actionslot 2"] ? "move_down" : "move_up";
        else if (buttons["+actionslot 3"] || buttons["+actionslot 4"])
            return buttons["+actionslot 4"] ? "move_right" : "move_left";
        else if (mode == "reposition" && buttons["+smoke"])
            return "offset_decrease";
        else if (mode == "reposition" && buttons["+frag"])
            return "offset_increase";
        else if (buttons["+melee"])
            return "exit";
    }
    // Ordinary menu directions, Use and the quick chord have no modal action
    return "none";
}

editor_delay_ms(command)
{
    // Source branch waits run before the shared 25-millisecond pass
    switch (command)
    {
        case "width_increase":
        case "width_decrease": return 75;
        case "offset_decrease":
        case "offset_increase": return 125;
        case "move_up":
        case "move_down":
        case "move_left":
        case "move_right":
        case "none": return 25;
    }
    return 0;
}

back_action(page, quick_exit, held_samples)
{
    // Source roots close immediately while nested pages may wait for a hold
    if (page == "Main" || page == "Quick Menu")
        return "close";
    if (!quick_exit)
        return "back";
    if (!isDefined(held_samples))
        return "hold";
    return held_samples >= 10 ? "close" : "back";
}

can_resume_hold(is_open, hud_available, session_available, state_unchanged)
{
    // A delayed input is valid only while its original menu session remains live
    return is_open && hud_available && session_available && state_unchanged;
}

cooldown(command, scroll_time, selection_delay)
{
    switch (command)
    {
        case "up":
        case "down": return int(scroll_time * 1000) + 75;
        case "left":
        case "right": return 180;
        case "select": return 250 + (isDefined(selection_delay) ? int(selection_delay * 1000 + 0.5) : 0);
        case "back": return 250;
        case "open": return 600;
        case "quick": return 550;
    }
    return 0;
}
