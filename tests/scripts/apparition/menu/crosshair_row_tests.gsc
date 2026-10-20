// Slider preview, saved text and native HUD presence remain separate

run()
{
    source_choices_default_to_disable_for_the_selected_personal_target();
    configured_text_does_not_replace_the_slider_preview();
    missing_hud_handles_and_unknown_records_remain_clearable();
    invalid_actor_snapshots_block_before_target_field_reads();
    switching_to_an_empty_name_keeps_preview_and_action_in_range();
}

source_choices_default_to_disable_for_the_selected_personal_target()
{
    view = ready_view();
    row = scripts\apparition\menu\crosshair_row::build(view);
    tests\support\checks::expect(row.label == "Custom Crosshairs" && row.kind == "slider"
        && row.enabled && !row.lobby && row.target == view.target,
        "Crosshairs remain a personal control for the selected target");
    tests\support\checks::expect(row.callback == scripts\apparition\menu\actions::set_crosshair
        && row.values.size == 14 && row.values[0] == "Disable" && row.values[13] == "Player",
        "The source catalog order and cleaned selected-player choice feed the slider");
    tests\support\checks::expect(row.active_value == "Disable"
        && row.description == "Configured: Disable; Use applies the preview text",
        "The initial configured value is distinct from the source Disable preview");
}

configured_text_does_not_replace_the_slider_preview()
{
    view = ready_view();
    record = spawnstruct();
    record.text = "@";
    record.element = spawnstruct();
    view.target.apparition_crosshair = record;
    row = scripts\apparition\menu\crosshair_row::build(view);
    state = scripts\apparition\menu\state::create(view.target);
    state.page = "Basic Scripts";
    tests\support\checks::expect(row.active_value == "@" && row.values[0] == "Disable"
        && scripts\apparition\menu\state::slider_value(state, row) == "Disable",
        "An enabled overlay does not silently apply or preview a different text choice");
    tests\support\checks::expect(row.description == "Configured: @; Use applies the preview text; native visibility is unconfirmed",
        "An owned handle is not presented as confirmed rendered visibility");
    tests\support\checks::expect(view.target.apparition_crosshair == record
        && record.text == "@" && isDefined(record.element), "Rendering changes neither configuration nor HUD ownership");
}

missing_hud_handles_and_unknown_records_remain_clearable()
{
    view = ready_view();
    record = spawnstruct();
    record.text = "+";
    view.target.apparition_crosshair = record;
    row = scripts\apparition\menu\crosshair_row::build(view);
    tests\support\checks::expect(row.enabled && row.active_value == "+"
        && row.description == "Configured: +; HUD handle missing; Use applies the preview text",
        "Saved text remains visible and Disable remains selectable after losing the native handle");
    record.text = undefined;
    row = scripts\apparition\menu\crosshair_row::build(view);
    tests\support\checks::expect(row.enabled && row.active_value == "Unknown"
        && row.values[0] == "Disable", "Unknown saved state can still be replaced or disabled");
}

invalid_actor_snapshots_block_before_target_field_reads()
{
    view = spawnstruct();
    view.target = 17;
    view.target_actor_reason = "Wait for a valid player roster";
    row = scripts\apparition\menu\crosshair_row::build(view);
    tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
        && row.description == view.target_actor_reason && row.values.size == 13,
        "An invalid selected actor is never read for name, saved text or HUD ownership");
    view = ready_view();
    view.target_actor_reason = undefined;
    row = scripts\apparition\menu\crosshair_row::build(view);
    tests\support\checks::expect(!row.enabled, "Missing actor admission data fails closed");
}

switching_to_an_empty_name_keeps_preview_and_action_in_range()
{
    view = ready_view();
    row = scripts\apparition\menu\crosshair_row::build(view);
    state = scripts\apparition\menu\state::create(view.target);
    state.page = "Basic Scripts";
    state.choices[state.page] = [];
    state.choices[state.page][row.label] = 13;
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "Player",
        "The final dynamic choice initially resolves to the selected player's name");
    view.target.name = "^1";
    row = scripts\apparition\menu\crosshair_row::build(view);
    tests\support\checks::expect(row.values.size == 13
        && scripts\apparition\menu\state::slider_index(state, row) == 12
        && scripts\apparition\menu\state::slider_value(state, row) == "discord.gg/apparitionbo3",
        "A smaller dynamic catalog clamps the same index for display and selection");
    scripts\apparition\menu\state::adjust_slider(state, row, 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "Disable",
        "Right from the displayed final remaining choice wraps to Disable");
}

ready_view()
{
    view = spawnstruct();
    view.target = spawnstruct();
    view.target.name = "^1Player";
    view.target_actor_reason = "";
    return view;
}
