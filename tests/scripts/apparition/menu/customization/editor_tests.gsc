// Customization editors share one temporary owner-scoped modal

run()
{
    instruction_input_waits_for_the_initial_settle_deadline();
    editor_resume_rejects_changed_hud_page_role_or_grant();
    instructions_editor_requires_its_page_and_fixed_step();
    source_width_bounds_and_steps_are_preserved();
    source_offset_bounds_and_mode_instructions_are_preserved();
    reposition_moves_only_the_requested_axis_by_the_current_step();
    reposition_translates_every_hud_element();
    reposition_without_an_outgoing_group_moves_current_rows();
    modal_reposition_moves_fixed_elements_without_option_groups();
    editor_rows_require_their_owner_and_original_menu_session();
    normal_hud_render_stays_suppressed_during_modal_edits();
}

modal_reposition_moves_fixed_elements_without_option_groups()
{
    hud = translation_hud();
    hud.rows = [];
    hud.spare = undefined;
    tests\support\checks::expect(scripts\apparition\menu\hud::translate(hud, -4, 6),
        "A modal HUD accepts repositioning after option groups have been released");
    tests\support\checks::expect(hud.auxiliary.x == 46 && hud.auxiliary.y == 66
        && hud.rows.size == 0 && !isDefined(hud.spare),
        "Modal reposition moves fixed elements without recreating option ownership");
}

source_width_bounds_and_steps_are_preserved()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(layout.width == 260, "The source default width is retained");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::width_after(260, 3, "increase") == 263, "Attack increases width by the selected offset");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::width_after(260, 3, "decrease") == 257, "ADS decreases width by the selected offset");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::width_after(499, 3, "increase") == 500, "Attack clamps the upper edge to 500");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::width_after(200, 3, "decrease") == 200, "ADS clamps the lower edge to 200");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::width_after(500, 1, "increase") == 500, "Attack at the upper edge does not change the width");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::width_after(200, 1, "decrease") == 200, "ADS at the lower edge does not change the width");
}

source_offset_bounds_and_mode_instructions_are_preserved()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::offset_after(1, "decrease") == 1, "The source offset cannot fall below one");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::offset_after(10, "increase") == 10, "The source offset cannot exceed ten");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::offset_after(4, "decrease") == 3 && scripts\apparition\menu\customization\editor::offset_after(4, "increase") == 5, "Decrease and increase move the step by one");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::mode_for_setting("width_editor") == "width" && scripts\apparition\menu\customization\editor::mode_for_setting("reposition_menu") == "reposition", "The two source rows select distinct modes in one editor session");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::create_session("reposition", spawnstruct()).mode == "reposition", "The canonical active editor records its mode");
    active = scripts\apparition\menu\customization\editor::create_session("width", spawnstruct());
    tests\support\checks::expect(active.offset == 1 && isDefined(active.session), "Every modal starts with one step and captures its menu session");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::instructions("width") == "[{+attack}] - Increase Width\n[{+speed_throw}] - Decrease Width\n[{+actionslot 4}] - Increase Offset\n[{+actionslot 3}] - Decrease Offset\n[{+melee}] - Exit", "Width instructions retain the source bindings and order");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::instructions("reposition") == "[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right\n[{+frag}] - Increase Offset\n[{+smoke}] - Decrease Offset\n[{+melee}] - Exit", "Reposition instructions retain the source bindings and order");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::instructions_y(layout, "width") == layout.y + 25 && scripts\apparition\menu\customization\editor::offset_y(layout, "width") == layout.y + 98, "Width instructions and offset use the source five-line geometry");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::instructions_y(layout, "reposition") == layout.y + 22 && scripts\apparition\menu\customization\editor::offset_y(layout, "reposition") == layout.y + 113, "Reposition instructions and offset use the source seven-line geometry");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::offset_value_x(layout) == layout.x + 48, "The offset number follows the source label-width adjustment");
}

reposition_moves_only_the_requested_axis_by_the_current_step()
{
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::position_after(10, 20, "move_up", 3).y == 17, "Action Slot 1 moves the whole menu up by the selected step");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::position_after(10, 20, "move_down", 3).y == 23, "Action Slot 2 moves the whole menu down by the selected step");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::position_after(10, 20, "move_left", 3).x == 7, "Action Slot 3 moves the whole menu left by the selected step");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::position_after(10, 20, "move_right", 3).x == 13, "Action Slot 4 moves the whole menu right by the selected step");
    position = scripts\apparition\menu\customization\editor::position_after(10, 20, "none", 3);
    tests\support\checks::expect(position.x == 10 && position.y == 20, "An unrelated command leaves the saved menu origin unchanged");
}

reposition_translates_every_hud_element()
{
    hud = translation_hud();
    tests\support\checks::expect(scripts\apparition\menu\hud::translate(hud, -3, 5), "An active HUD accepts a reposition delta");
    for (index = 0; index < 12; index++)
        expect_translated_row(hud.rows[index], index, -3, 5);
    expect_translated_row(hud.spare, 12, -3, 5);
    tests\support\checks::expect(hud.auxiliary.x == 47 && hud.auxiliary.y == 65,
        "The same delta moves non-row HUD elements on both axes");
    first_row_y = hud.rows[0].requested_y;
    first_label_x = hud.rows[0].elements["label"].x;
    first_label_y = hud.rows[0].elements["label"].y;
    auxiliary_x = hud.auxiliary.x;
    auxiliary_y = hud.auxiliary.y;
    hud.released = true;
    tests\support\checks::expect(!scripts\apparition\menu\hud::translate(hud, 2, 2), "A released HUD rejects later position updates");
    tests\support\checks::expect(hud.rows[0].requested_y == first_row_y
        && hud.rows[0].elements["label"].x == first_label_x && hud.rows[0].elements["label"].y == first_label_y
        && hud.auxiliary.x == auxiliary_x && hud.auxiliary.y == auxiliary_y,
        "A released HUD keeps its final row targets and native positions");
}

translation_hud()
{
    hud = spawnstruct();
    hud.released = false;
    hud.rows = [];
    hud.fixed_elements = [];
    for (index = 0; index < 12; index++)
    {
        row = translation_row(index);
        hud.rows[index] = row;
    }
    hud.spare = translation_row(12);
    hud.auxiliary = spawnstruct();
    hud.auxiliary.x = 50;
    hud.auxiliary.y = 60;
    hud.fixed_elements[hud.fixed_elements.size] = hud.auxiliary;
    return hud;
}

translation_row(index)
{
    row = spawnstruct();
    row.elements = [];
    row.requested_y = 30 + index;
    row.elements["label"] = translation_element(10 + index, row.requested_y);
    row.elements["value"] = translation_element(20 + index, row.requested_y);
    row.elements["box"] = translation_element(30 + index, row.requested_y);
    row.elements["fill"] = translation_element(40 + index, row.requested_y);
    return row;
}

translation_element(x, y)
{
    element = spawnstruct();
    element.x = x;
    element.y = y;
    return element;
}

reposition_without_an_outgoing_group_moves_current_rows()
{
    hud = translation_hud();
    hud.spare = undefined;
    tests\support\checks::expect(scripts\apparition\menu\hud::translate(hud, 3, -5),
        "Reposition remains available after the outgoing row has retired");
    for (index = 0; index < hud.rows.size; index++)
        expect_translated_row(hud.rows[index], index, 3, -5);
    tests\support\checks::expect(hud.auxiliary.x == 53 && hud.auxiliary.y == 55,
        "Fixed elements move once when no outgoing row is present");
}

expect_translated_row(row, index, delta_x, delta_y)
{
    expected_y = 30 + index + delta_y;
    tests\support\checks::expect(row.requested_y == expected_y,
        "Reposition applies one Y delta to the active and spare row targets");
    tests\support\checks::expect(row.elements["label"].x == 10 + index + delta_x
        && row.elements["label"].y == expected_y && row.elements["value"].x == 20 + index + delta_x
        && row.elements["value"].y == expected_y && row.elements["box"].x == 30 + index + delta_x
        && row.elements["box"].y == expected_y && row.elements["fill"].x == 40 + index + delta_x
        && row.elements["fill"].y == expected_y,
        "Reposition moves every native element in each active and spare row group");
}

editor_rows_require_their_owner_and_original_menu_session()
{
    owner = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    state.page = "Menu Customization";
    layout = scripts\apparition\menu\layout::defaults();
    hud = spawnstruct();
    hud.owner = owner;
    hud.released = false;
    row = spawnstruct();
    row.elements = [];
    row.setting = "width_editor";
    row.target = owner;
    row.session = state;
    row.hud = hud;
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true), "A live Width Editor row can start for its current owner session");
    row.setting = "reposition_menu";
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true), "A live Reposition Menu row can start for its current owner session");
    state.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true), "A menu session targeting another actor cannot start an editor");
    state.target = owner;
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, false, true), "A closed owner cannot start an editor");
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, false), "A dead owner cannot start an editor");
    row.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true), "A row targeting another actor cannot start the owner's editor");
    row.target = owner;
    row.session = scripts\apparition\menu\state::create(owner);
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true), "A stale menu session cannot start an editor");
    row.session = state;
    row.hud = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true), "A stale HUD cannot start a replacement editor");
    row.hud = hud;
    hud.released = true;
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true), "A released HUD cannot start an editor");
    hud.released = false;
    layout.active_editor = scripts\apparition\menu\customization\editor::create_session("width", state);
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true), "A second editor cannot replace the current canonical modal session");
}

normal_hud_render_stays_suppressed_during_modal_edits()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\hud::normal_render_allowed(layout), "Normal HUD render remains available outside an editor");
    layout.active_editor = scripts\apparition\menu\customization\editor::create_session("reposition", spawnstruct());
    tests\support\checks::expect(!scripts\apparition\menu\hud::normal_render_allowed(layout), "Periodic refresh does not restore the title or rows during either modal");
}

instructions_editor_requires_its_page_and_fixed_step()
{
    owner = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    state.page = "Menu Instructions";
    hud = spawnstruct();
    hud.owner = owner;
    hud.released = false;
    layout = scripts\apparition\menu\layout::defaults();
    row = spawnstruct();
    row.setting = "reposition_instructions";
    row.target = owner;
    row.session = state;
    row.hud = hud;
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true),
        "The instruction editor accepts its current owner page and HUD");
    active = scripts\apparition\menu\customization\editor::create_session("instructions", state);
    tests\support\checks::expect(active.offset == 8 && active.session == state
        && scripts\apparition\menu\customization\editor::mode_for_setting(row.setting) == "instructions",
        "Instruction movement uses the source fixed eight-pixel step in one editor session");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::instructions("instructions")
        == "[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right\n[{+melee}] - Exit",
        "The persistent guide exposes only the instruction reposition controls");
    layout.disable_instructions = true;
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true),
        "A stale Reposition callback cannot run after instructions are disabled");
    layout.disable_instructions = false;
    state.page = "Menu Customization";
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::can_begin(row, state, hud, layout, true, true),
        "The instruction editor cannot begin on the menu-position page");
}

editor_resume_rejects_changed_hud_page_role_or_grant()
{
    owner = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    state.page = "Menu Instructions";
    hud = spawnstruct();
    hud.released = false;
    active = scripts\apparition\menu\customization\editor::create_session("instructions", state);
    active.hud = hud;
    active.access = "Verified";
    active.grant = spawnstruct();
    active.grant.access = "Verified";
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::same_session(active, state, hud, "Verified", active.grant),
        "The captured page HUD role and grant can resume their modal");
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::same_session(active, state, spawnstruct(), "Verified", active.grant),
        "A replaced HUD rejects the former modal before applying input");
    state.page = "Menu Customization";
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::same_session(active, state, hud, "Verified", active.grant),
        "Changing pages invalidates an instruction modal even within the same menu session");
    state.page = "Menu Instructions";
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::same_session(active, state, hud, "Admin", active.grant),
        "A changed role cannot inherit the former editor");
    replacement = spawnstruct();
    replacement.access = "Verified";
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::same_session(active, state, hud, "Verified", replacement),
        "A replacement grant with the same role cannot inherit the former editor");
    hud.released = true;
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::same_session(active, state, hud, "Verified", active.grant),
        "A released captured HUD rejects a delayed exit");
}

instruction_input_waits_for_the_initial_settle_deadline()
{
    active = scripts\apparition\menu\customization\editor::create_session("instructions", spawnstruct());
    active.ready_at = 1100;
    tests\support\checks::expect(!scripts\apparition\menu\customization\editor::input_ready(active, 1099),
        "Instruction movement remains idle before the initial one-hundred-millisecond settle");
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::input_ready(active, 1100)
        && scripts\apparition\menu\customization\editor::input_ready(active, 1101),
        "Instruction movement and nonadaptive placement start together at the settle deadline");
    width = scripts\apparition\menu\customization\editor::create_session("width", spawnstruct());
    tests\support\checks::expect(scripts\apparition\menu\customization\editor::input_ready(width, 0),
        "Width editing keeps its existing immediate input timing");
}
