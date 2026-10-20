// Instruction text and placement follow the pinned Apparition source

run()
{
    source_width_ignores_small_characters_and_color_codes();
    alive_closed_guide_uses_saved_chords_and_quick_menu_state();
    open_guide_uses_source_controls_and_alive_override();
    dead_guides_ignore_override_and_hide_disabled_quick_menu();
    formatter_preserves_or_flattens_source_lines();
    reset_position_uses_the_selected_anchor();
    plan_matches_source_default_geometry_and_width();
    plan_preserves_the_formatted_message();
    plan_applies_alternate_anchor_and_text_layout();
    plan_uses_adaptive_panel_offsets_and_repositioning();
    plan_uses_adaptive_menu_fallback_without_panel();
    plan_preserves_design_offsets_and_background_colors();
    plan_width_uses_source_button_and_punctuation_rules();
    plan_height_uses_source_newline_count();
}

alive_closed_guide_uses_saved_chords_and_quick_menu_state()
{
    layout = fixture_layout();
    expected = "[{+attack}] & [{+gostand}]: Open Apparition\n[{+speed_throw}] & [{+smoke}]: Open Quick Menu";
    tests\support\checks::expect(scripts\apparition\menu\instructions::text(layout, true, false, undefined) == expected,
        "The live closed guide uses the saved chords for both menus");
    layout.disable_instructions = true;
    tests\support\checks::expect(scripts\apparition\menu\instructions::text(layout, true, false, undefined) == "",
        "Disabled instructions produce no guide text");
    layout.disable_instructions = false;
    layout.disable_quick_menu = true;
    tests\support\checks::expect(scripts\apparition\menu\instructions::text(layout, true, false, undefined)
        == "[{+attack}] & [{+gostand}]: Open Apparition",
        "The live guide omits a disabled Quick Menu");
}

open_guide_uses_source_controls_and_alive_override()
{
    layout = fixture_layout();
    expected = "[{+attack}]/[{+speed_throw}]/[{+actionslot 1}]/[{+actionslot 2}]: Scroll\n"
        + "[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n"
        + "[{+activate}]: Select\n[{+melee}]: Go Back/Exit";
    tests\support\checks::expect(scripts\apparition\menu\instructions::text(layout, true, true, undefined) == expected,
        "The live open guide matches the source control labels");
    tests\support\checks::expect(scripts\apparition\menu\instructions::text(layout, true, true, "Custom\nGuide") == "Custom\nGuide",
        "A live custom instruction overrides the default guide");
}

dead_guides_ignore_override_and_hide_disabled_quick_menu()
{
    layout = fixture_layout();
    tests\support\checks::expect(scripts\apparition\menu\instructions::text(layout, false, false, "Ignored")
        == "[{+speed_throw}] & [{+gostand}]: Open Quick Menu",
        "A dead closed menu shows only the source Quick Menu chord");
    tests\support\checks::expect(scripts\apparition\menu\instructions::text(layout, false, true, "Ignored")
        == "[{+attack}]/[{+speed_throw}]: Scroll\n"
        + "[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n"
        + "[{+activate}]: Select\n[{+gostand}]: Go Back/Exit",
        "A dead open menu uses the dead control labels and ignores custom text");
    layout.disable_quick_menu = true;
    tests\support\checks::expect(scripts\apparition\menu\instructions::text(layout, false, false, undefined) == "",
        "A disabled Quick Menu has no dead closed instruction");
}

formatter_preserves_or_flattens_source_lines()
{
    lines = ["Scroll", "Select", "Go Back"];
    tests\support\checks::expect(scripts\apparition\menu\instructions::format(lines, false) == "Scroll\nSelect\nGo Back",
        "Normal mode joins instruction arrays with newlines");
    tests\support\checks::expect(scripts\apparition\menu\instructions::format(lines, true) == "Scroll  |  Select  |  Go Back",
        "Alternate mode joins instruction arrays with source separators");
    tests\support\checks::expect(scripts\apparition\menu\instructions::format("First\n\nSecond\n", true) == "First  |  Second",
        "Alternate scalar formatting drops empty newline tokens");
    tests\support\checks::expect(scripts\apparition\menu\instructions::format("First\n\nSecond\n", false) == "First\n\nSecond\n",
        "Normal scalar formatting keeps the supplied newlines");
    tests\support\checks::expect(scripts\apparition\menu\instructions::format([], true) == "",
        "An empty instruction array formats as empty text");
}

reset_position_uses_the_selected_anchor()
{
    layout = fixture_layout();
    layout.instructions_x = 17;
    layout.instructions_y = 23;
    tests\support\checks::expect(scripts\apparition\menu\instructions::reset_position(layout)
        && layout.instructions_x == 255 && layout.instructions_y == 472,
        "Reset restores the normal instruction anchor");
    layout.alternate_instructions = true;
    tests\support\checks::expect(scripts\apparition\menu\instructions::reset_position(layout)
        && layout.instructions_x == 320 && layout.instructions_y == 472,
        "Reset centers alternate instructions at the source position");
}

plan_matches_source_default_geometry_and_width()
{
    layout = fixture_layout();
    panel = spawnstruct();
    result = scripts\apparition\menu\instructions::plan(layout, "abc", false, panel, false, false);
    tests\support\checks::expect(result.x == 255 && result.y == 460 && result.width == 16 && result.height == 12,
        "Normal placement uses the stored anchor and source single-line dimensions");
    tests\support\checks::expect(result.text_x == 256 && result.text_y == 466 && result.outline_x == 254 && result.outline_y == 459 && result.align == "TOP_LEFT" && result.text_align == "LEFT",
        "Normal text keeps its one-pixel and six-pixel source insets");
    tests\support\checks::expect(result.background && result.bg_color == (42 / 255.0, 42 / 255.0, 42 / 255.0)
        && result.bg_alpha == 1 && result.color_role == "outline" && result.shape == "Apparition|0|0",
        "The Apparition panel uses its source background, alpha, and stable allocation key");
}

plan_preserves_the_formatted_message()
{
    layout = fixture_layout();
    message = "Scroll\nSelect";
    result = scripts\apparition\menu\instructions::plan(layout, message, false, undefined, false, false);
    tests\support\checks::expect(result.message == message,
        "The plan retains the formatted message for the native text element");
}

plan_applies_alternate_anchor_and_text_layout()
{
    layout = fixture_layout();
    layout.alternate_instructions = true;
    scripts\apparition\menu\instructions::reset_position(layout);
    result = scripts\apparition\menu\instructions::plan(layout, "Scroll:\nSelect:", false, undefined, false, false);
    tests\support\checks::expect(result.x == 320 && result.y == 446 && result.width == 6 && result.height == 26,
        "Alternate instructions center the source-width estimate and subtract its width adjustment");
    tests\support\checks::expect(result.text_x == 320 && result.text_y == 446 && result.outline_x == 320 && result.outline_y == 446 && result.align == "CENTER" && result.text_align == "CENTER",
        "Alternate text and rectangles share the centered source anchor");
    layout.disable_instructions_background = true;
    result = scripts\apparition\menu\instructions::plan(layout, "Scroll:\nSelect:", false, undefined, false, false);
    tests\support\checks::expect(!result.background && result.text_align == "LEFT"
        && result.shape == "Apparition|1|1",
        "Text-only alternate instructions switch text alignment and allocation identity");
}

plan_uses_adaptive_panel_offsets_and_repositioning()
{
    layout = fixture_layout();
    layout.design = "AIO";
    layout.adaptive_instructions = true;
    panel = spawnstruct();
    panel.x = 100;
    panel.y = 200;
    panel.width = 240;
    panel.height = 120;
    result = scripts\apparition\menu\instructions::plan(layout, "abc", false, panel, true, false);
    tests\support\checks::expect(result.x == 99 && result.y == 350 && result.width == 242,
        "Adaptive AIO placement follows the panel and applies its source offsets");
    tests\support\checks::expect(result.text_x == 100 && result.text_y == 356 && result.color_role == "background",
        "Adaptive text and theme role use the source AIO adjustments");
    result = scripts\apparition\menu\instructions::plan(layout, "abc", false, panel, true, true);
    tests\support\checks::expect(result.x == 255 && result.y == 460 && result.width == 16,
        "Reposition mode bypasses adaptive panel anchoring and width expansion");
}

plan_uses_adaptive_menu_fallback_without_panel()
{
    layout = fixture_layout();
    layout.x = 100;
    layout.width = 240;
    layout.adaptive_instructions = true;
    result = scripts\apparition\menu\instructions::plan(layout, "abc", false, undefined, true, false);
    tests\support\checks::expect(result.x == 101 && result.y == 460 && result.width == 238,
        "Adaptive mode falls back to menu width and x while keeping the stored y anchor");
}

plan_preserves_design_offsets_and_background_colors()
{
    designs = ["Apparition", "Classic", "AIO", "Native", "Basic"];
    expected_x = [1, 0, -1, 1, 0];
    expected_y = [18, 5, 30, 5, 5];
    expected_width = [-2, 0, 2, -2, 0];
    expected_colors = [(42 / 255.0, 42 / 255.0, 42 / 255.0), (25 / 255.0, 25 / 255.0, 25 / 255.0),
        (0, 0, 0), (0, 0, 0), (0, 0, 0)];
    expected_alpha = [1, 0.85, 1, 1, 1];
    for (index = 0; index < designs.size; index++)
    {
        layout = fixture_layout();
        layout.design = designs[index];
        layout.adaptive_instructions = true;
        panel = spawnstruct();
        panel.x = 100;
        panel.y = 200;
        panel.width = 240;
        panel.height = 120;
        result = scripts\apparition\menu\instructions::plan(layout, "abc", false, panel, true, false);
        tests\support\checks::expect(result.x == 100 + expected_x[index] && result.y == 200 + 120 + expected_y[index]
            && result.width == 240 + expected_width[index], "Each design keeps its source adaptive offsets");
        tests\support\checks::expect(result.bg_color == expected_colors[index] && result.bg_alpha == expected_alpha[index],
            "Each design keeps its constructor background color and alpha");
        tests\support\checks::expect(result.color_role == (designs[index] == "AIO" ? "background" : "outline"),
            "Only AIO routes the instruction theme color to its background");
    }
}

plan_width_uses_source_button_and_punctuation_rules()
{
    layout = fixture_layout();
    button = scripts\apparition\menu\instructions::plan(layout, "[{+attack}] A.^1!", false, undefined, false, false);
    gamepad = scripts\apparition\menu\instructions::plan(layout, "[{+attack}] A.^1!", true, undefined, false, false);
    tests\support\checks::expect(button.width == 22 && gamepad.width == 19,
        "Button markup uses its source width scale and punctuation/color codes do not inflate line width");
    lines = scripts\apparition\menu\instructions::plan(layout, "short\nlonger", false, undefined, false, false);
    tests\support\checks::expect(lines.width == 31,
        "Multiline width follows the longest stripped line");
    tie = scripts\apparition\menu\instructions::plan(layout, "abc\n[{+attack}]abc", false, undefined, false, false);
    tests\support\checks::expect(tie.width == 32,
        "Equal stripped lines select the last line and retain its button width");
}

plan_height_uses_source_newline_count()
{
    layout = fixture_layout();
    result = scripts\apparition\menu\instructions::plan(layout, "One\nTwo\nThree", false, undefined, false, false);
    tests\support\checks::expect(result.height == 40 && result.y == 432,
        "Newline height counts three nonempty source tokens before its five-pixel adjustment");
    result = scripts\apparition\menu\instructions::plan(layout, "One\n\nTwo", false, undefined, false, false);
    tests\support\checks::expect(result.height == 26,
        "Empty newline tokens do not add source background height");
}

fixture_layout()
{
    layout = scripts\apparition\menu\layout::defaults();
    // A nondefault main chord makes the guide's saved-control dependency explicit
    layout.open_controls = ["+attack", "+gostand"];
    return layout;
}

source_width_ignores_small_characters_and_color_codes()
{
    tests\support\checks::expect(scripts\apparition\menu\instructions::text_width("|", false) == 1,
        "The source treats the inline separator as a zero-width small character");
    tests\support\checks::expect(scripts\apparition\menu\instructions::text_width("^1![]{}.,'|  ", false) == 7,
        "Color codes and small characters leave only two source-width spaces");
}
