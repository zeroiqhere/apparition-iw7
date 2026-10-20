// Power activation rows expose native progress without caching command state

run()
{
    power_row_requires_host_before_reading_native_snapshot();
    power_row_fails_closed_for_missing_or_malformed_snapshot();
    power_row_binds_one_sequenced_lobby_action_for_partial_progress();
    power_row_preserves_partial_progress_while_native_work_is_busy();
    power_row_keeps_full_native_progress_checked_and_disabled();
}

power_row_requires_host_before_reading_native_snapshot()
{
    view = spawnstruct();
    view.host = false;
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(row.label == "Turn On Power" && row.kind == "toggle"
        && !row.enabled && !row.checked && row.lobby && !isDefined(row.target),
        "Power is a native-host-only lobby action with a conservative unchecked state");
    tests\support\checks::expect(row.description == "Only the current host can activate native generators",
        "Host denial is shown before any missing power snapshot reason");
    tests\support\checks::expect(row.callback == scripts\apparition\menu\actions::turn_on_power,
        "The power row binds only the fresh native activation action");
}

power_row_fails_closed_for_missing_or_malformed_snapshot()
{
    view = spawnstruct();
    view.host = true;
    view.power = undefined;
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Wait for native power state",
        "Missing power data cannot imply readiness or completion");

    foreach (snapshot in [17, spawnstruct()])
    {
        view.power = snapshot;
        row = scripts\apparition\menu\power_row::build(view);
        tests\support\checks::expect(!row.enabled && !row.checked
            && row.description == "Wait for native power state",
            "A non-struct or incomplete power snapshot fails closed");
    }

    view.power = spawnstruct();
    view.power.reason = "";
    view.power.powered = 2;
    view.power.total = 1;
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Wait for native power state",
        "Impossible counts cannot create a completion checkbox");

    view.power.reason = 17;
    view.power.powered = 1;
    view.power.total = 2;
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Wait for native power state",
        "A malformed reason cannot authorize a valid-looking count pair");

    view.power.reason = "";
    view.power.powered = "1";
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Wait for native power state",
        "String progress values do not pass numeric snapshot validation");

    view.power.powered = 1;
    view.power.total = -2;
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked,
        "Negative totals cannot authorize activation");

    view.power.total = 2;
    view.power.powered = -1;
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked,
        "Negative native progress cannot enable power activation");
}

power_row_binds_one_sequenced_lobby_action_for_partial_progress()
{
    view = spawnstruct();
    view.host = true;
    view.power = spawnstruct();
    view.power.reason = "";
    view.power.powered = 1;
    view.power.total = 4;
    view.power.targets = [spawnstruct()];
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(row.enabled && !row.checked && row.kind == "toggle"
        && row.callback == scripts\apparition\menu\actions::turn_on_power
        && row.lobby && !isDefined(row.target),
        "Partial progress enables only the host-scoped native sequence request");
    tests\support\checks::expect(row.description == "Activate remaining native generators in sequence; powered 1/4",
        "The footer reports sampled counts without claiming delivery");
    tests\support\checks::expect(!isDefined(row.targets) && !isDefined(row.origin)
        && !isDefined(row.position) && !isDefined(row.parameters),
        "The UI row keeps no native target, origin or command parameters");
}

power_row_preserves_partial_progress_while_native_work_is_busy()
{
    view = spawnstruct();
    view.host = true;
    view.power = spawnstruct();
    view.power.reason = "Power activation is already running";
    view.power.powered = 1;
    view.power.total = 4;
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == view.power.reason,
        "A busy native sequence keeps partial progress visible without accepting a second request");
}

power_row_keeps_full_native_progress_checked_and_disabled()
{
    view = spawnstruct();
    view.host = true;
    view.power = spawnstruct();
    view.power.reason = "All native generators are powered";
    view.power.powered = 3;
    view.power.total = 3;
    row = scripts\apparition\menu\power_row::build(view);
    tests\support\checks::expect(row.checked && !row.enabled
        && row.description == view.power.reason,
        "Fully powered native fields remain checked and the action never offers toggle-off");
}
