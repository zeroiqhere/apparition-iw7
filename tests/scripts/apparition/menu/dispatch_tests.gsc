// Admission checks prevent overlapping callbacks and unavailable row execution

run()
{
    row = spawnstruct();
    row.enabled = true;
    row.callback = ::record;
    tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false), "An available row can start while idle");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, true), "An in-progress action prevents another callback");
    row.enabled = false;
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, false), "Disabled rows cannot start");
    row.enabled = true;
    row.callback = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, false), "A row without a callback cannot start");
    queued_rows_require_the_same_current_verified_access();
    restoring_the_same_level_does_not_restore_an_old_queued_grant();
    selection_refresh_plan_preserves_source_delays();
    delayed_redraw_requires_the_original_open_page();
}

delayed_redraw_requires_the_original_open_page()
{
    session = spawnstruct();
    session.page = "Basic Scripts";
    hud = spawnstruct();
    request = spawnstruct();
    request.session = session;
    request.page = session.page;
    request.hud = hud;
    tests\support\checks::expect(scripts\apparition\menu\dispatch::can_refresh(true, session, hud, request),
        "The original open session, page and HUD can accept its delayed redraw");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_refresh(false, session, hud, request),
        "A closed menu rejects a pending bool redraw");
    replacement = spawnstruct();
    replacement.page = session.page;
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_refresh(true, replacement, hud, request),
        "An equal page name in a replacement session cannot inherit an earlier redraw");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_refresh(true, session, spawnstruct(), request),
        "A close and reopen of the same page cannot inherit an old HUD timer");
    session.page = "Menu Preferences";
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_refresh(true, session, hud, request)
        && !scripts\apparition\menu\dispatch::can_refresh(true, undefined, hud, request),
        "Navigation and a missing current session reject the captured page redraw");
}

selection_refresh_plan_preserves_source_delays()
{
    row = spawnstruct();
    row.kind = "toggle";
    plan = scripts\apparition\menu\dispatch::refresh_plan(row);
    tests\support\checks::expect(plan.mode == "redraw" && plan.delay == 0.18 && !plan.color_update,
        "A source bool callback requests a fresh option draw after 180 milliseconds");
    row.setting = "disable_instructions";
    plan = scripts\apparition\menu\dispatch::refresh_plan(row);
    tests\support\checks::expect(plan.mode == "redraw" && plan.delay == 0.18 && !plan.color_update,
        "Disable retains the source bool redraw after its immediate capacity refresh");
    row.setting = "stealth_ui";
    plan = scripts\apparition\menu\dispatch::refresh_plan(row);
    tests\support\checks::expect(plan.mode == "redraw" && plan.delay == 0.18 && !plan.color_update,
        "Stealth keeps the source bool redraw after its optional counter-removal reopen");
    foreach (setting in ["theme", "smooth_rainbow"])
    {
        row.setting = setting;
        plan = scripts\apparition\menu\dispatch::refresh_plan(row);
        tests\support\checks::expect(plan.mode == "redraw" && plan.delay == 0.18 && plan.color_update,
            "Theme bool callbacks start their colors before the delayed option redraw");
    }
    row.kind = "slider";
    foreach (setting in ["bool_display", "bool_location"])
    {
        row.setting = setting;
        plan = scripts\apparition\menu\dispatch::refresh_plan(row);
        tests\support\checks::expect(plan.mode == "redraw" && plan.delay == 0 && !plan.color_update,
            "Applied option layout choices request an immediate fresh draw");
    }
    row.setting = "scroll_time";
    plan = scripts\apparition\menu\dispatch::refresh_plan(row);
    tests\support\checks::expect(plan.mode == "update" && plan.delay == 0 && !plan.color_update,
        "An applied scroll-time slider keeps option handles and has no bool delay");
    row.setting = "design";
    plan = scripts\apparition\menu\dispatch::refresh_plan(row);
    tests\support\checks::expect(plan.mode == "update" && plan.delay == 0 && !plan.color_update,
        "Design owns a full HUD reopen rather than a second option redraw on completion");
    row.kind = "action";
    row.setting = undefined;
    plan = scripts\apparition\menu\dispatch::refresh_plan(row);
    tests\support\checks::expect(plan.mode == "update" && plan.delay == 0 && !plan.color_update,
        "An ordinary completed action updates the current view without a forced redraw");
}

queued_rows_require_the_same_current_verified_access()
{
    row = spawnstruct();
    row.menu_access = "VIP";
    grant = spawnstruct();
    grant.access = "VIP";
    row.menu_grant = grant;
    tests\support\checks::expect(scripts\apparition\menu\dispatch::access_matches(row, "VIP", grant),
        "An unchanged verified role can execute its captured row");
    foreach (access in ["None", "Bot", "Verified", "Admin", "unknown", 7])
        tests\support\checks::expect(!scripts\apparition\menu\dispatch::access_matches(row, access, grant),
            "Revocation or any role change rejects a previously queued row");
    row.menu_access = "None";
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::access_matches(row, "None"),
        "Matching unverified roles still cannot execute menu actions");
    row.menu_access = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::access_matches(row, "Verified")
        && !scripts\apparition\menu\dispatch::access_matches(undefined, "Verified"),
        "A missing capture cannot inherit the current role");
}

record(row, value)
{
    return true;
}

restoring_the_same_level_does_not_restore_an_old_queued_grant()
{
    old_grant = spawnstruct();
    old_grant.access = "Verified";
    restored_grant = spawnstruct();
    restored_grant.access = "Verified";
    row = spawnstruct();
    row.menu_access = "Verified";
    row.menu_grant = old_grant;
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::access_matches(row, "Verified", restored_grant),
        "An equal role name on a new grant cannot revive a queued row from before revocation");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::access_matches(row, "Verified", undefined),
        "A removed current grant rejects the old captured reference");
    row.menu_grant = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::access_matches(row, "Verified", restored_grant),
        "A missing captured grant cannot inherit a later current grant");
    row.menu_access = "Host";
    tests\support\checks::expect(scripts\apparition\menu\dispatch::access_matches(row, "Host", undefined),
        "The native host does not need a guest grant record");
}
