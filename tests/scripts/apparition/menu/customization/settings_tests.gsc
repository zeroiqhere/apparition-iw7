// Persisted settings are validated before any restored layout is exposed

run()
{
    defaults_encode_to_the_versioned_record();
    version_one_record_restores_all_previous_settings_with_stealth_disabled();
    version_two_migrates_stealth_and_uses_instruction_defaults();
    changed_visual_controls_and_chords_restore_together();
    changed_instruction_preferences_roundtrip_without_editor_state();
    rainbow_restores_its_mode_instead_of_a_sampled_color();
    transient_editor_and_navigation_state_are_not_restored();
    missing_malformed_and_unknown_versions_are_rejected();
    version_three_requires_exact_fields_and_canonical_flags();
    version_three_rejects_conflicting_instruction_modes();
    active_stealth_roundtrips_supported_design_and_text_choices();
    invalid_geometry_enums_flags_and_design_combinations_are_rejected();
    invalid_opening_chords_are_rejected_before_restore();
    integer_parsing_rejects_bad_text_and_overflow_before_conversion();
    unsupported_accent_values_are_not_encoded();
    every_design_restores_its_supported_flags();
    source_minimum_width_and_scroll_time_are_accepted();
}

defaults_encode_to_the_versioned_record()
{
    layout = scripts\apparition\menu\layout::defaults();
    record = scripts\apparition\menu\customization\settings::encode(layout);
    expected = "3|0|85|260|Apparition|Boxes|Right|120|0|0|1|1|0|0|Dodger Blue|+speed_throw,+melee|+speed_throw,+smoke|0|255|472|0|0|0|0";
    tests\support\checks::expect(record == expected, "Default settings encode as one canonical version-three record");
    fields = strTok(record, "|");
    tests\support\checks::expect(fields.size == 24 && fields[0] == "3" && fields[17] == "0"
        && fields[18] == "255" && fields[19] == "472"
        && fields[20] == "0" && fields[21] == "0" && fields[22] == "0" && fields[23] == "0",
        "Version three appends six canonical instruction preferences after Stealth UI");
}

version_one_record_restores_all_previous_settings_with_stealth_disabled()
{
    layout = scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::record());
    tests\support\checks::expect(isDefined(layout), "The fixed version-one record is accepted");
    if (!isDefined(layout))
        return;
    tests\support\checks::expect(layout.x == 0 && layout.y == 85 && layout.width == 260 && layout.design == "Apparition", "Source default position width and design restore together");
    tests\support\checks::expect(layout.bool_display == "Boxes" && layout.bool_location == "Right" && layout.scroll_time == 0.12, "Display and timing values restore in their applied units");
    tests\support\checks::expect(!layout.quick_exit && !layout.disable_quick_menu && layout.spotlight_cursor && layout.colored_cursor && !layout.large_cursor && !layout.option_counter, "All six persisted flags retain their source defaults");
    tests\support\checks::expect(layout.stealth_ui == false, "A version-one record restores Stealth UI as disabled");
    tests\support\checks::expect(layout.instructions_x == 255 && layout.instructions_y == 472
        && !layout.disable_instructions && !layout.alternate_instructions
        && !layout.disable_instructions_background && !layout.adaptive_instructions,
        "A version-one record receives the current instruction defaults");
    tests\support\checks::expect(!layout.smooth_rainbow && layout.accent == scripts\apparition\menu\customization\palette::color("Dodger Blue"), "The named color restores through the canonical palette");
    tests\support\checks::expect(layout.open_controls.size == 2 && layout.open_controls[1] == "+melee" && layout.quick_controls.size == 2 && layout.quick_controls[1] == "+smoke", "Both default opening chords restore");
}

version_two_migrates_stealth_and_uses_instruction_defaults()
{
    ordinary = scripts\apparition\menu\customization\settings::decode(version_two_record(false));
    tests\support\checks::expect(isDefined(ordinary) && !ordinary.stealth_ui,
        "A version-two record with Stealth disabled retains its prior layout meaning");
    if (isDefined(ordinary))
        tests\support\checks::expect(ordinary.x == 0 && ordinary.y == 85 && ordinary.width == 260
            && ordinary.design == "Apparition" && ordinary.bool_display == "Boxes"
            && ordinary.bool_location == "Right" && ordinary.scroll_time == 0.12
            && ordinary.open_controls.size == 2 && ordinary.open_controls[1] == "+melee"
            && ordinary.quick_controls.size == 2 && ordinary.quick_controls[1] == "+smoke"
            && ordinary.instructions_x == 255 && ordinary.instructions_y == 472
            && !ordinary.disable_instructions && !ordinary.alternate_instructions
            && !ordinary.disable_instructions_background && !ordinary.adaptive_instructions,
            "Version-two visual settings and chords survive while instruction preferences use defaults");

    stealth = scripts\apparition\menu\customization\settings::decode(version_two_record(true));
    tests\support\checks::expect(isDefined(stealth) && stealth.stealth_ui && stealth.bool_display == "Text"
        && stealth.instructions_x == 255 && stealth.instructions_y == 472
        && !stealth.disable_instructions && !stealth.alternate_instructions
        && !stealth.disable_instructions_background && !stealth.adaptive_instructions,
        "A version-two Stealth record keeps the old Stealth flag and receives instruction defaults");

    fields = strTok(version_two_record(true), "|");
    fields[5] = "Boxes";
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(
        scripts\apparition\menu\customization\settings::join(fields, "|"))),
        "Version two still rejects Stealth combined with Boxes");
    fields = strTok(version_two_record(true), "|");
    fields[13] = "1";
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(
        scripts\apparition\menu\customization\settings::join(fields, "|"))),
        "Version two still rejects Stealth combined with Option Counter");
}

changed_visual_controls_and_chords_restore_together()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.x = -35;
    layout.y = 110;
    layout.width = 500;
    scripts\apparition\menu\customization\preferences::apply(layout, "design", "Classic");
    scripts\apparition\menu\customization\preferences::apply(layout, "theme", "Black");
    scripts\apparition\menu\customization\preferences::apply(layout, "bool_display", "Text Color");
    scripts\apparition\menu\customization\preferences::apply(layout, "bool_location", "Left");
    scripts\apparition\menu\customization\preferences::apply(layout, "scroll_time", 250);
    layout.quick_exit = true;
    layout.disable_quick_menu = true;
    layout.spotlight_cursor = false;
    layout.large_cursor = true;
    layout.option_counter = true;
    layout.open_controls = ["+stance", "+gostand", "+breath_sprint"];
    layout.quick_controls = ["+frag"];
    restored = scripts\apparition\menu\customization\settings::decode(scripts\apparition\menu\customization\settings::encode(layout));
    tests\support\checks::expect(isDefined(restored), "A changed supported configuration can be restored");
    if (!isDefined(restored))
        return;
    tests\support\checks::expect(restored.x == -35 && restored.y == 110 && restored.width == 500 && restored.design == "Classic", "Negative position and source maximum width survive restore");
    tests\support\checks::expect(restored.accent == (0, 0, 0) && !restored.smooth_rainbow, "Black restores without being confused with a missing color");
    tests\support\checks::expect(restored.bool_display == "Text Color" && restored.bool_location == "Left" && restored.scroll_time == 0.25, "Changed display and timing retain their applied units");
    tests\support\checks::expect(restored.quick_exit && restored.disable_quick_menu && !restored.spotlight_cursor && !restored.colored_cursor && restored.large_cursor && restored.option_counter, "Changed flags preserve the Classic design restriction");
    tests\support\checks::expect(restored.open_controls.size == 3 && restored.open_controls[0] == "+stance" && restored.open_controls[2] == "+breath_sprint" && restored.quick_controls.size == 1 && restored.quick_controls[0] == "+frag", "Independent one- and three-button chords survive restore");
}

changed_instruction_preferences_roundtrip_without_editor_state()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.instructions_x = 320;
    layout.instructions_y = -45;
    layout.disable_instructions = true;
    layout.alternate_instructions = true;
    layout.disable_instructions_background = true;
    layout.adaptive_instructions = false;
    layout.active_editor = spawnstruct();
    layout.active_editor.mode = "reposition";
    layout.theme_fade_pending = true;

    record = scripts\apparition\menu\customization\settings::encode(layout);
    fields = strTok(record, "|");
    tests\support\checks::expect(fields.size == 24 && fields[18] == "320" && fields[19] == "-45"
        && fields[20] == "1" && fields[21] == "1" && fields[22] == "1" && fields[23] == "0",
        "Instruction preferences append in the specified order using canonical values");
    restored = scripts\apparition\menu\customization\settings::decode(record);
    tests\support\checks::expect(isDefined(restored) && restored.instructions_x == 320
        && restored.instructions_y == -45 && restored.disable_instructions
        && restored.alternate_instructions && restored.disable_instructions_background
        && !restored.adaptive_instructions,
        "Changed instruction coordinates and compatible flags roundtrip together");
    if (isDefined(restored))
        tests\support\checks::expect(!isDefined(restored.active_editor) && !restored.theme_fade_pending,
            "The settings record restores applied instruction choices without editor or HUD work");
}

rainbow_restores_its_mode_instead_of_a_sampled_color()
{
    layout = scripts\apparition\menu\layout::defaults();
    scripts\apparition\menu\customization\theme::enable(layout);
    scripts\apparition\menu\customization\theme::sample(layout, (0.2, 0.3, 0.4));
    record = scripts\apparition\menu\customization\settings::encode(layout);
    fields = strTok(record, "|");
    tests\support\checks::expect(fields[14] == "Rainbow", "The shared rainbow mode is stored instead of its current RGB sample");
    restored = scripts\apparition\menu\customization\settings::decode(record);
    tests\support\checks::expect(isDefined(restored) && restored.smooth_rainbow && !restored.theme_fade_pending, "Restore enables rainbow without replaying a static fade request");
}

transient_editor_and_navigation_state_are_not_restored()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.binding_menu = "Quick Menu";
    layout.binding_slot = 3;
    layout.active_editor = spawnstruct();
    layout.active_editor.mode = "width";
    layout.theme_fade_pending = true;
    restored = scripts\apparition\menu\customization\settings::decode(scripts\apparition\menu\customization\settings::encode(layout));
    tests\support\checks::expect(isDefined(restored), "Transient state does not prevent saving supported settings");
    if (!isDefined(restored))
        return;
    tests\support\checks::expect(!isDefined(restored.active_editor) && !restored.theme_fade_pending, "An old editor or fade request cannot be revived after restore");
    tests\support\checks::expect(restored.binding_menu == "Apparition" && restored.binding_slot == 1, "Unsaved editor choices use fresh defaults");
}

missing_malformed_and_unknown_versions_are_rejected()
{
    foreach (record in ["", "1", "1|", "2|0|85|260", tests\fixtures\settings::record() + "|extra", "|" + tests\fixtures\settings::record()])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(record)), "Missing extra or unknown version fields cannot produce a partial layout");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(undefined)), "An undefined record is rejected");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(1)), "A non-string record is rejected");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(0, "4"))), "An unknown future version is rejected");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(5, ""))), "An empty interior field cannot shift other settings into place");
}

version_three_requires_exact_fields_and_canonical_flags()
{
    v3 = strTok(scripts\apparition\menu\customization\settings::encode(scripts\apparition\menu\layout::defaults()), "|");
    v3_text = scripts\apparition\menu\customization\settings::join(v3, "|");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(getSubStr(v3_text, 0, v3_text.size - 2))),
        "Version three rejects a record missing its final instruction field");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(v3_text + "|future")),
        "Version three rejects appended fields instead of partially restoring");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::record() + "|0")),
        "Version one rejects a mismatched field count");
    v2 = version_two_record(false);
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(getSubStr(v2, 0, v2.size - 2)))
        && !isDefined(scripts\apparition\menu\customization\settings::decode(v2 + "|future")),
        "Version two requires its exact legacy field count");
    v2_without_flag = getSubStr(v2, 0, v2.size - 2);
    foreach (flag in ["", "2", "01", "true"])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(v2_without_flag + "|" + flag)),
            "Version two accepts only a canonical Stealth UI flag");
    foreach (index in [17, 20, 21, 22, 23])
    {
        fields = v3;
        fields[index] = "2";
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(
            scripts\apparition\menu\customization\settings::join(fields, "|"))),
            "Version-three flags accept only canonical zero or one");
    }
    fields = v3;
    fields[17] = "1";
    stealth_conflict = scripts\apparition\menu\customization\settings::join(fields, "|");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(stealth_conflict)),
        "Version three preserves the Stealth UI and Boxes incompatibility");
    fields = v3;
    fields[5] = "Text";
    fields[13] = "1";
    fields[17] = "1";
    counter_conflict = scripts\apparition\menu\customization\settings::join(fields, "|");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(counter_conflict)),
        "Version three rejects Stealth UI combined with Option Counter");
}

version_three_rejects_conflicting_instruction_modes()
{
    foreach (index in [18, 19])
    {
        foreach (coordinate in ["", "1.5", "01", "-0", "2147483648", "-2147483649", "not-a-number"])
            tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(v3_change(index, coordinate))),
                "Version-three instruction coordinates require canonical signed integers");
    }
    minimum = scripts\apparition\menu\customization\settings::decode(v3_change(18, "-2147483648"));
    maximum = scripts\apparition\menu\customization\settings::decode(v3_change(19, "2147483647"));
    tests\support\checks::expect(isDefined(minimum) && minimum.instructions_x == (-2147483647 - 1)
        && isDefined(maximum) && maximum.instructions_y == 2147483647,
        "Instruction coordinates accept both signed integer limits");
    fields = strTok(scripts\apparition\menu\customization\settings::encode(scripts\apparition\menu\layout::defaults()), "|");
    fields[21] = "1";
    fields[23] = "1";
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(
        scripts\apparition\menu\customization\settings::join(fields, "|"))),
        "Alternate and adaptive instruction modes cannot be restored together");
}

active_stealth_roundtrips_supported_design_and_text_choices()
{
    foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
    {
        foreach (display in ["Text", "Text Color"])
        {
            layout = scripts\apparition\menu\layout::defaults();
            layout.design = design;
            layout.bool_display = display;
            layout.option_counter = false;
            layout.stealth_ui = true;
            layout.colored_cursor = design != "Native" && design != "Classic";
            restored = scripts\apparition\menu\customization\settings::decode(
                scripts\apparition\menu\customization\settings::encode(layout));
            tests\support\checks::expect(isDefined(restored) && restored.stealth_ui
                && restored.design == design && restored.bool_display == display && !restored.option_counter,
                "Stealth UI roundtrips with either text display across every supported design");
        }
    }
}

invalid_geometry_enums_flags_and_design_combinations_are_rejected()
{
    foreach (width in ["199", "501", "260.5", "0260", "bad"])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(3, width))), "Unsupported width data rejects the whole record");
    foreach (index in [1, 2])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(index, "bad"))), "Invalid coordinates cannot convert silently to zero");
    foreach (index in [4, 5, 6, 7, 14])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(index, "Unknown"))), "Unknown design display timing or theme values are rejected");
    foreach (index in [8, 9, 10, 11, 12, 13])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(index, "2"))), "Flags accept only canonical zero or one");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(4, "Native"))), "A saved Native design cannot enable its forbidden colored cursor");
    record = tests\fixtures\settings::change(4, "Basic");
    fields = strTok(record, "|");
    fields[13] = "1";
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(scripts\apparition\menu\customization\settings::join(fields, "|"))), "A saved Basic design cannot enable its forbidden option counter");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(7, "121"))), "A scroll time outside the source choices is rejected");
}

invalid_opening_chords_are_rejected_before_restore()
{
    foreach (value in ["", "+attack,+attack", "+frag,+smoke", "None", "+attack,None", "+attack,,+melee", ",+attack", "+unknown", "+attack,+melee,+gostand,+stance"])
    {
        foreach (index in [15, 16])
            tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(index, value))), "Malformed or unsupported opening chords reject the whole record");
    }
}

integer_parsing_rejects_bad_text_and_overflow_before_conversion()
{
    tests\support\checks::expect(scripts\apparition\menu\customization\settings::integer("0") == 0 && scripts\apparition\menu\customization\settings::integer("-35") == -35, "Zero and negative coordinates parse as exact integers");
    tests\support\checks::expect(scripts\apparition\menu\customization\settings::integer("2147483647") == 2147483647 && scripts\apparition\menu\customization\settings::integer("-2147483648") == (-2147483647 - 1), "The full signed integer limits are supported");
    foreach (text in ["", "-", "+1", "01", "-0", "1.0", "1x", " 1", "2147483648", "-2147483649", "999999999999999999999"])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::integer(text)), "Malformed noncanonical or overflowing integer text is rejected");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::integer(undefined)) && !isDefined(scripts\apparition\menu\customization\settings::integer(1)), "Integer parsing accepts only defined strings");
}

unsupported_accent_values_are_not_encoded()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.accent = (0.2, 0.3, 0.4);
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\settings::encode(layout)), "An unknown static accent cannot be stored as a different named color");
}

every_design_restores_its_supported_flags()
{
    foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
    {
        layout = scripts\apparition\menu\layout::defaults();
        scripts\apparition\menu\customization\preferences::apply(layout, "design", design);
        // Allowed counters restore as enabled while AIO and Basic keep theirs off
        layout.option_counter = design != "AIO" && design != "Basic";
        restored = scripts\apparition\menu\customization\settings::decode(scripts\apparition\menu\customization\settings::encode(layout));
        tests\support\checks::expect(isDefined(restored), "Each supported design has a valid persisted form");
        if (!isDefined(restored))
            continue;
        tests\support\checks::expect(restored.design == design, "Each source design name survives restoration");
        tests\support\checks::expect(restored.colored_cursor == (design != "Native" && design != "Classic") && restored.option_counter == (design != "AIO" && design != "Basic"), "Restoring a design retains the restrictions applied during selection");
    }
}

version_two_record(stealth)
{
    fields = strTok(tests\fixtures\settings::record(), "|");
    fields[0] = "2";
    if (stealth)
    {
        fields[5] = "Text";
        fields[13] = "0";
    }
    return scripts\apparition\menu\customization\settings::join(fields, "|") + "|" + (stealth ? "1" : "0");
}

v3_change(index, value)
{
    fields = strTok(scripts\apparition\menu\customization\settings::encode(scripts\apparition\menu\layout::defaults()), "|");
    fields[index] = value;
    return scripts\apparition\menu\customization\settings::join(fields, "|");
}

source_minimum_width_and_scroll_time_are_accepted()
{
    layout = scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(3, "200"));
    tests\support\checks::expect(isDefined(layout) && layout.width == 200, "The source minimum width is accepted without clamping");
    layout = scripts\apparition\menu\customization\settings::decode(tests\fixtures\settings::change(7, "100"));
    tests\support\checks::expect(isDefined(layout) && layout.scroll_time == 0.1, "The source minimum scroll time restores in seconds");
}
