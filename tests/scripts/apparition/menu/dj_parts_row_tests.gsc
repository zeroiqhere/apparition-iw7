// DJ-part controls display only the current native stage snapshot

run()
{
    host_denial_precedes_missing_or_malformed_progress();
    invalid_snapshots_fail_closed_without_integer_conversion();
    partial_progress_binds_one_host_action_without_native_payload();
    blocked_progress_preserves_the_provider_reason();
    complete_progress_stays_disabled_and_unchecked();
}

host_denial_precedes_missing_or_malformed_progress()
{
    view = spawnstruct();
    view.host = false;
    view.dj_parts = 17;
    row = scripts\apparition\menu\dj_parts_row::build(view);

    tests\support\checks::expect(row.label == "Collect DJ Parts" && row.kind == "action"
        && !row.enabled && row.lobby && !isDefined(row.target),
        "DJ-part collection remains a host-scoped action");
    tests\support\checks::expect(row.description == "Only the current host can collect native DJ parts",
        "Host denial wins before malformed progress is inspected");
}

invalid_snapshots_fail_closed_without_integer_conversion()
{
    view = spawnstruct();
    view.host = true;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "A missing progress field cannot enable collection");

    view.dj_parts = 17;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "A non-struct progress value cannot enable collection");

    snapshot = spawnstruct();
    snapshot.collected = 0;
    snapshot.total = 3;
    view.dj_parts = snapshot;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "A missing provider reason cannot authorize collection");

    snapshot.reason = 17;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "A nonstring reason cannot authorize apparently valid counts");

    snapshot.reason = "";
    snapshot.collected = undefined;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "A missing collected count cannot enable collection");

    snapshot.collected = 1;
    snapshot.total = undefined;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "A missing total cannot enable collection");

    snapshot.total = 3;
    snapshot.collected = 1.5;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "Fractional counts fail closed without conversion");

    foreach (count in [-2, -1, 4])
    {
        snapshot.collected = count;
        row = scripts\apparition\menu\dj_parts_row::build(view);
        tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
            "Out-of-range counts cannot enable collection");
    }

    snapshot.collected = 1;
    snapshot.total = 2;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "The native three-part total is fixed");

    snapshot.total = 3;
    snapshot.collected = -1;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "Unknown progress with a clear reason cannot authorize collection");

    snapshot.collected = 3;
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native DJ parts snapshot",
        "Complete counts require the canonical all-collected reason");
}

partial_progress_binds_one_host_action_without_native_payload()
{
    view = spawnstruct();
    view.host = true;
    view.dj_parts = progress_snapshot("", 1);
    row = scripts\apparition\menu\dj_parts_row::build(view);

    tests\support\checks::expect(row.kind == "action" && row.enabled
        && row.callback == scripts\apparition\menu\actions::collect_dj_parts
        && row.lobby && !isDefined(row.target),
        "A missing native part binds one current-host action without an actor target");
    tests\support\checks::expect(row.description == "Collect missing native DJ parts; sampled collected 1/3",
        "The footer reports the captured native count without claiming delivery");
    tests\support\checks::expect(!isDefined(row.targets) && !isDefined(row.part_model)
        && !isDefined(row.origin) && !isDefined(row.owner),
        "The menu row keeps no native model, recipient or command payload");
}

blocked_progress_preserves_the_provider_reason()
{
    view = spawnstruct();
    view.host = true;
    view.dj_parts = progress_snapshot("DJ parts are not the current quest step", 2);
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == view.dj_parts.reason,
        "A stage or readiness rejection stays visible and blocks the action");

    view.dj_parts = progress_snapshot("Wait for a valid player roster", -1);
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == view.dj_parts.reason,
        "An unavailable native count can retain its provider reason");
}

complete_progress_stays_disabled_and_unchecked()
{
    view = spawnstruct();
    view.host = true;
    view.dj_parts = progress_snapshot("All native DJ parts are collected", 3);
    row = scripts\apparition\menu\dj_parts_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "All native DJ parts are collected",
        "Native completion disables the action with the exact completion reason");
    tests\support\checks::expect(!isDefined(row.checked),
        "A one-shot action does not present completion as a toggle state");
}

progress_snapshot(reason, collected)
{
    snapshot = spawnstruct();
    snapshot.reason = reason;
    snapshot.collected = collected;
    snapshot.total = 3;
    snapshot.targets = [spawnstruct()];
    return snapshot;
}
