// Row target checks use structs without creating client HUD elements

run()
{
    unchanged_target_does_not_rewrite_live_scale_during_a_fade();
    changed_target_without_fade_updates_both_text_elements_and_cache();
    unchanged_row_y_does_not_rewrite_live_positions_during_a_fade();
    changed_row_y_updates_each_element_and_the_requested_target();
    immediate_visual_sync_writes_text_fill_and_three_alpha_roles();
    unchanged_visual_targets_preserve_in_flight_values();
    undefined_style_updates_alpha_without_color_cache();
    immediate_color_only_sync_preserves_live_alpha();
    outgoing_alpha_request_preserves_color_targets();
    unchanged_alpha_targets_do_not_rewrite_live_values_during_a_fade();
    changed_alpha_targets_write_only_changed_roles();
    apply_frame_preserves_live_chrome_alpha_for_an_unchanged_request();
    apply_frame_writes_a_changed_chrome_alpha_target();
    repeated_release_does_not_revisit_closed_hud_handles();
    label_only_rows_move_and_scale_without_missing_handles();
    spacer_rows_move_style_and_fade_only_their_present_roles();
}

repeated_release_does_not_revisit_closed_hud_handles()
{
    hud = spawnstruct();
    hud.released = true;
    fixed = spawnstruct();
    row = row_writer_slot();
    spare = row_writer_slot();
    hud.fixed_elements = [fixed];
    hud.rows = [row];
    hud.spare = spare;
    // Plain handles would reject a native destroy if the released guard were lost
    scripts\apparition\menu\hud::release(hud);
    tests\support\checks::expect(hud.fixed_elements.size == 1 && hud.fixed_elements[0] == fixed
        && hud.rows.size == 1 && hud.rows[0] == row && hud.spare == spare,
        "A repeated release returns before visiting or clearing previously retired ownership");
}

unchanged_target_does_not_rewrite_live_scale_during_a_fade()
{
    slot = scale_slot();
    slot.requested_scale = 1.2;
    slot.elements["label"].fontScale = 0.75;
    slot.elements["value"].fontScale = 0.6;
    scripts\apparition\menu\hud::sync_scale(slot, 1.2, 0.25);
    tests\support\checks::expect(slot.elements["label"].fontScale == 0.75 && slot.elements["value"].fontScale == 0.6,
        "An unchanged scale request does not replace either live interpolated scale");
    tests\support\checks::expect(slot.requested_scale == 1.2,
        "An unchanged scale request leaves the canonical target intact");
    tests\support\checks::expect(slot.elements["label"].x == 14 && slot.elements["value"].alpha == 0.4 && slot.marker == "preserved",
        "An unchanged scale request leaves unrelated HUD state intact");
}

changed_target_without_fade_updates_both_text_elements_and_cache()
{
    slot = scale_slot();
    slot.elements["label"].fontScale = 0.8;
    slot.elements["value"].fontScale = 0.9;
    scripts\apparition\menu\hud::sync_scale(slot, 1.2, 0);
    tests\support\checks::expect(slot.elements["label"].fontScale == 1.2 && slot.elements["value"].fontScale == 1.2,
        "A changed immediate request assigns the same scale to both text elements");
    tests\support\checks::expect(slot.requested_scale == 1.2,
        "A changed immediate request updates its single requested target");
    tests\support\checks::expect(slot.elements["label"].x == 14 && slot.elements["value"].alpha == 0.4 && slot.marker == "preserved",
        "A changed scale request leaves unrelated HUD state intact");
}

scale_slot()
{
    slot = spawnstruct();
    slot.elements = [];
    slot.requested_scale = 1;
    slot.elements["label"] = spawnstruct();
    slot.elements["value"] = spawnstruct();
    slot.elements["label"].x = 14;
    slot.elements["value"].alpha = 0.4;
    slot.marker = "preserved";
    return slot;
}

unchanged_row_y_does_not_rewrite_live_positions_during_a_fade()
{
    slot = row_writer_slot();
    slot.elements["label"].y = 23;
    slot.elements["value"].y = 24;
    slot.elements["box"].y = 25;
    slot.elements["fill"].y = 26;
    scripts\apparition\menu\hud::move_row(slot, 20, 0.25);
    tests\support\checks::expect(slot.elements["label"].y == 23 && slot.elements["value"].y == 24
        && slot.elements["box"].y == 25 && slot.elements["fill"].y == 26,
        "An unchanged row target leaves all in-flight native positions intact");
    tests\support\checks::expect(slot.requested_y == 20,
        "An unchanged row target leaves its canonical requested position intact");
    tests\support\checks::expect(slot.elements["label"].x == 14 && slot.elements["value"].alpha == 0.2
        && slot.elements["box"].marker == "preserved" && slot.elements["fill"].x == 28,
        "An unchanged row target leaves unrelated element state intact");
}

changed_row_y_updates_each_element_and_the_requested_target()
{
    slot = row_writer_slot();
    scripts\apparition\menu\hud::move_row(slot, 35, 0);
    tests\support\checks::expect(slot.elements["label"].y == 35 && slot.elements["value"].y == 35
        && slot.elements["box"].y == 35 && slot.elements["fill"].y == 35,
        "An immediate row move updates label, value, box and fill positions");
    tests\support\checks::expect(slot.requested_y == 35,
        "An immediate row move records one canonical requested position");
    tests\support\checks::expect(slot.elements["label"].x == 14 && slot.elements["value"].alpha == 0.2
        && slot.elements["box"].marker == "preserved" && slot.elements["fill"].x == 28,
        "An immediate row move leaves unrelated element state intact");
}

immediate_visual_sync_writes_text_fill_and_three_alpha_roles()
{
    slot = row_writer_slot();
    style = visual_style((0, 1, 0), (0.5, 0.25, 0));
    scripts\apparition\menu\hud::sync_visuals(slot, style, [0.25, 0.5, 0.75, 0], 0, 0, 0, 0);
    tests\support\checks::expect(slot.elements["label"].color == style.color && slot.elements["value"].color == style.color
        && slot.elements["fill"].color == style.fill_color && slot.elements["box"].color == (0.25, 0.25, 0.25),
        "Immediate color sync updates both text targets and fill while preserving the box border color");
    tests\support\checks::expect(slot.elements["label"].alpha == 0.25 && slot.elements["value"].alpha == 0.5
        && slot.elements["box"].alpha == 0.75 && slot.elements["fill"].alpha == 0.75,
        "Three alpha targets update label, value and both checkbox elements");
    tests\support\checks::expect(slot.requested_colors.text == style.color
        && slot.requested_colors.fill == style.fill_color && slot.requested_alpha[0] == 0.25
        && slot.requested_alpha[1] == 0.5 && slot.requested_alpha[2] == 0.75,
        "Immediate visual sync stores one target for each color and alpha role");
}

unchanged_visual_targets_preserve_in_flight_values()
{
    slot = row_writer_slot();
    style = visual_style(slot.requested_colors.text, slot.requested_colors.fill);
    slot.elements["label"].color = (0.2, 0.3, 0.4);
    slot.elements["value"].color = (0.4, 0.3, 0.2);
    slot.elements["fill"].color = (0.3, 0.4, 0.2);
    slot.requested_alpha = [0.1, 0.2, 0.3, 0];
    slot.elements["label"].alpha = 0.9;
    slot.elements["value"].alpha = 0.8;
    slot.elements["box"].alpha = 0.7;
    slot.elements["fill"].alpha = 0.6;
    scripts\apparition\menu\hud::sync_visuals(slot, style, [0.1, 0.2, 0.3, 0], 0.12, 0.5, 0.12, 0);
    tests\support\checks::expect(slot.elements["label"].color == (0.2, 0.3, 0.4)
        && slot.elements["value"].color == (0.4, 0.3, 0.2) && slot.elements["fill"].color == (0.3, 0.4, 0.2),
        "Unchanged positive color requests leave in-flight native color values intact");
    tests\support\checks::expect(slot.elements["label"].alpha == 0.9 && slot.elements["value"].alpha == 0.8
        && slot.elements["box"].alpha == 0.7 && slot.elements["fill"].alpha == 0.6,
        "Unchanged positive alpha requests leave in-flight native alpha values intact");
}

undefined_style_updates_alpha_without_color_cache()
{
    slot = row_writer_slot();
    slot.requested_colors = undefined;
    scripts\apparition\menu\hud::sync_visuals(slot, undefined, [0.25, 0.5, 0.75, 0], 0, 0, 0, 0);
    tests\support\checks::expect(slot.elements["label"].alpha == 0.25 && slot.elements["value"].alpha == 0.5
        && slot.elements["box"].alpha == 0.75 && slot.elements["fill"].alpha == 0.75,
        "An alpha-only sync does not require or inspect the color target cache");
}

immediate_color_only_sync_preserves_live_alpha()
{
    slot = row_writer_slot();
    style = visual_style((0.75, 0.25, 0.5), (0.2, 0.6, 0.4));
    slot.elements["label"].alpha = 0.9;
    slot.elements["value"].alpha = 0.8;
    slot.elements["box"].alpha = 0.7;
    slot.elements["fill"].alpha = 0.6;
    scripts\apparition\menu\hud::sync_visuals(slot, style, [0, 0, 0, 0], 0, 0, 0.12, 0);
    tests\support\checks::expect(slot.elements["label"].color == style.color && slot.elements["value"].color == style.color
        && slot.elements["fill"].color == style.fill_color,
        "Immediate rainbow-shaped sync updates text and fill colors");
    tests\support\checks::expect(slot.elements["label"].alpha == 0.9 && slot.elements["value"].alpha == 0.8
        && slot.elements["box"].alpha == 0.7 && slot.elements["fill"].alpha == 0.6,
        "Immediate color sampling leaves unchanged live alpha values alone");
}

visual_style(color, fill_color)
{
    style = spawnstruct();
    style.color = color;
    style.fill_color = fill_color;
    return style;
}

unchanged_alpha_targets_do_not_rewrite_live_values_during_a_fade()
{
    slot = row_writer_slot();
    slot.requested_alpha = [0.1, 0.2, 0.3, 0];
    slot.elements["label"].alpha = 0.9;
    slot.elements["value"].alpha = 0.8;
    slot.elements["box"].alpha = 0.7;
    slot.elements["fill"].alpha = 0.6;
    scripts\apparition\menu\hud::sync_visuals(slot, undefined, [0.1, 0.2, 0.3, 0], 0, 0, 0.25, 0);
    tests\support\checks::expect(slot.elements["label"].alpha == 0.9 && slot.elements["value"].alpha == 0.8
        && slot.elements["box"].alpha == 0.7 && slot.elements["fill"].alpha == 0.6,
        "An unchanged alpha vector leaves all in-flight native values intact");
    tests\support\checks::expect(slot.requested_alpha[0] == 0.1
        && slot.requested_alpha[1] == 0.2 && slot.requested_alpha[2] == 0.3,
        "An unchanged alpha vector preserves label, value and shared checkbox targets");
    tests\support\checks::expect(slot.elements["label"].x == 14 && slot.elements["value"].y == 20
        && slot.elements["box"].marker == "preserved" && slot.elements["fill"].x == 28,
        "An unchanged alpha vector leaves unrelated element state intact");
}

changed_alpha_targets_write_only_changed_roles()
{
    slot = row_writer_slot();
    slot.requested_alpha = [0, 0.2, 0.4, 0];
    slot.elements["label"].alpha = 0.9;
    slot.elements["value"].alpha = 0.8;
    slot.elements["box"].alpha = 0.7;
    slot.elements["fill"].alpha = 0.6;
    scripts\apparition\menu\hud::sync_visuals(slot, undefined, [0.25, 0.2, 0.5, 0], 0, 0, 0, 0);
    tests\support\checks::expect(slot.elements["label"].alpha == 0.25 && slot.elements["value"].alpha == 0.8
        && slot.elements["box"].alpha == 0.5 && slot.elements["fill"].alpha == 0.5,
        "Immediate alpha sync writes both checkbox elements and preserves an unchanged value target");
    tests\support\checks::expect(slot.requested_alpha[0] == 0.25
        && slot.requested_alpha[1] == 0.2 && slot.requested_alpha[2] == 0.5,
        "Immediate alpha sync updates the canonical target for every role");
    tests\support\checks::expect(slot.elements["label"].x == 14 && slot.elements["value"].y == 20
        && slot.elements["box"].marker == "preserved" && slot.elements["fill"].x == 28,
        "Immediate alpha sync leaves unrelated element state intact");
}



apply_frame_preserves_live_chrome_alpha_for_an_unchanged_request()
{
    fixture = chrome_frame_fixture(0.7);
    scripts\apparition\menu\hud::apply_frame(fixture.hud, fixture.frame, false);
    tests\support\checks::expect(fixture.element.alpha == 0.3
        && fixture.hud.requested_chrome_alpha["title"] == 0.7,
        "An unchanged chrome alpha request preserves its in-flight value and cached target");
    tests\support\checks::expect(fixture.element.x == 20 && fixture.element.y == 30
        && fixture.element.sort == 7 && fixture.element.alignX == "center"
        && fixture.element.fontScale == 1.2,
        "A stable chrome alpha still applies the current position and font layout");
}

apply_frame_writes_a_changed_chrome_alpha_target()
{
    fixture = chrome_frame_fixture(0);
    scripts\apparition\menu\hud::apply_frame(fixture.hud, fixture.frame, false);
    tests\support\checks::expect(fixture.element.alpha == 0
        && fixture.hud.requested_chrome_alpha["title"] == 0,
        "A changed chrome alpha request updates the HUD field and canonical cache");
}

chrome_frame_fixture(alpha)
{
    fixture = spawnstruct();
    fixture.hud = spawnstruct();
    fixture.hud.chrome = [];
    fixture.hud.requested_chrome_alpha = [];
    fixture.element = spawnstruct();
    fixture.element.x = 10;
    fixture.element.y = 11;
    fixture.element.alpha = 0.3;
    fixture.element.sort = 1;
    fixture.element.alignX = "left";
    fixture.element.fontScale = 0.5;
    fixture.hud.chrome["title"] = fixture.element;
    fixture.hud.requested_chrome_alpha["title"] = 0.7;

    fixture.frame = spawnstruct();
    fixture.frame.roles = [];
    role = spawnstruct();
    role.x = 20;
    role.y = 30;
    role.alpha = alpha;
    role.sort = 7;
    role.align_x = "center";
    role.scale = 1.2;
    fixture.frame.roles["title"] = role;
    return fixture;
}

row_writer_slot()
{
    slot = spawnstruct();
    slot.elements = [];
    slot.requested_y = 20;
    slot.requested_alpha = [0, 0, 0, 0];
    slot.requested_colors = spawnstruct();
    slot.requested_colors.text = (1, 1, 1);
    slot.requested_colors.fill = (0, 0, 0);
    slot.elements["label"] = row_writer_element(14, 20, 0.1);
    slot.elements["value"] = row_writer_element(24, 20, 0.2);
    slot.elements["box"] = row_writer_element(28, 20, 0.3);
    slot.elements["fill"] = row_writer_element(28, 20, 0.4);
    slot.elements["label"].color = (1, 1, 1);
    slot.elements["value"].color = (1, 1, 1);
    slot.elements["box"].color = (0.25, 0.25, 0.25);
    slot.elements["fill"].color = (0, 0, 0);
    slot.elements["box"].marker = "preserved";
    return slot;
}

row_writer_element(x, y, alpha)
{
    element = spawnstruct();
    element.x = x;
    element.y = y;
    element.alpha = alpha;
    return element;
}



outgoing_alpha_request_preserves_color_targets()
{
    slot = row_writer_slot();
    slot.elements["label"].color = (0.2, 0.3, 0.4);
    scripts\apparition\menu\hud::sync_visuals(slot, undefined, [0, 0, 0, 0], 0, 0, 0.12, 0);
    tests\support\checks::expect(slot.requested_colors.text == (1, 1, 1)
        && slot.requested_colors.fill == (0, 0, 0) && slot.elements["label"].color == (0.2, 0.3, 0.4),
        "An outgoing alpha-only request leaves existing color targets and native colors intact");
}

label_only_rows_move_and_scale_without_missing_handles()
{
    slot = spawnstruct();
    slot.elements = [];
    slot.elements["label"] = row_writer_element(14, 20, 0);
    slot.requested_y = 20;
    slot.requested_scale = 1;
    slot.requested_alpha = [0, 0, 0, 0];
    slot.requested_colors = spawnstruct();
    slot.requested_colors.text = (1, 1, 1);
    scripts\apparition\menu\hud::move_row(slot, 40, 0);
    scripts\apparition\menu\hud::sync_scale(slot, 1.2, 0);
    scripts\apparition\menu\hud::sync_visuals(slot, visual_style((0, 1, 0), (0, 0, 0)), [1, 0, 0, 0], 0, 0, 0, 0);
    tests\support\checks::expect(slot.elements.size == 1 && slot.elements["label"].y == 40
        && slot.elements["label"].fontScale == 1.2 && slot.elements["label"].alpha == 1
        && slot.elements["label"].color == (0, 1, 0),
        "An action group updates only its present label without fabricating optional elements");
    tests\support\checks::expect(!isDefined(slot.requested_colors.fill) && !isDefined(slot.requested_colors.line),
        "An action group does not acquire unused rectangle color targets");
}

spacer_rows_move_style_and_fade_only_their_present_roles()
{
    slot = scale_slot();
    label = slot.elements["label"];
    slot.elements = [];
    slot.elements["label"] = label;
    slot.elements["invalid_line"] = row_writer_element(130, 20, 0.4);
    slot.elements["invalid_line"].color = (1, 0, 0);
    slot.elements["invalid_line"].fontScale = 7;
    slot.requested_y = 20;
    slot.requested_alpha = [0, 0, 0, 0.4];
    slot.requested_colors = spawnstruct();
    slot.requested_colors.text = (1, 1, 1);
    slot.requested_colors.line = (1, 0, 0);
    scripts\apparition\menu\hud::move_row(slot, 38, 0);
    scripts\apparition\menu\hud::sync_scale(slot, 1.2, 0);
    style = visual_style((0, 1, 0), (0, 0, 0));
    style.line_color = (0, 0, 1);
    scripts\apparition\menu\hud::sync_visuals(slot, style, [1, 0, 0, 0.4], 0, 0, 0, 0);
    tests\support\checks::expect(slot.elements["invalid_line"].y == 38
        && slot.elements["invalid_line"].fontScale == 7 && slot.elements["invalid_line"].color == (0, 0, 1)
        && slot.elements["invalid_line"].alpha == 0.4 && slot.requested_colors.line == (0, 0, 1),
        "A spacer moves and changes accent without receiving a text scale or losing its opacity");
    scripts\apparition\menu\hud::sync_visuals(slot, undefined, [0, 0, 0, 0], 0, 0, 0, 0);
    tests\support\checks::expect(slot.elements["label"].alpha == 0 && slot.elements["invalid_line"].alpha == 0
        && slot.requested_colors.line == (0, 0, 1),
        "Outgoing alpha-only retirement hides both present roles and preserves the accent target");
}
