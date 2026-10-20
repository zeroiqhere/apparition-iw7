// Customization descriptors always act on the owner rather than a selected guest

run()
{
    instruction_rows_keep_source_order_owner_and_denial_reasons();
    root_rows_keep_source_order_and_owner_navigation();
    binding_rows_preserve_source_order_and_owner_scope();
    binding_rows_follow_selected_slot_and_proposal_reasons();
    binding_sliders_preview_without_changing_applied_selection();
    preferences_expose_applied_state_separately_from_slider_preview();
    design_restrictions_are_visible_in_preference_rows();
    stealth_row_keeps_source_position_and_owner_scope();
    stealth_rows_block_boxes_and_counter_without_hiding_other_choices();
    color_rows_bind_each_named_choice_and_read_the_applied_accent();
    color_rows_expose_the_applied_smooth_rainbow_mode();
}

stealth_row_keeps_source_position_and_owner_scope()
{
    view = view();
    rows = scripts\apparition\menu\model::build("Menu Preferences", view);
    tests\support\checks::expect(rows.size == 12 && rows[10].label == "Stealth UI" && rows[10].kind == "toggle",
        "Stealth UI keeps its source position after Option Counter");
    tests\support\checks::expect(rows[10].enabled && !rows[10].checked && rows[10].setting == "stealth_ui"
        && rows[10].target == view.owner && !rows[10].lobby
        && rows[10].callback == scripts\apparition\menu\actions::set_appearance,
        "Any verified owner can toggle the applied Stealth setting through appearance dispatch");
    scripts\apparition\menu\customization\preferences::apply(view.layout, "stealth_ui", undefined);
    rows = scripts\apparition\menu\model::build("Menu Preferences", view);
    tests\support\checks::expect(rows[10].checked && rows[10].enabled
        && rows[10].description == "Use five visible options with text indicators and no option counter",
        "The Stealth row reports the applied mode and its visible behavior");
}

stealth_rows_block_boxes_and_counter_without_hiding_other_choices()
{
    view = view();
    scripts\apparition\menu\customization\preferences::apply(view.layout, "stealth_ui", undefined);
    foreach (design in scripts\apparition\menu\customization\preferences::values("design"))
    {
        scripts\apparition\menu\customization\preferences::apply(view.layout, "design", design);
        rows = scripts\apparition\menu\model::build("Menu Preferences", view);
        tests\support\checks::expect(rows[1].enabled
            && scripts\apparition\menu\availability::choice_reason(rows[1], "Boxes") == "Boxes are unavailable while Stealth UI is enabled",
            "Only the Boxes choice is unavailable on the display slider while Stealth is active");
        tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(rows[1], "Text") == ""
            && scripts\apparition\menu\availability::choice_reason(rows[1], "Text Color") == "",
            "Both source text choices remain available for each design");
        tests\support\checks::expect(!rows[9].enabled && !rows[9].checked
            && rows[9].description == "Option Counter is unavailable while Stealth UI is enabled",
            "The Stealth counter restriction takes precedence over a design restriction");
    }
    // Rendering exposes restrictions without changing an applied preference
    tests\support\checks::expect(view.layout.stealth_ui && view.layout.bool_display == "Text" && !view.layout.option_counter,
        "Reading Stealth control rows leaves the applied settings unchanged");
    scripts\apparition\menu\customization\preferences::apply(view.layout, "stealth_ui", undefined);
    scripts\apparition\menu\customization\preferences::apply(view.layout, "design", "Apparition");
    rows = scripts\apparition\menu\model::build("Menu Preferences", view);
    tests\support\checks::expect(!rows[10].checked && rows[9].enabled
        && scripts\apparition\menu\availability::choice_reason(rows[1], "Boxes") == "",
        "Disabling Stealth restores the normal availability of Boxes and Option Counter");
}

view()
{
    view = spawnstruct();
    view.access = "Verified";
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.owner.apparition_hud = spawnstruct();
    view.owner.apparition_state = scripts\apparition\menu\state::create(view.owner);
    view.layout = scripts\apparition\menu\layout::defaults();
    return view;
}

root_rows_keep_source_order_and_owner_navigation()
{
    view = view();
    main = scripts\apparition\menu\model::build("Main", view);
    tests\support\checks::expect(main[1].target == view.owner, "Entering customization restores owner scope instead of the selected guest");
    view.owner.apparition_state.page = "Menu Customization";
    rows = scripts\apparition\menu\model::build("Menu Customization", view);
    tests\support\checks::expect(rows.size == 7 && rows[0].label == "Menu Credits" && rows[6].label == "Menu Preferences", "The source customization root keeps all seven entries in order");
    tests\support\checks::expect(rows[1].label == "Open Controls" && rows[1].kind == "submenu" && rows[1].destination == "Open Controls" && rows[1].enabled, "Open Controls opens the source binding editor");
    tests\support\checks::expect(rows[1].target == view.owner && !rows[1].lobby && rows[1].callback == scripts\apparition\menu\actions::open_page, "Open Controls is bound to its owning menu instead of a selected guest");
    tests\support\checks::expect(rows[5].label == "Main Design Color" && rows[5].destination == "Main Design Color", "The color page opens without applying a theme");
    tests\support\checks::expect(rows[5].target == view.owner && !rows[5].lobby, "Appearance navigation uses the owner's personal scope");
    tests\support\checks::expect(rows[2].enabled && rows[3].enabled, "The source Width Editor and Reposition Menu remain enabled after Open Controls");
    tests\support\checks::expect(rows[2].setting == "width_editor" && rows[2].callback == scripts\apparition\menu\customization\editor::begin, "Width Editor starts through its focused owner-scoped callback");
    tests\support\checks::expect(rows[2].target == view.owner && rows[2].session == view.owner.apparition_state && rows[2].hud == view.owner.apparition_hud && !rows[2].lobby, "Width Editor retains the owner, HUD and menu session used to build its row");
    tests\support\checks::expect(rows[3].label == "Reposition Menu" && rows[3].setting == "reposition_menu" && rows[3].callback == scripts\apparition\menu\customization\editor::begin, "Reposition Menu starts through the same owner-scoped editor callback");
    tests\support\checks::expect(rows[3].target == view.owner && rows[3].session == view.owner.apparition_state && rows[3].hud == view.owner.apparition_hud && !rows[3].lobby, "Reposition Menu retains the owner, HUD and menu session used to build its row");
}

binding_rows_preserve_source_order_and_owner_scope()
{
    view = view();
    commands = scripts\apparition\menu\customization\bindings::catalog();
    rows = scripts\apparition\menu\model::build("Open Controls", view);
    tests\support\checks::expect(commands.size == 13 && rows.size == 16, "The first binding slot shows its two selectors, separator and thirteen button choices");
    tests\support\checks::expect(rows[0].label == "Menu" && rows[0].setting == "binding_menu" && rows[0].kind == "slider", "Menu is the first binding selector");
    tests\support\checks::expect(rows[0].values.size == 2 && rows[0].values[0] == "Apparition" && rows[0].values[1] == "Quick Menu", "Menu choices preserve source order");
    tests\support\checks::expect(rows[1].label == "Bind Slot" && rows[1].setting == "binding_slot" && rows[1].kind == "slider", "Bind Slot is the second binding selector");
    tests\support\checks::expect(rows[1].values.size == 3 && rows[1].values[0] == 1 && rows[1].values[1] == 2 && rows[1].values[2] == 3, "Binding slots preserve source order");
    tests\support\checks::expect(rows[2].label == "" && !rows[2].enabled && !isDefined(rows[2].callback), "A blank read-only separator divides selectors from button choices");
    tests\support\checks::expect(rows[0].target == view.owner && rows[1].target == view.owner && !rows[0].lobby && !rows[1].lobby, "Both selectors use the menu owner's personal scope");
    tests\support\checks::expect(rows[0].callback == scripts\apparition\menu\actions::set_binding_selection && rows[1].callback == rows[0].callback, "Both selectors use the binding-specific application callback");
    for (index = 0; index < commands.size; index++)
    {
        row = rows[index + 3];
        tests\support\checks::expect(row.label == "[{" + commands[index] + "}]" && row.kind == "toggle", "Button choices keep the source command order and label syntax");
        tests\support\checks::expect(row.callback == scripts\apparition\menu\actions::set_open_binding && row.binding_type == "Apparition" && row.binding_slot == 1 && row.button == commands[index], "Each button row snapshots its type, slot and command");
        tests\support\checks::expect(row.target == view.owner && !row.lobby, "Button choices remain owner-scoped rather than targeting a selected guest");
    }
}

binding_rows_follow_selected_slot_and_proposal_reasons()
{
    view = view();
    commands = scripts\apparition\menu\customization\bindings::catalog();
    rows = scripts\apparition\menu\model::build("Open Controls", view);
    selected_row = undefined;
    duplicate_row = undefined;
    for (index = 0; index < commands.size; index++)
    {
        if (commands[index] == "+speed_throw")
            selected_row = rows[index + 3];
        if (commands[index] == "+melee")
            duplicate_row = rows[index + 3];
    }
    tests\support\checks::expect(selected_row.checked && selected_row.binding_slot == 1, "A button is checked only when it occupies the selected applied slot");
    proposal = scripts\apparition\menu\customization\bindings::proposal(view.layout, "Apparition", 1, "+melee");
    tests\support\checks::expect(!duplicate_row.checked && !duplicate_row.enabled && duplicate_row.description == proposal.reason, "A command used in another slot shows the binding proposal reason");

    view.layout.binding_slot = 2;
    rows = scripts\apparition\menu\model::build("Open Controls", view);
    tests\support\checks::expect(rows.size == 17 && rows[3].label == "None" && rows[3].button == "None" && !rows[3].checked, "None can clear an optional second slot without hiding its applied command");
    tests\support\checks::expect(rows[3].binding_type == "Apparition" && rows[3].binding_slot == 2 && rows[3].callback == scripts\apparition\menu\actions::set_open_binding, "None snapshots the selected type and optional slot");
    tests\support\checks::expect(rows[3].enabled && rows[3].description == "Clear the selected optional menu slot", "The None choice explains its clear action");

    view.layout.binding_slot = 3;
    rows = scripts\apparition\menu\model::build("Open Controls", view);
    tests\support\checks::expect(rows[3].label == "None" && rows[3].checked && rows[3].description == "Clear the selected optional menu slot", "None is checked when the selected optional slot has no applied command");
    view.layout.binding_slot = 1;
    rows = scripts\apparition\menu\model::build("Open Controls", view);
    tests\support\checks::expect(rows.size == 16 && rows[3].label != "None", "The required first slot cannot be cleared");
}

binding_sliders_preview_without_changing_applied_selection()
{
    view = view();
    rows = scripts\apparition\menu\model::build("Open Controls", view);
    state = scripts\apparition\menu\state::create(view.owner);
    state.page = "Open Controls";
    tests\support\checks::expect(rows[0].values.size == 2 && rows[0].values[0] == "Apparition" && rows[0].values[1] == "Quick Menu", "The menu slider uses binding values rather than appearance preferences");
    tests\support\checks::expect(rows[1].values.size == 3 && rows[1].values[0] == 1 && rows[1].values[2] == 3, "The slot slider uses binding values rather than appearance preferences");
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, rows[0]) == "Apparition" && scripts\apparition\menu\state::slider_value(state, rows[1]) == 1, "Binding selector previews start at the applied menu and slot");
    scripts\apparition\menu\state::adjust_slider(state, rows[0], 1);
    scripts\apparition\menu\state::adjust_slider(state, rows[1], 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, rows[0]) == "Quick Menu" && scripts\apparition\menu\state::slider_value(state, rows[1]) == 2, "Action slots change both binding previews independently");
    tests\support\checks::expect(view.layout.binding_menu == "Apparition" && view.layout.binding_slot == 1, "Previewing selectors does not commit editor selection before Use");
}

preferences_expose_applied_state_separately_from_slider_preview()
{
    view = view();
    view.layout.bool_display = "Text Color";
    rows = scripts\apparition\menu\model::build("Menu Preferences", view);
    tests\support\checks::expect(rows.size == 12 && rows[0].label == "Design" && rows[0].kind == "slider" && rows[0].enabled, "The source preference order exposes the applied design as a slider");
    tests\support\checks::expect(rows[0].setting == "design" && rows[0].values.size == 5 && rows[0].values[rows[0].initial_index] == "Apparition", "The design slider starts at the applied source design");
    tests\support\checks::expect(rows[1].setting == "bool_display" && rows[1].initial_index == 2, "A fresh display slider starts at its current applied mode");
    tests\support\checks::expect(rows[2].label == "Bool Box Location" && rows[3].values[rows[3].initial_index] == 120, "The box and scroll sliders show source defaults with correct time units");
    tests\support\checks::expect(rows[4].label == "Quick Exit [ Hold [{+melee}] ]" && rows[4].setting == "quick_exit" && !rows[4].checked, "Quick Exit keeps its source label, order and default state");
    tests\support\checks::expect(rows[5].label == "Disable Quick Menu" && rows[5].setting == "disable_quick_menu" && !rows[5].checked, "Disable Quick Menu keeps its source order and default state");
    tests\support\checks::expect(rows[6].checked && rows[7].checked && !rows[8].checked && !rows[9].checked, "Preference checkboxes read applied cursor and counter values");
    foreach (index in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    {
        tests\support\checks::expect(rows[index].enabled && rows[index].target == view.owner && !rows[index].lobby, "Visual preferences are personal and do not require host status");
        tests\support\checks::expect(rows[index].callback == scripts\apparition\menu\actions::set_appearance, "Visual preferences share one validated application path");
    }
    state = scripts\apparition\menu\state::create(view.owner);
    state.page = "Menu Preferences";
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, rows[0]) == "Apparition", "An untouched design preview starts at the applied design");
    scripts\apparition\menu\state::adjust_slider(state, rows[0], 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, rows[0]) == "Classic" && view.layout.design == "Apparition", "Changing design preview does not apply it before Use");
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, rows[1]) == "Text Color", "An untouched preview begins at the applied display mode");
    scripts\apparition\menu\state::adjust_slider(state, rows[1], 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, rows[1]) == "Boxes" && view.layout.bool_display == "Text Color", "Changing preview does not apply a preference before Use");
}

design_restrictions_are_visible_in_preference_rows()
{
    view = view();
    foreach (design in ["Native", "Classic"])
    {
        view.layout.design = design;
        view.layout.colored_cursor = false;
        view.layout.option_counter = false;
        rows = scripts\apparition\menu\model::build("Menu Preferences", view);
        tests\support\checks::expect(!rows[7].enabled && rows[7].description == "Colored Cursor is unavailable with the Native or Classic design", "Native and Classic explain why colored cursor is disabled");
        tests\support\checks::expect(rows[9].enabled, "Native and Classic keep the option counter available");
    }
    foreach (design in ["AIO", "Basic"])
    {
        view.layout.design = design;
        view.layout.colored_cursor = true;
        view.layout.option_counter = false;
        rows = scripts\apparition\menu\model::build("Menu Preferences", view);
        tests\support\checks::expect(rows[9].enabled == false && rows[9].description == "Option Counter is unavailable with the AIO or Basic design", "AIO and Basic explain why the option counter is disabled");
        tests\support\checks::expect(rows[7].enabled, "AIO and Basic keep colored cursor available");
    }
    view.layout.design = "Apparition";
    rows = scripts\apparition\menu\model::build("Menu Preferences", view);
    tests\support\checks::expect(rows[7].enabled && rows[9].enabled, "Apparition keeps both optional controls available");
}

color_rows_bind_each_named_choice_and_read_the_applied_accent()
{
    view = view();
    rows = scripts\apparition\menu\model::build("Main Design Color", view);
    tests\support\checks::expect(rows.size == 37 && rows[0].label == "Red" && rows[35].label == "Emerald", "All source named colors retain their order");
    tests\support\checks::expect(rows[6].checked && !rows[0].checked, "Only the applied Dodger Blue theme is checked by default");
    tests\support\checks::expect(rows[3].choice == "Black" && rows[3].setting == "theme" && rows[3].target == view.owner, "Black dispatches a named owner-only theme choice");
    tests\support\checks::expect(rows[36].enabled && rows[36].setting == "smooth_rainbow" && !rows[36].checked, "Smooth Rainbow is selectable and reflects its disabled state");
}

color_rows_expose_the_applied_smooth_rainbow_mode()
{
    view = view();
    view.layout.smooth_rainbow = true;
    rows = scripts\apparition\menu\model::build("Main Design Color", view);
    tests\support\checks::expect(rows[36].label == "Smooth Rainbow" && rows[36].checked, "The selected rainbow row shows the applied source mode");
    tests\support\checks::expect(!rows[0].checked && !rows[6].checked, "Named colors are unselected while rainbow mode controls the accent");
}

instruction_rows_keep_source_order_owner_and_denial_reasons()
{
    view = view();
    rows = scripts\apparition\menu\model::build("Menu Instructions", view);
    labels = ["Disable", "Alternate Style", "Disable Background", "Adaptive Position", "Reposition", "Reset Position"];
    tests\support\checks::expect(rows.size == 6, "Menu Instructions contains the six source controls");
    for (index = 0; index < labels.size; index++)
        tests\support\checks::expect(rows[index].label == labels[index] && rows[index].target == view.owner
            && !rows[index].lobby && rows[index].enabled, "Every instruction row belongs to the current menu owner");
    tests\support\checks::expect(rows[4].callback == scripts\apparition\menu\customization\editor::begin
        && rows[4].setting == "reposition_instructions" && rows[4].session == view.owner.apparition_state
        && rows[4].hud == view.owner.apparition_hud, "Reposition captures the exact owner session and HUD");
    view.layout.disable_instructions = true;
    view.layout.alternate_instructions = true;
    rows = scripts\apparition\menu\model::build("Menu Instructions", view);
    tests\support\checks::expect(rows[0].checked && rows[1].checked && !rows[3].enabled && !rows[4].enabled
        && rows[3].description == "Adaptive Position is unavailable with Alternate Style"
        && rows[4].description == "Enable menu instructions before repositioning"
        && rows[5].enabled, "Visible reasons match the action restrictions while Reset remains available");
}
