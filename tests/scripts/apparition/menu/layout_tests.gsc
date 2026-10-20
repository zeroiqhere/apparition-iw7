// Geometry checks use the original default Apparition layout

run()
{
    instruction_visibility_changes_source_capacity_and_modal_geometry();
    ten_rows_match_the_original_panel_geometry();
    short_menus_shrink_to_the_visible_row_count();
    checkboxes_remain_on_the_right();
    width_changes_reposition_the_title_and_value_edge();
    editor_modes_keep_their_source_soft_lock_geometry();
    descriptions_wrap_between_words();
    alternate_designs_use_the_source_final_padding_and_row_offsets();
    stealth_limits_the_viewport_and_panel_to_five_rows();
}

stealth_limits_the_viewport_and_panel_to_five_rows()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.stealth_ui = true;
    layout.bool_display = "Text";
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 5,
        "Stealth replaces the normal twelve-row Text viewport with five rows");
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(20, layout) == 90,
        "A long default-design Stealth panel holds five source row blocks");
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(2, layout) == 36,
        "Short Stealth pages still shrink to their actual visible count");
    layout.bool_display = "Text Color";
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 5,
        "Text Color keeps the same five-row Stealth viewport");
}

ten_rows_match_the_original_panel_geometry()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(layout.x == 0 && layout.y == 85, "The source position is retained");
    tests\support\checks::expect(layout.width == 260 && scripts\apparition\menu\layout::capacity(layout) == 10, "The source width and default page size are retained");
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(10, layout) == 180, "Ten rows occupy 180 pixels");
    tests\support\checks::expect(layout.accent == (57 / 255.0, 152 / 255.0, 254 / 255.0), "The source blue accent is retained");
}

short_menus_shrink_to_the_visible_row_count()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(1, layout) == 18, "One placeholder row occupies 18 pixels");
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(31, layout) == 180, "A long page uses only ten visible rows");
    tests\support\checks::expect(scripts\apparition\menu\layout::row_y(0, layout) == 93, "The first text row is eight pixels below the panel top");
    tests\support\checks::expect(scripts\apparition\menu\layout::row_y(9, layout) == 255, "Rows keep the source 18-pixel spacing");
}

checkboxes_remain_on_the_right()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(layout.x + layout.width - 8 == 252, "The checkbox center is eight pixels inside the right edge");
}

width_changes_reposition_the_title_and_value_edge()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.width = 500;
    tests\support\checks::expect(scripts\apparition\menu\design::frame(layout, 10, undefined).roles["title"].x == 250, "The centered default title follows the applied width");
    tests\support\checks::expect(scripts\apparition\menu\layout::value_x(layout) == 496, "Right-aligned values follow the applied width");
}

editor_modes_keep_their_source_soft_lock_geometry()
{
    layout = scripts\apparition\menu\layout::defaults();
    width = scripts\apparition\menu\design::frame(layout, 10, "width");
    position = scripts\apparition\menu\design::frame(layout, 10, "reposition");
    tests\support\checks::expect(width.roles["panel"].height == 120 && width.roles["banner"].height == 155, "Width Editor retains the source 120-pixel panel and 155-pixel banner");
    tests\support\checks::expect(width.roles["bottom"].y == layout.y + 119, "Width Editor places its bottom line at panel height minus one");
    tests\support\checks::expect(position.roles["panel"].height == 122 && position.roles["banner"].height == 157, "Reposition Menu retains SoftLockMenu's source 122-pixel panel and 157-pixel banner");
    tests\support\checks::expect(position.roles["bottom"].y == layout.y + 121, "Reposition Menu places its bottom line at panel height minus one");
}

alternate_designs_use_the_source_final_padding_and_row_offsets()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.design = "Classic";
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(10, layout) == 187 && scripts\apparition\menu\layout::row_y(0, layout) == layout.y + 11, "Classic uses the final 25-pixel height offset and 11-pixel first-row offset");
    layout.design = "Native";
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(10, layout) == 180 && scripts\apparition\menu\layout::row_y(0, layout) == layout.y + 8, "Native keeps 18-pixel row blocks and an eight-pixel row offset");
    layout.design = "AIO";
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(10, layout) == 193 && scripts\apparition\menu\layout::row_y(0, layout) == layout.y + 15, "AIO uses its final 31-pixel height offset and 15-pixel first-row offset");
    layout.design = "Basic";
    tests\support\checks::expect(scripts\apparition\menu\layout::panel_height(1, layout) == 40 && scripts\apparition\menu\layout::row_y(0, layout) == layout.y + 30, "Basic reserves its 20-pixel title area even on a short page");
}

descriptions_wrap_between_words()
{
    tests\support\checks::expect(scripts\apparition\menu\layout::wrap_description("one two three", 7) == "one two\nthree", "The footer wraps at a word boundary");
    tests\support\checks::expect(scripts\apparition\menu\layout::wrap_description("short", 48) == "short", "Short descriptions keep one line");
}

instruction_visibility_changes_source_capacity_and_modal_geometry()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(layout.instructions_x == 255 && layout.instructions_y == 472
        && !layout.disable_instructions && !layout.alternate_instructions
        && !layout.disable_instructions_background && !layout.adaptive_instructions,
        "Instructions start at the source position with all four preferences disabled");
    layout.disable_instructions = true;
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 11,
        "Disabling instructions adds one visible row with Boxes");
    layout.bool_display = "Text";
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 14,
        "Disabling instructions adds two visible rows with text indicators");
    layout.option_counter = true;
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 12,
        "The counter still reserves two rows after instructions are disabled");
    layout.stealth_ui = true;
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 5,
        "Stealth takes precedence over instruction and counter capacity");
    frame = scripts\apparition\menu\design::frame(layout, 10, "instructions");
    tests\support\checks::expect(frame.roles["panel"].height == 20 && frame.roles["scroller"].alpha == 0
        && frame.roles["title"].alpha == 1 && frame.roles["bottom"].y == layout.y + 19,
        "Instruction repositioning keeps the source twenty-pixel soft lock and visible title");
}
