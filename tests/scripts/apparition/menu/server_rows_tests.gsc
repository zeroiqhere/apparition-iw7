// Server settings retain source order while the live native values stay read-only

run()
{
    server_rows_keep_all_22_source_labels_in_order();
    only_six_current_controls_bind_native_actions();
    cohosts_can_use_server_controls_without_being_the_native_host();
    vip_and_verified_roles_are_denied_before_captured_settings();
    newsbar_reports_configured_state_and_preserves_typed_denials();
    newsbar_rejects_unmanaged_roles_and_malformed_snapshots();
    end_game_row_requires_managed_role_and_native_readiness();
    server_movement_rows_show_live_target_state_and_startup_baseline_readiness();
    server_movement_rows_reject_unmanaged_roles_and_snapshot_failures();
    timescale_keeps_live_value_separate_from_slider_preview();
    timescale_outside_choices_stays_visible_without_becoming_a_preview();
    timescale_rejects_unmanaged_roles_and_snapshot_failures();
    auto_revive_uses_configured_state_and_keeps_native_pause_clearable();
    auto_revive_rejects_unmanaged_roles_and_malformed_snapshots();
    lobby_timer_parent_opens_the_nested_page();
    doheart_parent_initializes_defaults_through_its_page_action();
    lobby_timer_rows_keep_source_default_and_live_duration_separate();
    lobby_timer_role_and_malformed_snapshots_fail_closed();
    lobby_timer_reasons_keep_configured_off_actionable_and_expiry_visible();
    lobby_timer_clock_admission_is_per_duration();
}

server_rows_keep_all_22_source_labels_in_order()
{
    view = server_view();
    rows = scripts\apparition\menu\server_rows::build(view);
    labels = ["Super Jump", "Low Gravity", "Super Speed", "Timescale", "Set Round",
        "Anti-Join", "Anti-Quit", "Auto-Revive", "Auto-Respawn", "Pause World",
        "Newsbar", "Doheart Options", "Lobby Timer Options", "Mystery Box Options",
        "Open All Doors & Debris", "Zombie Barriers", "Spawn Bot", "Craftables",
        "Zombie Traps", "Change Map", "Restart Game", "End Game"];

    tests\support\checks::expect(rows.size == labels.size,
        "Every original Server Modifications candidate keeps its source position");
    if (rows.size != labels.size)
        return;
    for (index = 0; index < labels.size; index++)
        tests\support\checks::expect(rows[index].label == labels[index],
            "Server labels retain their physical source order");
    tests\support\checks::expect(rows[13].kind == "unavailable" && !rows[13].enabled
        && !isDefined(rows[13].callback) && rows[17].kind == "unavailable"
        && rows[18].kind == "unavailable",
        "Conditional mystery box, craftable and trap entries remain explicit unavailable candidates");
}

only_six_current_controls_bind_native_actions()
{
    rows = scripts\apparition\menu\server_rows::build(server_view());
    if (rows.size != 22)
        return;
    tests\support\checks::expect(rows[1].kind == "toggle"
        && rows[1].callback == scripts\apparition\menu\actions::toggle_server_movement
        && rows[1].setting == "low_gravity" && rows[1].lobby && !isDefined(rows[1].target),
        "Low Gravity is a server-wide global toggle in its original row position");
    tests\support\checks::expect(rows[2].kind == "toggle"
        && rows[2].callback == scripts\apparition\menu\actions::toggle_server_movement
        && rows[2].setting == "super_speed" && rows[2].lobby && !isDefined(rows[2].target),
        "Super Speed is a server-wide global toggle in its original row position");
    tests\support\checks::expect(rows[3].kind == "slider" && rows[3].callback == scripts\apparition\menu\actions::set_server_timescale
        && rows[3].lobby && !isDefined(rows[3].target),
        "Timescale is one server-wide global action without a selected-player target");
    tests\support\checks::expect(rows[7].kind == "toggle" && rows[7].callback == scripts\apparition\menu\actions::toggle_auto_revive
        && rows[7].lobby && !isDefined(rows[7].target),
        "Auto-Revive is one server-wide global toggle without a selected-player target");
    tests\support\checks::expect(rows[10].kind == "toggle"
        && rows[10].callback == scripts\apparition\menu\actions::toggle_newsbar
        && rows[10].lobby && !isDefined(rows[10].target),
        "Newsbar is a server-wide global toggle in its original source position");
    tests\support\checks::expect(rows[21].kind == "action"
        && rows[21].callback == scripts\apparition\menu\actions::request_end_game
        && rows[21].lobby && !isDefined(rows[21].target) && !isDefined(rows[21].checked),
        "End Game keeps its final source position and submits a global request without a checkbox");

    foreach (index in [0, 4, 5, 6, 8, 9, 13, 14, 15, 16, 17, 18, 19, 20])
        tests\support\checks::expect(rows[index].kind == "unavailable" && !rows[index].enabled
            && !isDefined(rows[index].callback) && !isDefined(rows[index].checked),
            "Unported server controls remain noninteractive and cannot claim configured state");
}

cohosts_can_use_server_controls_without_being_the_native_host()
{
    view = ready_server_view("Co-Host", false);
    rows = scripts\apparition\menu\server_rows::build(view);
    enabled_indexes = [1, 2, 3, 7, 10, 21];
    foreach (index in enabled_indexes)
        tests\support\checks::expect(rows[index].enabled,
            "Co-Host access admits each supported source server control");

    tests\support\checks::expect(rows[1].callback == scripts\apparition\menu\actions::toggle_server_movement
        && rows[2].callback == scripts\apparition\menu\actions::toggle_server_movement
        && rows[3].callback == scripts\apparition\menu\actions::set_server_timescale
        && rows[7].callback == scripts\apparition\menu\actions::toggle_auto_revive
        && rows[10].callback == scripts\apparition\menu\actions::toggle_newsbar
        && rows[21].callback == scripts\apparition\menu\actions::request_end_game,
        "Co-Host admission keeps the six existing callbacks and source positions");
    foreach (index in enabled_indexes)
        tests\support\checks::expect(rows[index].lobby && !isDefined(rows[index].target),
            "Co-Host controls keep their existing global lobby scope");
    tests\support\checks::expect(rows[11].label == "Doheart Options" && rows[11].enabled
        && rows[11].target == view.owner && rows[12].label == "Lobby Timer Options"
        && rows[12].enabled && rows[12].target == view.owner,
        "Co-Host access leaves the source Doheart and timer parent links intact");

    timer_rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(timer_rows.size == 2 && timer_rows[0].enabled
        && !timer_rows[0].checked && timer_rows[1].enabled
        && timer_rows[0].lobby && !isDefined(timer_rows[0].target)
        && timer_rows[1].lobby && !isDefined(timer_rows[1].target),
        "Co-Host access admits both ready Lobby Timer controls without changing their global scope");
}

vip_and_verified_roles_are_denied_before_captured_settings()
{
    foreach (access in ["VIP", "Verified"])
    {
        // VIP with host identity set proves saved role authority wins over native-host status
        view = ready_server_view(access, access == "VIP");
        rows = scripts\apparition\menu\server_rows::build(view);
        foreach (index in [1, 2, 3, 7, 10, 21])
            tests\support\checks::expect(!rows[index].enabled,
                "A role below Co-Host cannot use captured server settings");
        foreach (index in [1, 2, 7, 10])
            tests\support\checks::expect(!rows[index].checked,
                "A denied role cannot expose captured toggle state");
        tests\support\checks::expect(rows[1].description == "Co-Host access is required to change server settings"
            && rows[3].description == rows[1].description && rows[21].description == rows[1].description,
            "Role denial is consistent for toggles, sliders, and the end-game action");

        timer_rows = scripts\apparition\menu\server_rows::timer_rows(view);
        tests\support\checks::expect(timer_rows.size == 2 && !timer_rows[0].enabled
            && !timer_rows[0].checked && !timer_rows[1].enabled
            && timer_rows[0].description == rows[1].description
            && timer_rows[1].description == rows[1].description,
            "A denied role cannot expose Lobby Timer settings, even when native host identity is true");
    }
}

doheart_parent_initializes_defaults_through_its_page_action()
{
    view = server_view();
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[11];
    tests\support\checks::expect(row.label == "Doheart Options" && row.kind == "submenu"
        && row.enabled && row.callback == scripts\apparition\menu\actions::open_doheart
        && row.destination == "Doheart Options" && row.target == view.owner,
        "Doheart opens from its source row through the default-capture navigation action");
}

lobby_timer_parent_opens_the_nested_page()
{
    view = server_view();
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[12];

    tests\support\checks::expect(row.label == "Lobby Timer Options" && row.kind == "submenu"
        && row.enabled && row.callback == scripts\apparition\menu\actions::open_page
        && row.destination == "Lobby Timer Options" && row.target == view.owner,
        "The original server row opens timer controls for its current menu owner");
}

lobby_timer_rows_keep_source_default_and_live_duration_separate()
{
    view = server_view();
    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", "", "", 17);
    rows = scripts\apparition\menu\model::build("Lobby Timer Options", view);

    tests\support\checks::expect(isDefined(rows) && isarray(rows) && rows.size == 2,
        "The timer page contains exactly the original toggle and duration controls");
    if (!isDefined(rows) || !isarray(rows) || rows.size != 2)
        return;
    toggle = rows[0];
    slider = rows[1];
    tests\support\checks::expect(toggle.label == "Lobby Timer" && toggle.kind == "toggle"
        && toggle.callback == scripts\apparition\menu\actions::toggle_lobby_timer
        && toggle.lobby && !isDefined(toggle.target) && toggle.enabled && !toggle.checked,
        "The first control toggles the global lobby timer from its captured off state");
    tests\support\checks::expect(slider.label == "Set Lobby Timer" && slider.kind == "slider"
        && slider.callback == scripts\apparition\menu\actions::configure_lobby_timer
        && slider.lobby && !isDefined(slider.target) && slider.enabled
        && isDefined(slider.values) && isarray(slider.values) && slider.values.size == 30
        && slider.values[0] == 1 && slider.values[9] == 10 && slider.values[29] == 30
        && slider.initial_index == 9 && slider.active_value == 17,
        "The slider always opens at the source ten-minute default while showing live duration separately");
    tests\support\checks::expect(isSubStr(toggle.description, "Off")
        && isSubStr(slider.description, "Off") && isSubStr(slider.description, "17"),
        "The timer rows expose current phase and configured duration");
    tests\support\checks::expect(!isDefined(toggle.record) && !isDefined(toggle.deadline)
        && !isDefined(toggle.clock)
        && !isDefined(toggle.players) && !isDefined(toggle.roster) && !isDefined(toggle.handles)
        && !isDefined(slider.record) && !isDefined(slider.deadline) && !isDefined(slider.clock)
        && !isDefined(slider.players) && !isDefined(slider.roster) && !isDefined(slider.handles),
        "Neither row caches a worker token, expiry, clock, roster or native handle");
    tests\support\checks::expect(view.lobby_timer.configured == false
        && view.lobby_timer.minutes == 17 && view.lobby_timer.phase == "Off",
        "Rendering leaves the provider snapshot unchanged");
}

lobby_timer_role_and_malformed_snapshots_fail_closed()
{
    view = server_view();
    view.host = false;
    view.access = "VIP";
    view.lobby_timer = 17;
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows.size == 2 && !rows[0].enabled && !rows[0].checked
        && rows[0].description == "Co-Host access is required to change server settings"
        && !rows[1].enabled && rows[1].description == rows[0].description,
        "Role denial precedes a malformed timer snapshot");

    view = server_view();
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked
        && !rows[1].enabled && rows[1].active_value == "Unknown",
        "A missing timer snapshot cannot create configured state or enable either control");

    view.lobby_timer = spawnstruct();
    view.lobby_timer.reason = "";
    view.lobby_timer.configured = 1;
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked && !rows[1].enabled,
        "A partial timer snapshot cannot expose a checked setting or enable controls");

    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", "", "", undefined);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked && !rows[1].enabled,
        "Missing minutes without a timing-recovery reason leave the snapshot incomplete");

    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", "", "", 10);
    view.lobby_timer.phase = 17;
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled,
        "A malformed phase cannot authorize timer controls");
    view.lobby_timer = lobby_timer_snapshot("", false, "Off", 17, "", "", 10);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled,
        "A malformed expiry error cannot authorize timer controls");
    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", 17, "", 10);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled,
        "A malformed native readiness reason cannot authorize timer controls");
    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", "", 17, 10);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled,
        "A malformed timing reason cannot authorize timer controls");
    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", "", "", "10");
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled,
        "A nonnumeric live duration cannot authorize timer controls");
    foreach (bad_minutes in [1.5, 31])
    {
        view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", "", "", bad_minutes);
        rows = scripts\apparition\menu\server_rows::timer_rows(view);
        tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled,
            "Fractional or out-of-range live durations cannot authorize timer controls");
    }

    view.lobby_timer = lobby_timer_snapshot("", 2, "Running", "", "", "", 10);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked && !rows[1].enabled,
        "A nonbinary configured field cannot authorize timer controls");

    view.lobby_timer = lobby_timer_snapshot(17, false, "Off", "", "", "", 10);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked && !rows[1].enabled,
        "A malformed provider reason cannot authorize timer controls");
}

lobby_timer_reasons_keep_configured_off_actionable_and_expiry_visible()
{
    view = server_view();
    view.lobby_timer = lobby_timer_snapshot("", true, "Running", "", "", "", 14);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked
        && rows[1].enabled && rows[1].active_value == 14,
        "A running timer reports its saved setting while native restart remains ready");

    view.lobby_timer = lobby_timer_snapshot("", true, "Expired", "End request was rejected",
        "Native game-over callback is unavailable", "The configured deadline has passed", 14, 2147420000);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked,
        "An enabled timer remains clearable when native end or expiry handling is unavailable");
    tests\support\checks::expect(!rows[1].enabled && rows[1].active_value == 14,
        "An active timer cannot start a new countdown while native end handling is unavailable");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(rows[1], 1) != ""
        && scripts\apparition\menu\availability::choice_reason(rows[1], 30) != "",
        "Native readiness blocks every active-timer restart choice");
    tests\support\checks::expect(isSubStr(rows[0].description, "Expired")
        && isSubStr(rows[0].description, "End request was rejected")
        && isSubStr(rows[0].description, "Native game-over callback is unavailable")
        && isSubStr(rows[0].description, "The configured deadline has passed"),
        "The enabled timer row reports its phase, expiry error and readiness reasons");
    tests\support\checks::expect(isSubStr(rows[1].description, "Expired")
        && isSubStr(rows[1].description, "End request was rejected")
        && isSubStr(rows[1].description, "The configured deadline has passed"),
        "The duration row also exposes current expiry status while native restart is blocked");

    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", "Native game-over callback is unavailable",
        "The previous timer expired", 14);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked && rows[1].enabled
        && rows[1].active_value == 14 && rows[1].initial_index == 9,
        "An off timer can store a new duration despite old native and timing reasons");

    view.lobby_timer = lobby_timer_snapshot("", true, "Expired", "", "", "", 14);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[1].enabled && rows[1].active_value == 14
        && rows[1].values[13] == 14,
        "The current configured duration remains selectable for the source restart action after expiry");

    view.lobby_timer = lobby_timer_snapshot("", true, "Expired", "", "",
        "The stored duration is invalid; choose a new duration", undefined, 0);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked && rows[1].enabled
        && rows[1].active_value == "Unknown" && rows[1].initial_index == 9,
        "A typed duration error leaves the timer clearable and enables a valid repair choice");
    tests\support\checks::expect(isSubStr(rows[1].description, "The stored duration is invalid"),
        "The repair row explains why no live duration can be shown");
}

lobby_timer_clock_admission_is_per_duration()
{
    view = server_view();
    view.lobby_timer = lobby_timer_snapshot("", true, "Expired", "", "",
        "The current duration cannot fit the native clock", 14, 2147420000);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked && rows[1].enabled,
        "An active timer remains clearable and allows a shorter representable restart");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(rows[1], 1) == ""
        && scripts\apparition\menu\availability::choice_reason(rows[1], 2) != ""
        && scripts\apparition\menu\dispatch::can_start(rows[1], false, 1)
        && !scripts\apparition\menu\dispatch::can_start(rows[1], false, 2),
        "Clock admission is checked per duration so one valid choice remains usable");

    view.lobby_timer = lobby_timer_snapshot("", true, "Expired", "", "",
        "The current duration cannot fit the native clock", 14, 2147483647);
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked && !rows[1].enabled,
        "At the maximum clock value every restart choice is blocked while off remains available");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(rows[1], 1) != ""
        && scripts\apparition\menu\availability::choice_reason(rows[1], 30) != "",
        "No duration is admitted when even the shortest countdown exceeds the clock limit");

    view.lobby_timer = lobby_timer_snapshot("", true, "Expired", "", "",
        "The native clock is unavailable", 14, undefined);
    view.lobby_timer.clock = undefined;
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked && !rows[1].enabled,
        "A missing clock cannot block clearing an active timer but cannot admit a restart");
    view.lobby_timer.clock = "invalid";
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked && !rows[1].enabled,
        "A malformed clock cannot block clearing an active timer but cannot admit a restart");

    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "",
        "Native timer readiness is unavailable", "The native clock is unavailable", 14, undefined);
    view.lobby_timer.clock = undefined;
    rows = scripts\apparition\menu\server_rows::timer_rows(view);
    tests\support\checks::expect(rows[1].enabled
        && scripts\apparition\menu\availability::choice_reason(rows[1], 1) == ""
        && scripts\apparition\menu\availability::choice_reason(rows[1], 30) == "",
        "An off timer can store any valid duration without clock or worker readiness");
    tests\support\checks::expect(!isDefined(rows[1].clock) && !isDefined(rows[1].deadline),
        "Clock admission data stays out of the row command payload");
}

newsbar_reports_configured_state_and_preserves_typed_denials()
{
    view = server_view();
    view.newsbar = newsbar_snapshot("", 0);
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[10];
    tests\support\checks::expect(row.enabled && !row.checked
        && row.callback == scripts\apparition\menu\actions::toggle_newsbar,
        "A ready Host role sees Newsbar configured off with the source toggle");
    tests\support\checks::expect(isSubStr(row.description, "all players")
        && isSubStr(row.description, "Use turns it on"),
        "Newsbar copy describes global coverage and the available action");

    view.newsbar = newsbar_snapshot("", 1);
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[10];
    tests\support\checks::expect(row.enabled && row.checked
        && isSubStr(row.description, "Use turns it off"),
        "A configured Newsbar remains visible and can be turned off");
    tests\support\checks::expect(!isDefined(row.messages) && !isDefined(row.record)
        && !isDefined(row.text) && !isDefined(row.background) && !isDefined(row.handles),
        "The row does not cache message text, worker identity or native HUD handles");

    view.newsbar = newsbar_snapshot("Newsbar native resources are not ready", 1);
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[10];
    tests\support\checks::expect(!row.enabled && row.checked
        && row.description == view.newsbar.reason,
        "A typed provider denial keeps the configured toggle visible without enabling it");
}

newsbar_rejects_unmanaged_roles_and_malformed_snapshots()
{
    view = server_view();
    view.newsbar = 17;
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[10];
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Co-Host access is required to change server settings",
        "Role denial precedes a malformed Newsbar snapshot");

    view = server_view();
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[10];
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description != "Co-Host access is required to change server settings",
        "A missing Newsbar snapshot cannot enable or check the toggle");

    view.newsbar = newsbar_snapshot("", 2);
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[10];
    tests\support\checks::expect(!row.enabled && !row.checked,
        "A nonbinary configured value cannot authorize a Newsbar toggle");

    view.newsbar = newsbar_snapshot(17, 1);
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[10];
    tests\support\checks::expect(!row.enabled && !row.checked,
        "A malformed provider reason cannot expose configured Newsbar state");

    view.newsbar = spawnstruct();
    view.newsbar.reason = "";
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[10];
    tests\support\checks::expect(!row.enabled && !row.checked,
        "A missing configured field cannot authorize a Newsbar mutation");
}

end_game_row_requires_managed_role_and_native_readiness()
{
    view = server_view();
    row = scripts\apparition\menu\server_rows::build(view)[21];
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native game-over readiness",
        "Missing native terminal readiness keeps End Game unavailable");
    view.server_end_reason = 17;
    row = scripts\apparition\menu\server_rows::build(view)[21];
    tests\support\checks::expect(!row.enabled && !isDefined(row.checked),
        "Malformed terminal readiness cannot enable a native request or create a checkbox");
    view.server_end_reason = "The native game has ended";
    row = scripts\apparition\menu\server_rows::build(view)[21];
    tests\support\checks::expect(!row.enabled && row.description == view.server_end_reason,
        "The provider's current terminal denial remains visible");
    view.server_end_reason = "";
    row = scripts\apparition\menu\server_rows::build(view)[21];
    tests\support\checks::expect(row.enabled && row.kind == "action"
        && row.callback == scripts\apparition\menu\actions::request_end_game
        && isSubStr(row.description, "all players") && isSubStr(row.description, "game-over"),
        "A ready authorized role can request the normal terminal sequence for the private lobby");
    tests\support\checks::expect(!isDefined(row.end_callback) && !isDefined(row.host_end)
        && !isDefined(row.players) && !isDefined(row.checked),
        "The row carries no native callback pointer, reason index, roster or completion claim");
    view.host = false;
    view.access = "VIP";
    view.server_end_reason = 17;
    row = scripts\apparition\menu\server_rows::build(view)[21];
    tests\support\checks::expect(!row.enabled && row.description == "Co-Host access is required to change server settings",
        "Role denial takes precedence over a malformed native terminal snapshot");
}

server_movement_rows_show_live_target_state_and_startup_baseline_readiness()
{
    view = server_view();
    view.server_movements = [];
    view.server_movements["low_gravity"] = movement_snapshot("low_gravity", "", 800, 200, 0, 1, 100);
    view.server_movements["super_speed"] = movement_snapshot("super_speed", "", 500, 500, 1, 1, 700);
    rows = scripts\apparition\menu\server_rows::build(view);

    tests\support\checks::expect(rows[1].enabled && !rows[1].checked
        && rows[1].setting == "low_gravity",
        "Low Gravity reports a live non-target value and remains selectable");
    tests\support\checks::expect(rows[2].enabled && rows[2].checked
        && rows[2].setting == "super_speed",
        "Super Speed reports the exact live target as checked");
    tests\support\checks::expect(isSubStr(rows[1].description, "Global")
        && isSubStr(rows[1].description, "Current: 800") && isSubStr(rows[1].description, "Use sets 100")
        && isSubStr(rows[1].description, "captured startup value")
        && isSubStr(rows[2].description, "Current: 500") && isSubStr(rows[2].description, "Use sets 700"),
        "The footer reports live state, the exact next native value and source baseline behavior");
    tests\support\checks::expect(!isDefined(rows[1].next_value) && !isDefined(rows[2].next_value),
        "Rows do not cache the provider's next write");

    view.server_movements["super_speed"] = movement_snapshot(
        "super_speed", "No valid startup baseline was captured", 500, 500, 1, 0, undefined);
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[2].enabled && rows[2].checked
        && rows[2].description == view.server_movements["super_speed"].reason,
        "A checked live target stays visible while a missing startup baseline disables the toggle");

    view.server_movements["low_gravity"] = movement_snapshot(
        "low_gravity", "", 800, 200, 0, 1, "200");
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked
        && rows[1].description == "Wait for native server movement state",
        "A nonnumeric next value cannot authorize a native toggle");
}

server_movement_rows_reject_unmanaged_roles_and_snapshot_failures()
{
    view = server_view();
    view.host = false;
    view.access = "VIP";
    view.server_movements = 17;
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked
        && rows[1].description == "Co-Host access is required to change server settings",
        "Role denial takes precedence over malformed movement snapshots");

    view = server_view();
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked
        && rows[1].description == "Wait for native server movement state",
        "Missing movement data cannot enable a global setting");

    view.server_movements = spawnstruct();
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked
        && rows[1].description == "Wait for native server movement state",
        "A struct container is not accepted as the captured movement array");

    view.server_movements = [];
    view.server_movements["low_gravity"] = 17;
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked
        && rows[1].description == "Wait for native server movement state",
        "A malformed provider snapshot cannot authorize a movement change");

    view.server_movements["low_gravity"] = spawnstruct();
    view.server_movements["low_gravity"].id = "low_gravity";
    view.server_movements["low_gravity"].reason = 17;
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked
        && rows[1].description == "Wait for native server movement state",
        "A malformed provider reason cannot authorize a movement change");

    view.server_movements["low_gravity"] = movement_snapshot("low_gravity", "", "200", 200, 1, 1, 100);
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked
        && rows[1].description == "Wait for native server movement state",
        "A string current value cannot authorize a global toggle");

    view.server_movements["low_gravity"] = movement_snapshot(
        "low_gravity", "Native dvar is unavailable", 200, 200, 1, 0, undefined);
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].checked
        && rows[1].description == view.server_movements["low_gravity"].reason,
        "A typed provider denial remains visible without hiding checked native state");

    view.server_movements["low_gravity"] = movement_snapshot("super_speed", "", 200, 200, 1, 1, 500);
    rows = scripts\apparition\menu\server_rows::build(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked
        && rows[1].description == "Wait for native server movement state",
        "A stale snapshot stored under another movement ID cannot enable the row");
}

timescale_keeps_live_value_separate_from_slider_preview()
{
    view = server_view();
    view.server_timescale = timescale_snapshot("", 1.5);
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[3];
    tests\support\checks::expect(row.enabled && row.values.size == 10
        && row.values[0] == 0.5 && row.values[1] == 1 && row.values[2] == 1.5
        && row.values[9] == 5 && row.initial_index == 2 && row.active_value == 1.5,
        "The live 1.5x value selects its matching preview without changing the captured value");
    tests\support\checks::expect(isSubStr(row.description, "game speed for all players")
        && isSubStr(row.description, "1x is normal") && isSubStr(row.description, "Use applies preview")
        && isSubStr(row.description, "Current: 1.5x"),
        "The footer describes actual global speed separately from the uncommitted preview");
    tests\support\checks::expect(view.server_timescale.current == 1.5
        && !isDefined(row.dvar) && !isDefined(row.command_value) && !isDefined(row.owner),
        "Rendering does not mutate the snapshot or cache a write payload");
}

timescale_outside_choices_stays_visible_without_becoming_a_preview()
{
    view = server_view();
    view.server_timescale = timescale_snapshot("", 8.25);
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[3];
    tests\support\checks::expect(row.enabled && row.active_value == 8.25
        && row.initial_index == 1 && row.values[row.initial_index] == 1,
        "An out-of-range live timescale remains visible while the safe preview defaults to 1x");
    tests\support\checks::expect(isSubStr(row.description, "Current: 8.25x")
        && isSubStr(row.description, "Use applies preview"),
        "The footer distinguishes the out-of-range live value from the unapplied slider selection");

    view.server_timescale.current = 1.25;
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[3];
    tests\support\checks::expect(row.active_value == 1.25 && row.initial_index == 1,
        "A fractional value absent from the discrete source choices does not get rounded into the preview");
}

timescale_rejects_unmanaged_roles_and_snapshot_failures()
{
    view = server_view();
    view.host = false;
    view.access = "VIP";
    view.server_timescale = 17;
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[3];
    tests\support\checks::expect(!row.enabled && row.description == "Co-Host access is required to change server settings",
        "A role below Co-Host is denied before malformed timescale data is inspected");

    view = server_view();
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[3];
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native server timescale",
        "Missing timescale data cannot enable a global setting");

    view.server_timescale = spawnstruct();
    view.server_timescale.reason = 17;
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[3];
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native server timescale",
        "A malformed provider reason cannot authorize a timescale write");

    view.server_timescale.reason = "The native timescale is unavailable";
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[3];
    tests\support\checks::expect(!row.enabled && row.description == view.server_timescale.reason,
        "A typed provider denial remains visible without requiring a live current value");

    view.server_timescale.reason = "";
    view.server_timescale.current = "2";
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[3];
    tests\support\checks::expect(!row.enabled && row.description == "Wait for native server timescale",
        "A string timescale cannot authorize a native dvar write");
}

auto_revive_uses_configured_state_and_keeps_native_pause_clearable()
{
    view = server_view();
    view.auto_revive = auto_snapshot("", 1, "The native revive hook is currently paused");
    row = scripts\apparition\menu\server_rows::build(view)[7];
    tests\support\checks::expect(row.enabled && row.checked
        && row.callback == scripts\apparition\menu\actions::toggle_auto_revive,
        "Configured global auto-revive remains available to turn off while its native effect is paused");
    tests\support\checks::expect(isSubStr(row.description, "Global setting")
        && isSubStr(row.description, "current and future players")
        && isSubStr(row.description, "including the host") && isSubStr(row.description, "Use turns it off")
        && isSubStr(row.description, view.auto_revive.native_reason),
        "The footer reports global scope and the native pause without claiming successful revives");
    tests\support\checks::expect(view.auto_revive.enabled == 1
        && !isDefined(row.owner) && !isDefined(row.players) && !isDefined(row.targets),
        "Rendering keeps the owner snapshot unchanged and stores no player list");

    view.auto_revive = auto_snapshot("", 0, "");
    row = scripts\apparition\menu\server_rows::build(view)[7];
    tests\support\checks::expect(row.enabled && !row.checked
        && isSubStr(row.description, "Use turns it on"),
        "A ready global auto-revive toggle reports its configured-off state");
}

auto_revive_rejects_unmanaged_roles_and_malformed_snapshots()
{
    view = server_view();
    view.host = false;
    view.access = "VIP";
    view.auto_revive = 17;
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[7];
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Co-Host access is required to change server settings",
        "Role denial wins before missing global auto-revive state");

    view = server_view();
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[7];
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Wait for native auto-revive state",
        "Missing auto-revive state cannot fabricate a configured checkbox");

    view.auto_revive = spawnstruct();
    view.auto_revive.reason = "Native auto-revive state is unavailable";
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[7];
    tests\support\checks::expect(!row.enabled && row.description == view.auto_revive.reason,
        "A typed provider denial is preserved before optional native fields are read");

    view.auto_revive = auto_snapshot("", 2, "");
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[7];
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Wait for native auto-revive state",
        "A nonbinary configured value cannot authorize an auto-revive mutation");

    view.auto_revive = auto_snapshot("", 0, 17);
    rows = scripts\apparition\menu\server_rows::build(view);
    row = rows[7];
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Wait for native auto-revive state",
        "A malformed native effect reason cannot authorize a global toggle");
}

server_view()
{
    view = spawnstruct();
    view.host = true;
    view.access = "Host";
    view.owner = spawnstruct();
    view.target = spawnstruct();
    return view;
}

ready_server_view(access, host)
{
    view = server_view();
    view.access = access;
    view.host = host;
    view.server_movements = [];
    view.server_movements["low_gravity"] = movement_snapshot("low_gravity", "", 800, 200, 0, 1, 100);
    view.server_movements["super_speed"] = movement_snapshot("super_speed", "", 500, 700, 0, 1, 700);
    view.server_timescale = timescale_snapshot("", 1.5);
    view.auto_revive = auto_snapshot("", 0, "");
    view.newsbar = newsbar_snapshot("", 0);
    view.server_end_reason = "";
    view.lobby_timer = lobby_timer_snapshot("", false, "Off", "", "", "", 10, 0);
    return view;
}

timescale_snapshot(reason, current)
{
    snapshot = spawnstruct();
    snapshot.reason = reason;
    snapshot.current = current;
    return snapshot;
}

auto_snapshot(reason, enabled, native_reason)
{
    snapshot = spawnstruct();
    snapshot.reason = reason;
    snapshot.enabled = enabled;
    snapshot.native_reason = native_reason;
    return snapshot;
}

newsbar_snapshot(reason, configured)
{
    snapshot = spawnstruct();
    snapshot.reason = reason;
    snapshot.configured = configured;
    return snapshot;
}

movement_snapshot(id, reason, current, target, checked, enabled, next_value)
{
    snapshot = spawnstruct();
    snapshot.id = id;
    snapshot.reason = reason;
    snapshot.current = current;
    snapshot.target = target;
    snapshot.checked = checked;
    snapshot.enabled = enabled;
    snapshot.next_value = next_value;
    return snapshot;
}

lobby_timer_snapshot(reason, configured, phase, error, native_reason, time_reason, minutes, clock)
{
    snapshot = spawnstruct();
    snapshot.reason = reason;
    snapshot.configured = configured;
    snapshot.phase = phase;
    snapshot.error = error;
    snapshot.native_reason = native_reason;
    snapshot.time_reason = time_reason;
    snapshot.minutes = minutes;
    snapshot.clock = isDefined(clock) ? clock : 0;
    return snapshot;
}
