// Only named visual preferences can change the owner's existing layout

reopen_required(setting, old_design, new_design, old_counter)
{
    return setting == "option_counter" || (setting == "design" && old_design != new_design)
        || (setting == "stealth_ui" && old_counter);
}

values(setting)
{
    switch (setting)
    {
        case "design": return ["Apparition", "Classic", "Native", "AIO", "Basic"];
        case "bool_display": return ["Boxes", "Text", "Text Color"];
        case "bool_location": return ["Right", "Left"];
        // Source values 10 through 25 are multiplied by 0.01 seconds
        case "scroll_time": return [100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250];
    }
    return [];
}

apply(layout, setting, value)
{
    switch (setting)
    {
        case "theme":
            color = scripts\apparition\menu\customization\palette::color(value);
            if (!isDefined(color))
                return false;
            layout.smooth_rainbow = false;
            layout.accent = color;
            layout.theme_fade_pending = true;
            return true;
        case "smooth_rainbow":
            return scripts\apparition\menu\customization\theme::enable(layout);
        case "design":
            if (!isDefined(value) || !scripts\engine\utility::array_contains(values("design"), value))
                return false;
            // A repeated selection must preserve independent preference choices
            if (layout.design == value)
                return true;
            layout.design = value;
            if (value == "Native" || value == "Classic")
                layout.colored_cursor = false;
            if (value == "AIO" || value == "Basic")
                layout.option_counter = false;
            return true;
        case "bool_display":
        case "bool_location":
        case "scroll_time":
            if (!isDefined(value) || !scripts\engine\utility::array_contains(values(setting), value))
                return false;
            // A queued Boxes choice must still respect the current Stealth setting
            if (setting == "bool_display" && value == "Boxes" && layout.stealth_ui)
                return false;
            if (setting == "bool_display")
                layout.bool_display = value;
            else if (setting == "bool_location")
                layout.bool_location = value;
            else
                layout.scroll_time = value / 1000.0;
            return true;
        // Toggle current state rather than trusting the earlier displayed checkbox
        case "spotlight_cursor": layout.spotlight_cursor = !layout.spotlight_cursor; return true;
        case "colored_cursor":
            next_state = !layout.colored_cursor;
            if (next_state && (layout.design == "Native" || layout.design == "Classic"))
                return false;
            layout.colored_cursor = next_state;
            return true;
        case "large_cursor": layout.large_cursor = !layout.large_cursor; return true;
        case "option_counter":
            next_state = !layout.option_counter;
            if (next_state && (layout.stealth_ui || layout.design == "AIO" || layout.design == "Basic"))
                return false;
            layout.option_counter = next_state;
            return true;
        case "stealth_ui":
            layout.stealth_ui = !layout.stealth_ui;
            if (layout.stealth_ui && layout.bool_display == "Boxes")
                layout.bool_display = "Text";
            // Source does not restore these preferences when Stealth is turned off
            layout.option_counter = false;
            return true;
        case "disable_instructions": layout.disable_instructions = !layout.disable_instructions; return true;
        case "disable_instructions_background":
            layout.disable_instructions_background = !layout.disable_instructions_background;
            return true;
        case "alternate_instructions":
            layout.alternate_instructions = !layout.alternate_instructions;
            // Either style transition clears Adaptive and restores its source origin
            layout.adaptive_instructions = false;
            return scripts\apparition\menu\instructions::reset_position(layout);
        case "adaptive_instructions":
            if (layout.alternate_instructions)
                return false;
            layout.adaptive_instructions = !layout.adaptive_instructions;
            return true;
        case "reset_instructions": return scripts\apparition\menu\instructions::reset_position(layout);
        case "quick_exit": layout.quick_exit = !layout.quick_exit; return true;
        case "disable_quick_menu": layout.disable_quick_menu = !layout.disable_quick_menu; return true;
    }
    return false;
}
