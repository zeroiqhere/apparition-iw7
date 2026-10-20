// Binding contracts exercise saved chords without native key input

run()
{
    defaults_keep_the_source_chords_and_first_editor_slot();
    the_catalog_retains_thirteen_source_commands_in_order();
    editor_selection_changes_only_valid_metadata();
    valid_changes_keep_main_and_quick_chords_independent();
    none_truncates_the_selected_slot_and_every_later_slot();
    invalid_slots_buttons_and_menu_names_preserve_the_applied_chord();
    duplicates_and_missing_prior_slots_are_rejected();
    frag_and_smoke_cannot_share_a_chord_but_can_replace_each_other();
    proposals_leave_saved_controls_unchanged_until_apply();
    labels_follow_the_applied_chord();
    matching_requires_every_member_of_a_nonempty_chord();
}

defaults_keep_the_source_chords_and_first_editor_slot()
{
    dead = scripts\apparition\menu\customization\bindings::dead_controls();
    tests\support\checks::expect(dead.size == 2 && dead[0] == "+speed_throw" && dead[1] == "+gostand", "The dead opening chord keeps the fixed source ADS plus Jump order");
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(layout.binding_menu == "Apparition" && layout.binding_slot == 1, "The editor starts on the main menu's first slot");
    tests\support\checks::expect(layout.open_controls.size == 2 && layout.open_controls[0] == "+speed_throw" && layout.open_controls[1] == "+melee", "The main menu keeps its source ADS plus Melee chord");
    tests\support\checks::expect(layout.quick_controls.size == 2 && layout.quick_controls[0] == "+speed_throw" && layout.quick_controls[1] == "+smoke", "The quick menu keeps its source ADS plus Secondary Offhand chord");
}

the_catalog_retains_thirteen_source_commands_in_order()
{
    commands = scripts\apparition\menu\customization\bindings::catalog();
    tests\support\checks::expect(commands.size == 13, "All thirteen source commands are available");
    tests\support\checks::expect(commands[0] == "+actionslot 1" && commands[3] == "+actionslot 4", "The four action slots lead the catalog");
    tests\support\checks::expect(commands[4] == "+melee" && commands[5] == "+speed_throw" && commands[6] == "+attack", "Melee ADS and Attack follow the slots");
    tests\support\checks::expect(commands[7] == "+breath_sprint" && commands[8] == "+activate", "Sprint and Use retain their source command strings");
    tests\support\checks::expect(commands[9] == "+frag" && commands[10] == "+smoke" && commands[11] == "+stance" && commands[12] == "+gostand", "Offhand Stance and Jump complete the source order");
}

editor_selection_changes_only_valid_metadata()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::select(layout, "binding_menu", "Quick Menu"), "The quick-menu editor can be selected");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::select(layout, "binding_slot", 3), "The third slot can be selected");
    tests\support\checks::expect(layout.binding_menu == "Quick Menu" && layout.binding_slot == 3 && layout.quick_controls.size == 2, "Editor selection leaves the saved chord untouched");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::select(layout, "binding_menu", "Main"), "Unknown menu names are rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::select(layout, "binding_slot", 1.5), "Fractional slots are rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::select(layout, "binding_slot", "1"), "Text slots are rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::select(layout, "binding_slot", undefined), "Undefined slots are rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::select(layout, "width", 3), "Unrelated layout settings cannot enter the editor API");
    tests\support\checks::expect(layout.binding_menu == "Quick Menu" && layout.binding_slot == 3, "Rejected selections retain the last valid editor state");
}

valid_changes_keep_main_and_quick_chords_independent()
{
    layout = scripts\apparition\menu\layout::defaults();
    // Separate layout instances represent independent menu owners
    other = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 1, "+gostand"), "A catalog button can replace the main chord's first slot");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::apply(layout, "Quick Menu", 3, "+breath_sprint"), "A third quick-menu button can follow its second slot");
    tests\support\checks::expect(layout.open_controls[0] == "+gostand" && layout.open_controls.size == 2 && layout.quick_controls[0] == "+speed_throw" && layout.quick_controls[2] == "+breath_sprint", "Main and quick chords keep their independent applied state");
    tests\support\checks::expect(other.open_controls[0] == "+speed_throw" && other.quick_controls.size == 2, "Changing one owner's layout leaves another layout unchanged");
}

none_truncates_the_selected_slot_and_every_later_slot()
{
    layout = scripts\apparition\menu\layout::defaults();
    scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 3, "+gostand");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 2, "None"), "None clears the chosen second slot");
    tests\support\checks::expect(layout.open_controls.size == 1 && layout.open_controls[0] == "+speed_throw", "Clearing slot two also removes the later third slot");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 1, "None"), "The first slot cannot be cleared");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 3, "None"), "Clearing a slot still requires its preceding slot");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 2, "+attack"), "The second slot can be filled after truncation");
    scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 3, "+gostand");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 3, "None") && layout.open_controls.size == 2, "Clearing the third slot preserves the earlier pair");
}

invalid_slots_buttons_and_menu_names_preserve_the_applied_chord()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 0, "+attack"), "Slot zero is rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 4, "+attack"), "A fourth slot is rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 1.5, "+attack"), "A fractional bind slot is rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 1, "+unknown"), "Unknown commands are rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Quick", 1, "+attack"), "Only source menu names select a chord");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, undefined, 1, undefined), "Missing selection data is rejected");
    tests\support\checks::expect(layout.open_controls[0] == "+speed_throw" && layout.open_controls[1] == "+melee" && layout.quick_controls.size == 2, "Rejected edits leave both saved chords unchanged");
}

duplicates_and_missing_prior_slots_are_rejected()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 2, "+speed_throw"), "A button already used by another slot is rejected");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 2, "+melee"), "Reselecting the current button follows the source duplicate rule");
    scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 2, "None");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 3, "+attack"), "Slot three cannot skip an empty second slot");
    tests\support\checks::expect(layout.open_controls.size == 1, "A rejected gap does not create a sparse chord");
}

frag_and_smoke_cannot_share_a_chord_but_can_replace_each_other()
{
    layout = scripts\apparition\menu\layout::defaults();
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Quick Menu", 3, "+frag"), "Frag cannot be appended to a chord containing Smoke");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::apply(layout, "Quick Menu", 2, "+frag"), "Frag can replace Smoke in the same slot");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Quick Menu", 3, "+smoke"), "Smoke cannot be appended to a chord containing Frag");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::apply(layout, "Quick Menu", 2, "+smoke"), "Smoke can replace Frag in the same slot");
    tests\support\checks::expect(layout.quick_controls.size == 2 && layout.quick_controls[1] == "+smoke", "The final offhand replacement is applied without a third slot");
}

proposals_leave_saved_controls_unchanged_until_apply()
{
    layout = scripts\apparition\menu\layout::defaults();
    proposal = scripts\apparition\menu\customization\bindings::proposal(layout, "Apparition", 3, "+attack");
    tests\support\checks::expect(proposal.reason == "" && proposal.value.size == 3 && proposal.value[2] == "+attack", "A valid proposal contains its complete prospective chord");
    tests\support\checks::expect(layout.open_controls.size == 2, "Building UI proposals cannot mutate saved controls");
    // A later truncation invalidates the third-slot proposal before commit
    scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 2, "None");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::apply(layout, "Apparition", 3, "+attack"), "Applying a formerly valid row rechecks changed prior slots");
    tests\support\checks::expect(layout.open_controls.size == 1, "A stale proposal cannot partially restore a truncated chord");
}

labels_follow_the_applied_chord()
{
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::label(["+speed_throw", "+melee"]) == "[{+speed_throw}] + [{+melee}]", "Two controls use source glyphs and a plus separator");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::label(["+gostand"]) == "[{+gostand}]", "A single control has no leading or trailing separator");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::label(["+stance", "+attack", "+gostand"]) == "[{+stance}] + [{+attack}] + [{+gostand}]", "All three applied controls appear in order");
}

matching_requires_every_member_of_a_nonempty_chord()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+speed_throw"] = true;
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::matches(buttons, ["+speed_throw", "+melee"]), "A partial chord does not match");
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::matches(buttons, ["+speed_throw", "+melee"]), "Every held member completes the chord");
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::matches(buttons, ["+melee"]), "A one-button chord is supported");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::matches(buttons, []), "An empty chord never opens a menu");
    tests\support\checks::expect(!scripts\apparition\menu\customization\bindings::matches(buttons, ["+missing"]), "An unknown sampled command does not match");
    // Extra held controls do not prevent an otherwise complete chord
    buttons["+gostand"] = true;
    tests\support\checks::expect(scripts\apparition\menu\customization\bindings::matches(buttons, ["+speed_throw", "+melee", "+gostand"]), "A three-button chord requires all three held controls");
}
