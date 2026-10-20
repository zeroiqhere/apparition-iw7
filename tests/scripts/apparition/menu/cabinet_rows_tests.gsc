// Cabinet guidance cannot turn a sampled predicate into quest completion

run()
{
    final_ghost_step_opens_owner_bound_requirements_without_activating();
    passing_count_and_player_blockers_share_one_snapshot();
    long_blocker_text_stays_in_the_selected_row_footer();
    all_passing_members_still_require_the_native_hold();
    unavailable_and_malformed_snapshots_never_report_passing_players();
}

final_ghost_step_opens_owner_bound_requirements_without_activating()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.ghost_progress = spawnstruct();
    view.ghost_progress.step = 6;
    view.ghost_progress.activated = false;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    row = rows[7];
    tests\support\checks::expect(row.label == "Activate Cabinet" && row.enabled
        && row.kind == "submenu" && row.destination == "Cabinet Activation",
        "The final native step opens its requirements page at its existing position");
    tests\support\checks::expect(row.target == view.owner && !row.lobby
        && row.callback == scripts\apparition\menu\actions::open_page && !row.checked,
        "Guests can inspect their owner-bound page without issuing activation input");
    view.ghost_progress.activated = true;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows[7].checked && rows[7].kind == "toggle"
        && rows[7].enabled && rows[7].destination == "Cabinet Activation",
        "Observed completion keeps its checkbox while the retry requirements remain reachable");
    tests\support\checks::expect(view.ghost_progress.activated && view.ghost_progress.step == 6,
        "Navigation rendering changes no progress fields");
}

passing_count_and_player_blockers_share_one_snapshot()
{
    view = snapshot_view();
    member = spawnstruct();
    member.name = "Player B";
    member.reason = "Leave last stand";
    view.cabinet_activation.members[1] = member;
    rows = scripts\apparition\menu\model::build("Cabinet Activation", view);
    tests\support\checks::expect(rows.size == 5 && rows[0].label == "Hold Use Together",
        "The page has instructions, route, count and each current member");
    tests\support\checks::expect(rows[1].label == "Cabinet Route: Initial Unlock"
        && rows[2].label == "Passing Now: 1/2", "The count includes every captured roster member");
    tests\support\checks::expect(rows[3].label == "Player A: Passing Now"
        && rows[4].label == "Player B: Blocked" && rows[4].description == "Leave last stand",
        "Compact member labels keep the sampled blocker in their selected footer");
    foreach (row in rows)
        tests\support\checks::expect(!row.enabled && !isDefined(row.callback)
            && row.kind != "toggle", "Requirements rows never dispatch input or display completion checkboxes");
    tests\support\checks::expect(view.cabinet_activation.members[1] == member
        && member.reason == "Leave last stand", "Rendering leaves the captured roster unchanged");
}

long_blocker_text_stays_in_the_selected_row_footer()
{
    view = snapshot_view();
    view.cabinet_activation.members[0].reason = "Move within 50 units of the cabinet corner";
    rows = scripts\apparition\menu\model::build("Cabinet Activation", view);
    tests\support\checks::expect(rows[3].label == "Player A: Blocked"
        && rows[3].description == view.cabinet_activation.members[0].reason,
        "Long blocker text uses the existing wrapped footer instead of overflowing the player label");
    tests\support\checks::expect(rows[2].label == "Passing Now: 0/1",
        "Compact labels retain the same complete-roster passing count");
}

all_passing_members_still_require_the_native_hold()
{
    view = snapshot_view();
    view.cabinet_activation.route = "Reactivation";
    rows = scripts\apparition\menu\model::build("Cabinet Activation", view);
    tests\support\checks::expect(rows[1].label == "Cabinet Route: Reactivation"
        && rows[2].label == "Passing Now: 1/1", "A retry snapshot keeps a distinct route and count");
    tests\support\checks::expect(rows[2].description == "One snapshot is not activation; keep Use held for the native two scans 0.25 seconds apart",
        "Even an entirely passing sample does not claim activation or a completed hold");
    tests\support\checks::expect(rows[0].description == "All current players must leave last stand, stop carrying, move within 50 units of the cabinet corner and hold [{+activate}] together",
        "Instructions describe the actual collective native requirements");
}

unavailable_and_malformed_snapshots_never_report_passing_players()
{
    view = spawnstruct();
    rows = scripts\apparition\menu\model::build("Cabinet Activation", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Cabinet Hold: Unknown",
        "A missing snapshot cannot report zero players or a passing count");
    view = snapshot_view();
    view.cabinet_activation.reason = "Wait for a complete native player roster";
    rows = scripts\apparition\menu\model::build("Cabinet Activation", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Cabinet Hold: Unavailable"
        && rows[0].description == view.cabinet_activation.reason,
        "A live unavailable reason takes precedence over stale members");
    view = snapshot_view();
    view.cabinet_activation.members = [];
    rows = scripts\apparition\menu\model::build("Cabinet Activation", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Cabinet Hold: Unknown",
        "An empty roster cannot display an all-passing snapshot");
    view = snapshot_view();
    view.cabinet_activation.members[0].reason = undefined;
    rows = scripts\apparition\menu\model::build("Cabinet Activation", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Cabinet Hold: Unknown",
        "One malformed member invalidates the entire passing count");
    view = snapshot_view();
    view.cabinet_activation.route = 1;
    rows = scripts\apparition\menu\model::build("Cabinet Activation", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Cabinet Hold: Unknown",
        "A malformed route cannot expose a passing roster");
}

snapshot_view()
{
    view = spawnstruct();
    snapshot = spawnstruct();
    snapshot.reason = "";
    snapshot.route = "Initial Unlock";
    member = spawnstruct();
    member.name = "Player A";
    member.reason = "";
    snapshot.members = [member];
    view.cabinet_activation = snapshot;
    return view;
}
