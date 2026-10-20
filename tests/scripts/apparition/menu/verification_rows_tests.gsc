// Verification rows render a read-only access snapshot and bind session grants

run()
{
    personal_rows_keep_assignable_order_and_session_only_save_notice();
    personal_rows_check_only_the_current_level_and_block_reassignment();
    cohost_player_access_cannot_enable_verification_assignments();
    host_self_roster_and_pending_reasons_keep_their_precedence();
    protected_or_malformed_current_levels_never_enable_assignment();
    lobby_rows_ignore_stale_or_missing_personal_targets();
    lobby_rows_grant_only_to_eligible_players_without_checkboxes();
    lobby_rows_disable_levels_already_held_by_every_eligible_player();
    invalid_lobby_snapshots_and_noop_grants_stay_disabled();
}

personal_rows_keep_assignable_order_and_session_only_save_notice()
{
    view = ready_view();
    rows = scripts\apparition\menu\verification_rows::build(view);
    expected = scripts\apparition\runtime\access::assignable();
    tests\support\checks::expect(rows.size == expected.size + 1
        && rows[0].label == "Save Verification" && !rows[0].enabled
        && !isDefined(rows[0].callback) && rows[0].kind == "unavailable",
        "Personal verification begins with an explicitly unavailable save row");
    tests\support\checks::expect(rows[0].description == "Verification grants last only for this session; persistence is not verified",
        "The save row explains the session-only limit without promising persistence");
    if (rows.size != expected.size + 1)
        return;

    for (index = 0; index < expected.size; index++)
    {
        row = rows[index + 1];
        tests\support\checks::expect(row.label == expected[index]
            && row.access_level == expected[index] && row.kind == "toggle",
            "Personal access levels follow the canonical assignable order");
        tests\support\checks::expect(row.callback == scripts\apparition\menu\actions::set_verification
            && row.target == view.target && !row.lobby,
            "Each personal level binds only the selected player action");
    }
    tests\support\checks::expect(rows[1].label == "None" && rows[1].checked,
        "None remains an assignable choice that clears a current grant");
    tests\support\checks::expect(!rows[2].checked && rows[2].enabled,
        "A different supported level is available for the selected player");
}

personal_rows_check_only_the_current_level_and_block_reassignment()
{
    view = ready_view();
    view.player_access[1].access = "VIP";
    rows = scripts\apparition\menu\verification_rows::build(view);
    for (index = 0; index < rows.size - 1; index++)
    {
        row = rows[index + 1];
        tests\support\checks::expect(row.checked == (row.access_level == "VIP"),
            "Only the typed current access level is checked");
        if (row.access_level == "VIP")
            tests\support\checks::expect(!row.enabled && row.description == "This player already has this verification level",
                "Repeating the existing level is disabled with a direct explanation");
        else
            tests\support\checks::expect(row.enabled,
                "A distinct assignable level remains available");
    }
    tests\support\checks::expect(view.player_access[1].access == "VIP",
        "Rendering the snapshot changes no access assignment");
}

host_self_roster_and_pending_reasons_keep_their_precedence()
{
    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[1].access = undefined;
    rows = scripts\apparition\menu\verification_rows::build(view);
    expect_personal_disabled(rows, "Only the current host can manage verification",
        "Host denial precedes pending access data");

    view = ready_view();
    view.target = view.owner;
    rows = scripts\apparition\menu\verification_rows::build(view);
    expect_personal_disabled(rows, "The host cannot change their own verification level",
        "The host cannot assign a level to self");

    view = ready_view();
    view.players = [view.owner];
    rows = scripts\apparition\menu\verification_rows::build(view);
    expect_personal_disabled(rows, scripts\apparition\menu\player_rows::selection_reason(view),
        "A stale target roster reason precedes access-level reads");

    view = ready_view();
    view.player_access[1].access = undefined;
    rows = scripts\apparition\menu\verification_rows::build(view);
    expect_personal_disabled(rows, "Wait for current player verification",
        "A missing access snapshot is pending rather than an enabled assignment");
}

cohost_player_access_cannot_enable_verification_assignments()
{
    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[0].access = "Co-Host";
    tests\support\checks::expect(scripts\apparition\menu\player_rows::selection_reason(view) == "",
        "A current Co-Host may select the nonhost player for gameplay controls");
    rows = scripts\apparition\menu\verification_rows::build(view);
    expect_personal_disabled(rows, "Only the current host can manage verification",
        "Player-control access cannot enable native-host-only verification assignments");
    for (index = 1; index < rows.size; index++)
        tests\support\checks::expect(!rows[index].checked,
            "Denied verification rows cannot claim a selectable current grant");
}

protected_or_malformed_current_levels_never_enable_assignment()
{
    foreach (level_name in ["Bot", "Host", "Developer", "Unknown", 7])
    {
        view = ready_view();
        view.player_access[1].access = level_name;
        rows = scripts\apparition\menu\verification_rows::build(view);
        if (level_name == "Unknown" || !isstring(level_name))
            reason = "Wait for current player verification";
        else
            reason = "This player has a protected verification level";
        expect_personal_disabled(rows, reason,
            "Protected or malformed current levels cannot be overwritten");
        for (index = 1; index < rows.size; index++)
            tests\support\checks::expect(!rows[index].checked,
                "An unassignable or unknown level checks no assignable row");
    }
}

lobby_rows_ignore_stale_or_missing_personal_targets()
{
    view = ready_view();
    view.player_access = [access_record(view.owner, "Host"), access_record(view.target, "None")];
    view.target = undefined;
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    tests\support\checks::expect(rows[1].enabled,
        "A missing personal target does not block a valid lobby assignment");

    view = ready_view();
    view.player_access = [access_record(view.owner, "Host"), access_record(view.target, "None")];
    stale_target = spawnstruct();
    view.target = stale_target;
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    tests\support\checks::expect(rows[1].enabled,
        "A stale personal target does not block a valid lobby assignment");
    tests\support\checks::expect(!isDefined(rows[1].target),
        "Lobby action rows remain unbound to the selected personal target");
}

lobby_rows_grant_only_to_eligible_players_without_checkboxes()
{
    view = ready_view();
    third = spawnstruct();
    view.players = [view.owner, view.target, third];
    view.player_access = [
        access_record(view.owner, "Host"),
        access_record(view.target, "Verified"),
        access_record(third, "None")
    ];
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    expected = scripts\apparition\runtime\access::assignable();
    tests\support\checks::expect(rows.size == expected.size,
        "The lobby page omits the personal save row");
    if (rows.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
    {
        row = rows[index];
        tests\support\checks::expect(row.label == expected[index]
            && row.access_level == expected[index] && row.kind == "action"
            && !isDefined(row.checked),
            "Lobby levels preserve source order without misleading checkboxes");
        tests\support\checks::expect(row.callback == scripts\apparition\menu\actions::set_verification_all
            && !isDefined(row.target) && row.lobby,
            "Lobby levels bind a bulk host action without a selected-player target");
        tests\support\checks::expect(row.enabled,
            "A valid differing eligible member enables each lobby grant");
    }
    tests\support\checks::expect(view.target.access_level == "unchanged"
        && view.owner.access_level == "unchanged",
        "Lobby rendering changes no player's access record");
}

lobby_rows_disable_levels_already_held_by_every_eligible_player()
{
    view = ready_view();
    view.player_access = [
        access_record(view.owner, "Host"),
        access_record(view.target, "Verified")
    ];
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    tests\support\checks::expect(!rows[1].enabled
        && rows[1].description == "No eligible player needs a different verification level",
        "An all-Verified eligible roster cannot dispatch a redundant Verified grant");
    tests\support\checks::expect(rows[0].enabled && rows[2].enabled
        && rows[3].enabled && rows[4].enabled,
        "Other levels stay available when at least one eligible player would change");

    view.player_access = [
        access_record(view.owner, "Host"),
        access_record(view.target, "Bot")
    ];
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    expect_lobby_disabled(rows, "No eligible player needs a different verification level",
        "Protected bot roles are excluded from lobby assignment");
}

invalid_lobby_snapshots_and_noop_grants_stay_disabled()
{
    view = ready_view();
    view.player_access = undefined;
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    expect_lobby_disabled(rows, "Wait for a complete player verification snapshot",
        "Missing roster access data cannot enable a bulk assignment");

    view = ready_view();
    view.player_access = [access_record(view.owner, "Host"), access_record(view.target, 7)];
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    expect_lobby_disabled(rows, "Wait for a complete player verification snapshot",
        "A malformed access entry invalidates the full lobby snapshot");

    view = ready_view();
    view.player_access = [access_record(view.owner, "Host"),
        access_record(view.target, "None")];
    view.player_access[1].player = view.owner;
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    expect_lobby_disabled(rows, "Wait for a complete player verification snapshot",
        "Duplicate access entries cannot stand in for a missing current player");

    view = ready_view();
    view.players = [view.owner];
    view.player_access = [access_record(view.owner, "Host")];
    owner = spawnstruct();
    view.owner = owner;
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    expect_lobby_disabled(rows, "Wait for a valid player roster",
        "An owner outside the captured roster blocks every lobby grant");

    view = ready_view();
    view.players = [view.owner];
    view.player_access = [access_record(view.owner, "Host")];
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    expect_lobby_disabled(rows, "No eligible player needs a different verification level",
        "A host-only roster has no eligible target for bulk assignment");

    view = ready_view();
    view.host = false;
    rows = scripts\apparition\menu\verification_rows::build(view, true);
    expect_lobby_disabled(rows, "Only the current host can open player controls",
        "Lobby host denial takes precedence over other reasons");
}

expect_personal_disabled(rows, reason, message)
{
    tests\support\checks::expect(rows.size == 6,
        "Personal denial keeps the save row and all five assignable rows");
    if (rows.size != 6)
        return;
    for (index = 1; index < rows.size; index++)
    {
        tests\support\checks::expect(!rows[index].enabled && rows[index].description == reason,
            message);
    }
}

expect_lobby_disabled(rows, reason, message)
{
    tests\support\checks::expect(rows.size == 5,
        "Lobby denial keeps all five assignable actions");
    if (rows.size != 5)
        return;
    foreach (row in rows)
    {
        tests\support\checks::expect(!row.enabled && row.description == reason,
            message);
    }
}

ready_view()
{
    view = spawnstruct();
    owner = spawnstruct();
    owner.access_level = "unchanged";
    target = spawnstruct();
    target.access_level = "unchanged";
    view.owner = owner;
    view.target = target;
    view.players = [owner, target];
    view.host = true;
    view.access = "Host";
    view.actor_reason = "";
    view.player_access = [access_record(owner, "Host"), access_record(target, "None")];
    return view;
}

access_record(player, access)
{
    record = spawnstruct();
    record.player = player;
    record.access = access;
    return record;
}
