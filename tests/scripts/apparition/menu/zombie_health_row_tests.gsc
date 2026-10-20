// The source health slider keeps its choices while only Custom is executable

run()
{
    custom_choice_keeps_the_source_contract_and_initial_preview();
    configured_zero_and_intmax_are_shown_as_requests();
    host_denial_precedes_malformed_native_snapshot_reads();
    native_snapshot_reason_precedes_configuration_validation();
    missing_or_malformed_views_and_snapshots_stay_disabled();
    malformed_configuration_cannot_enable_custom();
    rendering_does_not_publish_or_mutate_health_targets();
}

custom_choice_keeps_the_source_contract_and_initial_preview()
{
    view = health_view();
    row = scripts\apparition\menu\zombie_health_row::build(view);
    tests\support\checks::expect(row.label == "Health" && row.kind == "slider"
        && row.values.size == 2 && row.values[0] == "Custom" && row.values[1] == "Reset"
        && row.initial_index == 0,
        "Health preserves the source Custom/Reset order and starts on Custom");
    tests\support\checks::expect(row.callback == scripts\apparition\menu\actions::set_zombie_health
        && row.lobby && !isDefined(row.target),
        "Health binds one host-wide request without a selected player target");
    tests\support\checks::expect(row.enabled
        && scripts\apparition\menu\availability::choice_reason(row, "Custom") == ""
        && scripts\apparition\menu\availability::choice_reason(row, "Reset") != "",
        "Custom is admitted while Reset stays explicitly unavailable");
}

configured_zero_and_intmax_are_shown_as_requests()
{
    foreach (value in [0, 2147483647])
    {
        view = health_view();
        view.zombie_health.configured = true;
        view.zombie_health.value = value;
        row = scripts\apparition\menu\zombie_health_row::build(view);
        tests\support\checks::expect(row.enabled
            && scripts\apparition\menu\availability::choice_reason(row, "Custom") == ""
            && scripts\apparition\menu\availability::choice_reason(row, "Reset") != "",
            "Configured zero and signed INT_MAX remain valid Custom requests");
        tests\support\checks::expect(isSubStr(row.description, "Requested value: " + value)
            && isSubStr(row.description, "current live team")
            && isSubStr(row.description, "future base")
            && isSubStr(row.description, "may replace it"),
            "Configured values describe the source scopes and later native writers without claiming applied health");
        tests\support\checks::expect(!isSubStr(row.description, "Current health:")
            && !isSubStr(row.description, "Health applied:"),
            "A configured request is not presented as a confirmed native health effect");
    }
}

host_denial_precedes_malformed_native_snapshot_reads()
{
    view = health_view();
    view.host = false;
    view.zombie_health = 7;
    row = scripts\apparition\menu\zombie_health_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == "Only the current host can change zombie health"
        && scripts\apparition\menu\availability::choice_reason(row, "Custom") == row.description,
        "A non-host is denied before the malformed native snapshot is inspected");

    view = health_view();
    view.host = 7;
    view.zombie_health = 7;
    row = scripts\apparition\menu\zombie_health_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description != ""
        && scripts\apparition\menu\availability::choice_reason(row, "Custom") == row.description,
        "A malformed host flag cannot authorize reading feature snapshot data");
}

native_snapshot_reason_precedes_configuration_validation()
{
    view = health_view();
    view.zombie_health.reason = "The native zombie health state is unavailable";
    view.zombie_health.configured = 7;
    view.zombie_health.value = "invalid";
    row = scripts\apparition\menu\zombie_health_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description == view.zombie_health.reason
        && scripts\apparition\menu\availability::choice_reason(row, "Custom") == view.zombie_health.reason,
        "A typed native reason blocks Custom before optional configuration data is validated");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Reset") != "",
        "Reset remains unavailable even when native readiness supplies its own reason");
}

missing_or_malformed_views_and_snapshots_stay_disabled()
{
    foreach (view in [undefined, 7, []])
    {
        row = scripts\apparition\menu\zombie_health_row::build(view);
        tests\support\checks::expect(!row.enabled && isDefined(row.description) && row.description != "",
            "A missing or malformed page view cannot enable the health slider");
    }

    foreach (snapshot in [undefined, 7, []])
    {
        view = health_view();
        view.zombie_health = snapshot;
        row = scripts\apparition\menu\zombie_health_row::build(view);
        tests\support\checks::expect(!row.enabled && row.description != ""
            && scripts\apparition\menu\availability::choice_reason(row, "Custom") != "",
            "A missing or malformed native snapshot cannot enable Custom");
    }

    view = health_view();
    view.zombie_health.reason = 7;
    row = scripts\apparition\menu\zombie_health_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description != "",
        "An untyped native reason cannot be treated as ready");

    view = health_view();
    view.zombie_health.configured = false;
    view.zombie_health.value = 100;
    row = scripts\apparition\menu\zombie_health_row::build(view);
    tests\support\checks::expect(row.enabled
        && !isSubStr(row.description, "Requested value:"),
        "An unconfigured snapshot may omit its optional value without inventing a current request");
}

malformed_configuration_cannot_enable_custom()
{
    view = health_view();
    view.zombie_health.configured = 7;
    row = scripts\apparition\menu\zombie_health_row::build(view);
    tests\support\checks::expect(!row.enabled && row.description != "",
        "A non-boolean configured flag cannot enable the Custom request");

    foreach (value in [undefined, "10", -1, 1.5, 2147483648])
    {
        view = health_view();
        view.zombie_health.configured = true;
        view.zombie_health.value = value;
        row = scripts\apparition\menu\zombie_health_row::build(view);
        tests\support\checks::expect(!row.enabled && row.description != "",
            "A configured value outside the signed integer health domain cannot enable Custom");
    }
}

rendering_does_not_publish_or_mutate_health_targets()
{
    view = health_view();
    view.zombie_health.configured = true;
    view.zombie_health.value = 250;
    row = scripts\apparition\menu\zombie_health_row::build(view);
    tests\support\checks::expect(!isDefined(row.targets) && !isDefined(row.zombies)
        && !isDefined(row.health) && !isDefined(row.requested_health)
        && !isDefined(row.active_targets),
        "The row does not cache selected agents or publish health payload state");
    tests\support\checks::expect(view.zombie_health.reason == ""
        && view.zombie_health.configured && view.zombie_health.value == 250,
        "Building the row leaves the captured typed health snapshot unchanged");
}

health_view()
{
    view = spawnstruct();
    view.host = true;
    view.zombie_health = spawnstruct();
    view.zombie_health.reason = "";
    view.zombie_health.configured = false;
    return view;
}
