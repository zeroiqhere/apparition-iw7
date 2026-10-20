// Saved intent and current damage or effect readiness have separate meanings

run()
{
    the_second_source_row_is_a_personal_toggle_for_the_selected_target();
    demi_god_is_absent_from_quick_and_lobby_controls();
    the_checkbox_reads_demi_god_without_mutating_other_protection();
    enabling_requires_both_the_hook_and_native_feedback_snapshot();
    an_enabled_setting_remains_clearable_after_either_readiness_loss();
    invalid_actor_snapshots_are_rejected_before_target_fields_are_read();
    a_removed_player_is_unavailable_even_with_a_saved_demi_god_flag();
}

the_second_source_row_is_a_personal_toggle_for_the_selected_target()
{
    view = ready_view();
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[1];
    tests\support\checks::expect(rows.size == 31 && rows[0].label == "God Mode"
        && row.label == "Demi-God" && rows[2].label == "Noclip",
        "Demi-God keeps the original second Basic Scripts row");
    tests\support\checks::expect(row.kind == "toggle" && row.enabled && !row.checked
        && row.target == view.target && !row.lobby
        && row.callback == scripts\apparition\menu\actions::toggle_demi_god,
        "The source control dispatches a personal toggle for the selected player");
    tests\support\checks::expect(row.description == "Block damage with native directional hit effects; enabling clears God Mode",
        "The available row explains the protection, feedback and mutual exclusion");
}

demi_god_is_absent_from_quick_and_lobby_controls()
{
    view = ready_view();
    view.host = true;
    view.players = [view.target];
    view.actor_reason = "";
    foreach (page in ["Quick Menu", "All Players"])
    {
        rows = scripts\apparition\menu\model::build(page, view);
        foreach (row in rows)
            tests\support\checks::expect(row.label != "Demi-God",
                "The port does not invent a Quick Menu or lobby Demi-God control");
    }
}

the_checkbox_reads_demi_god_without_mutating_other_protection()
{
    view = ready_view();
    view.target.playerGodmode = true;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(!row.checked && view.target.playerGodmode,
        "God Mode does not check the separate Demi-God row");
    view.target.PlayerDemiGod = true;
    view.target.NoExplosiveDamage = true;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(row.checked && view.target.PlayerDemiGod
        && view.target.playerGodmode && view.target.NoExplosiveDamage,
        "Rendering reads Demi-God intent without repairing or changing any protection flags");
}

enabling_requires_both_the_hook_and_native_feedback_snapshot()
{
    view = ready_view();
    view.god_ready = false;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Enable requires the active Apparition damage callback",
        "Hook loss prevents enabling and explains the missing callback");
    view.god_ready = true;
    view.demi_feedback_reason = "Wait for native hit effects";
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == view.demi_feedback_reason,
        "An unavailable native effect setup prevents enabling with its current reason");
    view.demi_feedback_reason = undefined;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(!row.enabled,
        "An absent native effect snapshot cannot silently enable protection");
    view.demi_feedback_reason = 17;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(!row.enabled,
        "A malformed native effect snapshot cannot silently enable protection");
}

an_enabled_setting_remains_clearable_after_either_readiness_loss()
{
    view = ready_view();
    view.target.PlayerDemiGod = true;
    view.god_ready = false;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(row.checked && row.enabled
        && row.description == "Disable the saved Demi-God setting; damage protection is not confirmed",
        "A checked setting remains clearable while hook ownership is lost");
    view.god_ready = true;
    view.demi_feedback_reason = "Wait for native hit effects";
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(row.checked && row.enabled
        && row.description == "Disable the saved Demi-God setting; directional hit effects are unavailable",
        "Effect loss is explained without turning the checkbox into a false effect receipt");
    view.demi_feedback_reason = undefined;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(row.checked && row.enabled,
        "Clearing does not depend on a present effect snapshot");
}

invalid_actor_snapshots_are_rejected_before_target_fields_are_read()
{
    view = ready_view();
    view.target = 17;
    view.target_actor_reason = "Wait for a valid player roster";
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == view.target_actor_reason,
        "A rejected scalar target is not read for its saved flag");
    view.target_actor_reason = undefined;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked,
        "Missing actor admission fails closed before target state is inspected");
}

a_removed_player_is_unavailable_even_with_a_saved_demi_god_flag()
{
    view = ready_view();
    view.target.PlayerDemiGod = true;
    view.target_actor_reason = "The player is no longer in the current roster";
    view.demi_feedback_reason = view.target_actor_reason;
    row = scripts\apparition\menu\demi_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == view.target_actor_reason,
        "A removed actor is rejected before saved intent can offer a cleanup action");
}

ready_view()
{
    view = spawnstruct();
    view.access = "Verified";
    view.owner_alive = true;
    view.target = spawnstruct();
    view.target_actor_reason = "";
    view.god_ready = true;
    view.demi_feedback_reason = "";
    return view;
}
