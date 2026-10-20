// A versioned settings record contains applied choices without live HUD state

encode(layout)
{
    theme = "Rainbow";
    if (!layout.smooth_rainbow)
    {
        theme = undefined;
        foreach (entry in scripts\apparition\menu\customization\palette::catalog())
        {
            if (entry.color == layout.accent)
                theme = entry.name;
        }
    }
    if (!isDefined(theme))
        return undefined;
    // One record keeps both chords and the visual settings in the same snapshot
    return join(["3", int(layout.x), int(layout.y), int(layout.width), layout.design,
        layout.bool_display, layout.bool_location, int(layout.scroll_time * 1000 + 0.5),
        int(layout.quick_exit), int(layout.disable_quick_menu), int(layout.spotlight_cursor),
        int(layout.colored_cursor), int(layout.large_cursor), int(layout.option_counter), theme,
        join(layout.open_controls, ","), join(layout.quick_controls, ","), int(layout.stealth_ui),
        int(layout.instructions_x), int(layout.instructions_y), int(layout.disable_instructions),
        int(layout.alternate_instructions), int(layout.disable_instructions_background),
        int(layout.adaptive_instructions)], "|");
}

decode(record)
{
    if (!isDefined(record) || !isString(record))
        return undefined;
    fields = strTok(record, "|");
    // Rejoining detects empty fields that the native tokenizer may have skipped
    if (!fields.size || join(fields, "|") != record)
        return undefined;
    instructions_x = undefined;
    instructions_y = undefined;
    if (fields[0] == "1")
    {
        if (fields.size != 17)
            return undefined;
        stealth_ui = false;
    }
    else if (fields[0] == "2")
    {
        if (fields.size != 18 || (fields[17] != "0" && fields[17] != "1"))
            return undefined;
        stealth_ui = fields[17] == "1";
    }
    else if (fields[0] == "3")
    {
        if (fields.size != 24 || (fields[17] != "0" && fields[17] != "1"))
            return undefined;
        stealth_ui = fields[17] == "1";
        instructions_x = integer(fields[18]);
        instructions_y = integer(fields[19]);
        if (!isDefined(instructions_x) || !isDefined(instructions_y))
            return undefined;
        foreach (index in [20, 21, 22, 23])
        {
            if (fields[index] != "0" && fields[index] != "1")
                return undefined;
        }
        if (fields[21] == "1" && fields[23] == "1")
            return undefined;
    }
    else
        return undefined;
    x = integer(fields[1]);
    y = integer(fields[2]);
    width = integer(fields[3]);
    scroll_ms = integer(fields[7]);
    if (!isDefined(x) || !isDefined(y) || !isDefined(width) || !isDefined(scroll_ms))
        return undefined;
    if (width < 200 || width > 500)
        return undefined;
    if (!scripts\engine\utility::array_contains(scripts\apparition\menu\customization\preferences::values("design"), fields[4])
        || !scripts\engine\utility::array_contains(scripts\apparition\menu\customization\preferences::values("bool_display"), fields[5])
        || !scripts\engine\utility::array_contains(scripts\apparition\menu\customization\preferences::values("bool_location"), fields[6])
        || !scripts\engine\utility::array_contains(scripts\apparition\menu\customization\preferences::values("scroll_time"), scroll_ms))
        return undefined;
    foreach (index in [8, 9, 10, 11, 12, 13])
    {
        if (fields[index] != "0" && fields[index] != "1")
            return undefined;
    }
    // Validate dependent choices before exposing a restored layout
    if (stealth_ui && (fields[5] == "Boxes" || fields[13] == "1"))
        return undefined;
    if ((fields[4] == "Native" || fields[4] == "Classic") && fields[11] == "1")
        return undefined;
    if ((fields[4] == "AIO" || fields[4] == "Basic") && fields[13] == "1")
        return undefined;
    color = scripts\apparition\menu\customization\palette::color(fields[14]);
    if (fields[14] != "Rainbow" && !isDefined(color))
        return undefined;
    open_controls = parse_controls(fields[15]);
    quick_controls = parse_controls(fields[16]);
    if (!isDefined(open_controls) || !isDefined(quick_controls))
        return undefined;

    // Fresh defaults discard editors, slider previews and pending animation work
    layout = scripts\apparition\menu\layout::defaults();
    layout.x = x;
    layout.y = y;
    layout.width = width;
    layout.design = fields[4];
    layout.bool_display = fields[5];
    layout.bool_location = fields[6];
    layout.scroll_time = scroll_ms / 1000.0;
    layout.quick_exit = fields[8] == "1";
    layout.disable_quick_menu = fields[9] == "1";
    layout.spotlight_cursor = fields[10] == "1";
    layout.colored_cursor = fields[11] == "1";
    layout.large_cursor = fields[12] == "1";
    layout.option_counter = fields[13] == "1";
    layout.stealth_ui = stealth_ui;
    if (fields[0] == "3")
    {
        layout.instructions_x = instructions_x;
        layout.instructions_y = instructions_y;
        layout.disable_instructions = fields[20] == "1";
        layout.alternate_instructions = fields[21] == "1";
        layout.disable_instructions_background = fields[22] == "1";
        layout.adaptive_instructions = fields[23] == "1";
    }
    layout.smooth_rainbow = fields[14] == "Rainbow";
    if (!layout.smooth_rainbow)
        layout.accent = color;
    layout.open_controls = open_controls;
    layout.quick_controls = quick_controls;
    return layout;
}

parse_controls(text)
{
    commands = strTok(text, ",");
    if (commands.size == 0)
        return undefined;
    parsed = spawnstruct();
    parsed.open_controls = [];
    for (index = 0; index < commands.size; index++)
    {
        // Reuse the editor rules for catalog, slot, duplicate and offhand checks
        if (!scripts\apparition\menu\customization\bindings::apply(parsed, "Apparition", index + 1, commands[index]))
            return undefined;
    }
    // Empty tokens and the editor's None sentinel are not stored chord members
    return join(parsed.open_controls, ",") == text ? parsed.open_controls : undefined;
}

integer(text)
{
    if (!isDefined(text) || !isString(text) || text.size == 0)
        return undefined;
    negative = getSubStr(text, 0, 1) == "-";
    start = negative ? 1 : 0;
    if (start == text.size || text == "-0")
        return undefined;
    if (text.size - start > 1 && getSubStr(text, start, start + 1) == "0")
        return undefined;
    value = 0;
    for (index = start; index < text.size; index++)
    {
        character = getSubStr(text, index, index + 1);
        if (!isSubStr("0123456789", character))
            return undefined;
        digit = int(character);
        // Accumulating below zero also permits the full negative integer limit
        limit_digit = negative ? 8 : 7;
        if (value < -214748364 || (value == -214748364 && digit > limit_digit))
            return undefined;
        value = value * 10 - digit;
    }
    return negative ? value : -value;
}

join(values, separator)
{
    text = "";
    for (index = 0; index < values.size; index++)
        text += (index == 0 ? "" : separator) + values[index];
    return text;
}
