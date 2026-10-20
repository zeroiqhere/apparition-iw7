// Customization controls retain source labels and always bind the menu owner

root_rows(view)
{
    rows = [];
    // Returning from another player's page keeps customization on this menu owner
    rows[rows.size] = scripts\apparition\menu\model::link("Menu Credits", "Credits", view.owner);
    rows[rows.size] = scripts\apparition\menu\model::link("Open Controls", "Open Controls", view.owner);
    width_editor = scripts\apparition\menu\model::action("Width Editor", scripts\apparition\menu\customization\editor::begin, view.owner, false);
    width_editor.setting = "width_editor";
    width_editor.session = view.owner.apparition_state;
    width_editor.hud = view.owner.apparition_hud;
    width_editor.description = "Change this owner's menu width";
    rows[rows.size] = width_editor;
    reposition = scripts\apparition\menu\model::action("Reposition Menu", scripts\apparition\menu\customization\editor::begin, view.owner, false);
    reposition.setting = "reposition_menu";
    reposition.session = view.owner.apparition_state;
    reposition.hud = view.owner.apparition_hud;
    reposition.description = "Reposition this owner's menu";
    rows[rows.size] = reposition;
    rows[rows.size] = scripts\apparition\menu\model::link("Menu Instructions", "Menu Instructions", view.owner);
    rows[rows.size] = scripts\apparition\menu\model::link("Main Design Color", "Main Design Color", view.owner);
    rows[rows.size] = scripts\apparition\menu\model::link("Menu Preferences", "Menu Preferences", view.owner);
    return rows;
}

instruction_rows(view)
{
    layout = view.layout;
    rows = [];
    rows[rows.size] = toggle_row("Disable", "disable_instructions", layout.disable_instructions, view.owner);
    rows[rows.size] = toggle_row("Alternate Style", "alternate_instructions", layout.alternate_instructions, view.owner);
    rows[rows.size] = toggle_row("Disable Background", "disable_instructions_background", layout.disable_instructions_background, view.owner);
    adaptive = toggle_row("Adaptive Position", "adaptive_instructions", layout.adaptive_instructions, view.owner);
    adaptive.enabled = !layout.alternate_instructions;
    if (!adaptive.enabled)
        adaptive.description = "Adaptive Position is unavailable with Alternate Style";
    rows[rows.size] = adaptive;
    reposition = scripts\apparition\menu\model::action("Reposition", scripts\apparition\menu\customization\editor::begin, view.owner, false);
    reposition.setting = "reposition_instructions";
    // Delayed selections remain bound to the page and HUD that offered the action
    reposition.session = view.owner.apparition_state;
    reposition.hud = view.owner.apparition_hud;
    reposition.enabled = !layout.disable_instructions;
    reposition.description = reposition.enabled ? "Move instructions with Action Slots 1 through 4; Melee exits"
        : "Enable menu instructions before repositioning";
    rows[rows.size] = reposition;
    reset = scripts\apparition\menu\model::action("Reset Position", scripts\apparition\menu\actions::set_appearance, view.owner, false);
    reset.setting = "reset_instructions";
    reset.description = "Restore the source instruction position for the applied style";
    rows[rows.size] = reset;
    return rows;
}

binding_rows(view)
{
    layout = view.layout;
    menu_type = layout.binding_menu;
    slot = layout.binding_slot;
    controls = scripts\apparition\menu\customization\bindings::controls(layout, menu_type);
    commands = scripts\apparition\menu\customization\bindings::catalog();
    rows = [];
    rows[rows.size] = binding_choice_row("Menu", "binding_menu", menu_type, view.owner);
    rows[rows.size] = binding_choice_row("Bind Slot", "binding_slot", slot, view.owner);
    rows[rows.size] = scripts\apparition\menu\model::unavailable("", "");

    if (slot == 2 || slot == 3)
    {
        row = binding_toggle_row("None", menu_type, slot, "None", controls, layout, view.owner);
        rows[rows.size] = row;
    }
    foreach (button in commands)
    {
        row = binding_toggle_row("[{" + button + "}]", menu_type, slot, button, controls, layout, view.owner);
        rows[rows.size] = row;
    }
    return rows;
}

preference_rows(view)
{
    layout = view.layout;
    rows = [];
    // Descriptors expose applied values while navigation owns uncommitted previews
    rows[rows.size] = choice_row("Design", "design", layout.design, view.owner);
    bool_display = choice_row("Bool Display", "bool_display", layout.bool_display, view.owner);
    if (layout.stealth_ui)
    {
        // Other display choices remain available while the source Boxes choice is blocked
        bool_display.choice_reasons = [];
        foreach (choice in bool_display.values)
            bool_display.choice_reasons[choice] = choice == "Boxes"
                ? "Boxes are unavailable while Stealth UI is enabled" : "";
    }
    rows[rows.size] = bool_display;
    rows[rows.size] = choice_row("Bool Box Location", "bool_location", layout.bool_location, view.owner);
    rows[rows.size] = choice_row("Scroll Animation Time (ms)", "scroll_time", int(layout.scroll_time * 1000 + 0.5), view.owner);
    quick_exit = toggle_row("Quick Exit [ Hold [{+melee}] ]", "quick_exit", layout.quick_exit, view.owner);
    quick_exit.description = "Hold Melee in a submenu to close the menu; a short press goes back";
    rows[rows.size] = quick_exit;
    disable_quick = toggle_row("Disable Quick Menu", "disable_quick_menu", layout.disable_quick_menu, view.owner);
    disable_quick.description = "Block the quick opening chord while keeping normal menu controls available";
    rows[rows.size] = disable_quick;
    rows[rows.size] = toggle_row("Spotlight Cursor", "spotlight_cursor", layout.spotlight_cursor, view.owner);
    colored_cursor = toggle_row("Colored Cursor", "colored_cursor", layout.colored_cursor, view.owner);
    if (layout.design == "Native" || layout.design == "Classic")
    {
        colored_cursor.enabled = false;
        colored_cursor.description = "Colored Cursor is unavailable with the Native or Classic design";
    }
    rows[rows.size] = colored_cursor;
    rows[rows.size] = toggle_row("Large Cursor", "large_cursor", layout.large_cursor, view.owner);
    option_counter = toggle_row("Option Counter", "option_counter", layout.option_counter, view.owner);
    if (layout.stealth_ui)
    {
        option_counter.enabled = false;
        option_counter.description = "Option Counter is unavailable while Stealth UI is enabled";
    }
    else if (layout.design == "AIO" || layout.design == "Basic")
    {
        option_counter.enabled = false;
        option_counter.description = "Option Counter is unavailable with the AIO or Basic design";
    }
    rows[rows.size] = option_counter;
    stealth = toggle_row("Stealth UI", "stealth_ui", layout.stealth_ui, view.owner);
    stealth.description = "Use five visible options with text indicators and no option counter";
    rows[rows.size] = stealth;
    rows[rows.size] = scripts\apparition\menu\model::unavailable("No Target While In Menu");
    return rows;
}

color_rows(view)
{
    rows = [];
    foreach (entry in scripts\apparition\menu\customization\palette::catalog())
    {
        // Names select validated catalog values rather than accepting arbitrary RGB input
        row = toggle_row(entry.name, "theme", !view.layout.smooth_rainbow && view.layout.accent == entry.color, view.owner);
        row.choice = entry.name;
        row.description = "Apply " + entry.name + " to the title, accent lines, checked boxes and selected text";
        rows[rows.size] = row;
    }
    row = toggle_row("Smooth Rainbow", "smooth_rainbow", view.layout.smooth_rainbow, view.owner);
    row.description = "Enable the shared source rainbow; select a named color to stop it";
    rows[rows.size] = row;
    return rows;
}

choice_row(label, setting, current, owner)
{
    row = scripts\apparition\menu\model::action(label, scripts\apparition\menu\actions::set_appearance, owner, false);
    row.kind = "slider";
    row.setting = setting;
    row.values = scripts\apparition\menu\customization\preferences::values(setting);
    row.initial_index = 0;
    for (index = 0; index < row.values.size; index++)
    {
        if (row.values[index] == current)
            row.initial_index = index;
    }
    // A preview can move independently while this description still shows applied state
    row.description = "Active: " + current + "; Action Slots 3/4 preview, Use applies";
    return row;
}

binding_choice_row(label, setting, current, owner)
{
    row = scripts\apparition\menu\model::action(label, scripts\apparition\menu\actions::set_binding_selection, owner, false);
    row.kind = "slider";
    row.setting = setting;
    row.values = scripts\apparition\menu\customization\bindings::values(setting);
    row.initial_index = 0;
    for (index = 0; index < row.values.size; index++)
    {
        if (row.values[index] == current)
            row.initial_index = index;
    }
    row.description = "Current: " + current + "; Action Slots 3/4 preview, Use applies";
    return row;
}

binding_toggle_row(label, menu_type, slot, button, controls, layout, owner)
{
    row = scripts\apparition\menu\model::action(label, scripts\apparition\menu\actions::set_open_binding, owner, false);
    row.kind = "toggle";
    row.binding_type = menu_type;
    row.binding_slot = slot;
    row.button = button;
    current = controls[slot - 1];
    row.checked = isDefined(current) && current == button;
    if (button == "None")
        row.checked = !isDefined(current);
    proposal = scripts\apparition\menu\customization\bindings::proposal(layout, menu_type, slot, button);
    row.enabled = proposal.reason == "";
    if (!row.enabled)
        row.description = proposal.reason;
    else if (button == "None")
        row.description = "Clear the selected optional menu slot";
    else
        row.description = "Apply this control to the selected menu slot";
    return row;
}

toggle_row(label, setting, checked, owner)
{
    row = scripts\apparition\menu\model::action(label, scripts\apparition\menu\actions::set_appearance, owner, false);
    row.kind = "toggle";
    row.setting = setting;
    // This snapshot draws the checkbox from the current applied choice
    row.checked = checked;
    row.description = "Apply this visual preference to the current owner's menu";
    return row;
}
