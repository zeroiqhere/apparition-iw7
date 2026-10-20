// Player-message rows retain their selected or lobby scope and source keyboard action

run()
{
    selected_row_keeps_the_current_target_and_keyboard_callback();
    selected_row_obeys_current_player_and_target_role_protection();
    lobby_row_requires_a_current_owner_with_manage_access_and_another_player();
    cohost_lobby_row_keeps_the_current_host_as_a_recipient();
    lobby_row_rejects_missing_malformed_and_solo_rosters();
    missing_views_return_a_disabled_message_action();
}

selected_row_keeps_the_current_target_and_keyboard_callback()
{
    view = ready_view();
    row = scripts\apparition\menu\player_message_row::build(view, false);

    tests\support\checks::expect(row.label == "Send Message" && row.kind == "action"
        && row.callback == scripts\apparition\menu\actions::open_player_message_keyboard,
        "The selected-player Options entry opens the player-message keyboard");
    tests\support\checks::expect(row.target == view.target && !row.lobby && row.enabled,
        "A permitted selected-player row keeps the exact current target and personal scope");
}

selected_row_obeys_current_player_and_target_role_protection()
{
    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[0].access = "Co-Host";
    host_target = spawnstruct();
    host_target.name = "Current Host";
    view.target = host_target;
    view.players[view.players.size] = host_target;
    add_role(view, host_target, "Host");
    row = scripts\apparition\menu\player_message_row::build(view, false);

    tests\support\checks::expect(!row.enabled && row.target == host_target && !row.lobby,
        "A Co-Host cannot open a selected message keyboard for the current Host");

    view = ready_view();
    view.host = false;
    view.access = "VIP";
    view.player_access[0].access = "VIP";
    row = scripts\apparition\menu\player_message_row::build(view, false);
    tests\support\checks::expect(!row.enabled,
        "A verified player below Co-Host cannot open another player's message keyboard");

    view = ready_view();
    view.players = [view.owner];
    row = scripts\apparition\menu\player_message_row::build(view, false);
    tests\support\checks::expect(!row.enabled,
        "A departed selected target cannot retain an enabled message action");
}

lobby_row_requires_a_current_owner_with_manage_access_and_another_player()
{
    view = ready_view();
    row = scripts\apparition\menu\player_message_row::build(view, true);
    tests\support\checks::expect(row.enabled && row.target == view.owner && row.lobby,
        "A current Host with another current player can open the lobby message keyboard");

    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[0].access = "Co-Host";
    row = scripts\apparition\menu\player_message_row::build(view, true);
    tests\support\checks::expect(row.enabled && row.target == view.owner && row.lobby,
        "A current Co-Host with another current player can open the lobby message keyboard");

    view = ready_view();
    view.host = false;
    view.access = "VIP";
    view.player_access[0].access = "VIP";
    row = scripts\apparition\menu\player_message_row::build(view, true);
    tests\support\checks::expect(!row.enabled,
        "A verified player below Co-Host cannot open the lobby message keyboard");
}

cohost_lobby_row_keeps_the_current_host_as_a_recipient()
{
    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[0].access = "Co-Host";
    current_host = spawnstruct();
    current_host.name = "Current Host";
    view.players = [view.owner, current_host];
    view.player_access = [role_entry(view.owner, "Co-Host"), role_entry(current_host, "Host")];

    recipients = scripts\apparition\runtime\context::other_players(view.players, view.owner);
    row = scripts\apparition\menu\player_message_row::build(view, true);
    tests\support\checks::expect(recipients.size == 1 && recipients[0] == current_host,
        "The lobby recipient selection excludes the Co-Host sender while retaining the current Host");
    tests\support\checks::expect(row.enabled && row.target == view.owner && row.lobby,
        "A current Host counts as another recipient for a Co-Host lobby message");
}

lobby_row_rejects_missing_malformed_and_solo_rosters()
{
    view = ready_view();
    view.players = [view.target];
    row = scripts\apparition\menu\player_message_row::build(view, true);
    tests\support\checks::expect(!row.enabled,
        "A lobby message is unavailable when its owner is no longer current");

    view = ready_view();
    view.players = [view.owner];
    view.player_access = [role_entry(view.owner, "Host")];
    row = scripts\apparition\menu\player_message_row::build(view, true);
    tests\support\checks::expect(!row.enabled,
        "A solo roster has no lobby recipient and cannot open the message keyboard");

    view = ready_view();
    view.actor_reason = "Wait for a valid player roster";
    row = scripts\apparition\menu\player_message_row::build(view, true);
    tests\support\checks::expect(!row.enabled,
        "A rejected actor snapshot cannot enable the lobby message action");

    view = ready_view();
    view.players = "invalid";
    row = scripts\apparition\menu\player_message_row::build(view, true);
    tests\support\checks::expect(!row.enabled,
        "A malformed roster cannot be iterated to enable a lobby message");
}

missing_views_return_a_disabled_message_action()
{
    row = scripts\apparition\menu\player_message_row::build(undefined, false);
    tests\support\checks::expect(row.label == "Send Message" && !row.enabled
        && row.callback == scripts\apparition\menu\actions::open_player_message_keyboard
        && !isDefined(row.target) && !row.lobby,
        "A missing selected-player view returns the source action disabled without a target");

    row = scripts\apparition\menu\player_message_row::build(undefined, true);
    tests\support\checks::expect(!row.enabled && !isDefined(row.target) && row.lobby,
        "A missing lobby view returns the source action disabled without an owner");
}

ready_view()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.owner.name = "Host";
    view.target = spawnstruct();
    view.target.name = "Guest";
    view.players = [view.owner, view.target];
    view.actor_reason = "";
    view.host = true;
    view.access = "Host";
    view.player_access = [role_entry(view.owner, "Host"), role_entry(view.target, "None")];
    return view;
}

add_role(view, player, access)
{
    view.player_access[view.player_access.size] = role_entry(player, access);
}

role_entry(player, access)
{
    entry = spawnstruct();
    entry.player = player;
    entry.access = access;
    return entry;
}
