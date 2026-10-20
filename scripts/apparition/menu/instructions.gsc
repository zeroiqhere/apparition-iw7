// Instruction copy and geometry mirror the pinned menu source

text(layout, alive, open, override)
{
    // Disabled presentation has no guide text to format
    if (layout.disable_instructions)
        return "";
    alternate = layout.alternate_instructions;
    if (alive)
    {
        // Custom copy replaces source controls only for a live player
        if (isDefined(override))
            return format(override, alternate);
        if (open)
            return format(["[{+attack}]/[{+speed_throw}]/[{+actionslot 1}]/[{+actionslot 2}]: Scroll",
                "[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right", "[{+activate}]: Select",
                "[{+melee}]: Go Back/Exit"], alternate);
        message = join_controls(layout.open_controls) + ": Open Apparition";
        // The second line follows the active Quick Menu preference
        if (!layout.disable_quick_menu)
            message += "\n" + join_controls(layout.quick_controls) + ": Open Quick Menu";
        return format(message, alternate);
    }
    if (open)
        return format(["[{+attack}]/[{+speed_throw}]: Scroll", "[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right",
            "[{+activate}]: Select", "[{+gostand}]: Go Back/Exit"], alternate);
    if (layout.disable_quick_menu)
        return "";
    return join_controls(scripts\apparition\menu\customization\bindings::dead_controls()) + ": Open Quick Menu";
}

format(value, alternate)
{
    // Missing copy behaves like an empty instruction string
    if (!isDefined(value))
        return "";
    if (!isArray(value))
    {
        if (value == "" || !isSubStr(value, "\n") || !alternate)
            return value;
        lines = strTok(value, "\n");
        result = "";
        for (index = 0; index < lines.size; index++)
        {
            // Alternate mode drops blank lines before joining
            if (lines[index] == "")
                continue;
            result += (result == "" ? "" : "  |  ") + lines[index];
        }
        return result;
    }
    result = "";
    for (index = 0; index < value.size; index++)
    {
        if (index > 0)
            result += alternate ? "  |  " : "\n";
        result += value[index];
    }
    return result;
}

reset_position(layout)
{
    // Alternate instructions use a centered reset position
    layout.instructions_x = layout.alternate_instructions ? 320 : 255;
    layout.instructions_y = 472;
    return true;
}

plan(layout, message, gamepad, panel, open, repositioning)
{
    message = isDefined(message) ? message : "";
    alternate = layout.alternate_instructions;
    has_background = !layout.disable_instructions_background;
    width = text_width(message, gamepad) - (alternate ? 28 : 0);
    height = correct_nl_bg_height(message) - (isSubStr(message, "\n") ? 5 : 0);
    offsets = design_offsets(layout.design);
    x = layout.instructions_x;
    y = layout.instructions_y - height;
    // Adaptive placement follows the menu only while it is open and not being moved
    if (open && layout.adaptive_instructions && !repositioning)
    {
        if (isDefined(panel))
        {
            menu_width = panel.width + offsets.width;
            x = panel.x + offsets.x;
            y = panel.y + panel.height + offsets.y;
        }
        else
        {
            // Without an active panel the source falls back to menu width and x only
            menu_width = layout.width + offsets.width;
            x = layout.x + offsets.x;
        }
        if (width < menu_width)
            width = menu_width;
    }
    result = spawnstruct();
    result.message = message;
    result.shape = layout.design + "|" + int(alternate) + "|" + int(!has_background);
    result.x = x;
    result.y = y;
    result.width = width;
    result.height = height;
    result.outline_x = alternate ? x : x - 1;
    result.outline_y = alternate ? y : y - 1;
    result.text_x = alternate ? x : x + 1;
    result.text_y = alternate ? y : y + 6;
    result.align = alternate ? "CENTER" : "TOP_LEFT";
    result.text_align = alternate && has_background ? "CENTER" : "LEFT";
    result.background = has_background;
    result.bg_color = background_color(layout.design);
    result.bg_alpha = layout.design == "Classic" ? 0.85 : 1;
    result.color_role = layout.design == "AIO" ? "background" : "outline";
    return result;
}

join_controls(controls)
{
    result = "";
    for (index = 0; index < controls.size; index++)
        result += (index == 0 ? "" : " & ") + "[{" + controls[index] + "}]";
    return result;
}

design_offsets(design)
{
    result = spawnstruct();
    // Each design keeps its original relationship to the menu panel
    switch (design)
    {
        case "Basic":
        case "Classic":
            result.y = 5;
            result.x = 0;
            result.width = 0;
            break;
        case "AIO":
            result.y = 30;
            result.x = -1;
            result.width = 2;
            break;
        case "Native":
            result.y = 5;
            result.x = 1;
            result.width = -2;
            break;
        default:
            result.y = 18;
            result.x = 1;
            result.width = -2;
            break;
    }
    return result;
}

background_color(design)
{
    if (design == "Classic")
        return (25 / 255.0, 25 / 255.0, 25 / 255.0);
    if (design == "Apparition")
        return (42 / 255.0, 42 / 255.0, 42 / 255.0);
    return (0, 0, 0);
}

text_width(message, gamepad)
{
    if (message == "")
        return 1;
    // Button markup changes the width scale even when it is not on the widest line
    has_buttons = isSubStr(message, "[{");
    width_scale = has_buttons ? (gamepad ? 6 : 7) : 5;
    lines = strTok(message, "\n");
    longest = 0;
    longest_size = 0;
    for (line = 0; line < lines.size; line++)
    {
        stripped = strip_string_buttons(lines[line]);
        // Equal line widths select the later source line
        if (stripped.size >= longest_size)
        {
            longest = line;
            longest_size = stripped.size;
        }
    }
    source_line = lines[longest];
    stripped_line = strip_string_buttons(source_line);
    width = 1;
    for (index = 0; index < stripped_line.size; index++)
        width += character_width(stripped_line[index], width_scale);
    width += int(width_scale * 1.5) * count_button_codes(source_line);
    return width;
}

character_width(character, width_scale)
{
    if (is_small_char(character))
        return 0;
    if (character == "/" || character == ":" || character == "-" || character == "&" || character == " ")
        return int(width_scale * 0.6);
    return width_scale;
}

count_button_codes(text)
{
    count = 0;
    for (index = 0; index < text.size - 1; index++)
    {
        if (text[index] == "[" && text[index + 1] == "{")
            count++;
    }
    return count;
}

strip_string_buttons(text)
{
    result = "";
    for (index = 0; index < text.size; index++)
    {
        // Button tokens disappear from visible width but still count separately
        if (index < text.size - 1 && text[index] == "[" && text[index + 1] == "{")
        {
            for (end = index + 2; end < text.size; end++)
            {
                if (end < text.size - 1 && text[end] == "}" && text[end + 1] == "]")
                {
                    index = end + 1;
                    break;
                }
            }
            continue;
        }
        if (index < text.size - 1 && is_code_chars(text[index] + text[index + 1]))
        {
            index++;
            continue;
        }
        if (!is_small_char(text[index]))
            result += text[index];
    }
    return result;
}

is_code_chars(value)
{
    return value == "^A" || value == "^B" || value == "^F" || value == "^H" || value == "^I"
        || value == "^0" || value == "^1" || value == "^2" || value == "^3" || value == "^4"
        || value == "^5" || value == "^6" || value == "^7" || value == "^8" || value == "^9";
}

is_small_char(character)
{
    return character == "[" || character == "]" || character == "." || character == "," || character == "'"
        || character == "!" || character == "{" || character == "}" || character == "|";
}

correct_nl_bg_height(text)
{
    // Single-line copy uses its fixed source height
    if (!isSubStr(text, "\n"))
        return 12;
    // Tokenizing matches the source count of nonempty lines
    lines = strTok(text, "\n");
    return 3 + (14 * lines.size);
}
