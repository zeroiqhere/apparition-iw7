// Each option owns only the native elements used by its current display

roles(model, layout)
{
    roles = [];
    if (model.kind == "toggle" && layout.bool_display == "Boxes")
    {
        roles[roles.size] = "box";
        roles[roles.size] = "fill";
    }
    else if (model.kind == "submenu" || model.kind == "slider"
        || (model.kind == "toggle" && layout.bool_display == "Text"))
        roles[roles.size] = "value";
    // The label remains present even for a blank spacer
    roles[roles.size] = "label";
    if (invalid_label(model.label))
        roles[roles.size] = "invalid_line";
    return roles;
}

invalid_label(label)
{
    if (!isDefined(label))
        return true;
    // Localized strings without a character count are valid in the source
    if (!isDefined(label.size))
        return false;
    for (index = 0; index < label.size; index++)
    {
        if (label[index] != " ")
            return false;
    }
    return true;
}

matches(slot, model, layout)
{
    expected = roles(model, layout);
    if (slot.elements.size != expected.size)
        return false;
    foreach (role in expected)
    {
        if (!isDefined(slot.elements[role]))
            return false;
    }
    return true;
}

window_matches(slots, rows, start, shift, layout)
{
    for (index = 0; index < slots.size; index++)
    {
        previous = index + shift;
        // The entering edge gets fresh elements after retained shapes are checked
        if (previous < 0 || previous >= slots.size)
            continue;
        if (!matches(slots[previous], rows[start + index], layout))
            return false;
    }
    return true;
}

owned(slot)
{
    // Ownership is the actual map, without a second list of optional handles
    return isDefined(slot) ? slot.elements : [];
}
