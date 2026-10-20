// Row presentation is the same deterministic plan consumed by the HUD

run()
{
    native_and_classic_keep_white_selected_text_and_source_counter_positions();
    default_boxes_keep_the_source_selected_and_unselected_styles();
    left_boxes_move_only_toggle_labels();
    text_modes_remove_boxes_and_checked_text_color_overrides_the_theme();
    cursor_preferences_change_only_their_requested_effects();
    capacity_and_counter_follow_source_rules();
    shrinking_capacity_keeps_the_last_row_inside_the_visible_window();
    opening_fade_duration_uses_the_visible_slot_and_leaves_the_first_row_immediate();
    ordinary_redraws_do_not_start_an_opening_fade();
    fade_times_follow_cursor_duration_and_alpha();
    fade_times_keep_opening_and_entering_colors_immediate();
    fade_times_separate_theme_changes_from_rainbow_updates();
    fade_times_keep_pending_theme_colors_on_the_current_transition();
    line_opacity_preserves_opening_entering_and_retained_targets();
    row_opacity_keeps_only_present_indicators_visible();
    row_opacity_preserves_disabled_and_blocked_choice_dimming();
    disabled_slider_keeps_its_preview_readable_while_the_label_is_dimmed();
    numeric_slider_text_has_no_invented_choice_index();
}

opening_fade_duration_uses_the_visible_slot_and_leaves_the_first_row_immediate()
{
    first = scripts\apparition\menu\appearance::opening_time(0);
    second = scripts\apparition\menu\appearance::opening_time(1);
    tenth = scripts\apparition\menu\appearance::opening_time(9);
    tests\support\checks::expect(first == 0 && second == 0.1,
        "Opening starts the first row immediately and fades the second over one tenth second");
    tests\support\checks::expect(abs(tenth - 0.9) < 0.0001,
        "The tenth visible row fades concurrently over nine tenths second");
    // A saved cursor can reopen far into a page without lengthening its row fades
    start = scripts\apparition\navigation::visible_start(26, 37, 10);
    slot = 26 - start;
    reopened = scripts\apparition\menu\appearance::opening_time(slot);
    tests\support\checks::expect(start == 22 && slot == 4
        && abs(reopened - 0.4) < 0.0001,
        "Reopening a scrolled page uses visible position rather than the absolute option index");
    last = scripts\apparition\menu\appearance::opening_time(11);
    tests\support\checks::expect(abs(last - 1.1) < 0.0001,
        "The twelfth text-mode slot retains the source visible-position duration");
}

ordinary_redraws_do_not_start_an_opening_fade()
{
    tests\support\checks::expect(scripts\apparition\menu\appearance::opening_time(undefined) == 0,
        "Ordinary refreshes and cursor redraw plans do not replay the opening fade");
    times = scripts\apparition\menu\appearance::fade_times(0, undefined, true, true, false, true);
    tests\support\checks::expect(times.text == 0 && times.fill == 0 && times.alpha == 0,
        "The fresh-redraw packet keeps colors and opacity immediate even with a pending theme");
}

fade_times_follow_cursor_duration_and_alpha()
{
    cursor = scripts\apparition\menu\appearance::fade_times(0.12, undefined, false, false, false, false);
    tests\support\checks::expect(cursor.text == 0.12 && cursor.fill == 0 && cursor.alpha == 0.12,
        "A same-window cursor change shares its duration with text color and alpha");

    immediate = scripts\apparition\menu\appearance::fade_times(0, undefined, false, false, false, false);
    tests\support\checks::expect(immediate.text == 0 && immediate.fill == 0 && immediate.alpha == 0,
        "A zero-duration cursor change or passive refresh requests no visual transition");
}

fade_times_keep_opening_and_entering_colors_immediate()
{
    first = scripts\apparition\menu\appearance::fade_times(0.12, 0, false, false, false, false);
    tenth = scripts\apparition\menu\appearance::fade_times(0.12, 9, false, false, false, false);
    entering = scripts\apparition\menu\appearance::fade_times(0.12, undefined, true, false, false, false);
    tests\support\checks::expect(first.text == 0 && first.fill == 0 && first.alpha == 0,
        "The first opening slot receives immediate colors and alpha");
    tests\support\checks::expect(tenth.text == 0 && tenth.fill == 0 && abs(tenth.alpha - 0.9) < 0.0001,
        "The tenth opening slot keeps its visible-position alpha duration with immediate colors");
    tests\support\checks::expect(entering.text == 0 && entering.fill == 0 && entering.alpha == 0.12,
        "A newly entering pool slot changes colors immediately and uses the cursor alpha duration");
}

fade_times_separate_theme_changes_from_rainbow_updates()
{
    checked_boxes = scripts\apparition\menu\appearance::fade_times(0, undefined, false, true, false, true);
    unchecked_boxes = scripts\apparition\menu\appearance::fade_times(0, undefined, false, true, false, false);
    rainbow_cursor = scripts\apparition\menu\appearance::fade_times(0.12, undefined, false, true, true, true);
    tests\support\checks::expect(checked_boxes.text == 1 && checked_boxes.fill == 0.5 && checked_boxes.alpha == 0,
        "An ordinary theme change fades text and checked-box fill at their source durations");
    tests\support\checks::expect(unchecked_boxes.text == 1 && unchecked_boxes.fill == 0 && unchecked_boxes.alpha == 0,
        "An unchecked theme change does not fade an unchanged box fill");
    tests\support\checks::expect(rainbow_cursor.text == 0 && rainbow_cursor.fill == 0
        && rainbow_cursor.alpha == 0.12,
        "Rainbow color sampling stays immediate while cursor alpha keeps its duration");
}

fade_times_keep_pending_theme_colors_on_the_current_transition()
{
    cursor = scripts\apparition\menu\appearance::fade_times(0.12, undefined, false, true, false, true);
    tests\support\checks::expect(cursor.text == 0.12 && cursor.fill == 0 && cursor.alpha == 0.12,
        "A pending theme cannot give a cursor element two different positive fade durations");
    opening = scripts\apparition\menu\appearance::fade_times(0, 9, false, true, false, true);
    tests\support\checks::expect(opening.text == 0 && opening.fill == 0 && abs(opening.alpha - 0.9) < 0.0001,
        "A pending theme keeps new opening colors immediate before their opacity fade");
}

native_and_classic_keep_white_selected_text_and_source_counter_positions()
{
    layout = scripts\apparition\menu\layout::defaults();
    row = scripts\apparition\menu\model::unavailable("Source row");
    layout.option_counter = true;
    foreach (design in ["Classic", "Native"])
    {
        layout.design = design;
        style = scripts\apparition\menu\appearance::row_style(row, true, layout);
        tests\support\checks::expect(style.color == (1, 1, 1), "Native and Classic selected text stays white even if a stale colored preference remains");
    }
    counter = scripts\apparition\menu\appearance::counter(0, 5, layout, scripts\apparition\menu\design::frame(layout, 5, undefined));
    tests\support\checks::expect(counter.y == layout.y - 9.5 && counter.alpha == 0.7, "Native counter stays in its black title strip");
    layout.design = "Classic";
    counter = scripts\apparition\menu\appearance::counter(0, 5, layout, scripts\apparition\menu\design::frame(layout, 5, undefined));
    tests\support\checks::expect(counter.y == layout.y - 7 && counter.alpha == 1, "Classic counter stays beside the title at full alpha");
    foreach (design in ["AIO", "Basic"])
    {
        layout.design = design;
        tests\support\checks::expect(scripts\apparition\menu\appearance::counter(0, 5, layout, scripts\apparition\menu\design::frame(layout, 5, undefined)).alpha == 0, "Designs without counter HUDs cannot show a stale counter");
    }
}

toggle_row(checked)
{
    row = spawnstruct();
    row.kind = "toggle";
    row.enabled = true;
    row.checked = checked;
    return row;
}

default_boxes_keep_the_source_selected_and_unselected_styles()
{
    layout = scripts\apparition\menu\layout::defaults();
    row = toggle_row(true);
    selected = scripts\apparition\menu\appearance::row_style(row, true, layout);
    other = scripts\apparition\menu\appearance::row_style(row, false, layout);
    tests\support\checks::expect(selected.boxes && selected.box_x == 252 && selected.label_x == 4, "Default boxes stay on the right without moving the label");
    tests\support\checks::expect(selected.color == layout.accent && selected.fill_color == layout.accent, "Selection and checked boxes use the applied theme");
    tests\support\checks::expect(selected.alpha == 1 && other.alpha == 0.4 && other.color == (1, 1, 1), "Spotlight dims other rows while keeping their text white");
    row.checked = false;
    style = scripts\apparition\menu\appearance::row_style(row, true, layout);
    tests\support\checks::expect(style.fill_color == (0, 0, 0), "An unchecked box keeps its black center");
}

left_boxes_move_only_toggle_labels()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.bool_location = "Left";
    row = toggle_row(false);
    style = scripts\apparition\menu\appearance::row_style(row, false, layout);
    tests\support\checks::expect(style.box_x == 9 && style.label_x == 18, "Left boxes retain their source inset and label clearance");
    row.kind = "submenu";
    style = scripts\apparition\menu\appearance::row_style(row, false, layout);
    tests\support\checks::expect(!style.boxes && style.label_x == 4 && style.value == ">", "A submenu keeps its own label position and arrow");
}

text_modes_remove_boxes_and_checked_text_color_overrides_the_theme()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.bool_display = "Text";
    layout.bool_location = "Left";
    row = toggle_row(true);
    style = scripts\apparition\menu\appearance::row_style(row, true, layout);
    tests\support\checks::expect(!style.boxes && style.value == "ON" && style.label_x == 4, "Text mode ignores the box side and displays ON");
    row.checked = false;
    tests\support\checks::expect(scripts\apparition\menu\appearance::row_style(row, false, layout).value == "OFF", "Text mode displays OFF for an unchecked row");
    layout.bool_display = "Text Color";
    row.checked = true;
    style = scripts\apparition\menu\appearance::row_style(row, true, layout);
    tests\support\checks::expect(!style.boxes && style.value == "" && style.color == (0, 1, 0), "Checked Text Color uses green instead of the selected accent");
    layout.colored_cursor = false;
    tests\support\checks::expect(scripts\apparition\menu\appearance::row_style(row, false, layout).color == (0, 1, 0), "Checked Text Color remains green without a colored cursor");
    row.checked = false;
    tests\support\checks::expect(scripts\apparition\menu\appearance::row_style(row, true, layout).color == (1, 1, 1), "Unchecked Text Color follows ordinary cursor color");
}

cursor_preferences_change_only_their_requested_effects()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.spotlight_cursor = false;
    layout.colored_cursor = false;
    layout.large_cursor = true;
    row = toggle_row(true);
    selected = scripts\apparition\menu\appearance::row_style(row, true, layout);
    other = scripts\apparition\menu\appearance::row_style(row, false, layout);
    tests\support\checks::expect(selected.color == (1, 1, 1) && selected.fill_color == layout.accent, "Disabling colored text preserves checked-box theme color");
    tests\support\checks::expect(other.alpha == 1, "Disabling spotlight restores full row opacity");
    tests\support\checks::expect(selected.scale == 1.2 && other.scale == 1, "Large Cursor enlarges only the selected row");
}

capacity_and_counter_follow_source_rules()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 10, "Boxes use the default ten visible rows");
    layout.option_counter = true;
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 8, "The counter reserves two rows in box mode");
    layout.bool_display = "Text";
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 10, "Text adds two rows even while the counter is enabled");
    layout.option_counter = false;
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 12, "Text mode fits twelve visible rows");
    layout.bool_display = "Text Color";
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 12, "Text Color has the same source capacity as Text");
    layout.option_counter = true;
    counter = scripts\apparition\menu\appearance::counter(31, 32, layout, scripts\apparition\menu\design::frame(layout, 32, undefined));
    tests\support\checks::expect(counter.index == 32 && counter.total == 32 && counter.x == 244 && counter.y == 273, "The counter uses the full one-based index and source bottom position");
    counter = scripts\apparition\menu\appearance::counter(0, 5, layout, scripts\apparition\menu\design::frame(layout, 5, undefined));
    tests\support\checks::expect(counter.x == 248 && counter.y == 183, "Short-page counters follow the resized panel");
}

shrinking_capacity_keeps_the_last_row_inside_the_visible_window()
{
    layout = scripts\apparition\menu\layout::defaults();
    foreach (display in ["Boxes", "Text", "Text Color"])
    {
        layout.bool_display = display;
        foreach (enabled in [false, true])
        {
            layout.option_counter = enabled;
            capacity = scripts\apparition\menu\layout::capacity(layout);
            start = scripts\apparition\navigation::visible_start(36, 37, capacity);
            tests\support\checks::expect(start <= 36 && start + capacity > 36, "The final selected row remains visible in every supported capacity");
            tests\support\checks::expect(start + capacity == 37, "A resized viewport stays pinned to the final full page");
        }
    }
}


row_opacity_keeps_only_present_indicators_visible()
{
    layout = scripts\apparition\menu\layout::defaults();
    row = toggle_row(true);
    style = scripts\apparition\menu\appearance::row_style(row, true, layout);
    alpha = scripts\apparition\menu\appearance::opacity(row, true, style, false);
    tests\support\checks::expect(alpha[0] == 1 && alpha[1] == 0 && alpha[2] == 1,
        "Box mode shows its label and both boxes while hiding the unused value slot");
    layout.bool_display = "Text";
    style = scripts\apparition\menu\appearance::row_style(row, false, layout);
    alpha = scripts\apparition\menu\appearance::opacity(row, false, style, false);
    tests\support\checks::expect(alpha[0] == 0.4 && alpha[1] == 0.4 && alpha[2] == 0,
        "Text mode dims both present text elements and hides both boxes");
    row.kind = "submenu";
    style = scripts\apparition\menu\appearance::row_style(row, true, layout);
    alpha = scripts\apparition\menu\appearance::opacity(row, true, style, false);
    tests\support\checks::expect(alpha[0] == 1 && alpha[1] == 1 && alpha[2] == 0,
        "A selected submenu shows its label and arrow without boxes");
}

row_opacity_preserves_disabled_and_blocked_choice_dimming()
{
    layout = scripts\apparition\menu\layout::defaults();
    row = scripts\apparition\menu\model::unavailable("Unavailable row");
    style = scripts\apparition\menu\appearance::row_style(row, true, layout);
    alpha = scripts\apparition\menu\appearance::opacity(row, true, style, true);
    tests\support\checks::expect(alpha[0] == 0.65 && alpha[1] == 0 && alpha[2] == 0,
        "A selected disabled action uses row-level dimming and hides unused indicators");
    style = scripts\apparition\menu\appearance::row_style(row, false, layout);
    alpha = scripts\apparition\menu\appearance::opacity(row, false, style, false);
    tests\support\checks::expect(alpha[0] == 0.3 && alpha[1] == 0,
        "An unselected disabled action retains the source-candidate dimming");
    row.enabled = true;
    row.kind = "slider";
    alpha = scripts\apparition\menu\appearance::opacity(row, false, style, true);
    tests\support\checks::expect(abs(alpha[0] - 0.26) < 0.0001 && abs(alpha[1] - 0.26) < 0.0001
        && alpha[2] == 0,
        "A blocked slider choice dims both label and present slider value after spotlight");
}

disabled_slider_keeps_its_preview_readable_while_the_label_is_dimmed()
{
    layout = scripts\apparition\menu\layout::defaults();
    row = scripts\apparition\menu\model::unavailable("Official Spawn Points");
    row.kind = "slider";
    row.values = ["Preview"];
    // A disabled preview remains readable while its footer explains the block
    style = scripts\apparition\menu\appearance::row_style(row, true, layout);
    alpha = scripts\apparition\menu\appearance::opacity(row, true, style, true);
    tests\support\checks::expect(alpha[0] == 0.65 && alpha[1] == 1 && alpha[2] == 0,
        "A selected disabled slider dims its label while keeping the preview readable");
    style = scripts\apparition\menu\appearance::row_style(row, false, layout);
    alpha = scripts\apparition\menu\appearance::opacity(row, false, style, true);
    tests\support\checks::expect(alpha[0] == 0.3 && alpha[1] == 0.4 && alpha[2] == 0,
        "A disabled slider preserves spotlight on its preview without choice-level double dimming");
}

line_opacity_preserves_opening_entering_and_retained_targets()
{
    tests\support\checks::expect(scripts\apparition\menu\appearance::line_opacity(0.4, 1, true, true) == 1,
        "An animated opening can brighten a spacer from its constructor opacity");
    tests\support\checks::expect(scripts\apparition\menu\appearance::line_opacity(0.4, 0.4, true, true) == 0.4,
        "Spotlight retains the dim target during animated opening");
    tests\support\checks::expect(scripts\apparition\menu\appearance::line_opacity(1, 1, false, true) == 0.4,
        "A fresh nonanimated or entering spacer keeps the source constructor target");
    tests\support\checks::expect(scripts\apparition\menu\appearance::line_opacity(1, 0.4, false, false) == 1,
        "An ordinary retained-row update preserves its earlier opening target");
    tests\support\checks::expect(scripts\apparition\menu\appearance::line_opacity(0.4, 1, false, false) == 0.4,
        "A retained entering spacer is not brightened by later cursor styling");
    theme = scripts\apparition\menu\appearance::fade_times(0, undefined, false, true, false, false);
    cursor = scripts\apparition\menu\appearance::fade_times(0.12, undefined, false, true, false, false);
    rainbow = scripts\apparition\menu\appearance::fade_times(0, undefined, false, true, true, false);
    tests\support\checks::expect(theme.line == 0.5 && cursor.line == 0 && rainbow.line == 0,
        "Named themes fade spacer color while cursor and rainbow updates do not");
}

numeric_slider_text_has_no_invented_choice_index()
{
    row = spawnstruct();
    row.range = scripts\apparition\features\fov::range();
    tests\support\checks::expect(scripts\apparition\menu\appearance::slider_text(row, 70.5, undefined) == "< 70.5 >",
        "The numeric value stays literal without an integer-choice index");
    tests\support\checks::expect(scripts\apparition\menu\appearance::slider_text(row, undefined, undefined) == "< Unknown >",
        "Missing numeric data stays visibly unknown");
    row.range = undefined;
    row.values = ["A", "B"];
    tests\support\checks::expect(scripts\apparition\menu\appearance::slider_text(row, "B", 1) == "< B > [2/2]",
        "Named-choice sliders retain their existing value and index display");
}
