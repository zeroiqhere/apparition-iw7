// Host rows preserve the source order without claiming unavailable native controls

run()
{
    source_order_keeps_show_origin_at_the_eighth_row();
    fov_scale_uses_the_source_numeric_range_and_current_host_owner();
    fov_scale_denials_keep_native_state_and_missing_preview_distinct();
    show_origin_uses_an_owner_scoped_typed_toggle();
    missing_and_denied_snapshots_keep_the_control_disabled();
    malformed_snapshots_cannot_enable_the_native_action();
    main_navigation_and_page_dispatch_reach_the_host_display();
    rejected_callback_scope_cannot_touch_saved_state();
    server_cheats_reads_native_state_and_describes_the_next_toggle();
    server_cheats_rejects_unavailable_or_malformed_snapshots();
    server_cheats_callback_rejects_lobby_and_remote_scope();
}

ready_view()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.host = true;
    view.access = "Host";
    view.fov = spawnstruct();
    view.fov.reason = "";
    view.fov.current = 80.5;
    view.server_cheats = spawnstruct();
    view.server_cheats.reason = "";
    view.server_cheats.current = "0";
    view.origin_display = spawnstruct();
    view.origin_display.reason = "";
    view.origin_display.configured = false;
    return view;
}

source_order_keeps_show_origin_at_the_eighth_row()
{
    expected = ["Disconnect", "Player Info", "Music Player", "Custom Map Spawns",
        "Player Score & Overhead Name Color", "Field Of View Scale", "Field Of View",
        "Show Origin", "Anti-End Game", "Force Host", "Entity Count Display",
        "Tris Lines", "DevGui Info", "Disable Fog", "SV Cheats", "Developer Mode"];
    rows = scripts\apparition\menu\host_rows::build(ready_view());
    tests\support\checks::expect(rows.size == expected.size,
        "Unknown IW7 entity limits do not invent the conditional BO3 protection row");
    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(rows[index].label == expected[index],
            "The original Host Menu positions remain stable");
        if (index != 5 && index != 7 && index != 14)
            tests\support\checks::expect(!rows[index].enabled,
                "Other host controls remain visibly unavailable until their bindings are verified");
    }
}

server_cheats_reads_native_state_and_describes_the_next_toggle()
{
    view = ready_view();
    foreach (value in ["0", "1"])
    {
        view.server_cheats.current = value;
        row = scripts\apparition\menu\host_rows::build(view)[14];
        tests\support\checks::expect(row.label == "SV Cheats" && row.kind == "toggle"
            && row.enabled && row.checked == (value == "1"),
            "The source SV Cheats row reports the captured native boolean setting");
        tests\support\checks::expect(row.target == view.owner && !row.lobby
            && row.callback == scripts\apparition\menu\actions::toggle_server_cheats,
            "The global setting is invoked through the current host owner");
        next_action = value == "1" ? "Use turns it OFF" : "Use turns it ON";
        tests\support\checks::expect(isSubStr(row.description, next_action),
            "The native checkbox and next toggle description agree");
        tests\support\checks::expect(view.server_cheats.current == value,
            "Rendering leaves the captured native setting unchanged");
    }
}

server_cheats_rejects_unavailable_or_malformed_snapshots()
{
    tests\support\checks::expect(!scripts\apparition\menu\host_rows::build(undefined)[14].enabled,
        "A missing host view cannot enable SV Cheats");
    view = ready_view();
    view.host = false;
    view.server_cheats = undefined;
    row = scripts\apparition\menu\host_rows::build(view)[14];
    tests\support\checks::expect(!row.enabled && !row.checked
        && row.description == "Only the current host can change SV Cheats",
        "Native host denial takes precedence over missing setting data");
    view = ready_view();
    view.server_cheats.reason = "The native cheat setting is unavailable";
    row = scripts\apparition\menu\host_rows::build(view)[14];
    tests\support\checks::expect(!row.enabled && row.description == view.server_cheats.reason,
        "A current native denial remains visible on SV Cheats");
    view = ready_view();
    view.server_cheats = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\host_rows::build(view)[14].enabled,
        "A missing native snapshot cannot enable SV Cheats");
    foreach (snapshot in [false, [], spawnstruct(), "1"])
    {
        view = ready_view();
        view.server_cheats = snapshot;
        row = scripts\apparition\menu\host_rows::build(view)[14];
        tests\support\checks::expect(!row.enabled && !row.checked,
            "An unreadable snapshot cannot invent a usable native checkbox");
    }
    view = ready_view();
    view.server_cheats.current = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\host_rows::build(view)[14].enabled,
        "A missing native value cannot enable SV Cheats");
    foreach (value in ["", "2", 0, 1, [], spawnstruct()])
    {
        view = ready_view();
        view.server_cheats.current = value;
        row = scripts\apparition\menu\host_rows::build(view)[14];
        tests\support\checks::expect(!row.enabled && !row.checked,
            "Malformed native state cannot enable the global toggle");
    }
}

server_cheats_callback_rejects_lobby_and_remote_scope()
{
    row = spawnstruct();
    row.lobby = true;
    row.target = self;
    tests\support\checks::expect(!(self scripts\apparition\menu\actions::toggle_server_cheats(row, undefined)),
        "A lobby-shaped descriptor cannot invoke the host-owned cheat setting");
    row.lobby = false;
    row.target = spawnstruct();
    tests\support\checks::expect(!(self scripts\apparition\menu\actions::toggle_server_cheats(row, undefined)),
        "A remote target cannot replace the host owner for SV Cheats");
    row.target = undefined;
    tests\support\checks::expect(!(self scripts\apparition\menu\actions::toggle_server_cheats(row, undefined)),
        "An absent target cannot invoke the native setting writer");
}

show_origin_uses_an_owner_scoped_typed_toggle()
{
    view = ready_view();
    row = scripts\apparition\menu\host_rows::build(view)[7];
    tests\support\checks::expect(row.enabled && row.kind == "toggle" && !row.checked
        && row.target == view.owner && !row.lobby
        && row.callback == scripts\apparition\menu\actions::toggle_show_origin,
        "Show Origin operates only on the host owner rather than the current selected player");
    view.origin_display.configured = true;
    row = scripts\apparition\menu\host_rows::build(view)[7];
    tests\support\checks::expect(row.enabled && row.checked,
        "A configured display stays available to turn off without native position readiness");
}

missing_and_denied_snapshots_keep_the_control_disabled()
{
    tests\support\checks::expect(!scripts\apparition\menu\host_rows::build(undefined)[7].enabled,
        "A missing host view cannot enable the display");
    tests\support\checks::expect(!scripts\apparition\menu\host_rows::build(spawnstruct())[7].enabled,
        "An empty view cannot enable the display");
    view = ready_view();
    view.host = false;
    tests\support\checks::expect(!scripts\apparition\menu\host_rows::build(view)[7].enabled,
        "Co-Host and stale host views cannot inherit the native host control");
    view = ready_view();
    view.origin_display.reason = "Wait for native position";
    row = scripts\apparition\menu\host_rows::build(view)[7];
    tests\support\checks::expect(!row.enabled && row.description == view.origin_display.reason,
        "The provider denial remains visible on the disabled row");
}

malformed_snapshots_cannot_enable_the_native_action()
{
    view = ready_view();
    foreach (value in [7, "on", [], spawnstruct()])
    {
        view.origin_display = value;
        tests\support\checks::expect(!scripts\apparition\menu\host_rows::build(view)[7].enabled,
            "Malformed captured state cannot enable Show Origin");
    }
    foreach (value in [2, -1, "0", [], spawnstruct()])
    {
        view = ready_view();
        view.origin_display.configured = value;
        tests\support\checks::expect(!scripts\apparition\menu\host_rows::build(view)[7].enabled,
            "Only a typed boolean can supply a checked state");
    }
}

main_navigation_and_page_dispatch_reach_the_host_display()
{
    view = ready_view();
    rows = scripts\apparition\menu\main_rows::build(view);
    tests\support\checks::expect(rows[19].enabled && rows[19].destination == "Host Menu"
        && rows[19].target == view.owner,
        "Native host navigation opens the owner-scoped Host Menu");
    rows = scripts\apparition\menu\model::build("Host Menu", view);
    tests\support\checks::expect(rows[7].enabled && rows[7].label == "Show Origin",
        "The model routes Host Menu through the source host rows");
}

rejected_callback_scope_cannot_touch_saved_state()
{
    row = spawnstruct();
    row.lobby = true;
    row.target = self;
    tests\support\checks::expect(!(self scripts\apparition\menu\actions::toggle_show_origin(row, undefined)),
        "A lobby-shaped callback cannot enable this personal host display");
    row.lobby = false;
    row.target = spawnstruct();
    tests\support\checks::expect(!(self scripts\apparition\menu\actions::toggle_show_origin(row, undefined)),
        "A different selected target cannot be used for the host-owned display");
}

fov_scale_uses_the_source_numeric_range_and_current_host_owner()
{
    view = ready_view();
    rows = scripts\apparition\menu\host_rows::build(view);
    row = rows[5];
    tests\support\checks::expect(row.enabled && row.kind == "slider" && row.target == view.owner
        && !row.lobby && row.callback == scripts\apparition\menu\actions::set_host_fov,
        "The sixth source host row writes through its owner-scoped native FOV action");
    tests\support\checks::expect(row.range.minimum == 65 && row.range.maximum == 85
        && row.range.increment == 1 && row.range.start == 80.5 && !isDefined(row.values),
        "A numeric range preserves the live fractional seed without an integer-choice substitute");
    tests\support\checks::expect(!rows[6].enabled && !isDefined(rows[6].callback),
        "The separate unmapped Field Of View control remains unavailable");
    view.fov.current = 90;
    row = scripts\apparition\menu\host_rows::build(view)[5];
    state = scripts\apparition\menu\state::create(view.owner);
    tests\support\checks::expect(row.enabled && row.range.start == 90
        && scripts\apparition\menu\state::slider_value(state, row) == 85,
        "The actual setting stays distinct from the source-clamped preview");
}

fov_scale_denials_keep_native_state_and_missing_preview_distinct()
{
    view = ready_view();
    view.host = false;
    view.fov = undefined;
    row = scripts\apparition\menu\host_rows::build(view)[5];
    tests\support\checks::expect(!row.enabled && row.description == "Only the current host can change Field Of View Scale",
        "Native host denial takes precedence over missing setting data");
    view = ready_view();
    view.fov.reason = "Native FOV is unavailable";
    row = scripts\apparition\menu\host_rows::build(view)[5];
    tests\support\checks::expect(!row.enabled && row.description == view.fov.reason,
        "A current native denial explains the disabled FOV action");
    foreach (snapshot in [false, [], spawnstruct(), "80"])
    {
        view.fov = snapshot;
        row = scripts\apparition\menu\host_rows::build(view)[5];
        tests\support\checks::expect(!row.enabled && !isDefined(row.range.start),
            "Malformed FOV data cannot invent a native reading or preview seed");
    }
    row = spawnstruct();
    row.lobby = true;
    row.target = self;
    tests\support\checks::expect(!(self scripts\apparition\menu\actions::set_host_fov(row, 80)),
        "A lobby-shaped descriptor cannot invoke the host-only FOV setter");
    row.lobby = false;
    row.target = spawnstruct();
    tests\support\checks::expect(!(self scripts\apparition\menu\actions::set_host_fov(row, 80)),
        "A selected remote target cannot replace the current host owner");
}
