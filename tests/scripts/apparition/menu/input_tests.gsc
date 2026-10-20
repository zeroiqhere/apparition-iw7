// Input decisions are checked without synthesizing game input

run()
{
    instruction_reposition_prioritizes_axes_and_has_no_step_controls();
    the_open_chord_does_not_scroll();
    opposed_scroll_inputs_cancel();
    a_single_direction_has_the_source_priority();
    held_use_remains_selected_for_the_source_repeat_cadence();
    slider_input_cannot_change_a_non_slider_row();
    disabling_quick_menu_blocks_only_the_quick_open_chord();
    quick_exit_uses_source_root_and_hold_boundaries();
    held_back_resumes_only_for_the_same_live_menu_session();
    command_cooldowns_include_the_source_poll_wait();
    bool_selection_cooldown_includes_redraw_and_post_redraw_waits();
    width_editor_uses_source_button_priority();
    reposition_editor_uses_source_button_priority();
    editor_waits_include_source_branch_and_outer_delays();
    configured_chords_drive_opening_without_changing_navigation();
    dead_opening_uses_only_the_fixed_ads_jump_chord();
    disabling_quick_also_blocks_dead_opening();
    jump_is_a_dead_only_back_control_with_source_priority();
}

bool_selection_cooldown_includes_redraw_and_post_redraw_waits()
{
    tests\support\checks::expect(scripts\apparition\menu\input::cooldown("select", 0.12, 0.18) == 430,
        "A bool selection holds input through 180 ms redraw, 200 ms post-wait and 50 ms poll");
    tests\support\checks::expect(scripts\apparition\menu\input::cooldown("select", 0.12, 0) == 250,
        "A slider or ordinary action selection keeps the normal source cooldown");
    tests\support\checks::expect(scripts\apparition\menu\input::cooldown("back", 0.12, 0.18) == 250
        && scripts\apparition\menu\input::cooldown("up", 0.12, 0.18) == 195,
        "A selection delay does not alter other command cooldowns");
}

the_open_chord_does_not_scroll()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+speed_throw"] = true;
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, scripts\apparition\menu\layout::defaults(), true) == "open", "ADS plus melee opens the menu");
}

opposed_scroll_inputs_cancel()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+speed_throw"] = true;
    buttons["+attack"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, scripts\apparition\menu\layout::defaults(), true) == "none", "Opposing scroll directions cancel");
}

a_single_direction_has_the_source_priority()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+speed_throw"] = true;
    buttons["+activate"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, scripts\apparition\menu\layout::defaults(), true) == "up", "Scrolling has the original priority over selection");
}

held_use_remains_selected_for_the_source_repeat_cadence()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+activate"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, scripts\apparition\menu\layout::defaults(), true) == "select", "Held Use stays eligible at the source repeat cadence");
}

slider_input_cannot_change_a_non_slider_row()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 3"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, scripts\apparition\menu\layout::defaults(), true) == "none", "A non-slider row ignores slider adjustment");
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, true, scripts\apparition\menu\layout::defaults(), true) == "left", "A held slider accepts the source left control");
    buttons["+actionslot 4"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, true, scripts\apparition\menu\layout::defaults(), true) == "none", "Opposing slider directions cancel");
}

disabling_quick_menu_blocks_only_the_quick_open_chord()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+speed_throw"] = true;
    buttons["+smoke"] = true;
    layout = scripts\apparition\menu\layout::defaults();
    layout.disable_quick_menu = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, scripts\apparition\menu\layout::defaults(), true) == "quick", "The enabled quick chord opens its menu");
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "none", "Disable Quick Menu blocks the outside quick chord");
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "open", "Disable Quick Menu leaves normal menu opening available");
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, layout, true) == "up", "Disable Quick Menu does not alter navigation after opening");
}

quick_exit_uses_source_root_and_hold_boundaries()
{
    tests\support\checks::expect(scripts\apparition\menu\input::back_action("Main", true, undefined) == "close", "Melee closes the main page immediately even when Quick Exit is enabled");
    tests\support\checks::expect(scripts\apparition\menu\input::back_action("Quick Menu", true, undefined) == "close", "Melee closes the quick root immediately even when Quick Exit is enabled");
    tests\support\checks::expect(scripts\apparition\menu\input::back_action("Menu Preferences", false, undefined) == "back", "A submenu press goes back when Quick Exit is disabled");
    tests\support\checks::expect(scripts\apparition\menu\input::back_action("Menu Preferences", true, undefined) == "hold", "A submenu press waits for the source hold decision when Quick Exit is enabled");
    tests\support\checks::expect(scripts\apparition\menu\input::back_action("Menu Preferences", true, 9) == "back", "Fewer than ten source samples go back one page");
    tests\support\checks::expect(scripts\apparition\menu\input::back_action("Menu Preferences", true, 10) == "close", "Ten source samples close the entire menu");
}

held_back_resumes_only_for_the_same_live_menu_session()
{
    tests\support\checks::expect(scripts\apparition\menu\input::can_resume_hold(true, true, true, true), "A live unchanged menu can finish its held back action");
    tests\support\checks::expect(!scripts\apparition\menu\input::can_resume_hold(false, true, true, true), "A closed menu ignores a held back result");
    tests\support\checks::expect(!scripts\apparition\menu\input::can_resume_hold(true, false, true, true), "A released HUD invalidates a held back result");
    tests\support\checks::expect(!scripts\apparition\menu\input::can_resume_hold(true, true, false, true), "An unavailable session cannot resume a held back action");
    tests\support\checks::expect(!scripts\apparition\menu\input::can_resume_hold(true, true, true, false), "A changed menu state invalidates a held back result");
}

command_cooldowns_include_the_source_poll_wait()
{
    tests\support\checks::expect(scripts\apparition\menu\input::cooldown("up", 0.12) == 195, "Scroll includes animation, branch wait and poll wait");
    tests\support\checks::expect(scripts\apparition\menu\input::cooldown("left", 0.12) == 180, "Slider repeats include the 0.13-second wait and poll wait");
    tests\support\checks::expect(scripts\apparition\menu\input::cooldown("select", 0.12) == 250, "Use repeats include the 0.2-second wait and poll wait");
    tests\support\checks::expect(scripts\apparition\menu\input::cooldown("open", 0.12) == 600, "Normal opening includes its own 0.05-second wait");
    tests\support\checks::expect(scripts\apparition\menu\input::cooldown("quick", 0.12) == 550, "Quick opening uses its source delay");
}

width_editor_uses_source_button_priority()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+attack"] = true;
    buttons["+speed_throw"] = true;
    buttons["+actionslot 3"] = true;
    buttons["+actionslot 4"] = true;
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "width") == "width_increase", "Attack wins over ADS, action slots and Melee in the source branch order");
    buttons["+attack"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "width") == "width_decrease", "ADS follows Attack and precedes action slots");
    buttons["+speed_throw"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "width") == "offset_decrease", "Action Slot 3 decreases offset before Action Slot 4");
    buttons["+actionslot 3"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "width") == "offset_increase", "Action Slot 4 increases offset before Melee");
    buttons["+actionslot 4"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "width") == "exit", "Melee exits when no higher-priority editor action is held");
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 1"] = true;
    buttons["+actionslot 2"] = true;
    buttons["+activate"] = true;
    buttons["+smoke"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "width") == "none", "Normal scrolling, selection and quick-menu controls stay blocked in the modal");
}

reposition_editor_uses_source_button_priority()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 1"] = true;
    buttons["+actionslot 2"] = true;
    buttons["+actionslot 3"] = true;
    buttons["+actionslot 4"] = true;
    buttons["+smoke"] = true;
    buttons["+frag"] = true;
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "reposition") == "move_down", "Vertical slots have priority and Action Slot 2 wins when both are pressed");
    buttons["+actionslot 1"] = false;
    buttons["+actionslot 2"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "reposition") == "move_right", "Horizontal slots follow vertical input and Action Slot 4 wins when both are pressed");
    buttons["+actionslot 3"] = false;
    buttons["+actionslot 4"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "reposition") == "offset_decrease", "Secondary Offhand decreases offset before Frag and Melee");
    buttons["+smoke"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "reposition") == "offset_increase", "Frag increases offset before Melee");
    buttons["+frag"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "reposition") == "exit", "Melee exits when no higher-priority reposition action is held");
    buttons["+melee"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "reposition") == "none", "Width controls and normal menu controls have no reposition action");
}

editor_waits_include_source_branch_and_outer_delays()
{
    tests\support\checks::expect(scripts\apparition\menu\input::editor_delay_ms("width_increase") == 75, "Width changes wait 50 milliseconds plus the 25 millisecond outer cadence");
    tests\support\checks::expect(scripts\apparition\menu\input::editor_delay_ms("width_decrease") == 75, "Width decreases use the same source cadence");
    tests\support\checks::expect(scripts\apparition\menu\input::editor_delay_ms("offset_decrease") == 125, "Offset changes wait 100 milliseconds plus the outer cadence");
    tests\support\checks::expect(scripts\apparition\menu\input::editor_delay_ms("offset_increase") == 125, "Offset increases use the same source cadence");
    tests\support\checks::expect(scripts\apparition\menu\input::editor_delay_ms("move_up") == 25 && scripts\apparition\menu\input::editor_delay_ms("move_right") == 25, "Reposition translations wait only for the source outer cadence");
    tests\support\checks::expect(scripts\apparition\menu\input::editor_delay_ms("none") == 25, "An idle editor pass waits only for the source outer cadence");
    tests\support\checks::expect(scripts\apparition\menu\input::editor_delay_ms("exit") == 0, "Melee breaks before the source editor's outer wait");
}

configured_chords_drive_opening_without_changing_navigation()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.open_controls = ["+stance", "+gostand", "+breath_sprint"];
    layout.quick_controls = ["+frag"];
    buttons = tests\fixtures\input::buttons();
    buttons["+stance"] = true;
    buttons["+gostand"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "none", "Two members cannot open a configured three-button chord");
    buttons["+breath_sprint"] = true;
    buttons["+frag"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "open", "The full main chord has priority over a simultaneous quick chord");
    buttons["+stance"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "quick", "A configured one-button quick chord opens independently");
    layout.disable_quick_menu = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "none", "Disable Quick Menu also blocks a custom quick chord");
    buttons["+speed_throw"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, layout, true) == "up", "Remapping opening chords leaves the source navigation controls intact");
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "none", "The old default chord no longer opens after remapping");
}

dead_opening_uses_only_the_fixed_ads_jump_chord()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.open_controls = ["+attack"];
    layout.quick_controls = ["+frag"];
    buttons = tests\fixtures\input::buttons();
    buttons["+attack"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, false) == "none", "A dead player cannot open the main menu with its custom chord");
    buttons["+attack"] = false;
    buttons["+frag"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, false) == "none", "A dead player does not use the configured living quick chord");
    buttons["+frag"] = false;
    buttons["+speed_throw"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, false) == "none", "ADS alone is not the dead quick chord");
    buttons["+gostand"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, false) == "quick", "A dead player uses the fixed ADS plus Jump quick chord");
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "none", "The fixed dead chord does not override custom living chords");
    layout.open_controls = ["+speed_throw", "+gostand"];
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, false) == "quick", "A coincidentally identical main chord still opens only Quick Menu while dead");
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "open", "The same configured main chord retains priority while alive");
    buttons["+speed_throw"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, false) == "none", "Jump alone cannot open the dead Quick Menu");
}

disabling_quick_also_blocks_dead_opening()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.disable_quick_menu = true;
    buttons = tests\fixtures\input::buttons();
    buttons["+speed_throw"] = true;
    buttons["+gostand"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, false) == "none", "Disable Quick Menu blocks the fixed dead chord");
    buttons["+gostand"] = false;
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, false, false, layout, true) == "open", "The disable flag continues to allow a living main-menu opening");
}

jump_is_a_dead_only_back_control_with_source_priority()
{
    layout = scripts\apparition\menu\layout::defaults();
    buttons = tests\fixtures\input::buttons();
    buttons["+gostand"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, layout, false) == "back", "Jump backs out of a dead-open menu");
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, layout, true) == "none", "Jump is not a living menu back control");
    buttons["+speed_throw"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, layout, false) == "up", "Source scrolling still has priority over dead Jump back");
    buttons["+speed_throw"] = false;
    buttons["+activate"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, false, layout, false) == "select", "Source Use still has priority over dead Jump back");
    buttons["+activate"] = false;
    buttons["+actionslot 3"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::command(buttons, true, true, layout, false) == "left", "An eligible slider keeps priority over dead Jump back");
    tests\support\checks::expect(scripts\apparition\menu\input::back_action("Perk Menu", true, 0) == "back", "Dead Jump with no held Melee goes back immediately even with Quick Exit enabled");
}

instruction_reposition_prioritizes_axes_and_has_no_step_controls()
{
    buttons = tests\fixtures\input::buttons();
    buttons["+actionslot 1"] = true;
    buttons["+actionslot 2"] = true;
    buttons["+actionslot 3"] = true;
    buttons["+actionslot 4"] = true;
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "instructions") == "move_down",
        "Both vertical controls resolve to Down before horizontal input and Exit");
    buttons["+actionslot 1"] = false;
    buttons["+actionslot 2"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "instructions") == "move_right",
        "Both horizontal controls resolve to Right before Exit");
    buttons["+actionslot 3"] = false;
    buttons["+actionslot 4"] = false;
    buttons["+smoke"] = true;
    buttons["+frag"] = true;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "instructions") == "exit",
        "Offhand buttons cannot change the fixed instruction movement step");
    buttons["+melee"] = false;
    tests\support\checks::expect(scripts\apparition\menu\input::editor_command(buttons, "instructions") == "none",
        "Unrelated controls leave instruction repositioning idle");
}
