// Numeric input uses the source horizontal, select, confirm and back priority

command(buttons, gamepad)
{
    if (buttons["+actionslot 3"] || buttons["+actionslot 4"])
    {
        right = gamepad ? buttons["+actionslot 4"] : buttons["+actionslot 3"];
        return right ? "right" : "left";
    }
    // Vertical and Frag buttons are absent from this source control loop
    if (buttons["+activate"])
        return "select";
    if (buttons["+gostand"])
        return "confirm";
    if (buttons["+melee"])
        return "back";
    return "none";
}
