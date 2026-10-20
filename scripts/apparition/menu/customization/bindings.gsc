// Applied opening chords and editor choices share the original command strings

catalog()
{
    return ["+actionslot 1", "+actionslot 2", "+actionslot 3", "+actionslot 4",
        "+melee", "+speed_throw", "+attack", "+breath_sprint", "+activate",
        "+frag", "+smoke", "+stance", "+gostand"];
}

dead_controls()
{
    // Death uses this fixed chord instead of either configurable opening chord
    return ["+speed_throw", "+gostand"];
}

values(setting)
{
    if (setting == "binding_menu")
        return ["Apparition", "Quick Menu"];
    if (setting == "binding_slot")
        return [1, 2, 3];
    return [];
}

controls(layout, type)
{
    if (isDefined(type) && type == "Apparition")
        return layout.open_controls;
    if (isDefined(type) && type == "Quick Menu")
        return layout.quick_controls;
    return undefined;
}

select(layout, setting, value)
{
    if (!isDefined(value) || !scripts\engine\utility::array_contains(values(setting), value))
        return false;
    // Editor selection never changes the chord that is currently applied
    if (setting == "binding_menu")
        layout.binding_menu = value;
    else
        layout.binding_slot = int(value);
    return true;
}

proposal(layout, type, slot, button)
{
    result = spawnstruct();
    result.reason = "";
    result.value = [];
    current = controls(layout, type);
    if (!isDefined(current))
        result.reason = "Select Apparition or Quick Menu";
    else if (!isDefined(slot) || !scripts\engine\utility::array_contains(values("binding_slot"), slot))
        result.reason = "Select a bind slot from 1 to 3";
    else if (!isDefined(button) || (button != "None" && !scripts\engine\utility::array_contains(catalog(), button)))
        result.reason = "Select a listed control";
    if (result.reason != "")
        return result;

    index = int(slot) - 1;
    // Dense prefixes prevent an empty first control or a skipped earlier slot
    if (index == 0 && button == "None")
        result.reason = "Button 1 cannot be set to None";
    else if (button != "None" && scripts\engine\utility::array_contains(current, button))
        result.reason = "This button is already being used";
    else if (index > 0 && !isDefined(current[index - 1]))
        result.reason = "Fill Bind Slot " + index + " first";
    if (result.reason != "")
        return result;

    // Build a new array so rendering a proposal cannot change saved controls
    count = button == "None" ? index : max(current.size, index + 1);
    for (position = 0; position < count; position++)
        result.value[result.value.size] = position == index ? button : current[position];
    if (scripts\engine\utility::array_contains(result.value, "+frag")
        && scripts\engine\utility::array_contains(result.value, "+smoke"))
        result.reason = "Frag and Secondary Offhand cannot be paired together";
    return result;
}

apply(layout, type, slot, button)
{
    // Recheck current controls after the row was drawn before committing one array
    result = proposal(layout, type, slot, button);
    if (result.reason != "")
        return false;
    if (type == "Apparition")
        layout.open_controls = result.value;
    else
        layout.quick_controls = result.value;
    return true;
}

matches(buttons, chord)
{
    if (chord.size == 0)
        return false;
    foreach (command in chord)
    {
        // Chord members use AND while physical alternatives are handled by input
        if (!isDefined(buttons[command]) || !buttons[command])
            return false;
    }
    return true;
}

label(chord)
{
    // The same glyph order is used for both applied instruction rows
    text = "";
    foreach (command in chord)
        text += (text == "" ? "" : " + ") + "[{" + command + "}]";
    return text;
}
