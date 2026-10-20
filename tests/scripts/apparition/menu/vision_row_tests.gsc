// Set Vision keeps source choices while gating changes on current target state

run()
{
    the_personal_slider_keeps_the_exact_source_choices_and_default_preview();
    row_reasons_share_the_feature_choice_support_map();
    actor_admission_precedes_typed_vision_snapshot_reads();
    only_a_typed_ready_snapshot_enables_the_row();
    malformed_snapshots_and_overrides_fail_closed();
    basic_scripts_keeps_vision_at_source_row_twenty();
}

the_personal_slider_keeps_the_exact_source_choices_and_default_preview()
{
    view = ready_view();
    row = scripts\apparition\menu\vision_row::build(view);
    expected = scripts\apparition\features\vision::values();

    tests\support\checks::expect(row.label == "Set Vision" && row.kind == "slider"
        && row.callback == scripts\apparition\menu\actions::set_vision
        && row.target == view.target && !row.lobby,
        "Set Vision is a personal slider for the selected target");
    tests\support\checks::expect(row.enabled && row.initial_index == 0
        && isDefined(row.values) && isarray(row.values) && row.values.size == expected.size,
        "A ready snapshot enables the original slider with Default first");
    if (isDefined(row.values) && isarray(row.values) && row.values.size == expected.size)
    {
        for (index = 0; index < expected.size; index++)
        {
            tests\support\checks::expect(row.values[index] == expected[index],
                "The Set Vision slider preserves the source choice order");
        }
    }
    tests\support\checks::expect(!isDefined(row.checked) && !isDefined(row.active_value)
        && !isDefined(row.native_profile) && !isDefined(row.nativeprofile)
        && !isDefined(row.profile) && !isDefined(row.worker) && !isDefined(row.worker_id),
        "The row carries no checkbox, active profile, native profile, or worker payload");
}

row_reasons_share_the_feature_choice_support_map()
{
    view = ready_view();
    row = scripts\apparition\menu\vision_row::build(view);
    expected = scripts\apparition\features\vision::values();
    supported_count = 0;
    blocked_count = 0;

    foreach (value in expected)
    {
        selected = scripts\apparition\features\vision::choice(value, "");
        tests\support\checks::expect(isDefined(row.choice_reasons)
            && isarray(row.choice_reasons) && row.choice_reasons[value] == selected.reason,
            "Each slider choice uses the shared feature reason");
        tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false, value)
            == (selected.reason == ""),
            "Only supported vision choices can enter the menu dispatch path");
        if (selected.reason == "")
            supported_count++;
        else
            blocked_count++;
    }
    tests\support\checks::expect(supported_count == 3 && blocked_count == 7,
        "The source row exposes three supported choices and seven blocked BO3 choices");
    tests\support\checks::expect(isSubStr(row.description, "IW7")
        && isSubStr(row.description, "analogue")
        && isSubStr(row.description, "native")
        && (isSubStr(row.description, "may replace") || isSubStr(row.description, "can replace"))
        && isSubStr(row.description, "effect"),
        "The description identifies IW7 analogues and says native events may replace the effect");
}

actor_admission_precedes_typed_vision_snapshot_reads()
{
    view = spawnstruct();
    view.target = 17;
    view.target_actor_reason = "Wait for a valid player roster";
    view.vision = "malformed snapshot";
    row = scripts\apparition\menu\vision_row::build(view);

    tests\support\checks::expect(!row.enabled && row.target == view.target
        && row.description == view.target_actor_reason,
        "Target admission wins before the malformed vision snapshot is read");
}

only_a_typed_ready_snapshot_enables_the_row()
{
    view = ready_view();
    view.vision.reason = "Native vision snapshot is stale";
    row = scripts\apparition\menu\vision_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == view.vision.reason,
        "A typed snapshot reason keeps stale native vision state unavailable");

    view = ready_view();
    view.vision.reason = "";
    row = scripts\apparition\menu\vision_row::build(view);
    tests\support\checks::expect(row.enabled,
        "A typed snapshot with an empty reason enables the slider");
    tests\support\checks::expect(row.choice_reasons["Default"]
        == scripts\apparition\features\vision::choice("Default", undefined).reason,
        "An absent optional override uses the empty base profile for Default");

    view = ready_view();
    view.vision.override = "iw7_current_vision_override";
    row = scripts\apparition\menu\vision_row::build(view);
    tests\support\checks::expect(row.enabled
        && row.choice_reasons["Default"]
            == scripts\apparition\features\vision::choice("Default",
                view.vision.override).reason,
        "A typed current override shares the feature reason for Default");
}

malformed_snapshots_and_overrides_fail_closed()
{
    view = ready_view();
    view.vision = undefined;
    row = scripts\apparition\menu\vision_row::build(view);
    tests\support\checks::expect(!row.enabled,
        "A missing vision snapshot cannot enable the slider");

    foreach (invalid in [17, "ready", [], (1, 2, 3)])
    {
        view = ready_view();
        view.vision = invalid;
        row = scripts\apparition\menu\vision_row::build(view);
        tests\support\checks::expect(!row.enabled,
            "A scalar, string, array, or vector vision snapshot fails closed");
    }

    view = ready_view();
    view.vision.reason = 17;
    row = scripts\apparition\menu\vision_row::build(view);
    tests\support\checks::expect(!row.enabled,
        "A nonstring vision snapshot reason fails closed");

    foreach (invalid_override in [17, true, [], spawnstruct()])
    {
        view = ready_view();
        view.vision.override = invalid_override;
        row = scripts\apparition\menu\vision_row::build(view);
        tests\support\checks::expect(!row.enabled,
            "A defined nonstring override makes the typed snapshot invalid");
    }
}

basic_scripts_keeps_vision_at_source_row_twenty()
{
    view = ready_view();
    // Block actor reads while checking only the fixture-backed menu position
    view.target_actor_reason = "Wait for a valid player roster";
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows.size == 31 && rows[19].label == "Visual Effects"
        && rows[20].label == "Set Vision" && rows[21].label == "Zombie Charms",
        "Set Vision remains at zero-based Basic Scripts row 20 in the source order");
    tests\support\checks::expect(rows[20].callback == scripts\apparition\menu\actions::set_vision
        && rows[20].target == view.target && !rows[20].lobby,
        "The source-positioned row binds the personal Set Vision action");
}

ready_view()
{
    view = spawnstruct();
    view.target = spawnstruct();
    view.target_actor_reason = "";
    view.vision = spawnstruct();
    view.vision.reason = "";
    return view;
}
