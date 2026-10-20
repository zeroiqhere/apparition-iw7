// Lobby travel descriptors report current readiness without caching coordinates

run()
{
    ready_snapshot_exposes_source_choices_and_counts_other_players();
    cohost_can_use_lobby_teleport_without_becoming_native_host();
    owner_travel_pause_blocks_only_self_and_crosshairs();
    shared_target_reason_disables_every_choice();
    guest_denial_precedes_missing_or_malformed_snapshots();
    missing_malformed_or_empty_snapshots_remain_unavailable();
}

ready_snapshot_exposes_source_choices_and_counts_other_players()
{
    view = view();
    snapshot = view.lobby_teleport;
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(row.kind == "slider" && row.enabled && row.lobby
        && !isDefined(row.target) && row.callback == scripts\apparition\menu\actions::teleport_lobby,
        "Current host readiness exposes a lobby action without one retained player target");
    tests\support\checks::expect(row.description == "Request Teleport for 2 other players; the current host stays in place"
        && !isDefined(row.targets) && !isDefined(row.origin) && view.lobby_teleport == snapshot,
        "The footer counts current targets while the row keeps no player list or coordinates");
    foreach (choice in ["Self", "Crosshairs", "Sky"])
        tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, choice) == "",
            "Every source choice is available when the complete snapshot is ready");
}

owner_travel_pause_blocks_only_self_and_crosshairs()
{
    view = view();
    view.lobby_teleport.owner_reason = "Finish the native portal trip first";
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(row.enabled && scripts\apparition\menu\availability::choice_reason(row, "Self")
        == view.lobby_teleport.owner_reason && scripts\apparition\menu\availability::choice_reason(row, "Crosshairs")
        == view.lobby_teleport.owner_reason,
        "Self and Crosshairs need the host's current travel position or aim");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Sky") == "",
        "Sky uses each target's own origin and remains available during a host-only travel pause");
}

shared_target_reason_disables_every_choice()
{
    view = view();
    view.lobby_teleport.reason = "The player must be alive and out of last stand";
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == view.lobby_teleport.reason,
        "One target's blocked preflight disables the whole lobby movement request");
}

guest_denial_precedes_missing_or_malformed_snapshots()
{
    view = spawnstruct();
    view.host = false;
    view.access = "VIP";
    view.lobby_teleport = 7;
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Co-Host access is required to teleport other players",
        "A guest gets the role boundary before any snapshot fields are read");
    row = scripts\apparition\menu\lobby_teleport_row::build(undefined);
    tests\support\checks::expect(!row.enabled && row.description == "Co-Host access is required to teleport other players",
        "A missing view cannot imply Co-Host authority");
}

cohost_can_use_lobby_teleport_without_becoming_native_host()
{
    view = view();
    view.host = false;
    view.access = "Co-Host";
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(row.enabled && row.lobby && !isDefined(row.target)
        && row.callback == scripts\apparition\menu\actions::teleport_lobby,
        "A ready Co-Host receives lobby Teleport while native Host identity stays false");

    view.access = "VIP";
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(!row.enabled,
        "A role below Co-Host cannot use lobby Teleport even with a ready snapshot");
}

missing_malformed_or_empty_snapshots_remain_unavailable()
{
    view = view();
    view.lobby_teleport = undefined;
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for current lobby travel data",
        "The host cannot infer readiness from a missing snapshot");
    view = view();
    view.lobby_teleport.owner_reason = 7;
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(!row.enabled,
        "A malformed owner reason cannot enable any lobby travel choice");
    view = view();
    view.lobby_teleport.targets = [];
    row = scripts\apparition\menu\lobby_teleport_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "No other current players are available",
        "Solo host state cannot report a successful lobby teleport target set");
}

view()
{
    view = spawnstruct();
    view.host = true;
    view.access = "Host";
    view.lobby_teleport = spawnstruct();
    view.lobby_teleport.reason = "";
    view.lobby_teleport.owner_reason = "";
    view.lobby_teleport.targets = [spawnstruct(), spawnstruct()];
    return view;
}
