// Scroll plans use plain rows and never create HUDs or sample live input

run()
{
    ordinary_named_rows_stop_after_one_directional_step();
    same_window_spacers_wait_before_the_final_selection();
    zero_duration_spacers_keep_the_same_step_order();
    short_wraps_use_a_defined_start_and_skip_blank_targets();
    long_wraps_redraw_before_testing_the_target_label();
    a_shifted_blank_moves_geometry_then_redraws_the_unchecked_next_row();
    all_blank_short_pages_stop_without_recursive_steps();
    a_single_named_option_remains_selectable();
    delayed_steps_require_the_exact_live_navigation_context();
    delayed_steps_reject_page_target_cursor_and_owner_changes();
    delayed_steps_require_the_same_row_objects_in_the_same_order();
}

ordinary_named_rows_stop_after_one_directional_step()
{
    layout = scripts\apparition\menu\layout::defaults();
    rows = [named_row("First"), named_row("Unavailable"), named_row("Last")];
    rows[1].enabled = false;
    steps = scripts\apparition\menu\scroll::plan(rows, 0, 1, layout);
    tests\support\checks::expect(steps.size == 1 && steps[0].cursor == 1
        && steps[0].previous == 0 && steps[0].mode == "cursor" && steps[0].delay == 0,
        "A disabled named option remains a normal cursor target");
    rows[1].label = "\t";
    steps = scripts\apparition\menu\scroll::plan(rows, 0, 1, layout);
    tests\support\checks::expect(steps.size == 1 && steps[0].cursor == 1 && steps[0].mode == "cursor",
        "A tab label is not treated as an all-space source separator");
}

same_window_spacers_wait_before_the_final_selection()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.scroll_time = 0.12;
    rows = [named_row("First"), named_row(""), named_row("  "), named_row("Last")];
    down = scripts\apparition\menu\scroll::plan(rows, 0, 1, layout);
    tests\support\checks::expect(down.size == 3 && down[0].cursor == 1 && down[1].cursor == 2
        && down[0].mode == "cursor_pending" && down[1].mode == "cursor_pending"
        && abs(down[0].delay - 0.06) < 0.0001 && abs(down[1].delay - 0.06) < 0.0001,
        "Each consecutive blank has its own half-scroll wait without selection styling");
    tests\support\checks::expect(down[2].cursor == 3 && down[2].previous == 2
        && down[2].mode == "cursor" && down[2].delay == 0,
        "The final named row styles from the last skipped cursor");
    up = scripts\apparition\menu\scroll::plan(rows, 3, -1, layout);
    tests\support\checks::expect(up.size == 3 && up[0].cursor == 2 && up[1].cursor == 1
        && up[2].cursor == 0 && up[2].previous == 1 && up[2].mode == "cursor",
        "Upward navigation skips consecutive spacers in reverse order");
    tests\support\checks::expect(rows[1].label == "" && rows[2].label == "  ",
        "Planning does not replace blank model rows or their labels");
}

zero_duration_spacers_keep_the_same_step_order()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.scroll_time = 0;
    steps = scripts\apparition\menu\scroll::plan([named_row("First"), named_row(""), named_row("Last")], 0, 1, layout);
    tests\support\checks::expect(steps.size == 2 && steps[0].mode == "cursor_pending"
        && steps[0].delay == 0 && steps[1].cursor == 2 && steps[1].mode == "cursor",
        "Zero timing retains the source wait site and final target without recursion");
}

short_wraps_use_a_defined_start_and_skip_blank_targets()
{
    layout = scripts\apparition\menu\layout::defaults();
    rows = [named_row(""), named_row("Middle"), named_row("Last")];
    down = scripts\apparition\menu\scroll::plan(rows, 2, 1, layout);
    tests\support\checks::expect(down.size == 2 && down[0].cursor == 0
        && down[0].mode == "cursor_pending" && down[1].cursor == 1 && down[1].mode == "cursor",
        "A short downward wrap uses start zero and skips its blank first row");
    rows[0].label = "First";
    rows[2].label = "";
    up = scripts\apparition\menu\scroll::plan(rows, 0, -1, layout);
    tests\support\checks::expect(up.size == 2 && up[0].cursor == 2 && up[1].cursor == 1
        && up[1].mode == "cursor",
        "A short upward wrap has a defined viewport instead of comparing undefined locals");
}

long_wraps_redraw_before_testing_the_target_label()
{
    foreach (capacity in [5, 8, 9, 10, 11, 12, 14])
    {
        layout = tests\fixtures\layout::for_capacity(capacity);
        rows = counted_rows(capacity + 1);
        rows[0].label = "";
        rows[rows.size - 1].label = "";
        down = scripts\apparition\menu\scroll::plan(rows, rows.size - 1, 1, layout);
        up = scripts\apparition\menu\scroll::plan(rows, 0, -1, layout);
        tests\support\checks::expect(down.size == 1 && down[0].cursor == 0
            && down[0].mode == "redraw" && down[0].delay == 0,
            "A long downward wrap redraws its blank target without an invalid-row wait");
        tests\support\checks::expect(up.size == 1 && up[0].cursor == rows.size - 1
            && up[0].mode == "redraw" && up[0].delay == 0,
            "A long upward wrap preserves the source early-redraw exception");
    }
}

a_shifted_blank_moves_geometry_then_redraws_the_unchecked_next_row()
{
    foreach (capacity in [5, 8, 9, 10, 11, 12, 14])
    {
        layout = tests\fixtures\layout::for_capacity(capacity);
        layout.scroll_time = 0.2;
        middle = int((capacity - 1) / 2);
        rows = counted_rows(capacity + 6);
        rows[middle + 1].label = "";
        rows[middle + 2].label = "";
        down = scripts\apparition\menu\scroll::plan(rows, middle, 1, layout);
        tests\support\checks::expect(down.size == 2 && down[0].cursor == middle + 1
            && down[0].mode == "cursor_pending" && abs(down[0].delay - 0.1) < 0.0001
            && down[1].cursor == middle + 2 && down[1].mode == "redraw",
            "A shifted blank gets geometry and a half-wait before an unchecked downward redraw");
        rows = counted_rows(capacity + 6);
        rows[middle].label = "";
        rows[middle - 1].label = "";
        up = scripts\apparition\menu\scroll::plan(rows, middle + 1, -1, layout);
        tests\support\checks::expect(up.size == 2 && up[0].cursor == middle
            && up[0].mode == "cursor_pending" && up[1].cursor == middle - 1 && up[1].mode == "redraw",
            "The upward edge exception also redraws without scanning its next blank");
    }
}

all_blank_short_pages_stop_without_recursive_steps()
{
    layout = scripts\apparition\menu\layout::defaults();
    foreach (rows in [[named_row("")], [named_row(""), named_row(" "), named_row("  ")]])
    {
        foreach (direction in [-1, 1])
            tests\support\checks::expect(scripts\apparition\menu\scroll::plan(rows, 0, direction, layout).size == 0,
                "An all-blank short page produces no writes or waits instead of an endless recursion");
    }
}

a_single_named_option_remains_selectable()
{
    layout = scripts\apparition\menu\layout::defaults();
    foreach (direction in [-1, 1])
    {
        steps = scripts\apparition\menu\scroll::plan([named_row("No Options Found")], 0, direction, layout);
        tests\support\checks::expect(steps.size == 1 && steps[0].cursor == 0
            && steps[0].mode == "cursor" && steps[0].delay == 0,
            "The inert named placeholder remains a finite ordinary selection");
    }
}

delayed_steps_require_the_exact_live_navigation_context()
{
    fixture = resume_fixture();
    tests\support\checks::expect(can_resume(fixture), "The captured live context can resume a delayed spacer step");
    fixture.open = false;
    tests\support\checks::expect(!can_resume(fixture), "Close cancels a delayed step");
    fixture.open = true;
    hud = fixture.hud;
    fixture.hud = spawnstruct();
    fixture.hud.released = false;
    tests\support\checks::expect(!can_resume(fixture), "A replacement HUD cannot inherit an older directional step");
    fixture.hud = hud;
    fixture.hud.released = true;
    tests\support\checks::expect(!can_resume(fixture), "Retired native ownership rejects a delayed step");
    fixture.hud.released = false;
    fixture.rows = [named_row("First")];
    tests\support\checks::expect(!can_resume(fixture), "Rebuilt row objects cancel the old scroll plan");
}

delayed_steps_reject_page_target_cursor_and_owner_changes()
{
    fixture = resume_fixture();
    fixture.state.page = "Other";
    tests\support\checks::expect(!can_resume(fixture), "A changed page cancels the captured step");
    fixture.state.page = fixture.request.page;
    fixture.state.target = spawnstruct();
    tests\support\checks::expect(!can_resume(fixture), "A replacement actor rejects the old step");
    fixture.state.target = undefined;
    tests\support\checks::expect(!can_resume(fixture), "A removed actor rejects the old step before equality");
    fixture.state.target = fixture.request.target;
    fixture.state.cursors[fixture.state.page] = 1;
    tests\support\checks::expect(!can_resume(fixture), "A changed cursor cannot be overwritten after the wait");
    fixture.state.cursors[fixture.state.page] = 0;
    fixture.state = scripts\apparition\menu\state::create(fixture.request.target);
    tests\support\checks::expect(!can_resume(fixture), "A new session with the same values is a different navigation owner");
    fixture.state = undefined;
    tests\support\checks::expect(!can_resume(fixture), "An absent session rejects continuation");
    fixture.state = fixture.request.session;
    fixture.hud = undefined;
    tests\support\checks::expect(!can_resume(fixture), "An absent HUD rejects continuation");
}

can_resume(fixture)
{
    return scripts\apparition\menu\scroll::can_resume(fixture.request, fixture.open, fixture.state, fixture.hud, fixture.rows);
}

delayed_steps_require_the_same_row_objects_in_the_same_order()
{
    fixture = resume_fixture();
    first = fixture.rows[0];
    second = named_row("Second");
    fixture.request.rows = [first, second];
    fixture.rows = [first, second];
    tests\support\checks::expect(can_resume(fixture),
        "An equivalent container of the same row objects preserves the displayed snapshot");
    fixture.rows = [second, fixture.request.rows[0]];
    tests\support\checks::expect(!can_resume(fixture),
        "Reordered row objects reject a delayed plan even when the count stays equal");
    fixture.rows = [fixture.request.rows[0]];
    tests\support\checks::expect(!can_resume(fixture),
        "A changed row count rejects continuation before indexing a missing row");
    fixture.rows = undefined;
    tests\support\checks::expect(!can_resume(fixture),
        "Removed model rows cannot resume a pending step");
}

resume_fixture()
{
    fixture = spawnstruct();
    fixture.open = true;
    fixture.state = scripts\apparition\menu\state::create(spawnstruct());
    fixture.hud = spawnstruct();
    fixture.hud.released = false;
    fixture.rows = [named_row("First")];
    fixture.request = spawnstruct();
    fixture.request.session = fixture.state;
    fixture.request.page = fixture.state.page;
    fixture.request.target = fixture.state.target;
    fixture.request.hud = fixture.hud;
    fixture.request.rows = fixture.rows;
    fixture.request.cursor = 0;
    return fixture;
}

named_row(label)
{
    row = spawnstruct();
    row.label = label;
    return row;
}

counted_rows(count)
{
    rows = [];
    for (index = 0; index < count; index++)
        rows[index] = named_row("Option " + index);
    return rows;
}
