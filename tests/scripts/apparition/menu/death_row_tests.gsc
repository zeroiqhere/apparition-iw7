// Death rows expose Down and keep unsupported Kill visible but blocked

run()
{
    personal_row_keeps_the_source_slider_and_selected_target();
    lobby_row_is_host_scoped_and_keeps_its_source_position();
    ready_rows_use_only_readiness_hints_and_do_not_copy_actor_payloads();
    missing_and_malformed_snapshots_remain_pending();
    empty_or_sparse_ready_targets_cannot_claim_readiness();
    lobby_host_denial_precedes_snapshot_validation();
    cohost_can_use_lobby_down_without_becoming_native_host();
    kill_stays_visible_but_cannot_dispatch();
    basic_scripts_keeps_death_at_source_position();
    all_players_keeps_down_at_source_position();
}

personal_row_keeps_the_source_slider_and_selected_target()
{
    view = ready_view();
    row = scripts\apparition\menu\death_row::build(view, false);

    tests\support\checks::expect(row.label == "Death" && row.kind == "slider"
        && row.callback == scripts\apparition\menu\actions::player_death
        && row.target == view.target && !row.lobby,
        "The personal source row dispatches only for its selected target");
    tests\support\checks::expect(row.values.size == 2
        && row.values[0] == "Down" && row.values[1] == "Kill"
        && row.initial_index == 0 && !isDefined(row.active_value),
        "The source slider previews Down first without inventing active state");
    tests\support\checks::expect(row.enabled && row.description == view.down.hint,
        "A ready personal snapshot supplies the row hint");
}

lobby_row_is_host_scoped_and_keeps_its_source_position()
{
    view = ready_view();
    view.host = true;
    view.players = view.down.targets;
    view.actor_reason = "";
    row = scripts\apparition\menu\death_row::build(view, true);

    tests\support\checks::expect(row.label == "Down" && row.kind == "action"
        && row.callback == scripts\apparition\menu\actions::down_players
        && row.lobby && !isDefined(row.target) && row.enabled,
        "The lobby action targets the current host scope without caching a player");
    tests\support\checks::expect(row.description == view.down.hint
        && !isDefined(row.values) && !isDefined(row.active_value),
        "The lobby action uses its readiness hint without slider state");
}

ready_rows_use_only_readiness_hints_and_do_not_copy_actor_payloads()
{
    view = ready_view();
    snapshot = view.down;
    target = snapshot.targets[0];
    personal = scripts\apparition\menu\death_row::build(view, false);
    view.host = true;
    lobby = scripts\apparition\menu\death_row::build(view, true);

    tests\support\checks::expect(personal.description == snapshot.hint
        && lobby.description == snapshot.hint && snapshot.targets[0] == target,
        "Row inspection leaves the captured readiness snapshot unchanged");
    tests\support\checks::expect(!isDefined(personal.targets) && !isDefined(personal.players)
        && !isDefined(lobby.targets) && !isDefined(lobby.players),
        "Rows carry no captured player list or actor payload");
}

missing_and_malformed_snapshots_remain_pending()
{
    view = ready_view();
    view.down = undefined;
    row = scripts\apparition\menu\death_row::build(view, false);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for down readiness",
        "A missing personal snapshot stays pending");

    foreach (invalid in [7, "ready", [], spawnstruct()])
    {
        view.down = invalid;
        row = scripts\apparition\menu\death_row::build(view, false);
        tests\support\checks::expect(!row.enabled && row.description == "Wait for down readiness",
            "A malformed personal snapshot cannot enable the row");
    }

    view.down = ready_down(view.target);
    view.down.reason = 7;
    row = scripts\apparition\menu\death_row::build(view, false);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for down readiness",
        "A nonstring snapshot reason stays pending");

    view.down = ready_down(view.target);
    view.down.hint = 7;
    row = scripts\apparition\menu\death_row::build(view, false);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for down readiness",
        "A nonstring snapshot hint stays pending");

    view.down = ready_down(view.target);
    view.down.targets = "player";
    row = scripts\apparition\menu\death_row::build(view, false);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for down readiness",
        "A nonarray actor list stays pending");
}

empty_or_sparse_ready_targets_cannot_claim_readiness()
{
    view = ready_view();
    view.down.targets = [];
    row = scripts\apparition\menu\death_row::build(view, false);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for down readiness",
        "An empty ready roster cannot enable Down");

    view.down.targets = [];
    view.down.targets["target"] = view.target;
    row = scripts\apparition\menu\death_row::build(view, false);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for down readiness",
        "A non-dense ready actor list cannot enable Down");

    view.down = ready_down(view.target);
    view.down.reason = "The native player state blocks damage";
    view.down.targets = [];
    row = scripts\apparition\menu\death_row::build(view, false);
    tests\support\checks::expect(!row.enabled
        && row.description == "The native player state blocks damage",
        "A reasoned unavailable snapshot keeps its reason when no targets are eligible");
}

lobby_host_denial_precedes_snapshot_validation()
{
    view = ready_view();
    view.host = false;
    view.access = "VIP";
    view.down = 7;
    row = scripts\apparition\menu\death_row::build(view, true);
    tests\support\checks::expect(!row.enabled
        && row.description == "Co-Host access is required to down current players",
        "Lobby role denial stays ahead of malformed readiness data");
}

cohost_can_use_lobby_down_without_becoming_native_host()
{
    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    row = scripts\apparition\menu\death_row::build(view, true);
    tests\support\checks::expect(row.enabled && row.label == "Down" && row.lobby
        && !isDefined(row.target) && row.callback == scripts\apparition\menu\actions::down_players,
        "A ready Co-Host receives source lobby Down while native Host identity stays false");

    view.access = "VIP";
    row = scripts\apparition\menu\death_row::build(view, true);
    tests\support\checks::expect(!row.enabled,
        "A role below Co-Host cannot use lobby Down even with a ready snapshot");
}

kill_stays_visible_but_cannot_dispatch()
{
    view = ready_view();
    row = scripts\apparition\menu\death_row::build(view, false);
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Down") == ""
        && scripts\apparition\menu\availability::choice_reason(row, "Kill")
            == "Kill is not available in this build",
        "Down is available while Kill shows its unresolved native dependency");
    tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false, "Down")
        && !scripts\apparition\menu\dispatch::can_start(row, false, "Kill"),
        "Slider selection can dispatch Down but cannot dispatch Kill");
}

basic_scripts_keeps_death_at_source_position()
{
    view = model_view();
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[30];
    tests\support\checks::expect(rows.size == 31 && rows[29].label == "Revive"
        && row.label == "Death" && row.callback == scripts\apparition\menu\actions::player_death
        && row.target == view.target && !row.lobby,
        "Basic Scripts retains Death at source position 31");
}

all_players_keeps_down_at_source_position()
{
    view = model_view();
    view.host = true;
    view.access = "Host";
    view.players = [view.target];
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players", view);
    row = rows[8];
    tests\support\checks::expect(rows.size == 14 && row.label == "Down"
        && row.callback == scripts\apparition\menu\actions::down_players
        && row.lobby && !isDefined(row.target),
        "All Players retains Down at source position 9 with host-level scope");
}

ready_view()
{
    view = spawnstruct();
    view.target = spawnstruct();
    view.host = true;
    view.access = "Host";
    view.down = ready_down(view.target);
    return view;
}

ready_down(target)
{
    snapshot = spawnstruct();
    snapshot.reason = "";
    snapshot.hint = "Request native Down; native protection may block damage";
    snapshot.targets = [target];
    return snapshot;
}

model_view()
{
    view = ready_view();
    view.owner_alive = true;
    view.target.apparition_jump_input = spawnstruct();
    view.target.apparition_jump_input.held = false;
    view.target.apparition_jump_input.bound = true;
    view.god_ready = true;
    view.target_actor_reason = "";
    view.score = spawnstruct();
    view.score.reason = "";
    view.score.balance = 500;
    view.score.cap = 999999;
    return view;
}
