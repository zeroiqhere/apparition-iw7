// Applied source geometry stays independent from game HUD objects

defaults()
{
    layout = spawnstruct();
    layout.x = 0;
    layout.y = 85;
    layout.width = 260;
    layout.design = "Apparition";
    layout.row_height = 18;
    layout.scroll_time = 0.12;
    layout.quick_exit = false;
    layout.disable_quick_menu = false;
    // Instruction placement remains independent from the main menu origin
    layout.instructions_x = 255;
    layout.instructions_y = 472;
    layout.disable_instructions = false;
    layout.alternate_instructions = false;
    layout.disable_instructions_background = false;
    layout.adaptive_instructions = false;
    // Applied chords remain separate from the editor menu and slot selections
    layout.open_controls = ["+speed_throw", "+melee"];
    layout.quick_controls = ["+speed_throw", "+smoke"];
    layout.binding_menu = "Apparition";
    layout.binding_slot = 1;
    layout.active_editor = undefined;
    layout.accent = scripts\apparition\menu\customization\palette::color("Dodger Blue");
    layout.smooth_rainbow = false;
    layout.theme_fade_pending = false;
    layout.bool_display = "Boxes";
    layout.bool_location = "Right";
    layout.spotlight_cursor = true;
    layout.colored_cursor = true;
    layout.large_cursor = false;
    layout.option_counter = false;
    layout.stealth_ui = false;
    return layout;
}

capacity(layout)
{
    // Source Stealth UI uses a fixed window before the other capacity choices
    if (layout.stealth_ui)
        return 5;
    // Text indicators allow two extra rows; the counter reserves two rows
    return 12 - (layout.bool_display == "Boxes" ? 2 : 0) - (layout.option_counter ? 2 : 0)
        + (layout.disable_instructions ? (layout.bool_display == "Boxes" ? 1 : 2) : 0);
}

panel_height(row_count, layout)
{
    // Final source resize adds design padding after the visible row blocks
    padding = layout.design == "Classic" ? 7 : layout.design == "AIO" ? 13 : layout.design == "Basic" ? 22 : 0;
    return min(row_count, capacity(layout)) * layout.row_height + padding;
}

row_y(visible_index, layout)
{
    // Basic keeps room for its title inside the panel
    offset = layout.design == "Classic" ? 11 : layout.design == "AIO" ? 15 : layout.design == "Basic" ? 30 : 8;
    return layout.y + offset + visible_index * layout.row_height;
}

value_x(layout)
{
    return layout.x + layout.width - 4;
}

fixed_panel_height(mode)
{
    if (mode == "keyboard")
        return 130;
    if (mode == "numberpad")
        return 58;
    if (mode == "credits")
        return 220;
    if (mode == "instructions")
        return 20;
    if (mode == "width")
        return 120;
    if (mode == "reposition")
        return 122;
    return undefined;
}

wrap_description(description, width)
{
    result = "";
    line = "";
    foreach (word in strTok(description, " "))
    {
        if (line.size > 0 && line.size + word.size + 1 > width)
        {
            result += line + "\n";
            line = word;
        }
        else
            line += (line.size > 0 ? " " : "") + word;
    }
    return result + line;
}
