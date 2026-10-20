// Page dispatch contracts keep feature probes off unrelated renders

run()
{
    zombie_visibility_probe_stays_on_the_zombie_page();
    nonfeature_pages_keep_core_view_without_an_owner();
    host_page_captures_only_its_coordinate_probe();
    weapon_root_does_not_read_inventory_and_rejected_options_do_not_probe_it();
    invalid_pages_return_without_changing_core_view();
    verification_pages_admit_the_empty_roster_without_feature_probes();
    server_page_denies_an_undefined_owner_before_native_reads();
    lobby_timer_probe_is_limited_to_its_child_page();
    doheart_probe_is_read_only_and_limited_to_its_child_page();
    rejected_basic_target_keeps_its_reason_without_target_probes();
}

doheart_probe_is_read_only_and_limited_to_its_child_page()
{
    view = core_view();
    scripts\apparition\runtime\view_pages::capture("Doheart Options", undefined, undefined, view);
    tests\support\checks::expect(isDefined(view.doheart) && isstruct(view.doheart)
        && isDefined(view.doheart.reason) && view.doheart.reason != ""
        && view.doheart.configured == 0 && view.doheart.settings_ready == 0,
        "The Doheart child page captures a typed denial before any native settings or names");
    tests\support\checks::expect(!isDefined(view.newsbar) && !isDefined(view.lobby_timer)
        && !isDefined(view.server_timescale) && !isDefined(view.ufo),
        "The Doheart child does not gather unrelated server or quest snapshots");
    expect_core_view_unchanged(view);

    view = core_view();
    scripts\apparition\runtime\view_pages::capture("Server Modifications", undefined, undefined, view);
    tests\support\checks::expect(!isDefined(view.doheart),
        "Opening the parent page does not initialize or inspect Doheart defaults");
}

nonfeature_pages_keep_core_view_without_an_owner()
{
    foreach (page in ["Main", "Unknown Page", "Menu Preferences", "Menu Customization"])
    {
        view = core_view();
        scripts\apparition\runtime\view_pages::capture(page, undefined, undefined, view);

        expect_core_view_unchanged(view);
        tests\support\checks::expect(!isDefined(view.owner_alive) && !isDefined(view.actor_reason),
            "A page without owner-life or roster controls leaves those snapshots unset");
        tests\support\checks::expect(!isDefined(view.target_actor_reason)
            && !isDefined(view.target_alive) && !isDefined(view.player_access),
            "A nonfeature page does not capture target or player-role snapshots");
        tests\support\checks::expect(!isDefined(view.perk_callbacks)
            && !isDefined(view.perk_roster_reason) && !isDefined(view.perk_target_reason)
            && !isDefined(view.god_ready) && !isDefined(view.retention_ready),
            "A nonfeature page does not capture perk, damage or retention snapshots");
        tests\support\checks::expect(!isDefined(view.score) && !isDefined(view.revive)
            && !isDefined(view.down) && !isDefined(view.demi_feedback_reason)
            && !isDefined(view.equipment_status),
            "A nonfeature page does not capture personal or lobby control snapshots");
        tests\support\checks::expect(!isDefined(view.ufo) && !isDefined(view.portal_sides)
            && !isDefined(view.ghost_probe) && !isDefined(view.balloons)
            && !isDefined(view.server_timescale) && !isDefined(view.server_movements)
            && !isDefined(view.newsbar),
            "A nonfeature page does not capture representative map or server snapshots");
    }
}

verification_pages_admit_the_empty_roster_without_feature_probes()
{
    foreach (page in ["Verification", "All Players Verification"])
    {
        view = core_view();
        scripts\apparition\runtime\view_pages::capture(page, undefined, undefined, view);

        tests\support\checks::expect(isDefined(view.actor_reason) && isstring(view.actor_reason)
            && view.actor_reason != "" && isDefined(view.player_access)
            && isarray(view.player_access) && view.player_access.size == 0,
            "A verification page captures its typed roster denial without fake players");
        tests\support\checks::expect(!isDefined(view.perk_callbacks)
            && !isDefined(view.perk_roster_reason) && !isDefined(view.god_ready)
            && !isDefined(view.retention_ready) && !isDefined(view.ufo)
            && !isDefined(view.server_timescale) && !isDefined(view.server_movements),
            "A verification page avoids unrelated perk, gameplay and server probes");
        expect_core_view_unchanged(view);
    }
}

invalid_pages_return_without_changing_core_view()
{
    view = core_view();
    scripts\apparition\runtime\view_pages::capture(undefined, undefined, undefined, view);
    expect_core_view_unchanged(view);
    tests\support\checks::expect(!isDefined(view.target_actor_reason)
        && !isDefined(view.server_timescale) && !isDefined(view.ufo),
        "An undefined page returns before any page-specific snapshot");

    scripts\apparition\runtime\view_pages::capture(17, undefined, undefined, view);
    expect_core_view_unchanged(view);
    tests\support\checks::expect(!isDefined(view.target_actor_reason)
        && !isDefined(view.server_timescale) && !isDefined(view.ufo),
        "A nonstring page returns before any page-specific snapshot");
}

server_page_denies_an_undefined_owner_before_native_reads()
{
    view = core_view();
    scripts\apparition\runtime\view_pages::capture("Server Modifications", undefined, undefined, view);

    tests\support\checks::expect(isDefined(view.server_timescale)
        && isDefined(view.server_timescale.reason) && view.server_timescale.reason != ""
        && !isDefined(view.server_timescale.current),
        "The timescale provider denies a missing owner before reading its native value");
    tests\support\checks::expect(isDefined(view.auto_revive)
        && isDefined(view.auto_revive.reason) && view.auto_revive.reason != ""
        && view.auto_revive.enabled == false && view.auto_revive.native_reason == "",
        "The auto-revive provider denies a missing owner before reading native state");
    tests\support\checks::expect(isDefined(view.server_movements)
        && isarray(view.server_movements)
        && isDefined(view.server_movements["low_gravity"])
        && isDefined(view.server_movements["super_speed"])
        && view.server_movements["low_gravity"].reason != ""
        && view.server_movements["super_speed"].reason != ""
        && !isDefined(view.server_movements["low_gravity"].current)
        && !isDefined(view.server_movements["super_speed"].current),
        "Movement providers deny a missing owner before reading native dvars");
    tests\support\checks::expect(isDefined(view.server_end_reason)
        && view.server_end_reason != "",
        "The end-game provider denies a missing owner before reading native readiness");
    tests\support\checks::expect(isDefined(view.newsbar)
        && isDefined(view.newsbar.reason) && isstring(view.newsbar.reason)
        && view.newsbar.reason != "" && view.newsbar.configured == 0
        && isDefined(view.newsbar.messages) && isarray(view.newsbar.messages)
        && view.newsbar.messages.size == 0,
        "The Newsbar provider denies a missing owner without exposing messages or configured state");
    tests\support\checks::expect(!isDefined(view.lobby_timer),
        "The parent server page does not probe the nested Lobby Timer controls");
}

lobby_timer_probe_is_limited_to_its_child_page()
{
    view = core_view();
    scripts\apparition\runtime\view_pages::capture("Server Modifications", undefined, undefined, view);
    tests\support\checks::expect(!isDefined(view.lobby_timer),
        "The parent Server Modifications page leaves timer readiness unset");

    view = core_view();
    scripts\apparition\runtime\view_pages::capture("Lobby Timer Options", undefined, undefined, view);
    snapshot = view.lobby_timer;
    tests\support\checks::expect(isDefined(snapshot) && isstruct(snapshot)
        && isDefined(snapshot.reason) && isstring(snapshot.reason) && snapshot.reason != ""
        && isDefined(snapshot.configured) && snapshot.configured == false
        && isDefined(snapshot.native_reason) && snapshot.native_reason == ""
        && isDefined(snapshot.time_reason) && snapshot.time_reason == ""
        && isDefined(snapshot.phase) && snapshot.phase == "Off"
        && isDefined(snapshot.error) && snapshot.error == ""
        && !isDefined(snapshot.minutes),
        "The timer child page returns the provider's empty denied snapshot for a missing owner");
}

rejected_basic_target_keeps_its_reason_without_target_probes()
{
    stale_reason = "stale target admission reason";
    target = spawnstruct();
    view = core_view();
    view.host = false;
    view.access = "Verified";
    view.target_actor_reason = stale_reason;

    scripts\apparition\runtime\view_pages::capture("Basic Scripts", undefined, target, view);
    reason = view.target_actor_reason;

    tests\support\checks::expect(isDefined(reason) && isstring(reason) && reason != ""
        && reason != stale_reason && isDefined(view.score) && view.score.reason == reason
        && isDefined(view.revive) && view.revive.reason == reason
        && isDefined(view.down) && view.down.reason == reason
        && view.demi_feedback_reason == reason,
        "A rejected actor refreshes the stale reason and shares it across blocked controls");
    tests\support\checks::expect(isDefined(view.score.targets) && view.score.targets.size == 0
        && isDefined(view.revive.targets) && view.revive.targets.size == 0
        && isDefined(view.down.targets) && view.down.targets.size == 0
        && !isDefined(view.score.balance) && !isDefined(view.score.cap),
        "A denied target produces no native action targets or currency snapshot");
}

core_view()
{
    view = spawnstruct();
    view.owner = "core-owner";
    view.target = "core-target";
    view.layout = "core-layout";
    view.host = true;
    view.access = "Host";
    view.menu_grant = "core-grant";
    view.players = [];
    return view;
}

expect_core_view_unchanged(view)
{
    tests\support\checks::expect(view.owner == "core-owner" && view.target == "core-target"
        && view.layout == "core-layout" && view.host == true && view.access == "Host"
        && view.menu_grant == "core-grant"
        && isarray(view.players) && view.players.size == 0,
        "Page dispatch leaves common owner, access and roster fields unchanged");
}


host_page_captures_only_its_coordinate_probe()
{
    view = core_view();
    scripts\apparition\runtime\view_pages::capture("Host Menu", undefined, undefined, view);
    tests\support\checks::expect(isDefined(view.origin_display) && isstruct(view.origin_display)
        && view.origin_display.reason != "" && !view.origin_display.configured,
        "An invalid Host Menu owner receives a typed display denial before native reads");
    tests\support\checks::expect(isDefined(view.fov) && isstruct(view.fov)
        && view.fov.reason != "" && !isDefined(view.fov.current),
        "An invalid host owner cannot reach the native FOV setting read");
    tests\support\checks::expect(isDefined(view.server_cheats) && isstruct(view.server_cheats)
        && view.server_cheats.reason != "" && !isDefined(view.server_cheats.current),
        "An invalid host owner cannot reach the native SV Cheats reading");
    tests\support\checks::expect(!isDefined(view.health_bar) && !isDefined(view.doheart)
        && !isDefined(view.newsbar) && !isDefined(view.ufo),
        "The host display page does not probe unrelated features");
    expect_core_view_unchanged(view);
    view = core_view();
    scripts\apparition\runtime\view_pages::capture("Main", undefined, undefined, view);
    tests\support\checks::expect(!isDefined(view.origin_display) && !isDefined(view.server_cheats),
        "The main page does not read native host settings just to show the link");
}


weapon_root_does_not_read_inventory_and_rejected_options_do_not_probe_it()
{
    foreach (page in ["Weaponry", "Weapon Options"])
    {
        view = core_view();
        scripts\apparition\runtime\view_pages::capture(page, undefined, undefined, view);
        tests\support\checks::expect(isDefined(view.target_actor_reason) && view.target_actor_reason != "",
            "Both weapon pages capture current actor admission before feature state");
        tests\support\checks::expect(!isDefined(view.weapon_current) && !isDefined(view.health_bar)
            && !isDefined(view.perk_callbacks) && !isDefined(view.origin_display),
            "The root and a rejected Options selection cannot query native inventory or unrelated features");
        expect_core_view_unchanged(view);
    }
}


zombie_visibility_probe_stays_on_the_zombie_page()
{
    view = spawnstruct();
    scripts\apparition\runtime\view_pages::capture("Zombie Options", undefined, undefined, view);
    tests\support\checks::expect(isDefined(view.zombie_visibility)
        && view.zombie_visibility.reason != "" && !view.zombie_visibility.configured,
        "The zombie page captures a denied typed visibility snapshot before native queries");
    foreach (page in ["Basic Scripts", "Fun Scripts", "Host Menu", "Players"])
    {
        view = spawnstruct();
        scripts\apparition\runtime\view_pages::capture(page, undefined, undefined, view);
        tests\support\checks::expect(!isDefined(view.zombie_visibility),
            "Other pages do not query global zombie visibility");
    }
}
