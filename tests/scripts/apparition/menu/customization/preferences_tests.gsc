// Applied settings belong to one menu owner and reject unknown choices

run()
{
    instruction_preferences_reset_positions_and_enforce_style_compatibility();
    defaults_match_the_source_visual_preferences();
    enum_settings_reject_unknown_values_without_mutation();
    design_values_follow_source_order_and_reject_invalid_choices();
    design_changes_reset_only_prohibited_preferences();
    design_selection_stays_with_the_target_owner();
    toggles_read_current_settings_and_leave_other_owners_unchanged();
    scroll_values_use_real_milliseconds_and_source_bounds();
    theme_changes_reject_unknown_names_and_accept_black();
    named_theme_selection_stops_rainbow_and_requests_source_fades();
    smooth_rainbow_selection_is_idempotent();
    full_hud_reopen_follows_design_counter_and_stealth_rules();
    stealth_converts_boxes_and_clears_the_counter_without_restoring_them();
    stealth_keeps_text_color_and_changes_only_the_current_owner();
    stealth_rejects_boxes_and_counter_enable_without_mutating_settings();
}

full_hud_reopen_follows_design_counter_and_stealth_rules()
{
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::reopen_required("design", "Apparition", "Native", false),
        "Changing the applied design requires fresh chrome and option elements");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::reopen_required("design", "Native", "Native", false),
        "Selecting the current design does not reopen its HUD");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::reopen_required("option_counter", "Apparition", "Apparition", false),
        "The accepted Option Counter toggle reopens the full source HUD");
    foreach (setting in ["theme", "bool_display", "bool_location", "large_cursor", "scroll_time"])
        tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::reopen_required(setting, "Apparition", "Apparition", true),
            "Other preferences keep their own option or color update path");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::reopen_required("stealth_ui", "Apparition", "Apparition", true),
        "Stealth recreates the source HUD when it removes an active counter");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::reopen_required("stealth_ui", "Apparition", "Apparition", false),
        "Stealth uses the ordinary bool redraw when the counter was already off");
}

stealth_converts_boxes_and_clears_the_counter_without_restoring_them()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.option_counter = true;
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "stealth_ui", undefined),
        "The source Stealth UI toggle is accepted");
    tests\support\checks::expect(layout.stealth_ui && layout.bool_display == "Text" && !layout.option_counter,
        "Enabling Stealth changes Boxes to Text and clears the counter together");
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 5,
        "Stealth shows the source five-row window");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "stealth_ui", undefined)
        && !layout.stealth_ui && layout.bool_display == "Text" && !layout.option_counter,
        "Disabling Stealth preserves Text and does not restore the old counter");
    tests\support\checks::expect(scripts\apparition\menu\layout::capacity(layout) == 12,
        "Disabling Stealth returns to the current Text capacity");
}

stealth_keeps_text_color_and_changes_only_the_current_owner()
{
    first = scripts\apparition\menu\layout::defaults();
    second = scripts\apparition\menu\layout::defaults();
    first.bool_display = "Text Color";
    first.bool_location = "Left";
    first.option_counter = true;
    scripts\apparition\menu\customization\preferences::apply(first, "stealth_ui", undefined);
    tests\support\checks::expect(first.stealth_ui && first.bool_display == "Text Color" && first.bool_location == "Left"
        && !first.option_counter,
        "Stealth retains Text Color and its saved box location while clearing an active counter");
    tests\support\checks::expect(!second.stealth_ui && second.bool_display == "Boxes",
        "Another owner's visual settings remain unchanged");
    foreach (design in scripts\apparition\menu\customization\preferences::values("design"))
    {
        scripts\apparition\menu\customization\preferences::apply(first, "design", design);
        tests\support\checks::expect(first.stealth_ui && first.bool_display == "Text Color" && !first.option_counter,
            "Changing design preserves the current Stealth compatibility rules");
    }
}

stealth_rejects_boxes_and_counter_enable_without_mutating_settings()
{
    layout = scripts\apparition\menu\layout::defaults();
    scripts\apparition\menu\customization\preferences::apply(layout, "stealth_ui", undefined);
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "bool_display", "Boxes")
        && layout.bool_display == "Text" && layout.stealth_ui,
        "A stale Boxes callback cannot bypass active Stealth UI");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "option_counter", undefined)
        && !layout.option_counter && layout.stealth_ui,
        "A stale counter callback cannot enable it while Stealth is active");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "bool_display", "Text Color")
        && layout.bool_display == "Text Color",
        "The other source text display remains selectable in Stealth");
    scripts\apparition\menu\customization\preferences::apply(layout, "stealth_ui", undefined);
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "bool_display", "Boxes")
        && layout.bool_display == "Boxes",
        "Boxes can be explicitly selected after Stealth is disabled");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "option_counter", undefined)
        && layout.option_counter,
        "The counter can be explicitly enabled again after Stealth is disabled");
}

defaults_match_the_source_visual_preferences()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(layout.bool_display == "Boxes" && layout.bool_location == "Right", "Source defaults use right-side boxes");
    tests\support\checks::expect(!layout.smooth_rainbow && !layout.theme_fade_pending, "Static theme mode and its one-shot fade request start inactive");
    tests\support\checks::expect(layout.design == "Apparition", "The default source menu design is Apparition");
    tests\support\checks::expect(layout.spotlight_cursor && layout.colored_cursor, "Both source cursor highlights start enabled");
    tests\support\checks::expect(!layout.large_cursor && !layout.option_counter, "Enlarged text and the counter start disabled");
    tests\support\checks::expect(isDefined(layout.stealth_ui) && !layout.stealth_ui, "Stealth UI has one explicit disabled default");
    tests\support\checks::expect(!layout.quick_exit && !layout.disable_quick_menu, "Quick Exit and Disable Quick Menu start disabled");
}

enum_settings_reject_unknown_values_without_mutation()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "bool_display", "Text Color"), "Text Color is an accepted display mode");
    tests\support\checks::expect(layout.bool_display == "Text Color", "The selected display mode becomes active");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "bool_display", "Unknown") && layout.bool_display == "Text Color", "An invalid display choice preserves the active mode");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "bool_location", "Left") && layout.bool_location == "Left", "Left is an accepted box location");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "bool_location", undefined) && layout.bool_location == "Left", "A missing location preserves the active side");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "unknown", true), "An unknown setting does not create a new option");
}

design_values_follow_source_order_and_reject_invalid_choices()
{
    layout = scripts\apparition\menu\layout::defaults();
    values = scripts\apparition\menu\customization\preferences::values("design");
    tests\support\checks::expect(values.size == 5 && values[0] == "Apparition" && values[1] == "Classic" && values[2] == "Native" && values[3] == "AIO" && values[4] == "Basic", "Design choices follow the source menu order");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "design", "Unknown") && layout.design == "Apparition", "An unknown design leaves the applied design unchanged");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "design", undefined) && layout.design == "Apparition", "A missing design choice leaves the applied design unchanged");
}

design_changes_reset_only_prohibited_preferences()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.option_counter = true;
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "design", "Apparition"), "Selecting the already applied design succeeds");
    tests\support\checks::expect(layout.colored_cursor && layout.option_counter, "Selecting the same design is a no-op for other preferences");

    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "design", "Native"), "Native is a valid design transition");
    tests\support\checks::expect(layout.design == "Native" && !layout.colored_cursor && layout.option_counter, "Native disables only the incompatible colored cursor");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "colored_cursor", undefined) && !layout.colored_cursor, "Native cannot re-enable the colored cursor");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "design", "Classic") && !layout.colored_cursor && layout.option_counter, "Classic keeps its cursor restriction without changing the counter");

    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "design", "Apparition"), "Apparition is a valid design transition");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "colored_cursor", undefined) && layout.colored_cursor, "Apparition permits the colored cursor again");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "design", "AIO"), "AIO is a valid design transition");
    tests\support\checks::expect(layout.design == "AIO" && layout.colored_cursor && !layout.option_counter, "AIO disables only the incompatible option counter");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "option_counter", undefined) && !layout.option_counter, "AIO cannot re-enable the option counter");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "design", "Basic") && layout.colored_cursor && !layout.option_counter, "Basic keeps its counter restriction without changing the cursor");
}

design_selection_stays_with_the_target_owner()
{
    first = scripts\apparition\menu\layout::defaults();
    second = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(first, "design", "Classic"), "A design selection applies to the requested owner layout");
    tests\support\checks::expect(first.design == "Classic" && !first.colored_cursor, "The selected owner's design and compatibility state update together");
    tests\support\checks::expect(second.design == "Apparition" && second.colored_cursor, "Another owner's design and cursor preferences remain unchanged");
}

toggles_read_current_settings_and_leave_other_owners_unchanged()
{
    first = scripts\apparition\menu\layout::defaults();
    second = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(first, "spotlight_cursor", undefined) && !first.spotlight_cursor, "Spotlight toggles from the current applied value");
    scripts\apparition\menu\customization\preferences::apply(first, "spotlight_cursor", undefined);
    scripts\apparition\menu\customization\preferences::apply(first, "colored_cursor", undefined);
    scripts\apparition\menu\customization\preferences::apply(first, "large_cursor", undefined);
    scripts\apparition\menu\customization\preferences::apply(first, "option_counter", undefined);
    scripts\apparition\menu\customization\preferences::apply(first, "quick_exit", undefined);
    scripts\apparition\menu\customization\preferences::apply(first, "disable_quick_menu", undefined);
    tests\support\checks::expect(first.spotlight_cursor && !first.colored_cursor && first.large_cursor && first.option_counter && first.quick_exit && first.disable_quick_menu, "Each toggle changes only its intended owner preference");
    tests\support\checks::expect(second.spotlight_cursor && second.colored_cursor && !second.large_cursor && !second.option_counter, "Another owner's settings remain at their defaults");
    tests\support\checks::expect(!second.quick_exit && !second.disable_quick_menu, "Quick menu preferences remain scoped to their owner");
}

scroll_values_use_real_milliseconds_and_source_bounds()
{
    layout = scripts\apparition\menu\layout::defaults();
    values = scripts\apparition\menu\customization\preferences::values("scroll_time");
    tests\support\checks::expect(values.size == 16 && values[0] == 100 && values[15] == 250, "The source 0.10 to 0.25 second range is labeled in actual milliseconds");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "scroll_time", 250) && layout.scroll_time == 0.25, "250 milliseconds becomes a quarter-second animation");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "scroll_time", 255) && layout.scroll_time == 0.25, "Off-step animation values are rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "scroll_time", 0), "A zero animation outside the source range is rejected");
}

theme_changes_reject_unknown_names_and_accept_black()
{
    layout = scripts\apparition\menu\layout::defaults();
    original = layout.accent;
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "theme", "Unknown") && layout.accent == original, "An invalid theme preserves the previous accent");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "theme", "Black") && layout.accent == (0, 0, 0), "Black applies without being mistaken for an unavailable color");
    tests\support\checks::expect(layout.theme_fade_pending, "A named theme requests the source static fade on the next HUD update");
}

named_theme_selection_stops_rainbow_and_requests_source_fades()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.smooth_rainbow = true;
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "theme", "Unknown") && layout.smooth_rainbow, "An invalid palette choice leaves rainbow mode active");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "theme", "Green"), "A named palette choice applies successfully");
    tests\support\checks::expect(!layout.smooth_rainbow && layout.accent == (0, 1, 0), "A static theme stops rainbow and becomes the applied accent");
    tests\support\checks::expect(layout.theme_fade_pending, "A static theme change requests one source fade update");
}

smooth_rainbow_selection_is_idempotent()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "smooth_rainbow", undefined) && layout.smooth_rainbow, "Selecting Smooth Rainbow enables the source mode");
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "smooth_rainbow", false) && layout.smooth_rainbow, "Selecting an already active Smooth Rainbow option leaves it enabled");
}

instruction_preferences_reset_positions_and_enforce_style_compatibility()
{
    layout = scripts\apparition\menu\layout::defaults();
    other = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "adaptive_instructions", undefined)
        && layout.adaptive_instructions, "Normal instructions permit adaptive placement");
    layout.instructions_x = -20;
    layout.instructions_y = 100;
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "alternate_instructions", undefined)
        && layout.alternate_instructions && !layout.adaptive_instructions
        && layout.instructions_x == 320 && layout.instructions_y == 472,
        "Alternate Style clears adaptive placement and resets its centered source position");
    tests\support\checks::expect(!scripts\apparition\menu\customization\preferences::apply(layout, "adaptive_instructions", undefined)
        && !layout.adaptive_instructions, "A stale Adaptive callback cannot bypass Alternate Style");
    scripts\apparition\menu\customization\preferences::apply(layout, "alternate_instructions", undefined);
    tests\support\checks::expect(!layout.alternate_instructions && layout.instructions_x == 255,
        "Turning Alternate Style off resets the left source position");
    scripts\apparition\menu\customization\preferences::apply(layout, "disable_instructions", undefined);
    scripts\apparition\menu\customization\preferences::apply(layout, "disable_instructions_background", undefined);
    layout.instructions_x = -8;
    layout.instructions_y = 44;
    tests\support\checks::expect(scripts\apparition\menu\customization\preferences::apply(layout, "reset_instructions", undefined)
        && layout.instructions_x == 255 && layout.instructions_y == 472
        && layout.disable_instructions && layout.disable_instructions_background,
        "Reset Position remains available while disabled and leaves visibility settings intact");
    tests\support\checks::expect(!other.disable_instructions && !other.disable_instructions_background
        && other.instructions_x == 255, "Instruction preferences change only their owner's layout");
}
