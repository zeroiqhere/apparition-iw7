// Insta-Kill exposes source choices while keeping target state read-only

run()
{
    the_slider_uses_source_modes_and_separates_preview_from_configuration();
    native_hook_loss_blocks_enabling_modes_but_keeps_disable_available();
    valid_snapshot_reasons_and_unknown_modes_fail_closed_or_remain_recoverable();
    malformed_snapshots_do_not_create_a_ready_slider();
    target_admission_precedes_insta_kill_snapshot_reads();
    rendering_keeps_configuration_and_target_unchanged_without_native_fields();
}

the_slider_uses_source_modes_and_separates_preview_from_configuration()
{
    view = ready_view("All", "");
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(row.enabled && row.values.size == 3
        && row.values[0] == "Disable" && row.values[1] == "All" && row.values[2] == "Melee"
        && row.initial_index == 0 && row.active_value == "All",
        "The slider uses canonical modes while retaining the actual configured mode separately from its Disable preview");
    tests\support\checks::expect(row.choice_reasons["Disable"] == ""
        && row.choice_reasons["All"] == "" && row.choice_reasons["Melee"] == "",
        "Each source choice is enabled when the damage hook is ready");
    tests\support\checks::expect(row.description == "Configured: All; Use applies preview. Preserves Brute and Grey protections; accepted hits only, kills unconfirmed.",
        "Ready copy keeps the configured mode, protections and accepted-hit limit concise");

    foreach (configured_mode in ["Disable", "Melee", "Unknown"])
    {
        view.insta_kill.mode = configured_mode;
        row = scripts\apparition\menu\insta_kill_row::build(view);
        tests\support\checks::expect(row.enabled && row.active_value == configured_mode
            && row.initial_index == 0,
            "Each valid configured mode or Unknown stays distinct from the initial slider preview");
    }
}

native_hook_loss_blocks_enabling_modes_but_keeps_disable_available()
{
    view = ready_view("All", "Enable requires the active Apparition damage callback");
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(row.enabled && row.active_value == "All"
        && row.choice_reasons["Disable"] == ""
        && row.choice_reasons["All"] == view.insta_kill.hook_reason
        && row.choice_reasons["Melee"] == view.insta_kill.hook_reason,
        "Lost hook readiness blocks both enable modes but leaves Disable available to clear configuration");
    tests\support\checks::expect(row.description == "Configured: All; " + view.insta_kill.hook_reason
        + "; use Disable to clear. Preserves Brute and Grey protections; accepted hits only, kills unconfirmed.",
        "Hook-loss copy retains the exact reason and concise cleanup and effect limits");
}

valid_snapshot_reasons_and_unknown_modes_fail_closed_or_remain_recoverable()
{
    view = ready_view("Melee", "");
    view.insta_kill.reason = "Wait for a current Insta-Kill snapshot";
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == view.insta_kill.reason,
        "A valid pending base snapshot reason disables the slider");

    view = ready_view("Unknown", "");
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(row.enabled && row.active_value == "Unknown"
        && row.initial_index == 0 && row.choice_reasons["Disable"] == "",
        "Unknown saved state remains recoverable through the Disable preview");
}

malformed_snapshots_do_not_create_a_ready_slider()
{
    view = ready_view("Disable", "");
    view.insta_kill = undefined;
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
        && row.description == "Wait for a current Insta-Kill snapshot",
        "A missing snapshot leaves the slider disabled and active mode unknown");

    foreach (invalid in [17, "ready", (1, 2, 3), []])
    {
        view.insta_kill = invalid;
        row = scripts\apparition\menu\insta_kill_row::build(view);
        tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
            && row.description == "Wait for a current Insta-Kill snapshot",
            "Scalar, string, vector and array snapshots fail closed");
    }

    view.insta_kill = ready_snapshot("All", "");
    view.insta_kill.reason = undefined;
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
        && row.description == "Wait for a current Insta-Kill snapshot",
        "A missing typed snapshot reason fails closed");

    view.insta_kill = ready_snapshot("All", "");
    view.insta_kill.mode = undefined;
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
        && row.description == "Wait for a current Insta-Kill snapshot",
        "A missing typed snapshot mode fails closed");

    view.insta_kill = ready_snapshot("All", "");
    view.insta_kill.hook_reason = undefined;
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
        && row.description == "Wait for a current Insta-Kill snapshot",
        "A missing typed hook reason fails closed");

    foreach (invalid_reason in [17, 1])
    {
        view.insta_kill = ready_snapshot("All", "");
        view.insta_kill.reason = invalid_reason;
        row = scripts\apparition\menu\insta_kill_row::build(view);
        tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
            && row.description == "Wait for a current Insta-Kill snapshot",
            "A non-string base reason is malformed");

        view.insta_kill = ready_snapshot("All", "");
        view.insta_kill.hook_reason = invalid_reason;
        row = scripts\apparition\menu\insta_kill_row::build(view);
        tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
            && row.description == "Wait for a current Insta-Kill snapshot",
            "A non-string hook reason is malformed");
    }

    foreach (invalid_mode in [17, "Damage Everything"])
    {
        view.insta_kill = ready_snapshot("Unknown", "");
        view.insta_kill.mode = invalid_mode;
        row = scripts\apparition\menu\insta_kill_row::build(view);
        tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
            && row.description == "Wait for a current Insta-Kill snapshot",
            "A mode outside the exact source choices and Unknown fails closed");
    }
}

target_admission_precedes_insta_kill_snapshot_reads()
{
    row = scripts\apparition\menu\insta_kill_row::build(undefined);
    tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
        && !isDefined(row.target) && row.description == "Wait for a valid player roster",
        "An absent view cannot enable the slider or supply a target");
    foreach (invalid_view in [17, "view", []])
    {
        row = scripts\apparition\menu\insta_kill_row::build(invalid_view);
        tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
            && !isDefined(row.target) && row.description == "Wait for a valid player roster",
            "An absent or malformed view cannot enable the slider or supply a target");
    }

    view = ready_view("All", "");
    view.target = 17;
    view.target_actor_reason = "The selected player is no longer in the current roster";
    view.insta_kill = "malformed snapshot";
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(!row.enabled && row.active_value == "Unknown"
        && row.target == view.target && row.description == view.target_actor_reason,
        "Actor admission wins over a malformed snapshot and keeps the personal target scope");
}

rendering_keeps_configuration_and_target_unchanged_without_native_fields()
{
    view = ready_view("Melee", "");
    view.target.InstaKillSentinel = "unchanged";
    row = scripts\apparition\menu\insta_kill_row::build(view);
    tests\support\checks::expect(row.active_value == "Melee"
        && view.insta_kill.mode == "Melee" && view.target.InstaKillSentinel == "unchanged",
        "Rendering reads the configured mode without mutating its snapshot or target");
    tests\support\checks::expect(!isDefined(row.checked) && !isDefined(row.packet)
        && !isDefined(row.enemy) && !isDefined(row.enemy_ref) && !isDefined(row.damage)
        && !isDefined(row.weapon) && !isDefined(row.origin) && !isDefined(row.handle)
        && !isDefined(row.native_state) && !isDefined(row.grant),
        "The slider stores no checkbox, native packet, enemy, weapon, origin, handle or grant state");
}

ready_view(mode_value, hook_reason)
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.target_actor_reason = "";
    view.insta_kill = ready_snapshot(mode_value, hook_reason);
    return view;
}

ready_snapshot(mode_value, hook_reason)
{
    snapshot = spawnstruct();
    snapshot.reason = "";
    snapshot.mode = mode_value;
    snapshot.hook_reason = hook_reason;
    return snapshot;
}
