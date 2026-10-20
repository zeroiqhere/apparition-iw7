// Cursor and viewport contracts derived from Apparition's draw and scroll paths
// No HUD elements, game settings, or player state are changed by this suite
// Compilation is checked separately from executing checks in the game VM

run()
{
    undefined_cursor_selects_the_first_displayed_row();
    single_row_menu_keeps_the_only_selection();
    moving_beyond_last_row_wraps_to_first();
    moving_before_first_row_wraps_to_last();
    viewport_centers_the_selected_row();
    viewport_pins_near_the_final_rows();
    first_row_pins_viewport_at_the_top();
    wrapping_up_shows_the_last_page();
    rebuilding_a_shorter_menu_clamps_a_high_cursor();
    rebuilding_with_the_empty_menu_placeholder_selects_zero();
    println("Apparition navigation regression contract reached its final assertion");
}

undefined_cursor_selects_the_first_displayed_row()
{
    cursor = scripts\apparition\navigation::normalize_cursor(undefined, 1);
    tests\support\checks::expect(cursor == 0, "An undefined cursor selects the first displayed row");
}

single_row_menu_keeps_the_only_selection()
{
    up = scripts\apparition\navigation::move_cursor(0, -1, 1);
    down = scripts\apparition\navigation::move_cursor(0, 1, 1);
    tests\support\checks::expect(up == 0, "Moving up keeps the single row selected");
    tests\support\checks::expect(down == 0, "Moving down keeps the single row selected");
}

moving_beyond_last_row_wraps_to_first()
{
    cursor = scripts\apparition\navigation::move_cursor(11, 1, 12);
    tests\support\checks::expect(cursor == 0, "Moving beyond the final row wraps to the first row");
}

moving_before_first_row_wraps_to_last()
{
    cursor = scripts\apparition\navigation::move_cursor(0, -1, 12);
    tests\support\checks::expect(cursor == 11, "Moving before the first row wraps to the final row");
}

viewport_centers_the_selected_row()
{
    // Ten visible rows reproduce Apparition's default option count
    start = scripts\apparition\navigation::visible_start(5, 20, 10);
    tests\support\checks::expect(start == 1, "Selecting the sixth row keeps four rows above the cursor");
}

viewport_pins_near_the_final_rows()
{
    start = scripts\apparition\navigation::visible_start(10, 12, 10);
    tests\support\checks::expect(start == 2, "Selecting the eleventh row shows the final ten rows");
}

first_row_pins_viewport_at_the_top()
{
    start = scripts\apparition\navigation::visible_start(0, 12, 10);
    tests\support\checks::expect(start == 0, "Selecting the first row returns the window to the top");
}

wrapping_up_shows_the_last_page()
{
    cursor = scripts\apparition\navigation::move_cursor(0, -1, 12);
    start = scripts\apparition\navigation::visible_start(cursor, 12, 10);
    tests\support\checks::expect(start == 2, "Wrapping up shows the final ten rows");
}

rebuilding_a_shorter_menu_clamps_a_high_cursor()
{
    // A disconnected player can remove rows while a menu is open
    // drawText clamps the saved cursor before drawing the rebuilt options
    cursor = scripts\apparition\navigation::normalize_cursor(11, 3);
    start = scripts\apparition\navigation::visible_start(cursor, 3, 10);
    tests\support\checks::expect(cursor == 2, "Shrinking menu clamps the cursor to the last remaining row");
    tests\support\checks::expect(start == 0, "A menu shorter than the viewport starts at its first row");
}

rebuilding_with_the_empty_menu_placeholder_selects_zero()
{
    // The renderer inserts the inert No Options Found row before normalization
    cursor = scripts\apparition\navigation::normalize_cursor(11, 1);
    start = scripts\apparition\navigation::visible_start(cursor, 1, 10);
    tests\support\checks::expect(cursor == 0, "The placeholder row replaces the old out-of-range selection");
    tests\support\checks::expect(start == 0, "The placeholder row occupies the first page");
}
