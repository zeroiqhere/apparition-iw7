// Credits contracts check ownership without allocating native HUD elements

run()
{
    only_the_live_owner_customization_path_can_start_credits();
    the_same_session_hud_page_target_and_grant_must_survive();
    only_a_live_roll_with_owned_lines_can_continue();
    source_geometry_follows_the_applied_panel();
    only_melee_or_actual_completion_requests_exit();
    release_retires_only_the_current_record_and_is_repeatable();
    an_already_retired_line_cannot_revisit_a_hud_handle();
}

only_the_live_owner_customization_path_can_start_credits()
{
    f = fixture();
    tests\support\checks::expect(scripts\apparition\menu\credits::can_begin(f.state, f.hud, f.layout, true, true),
        "A live owner arriving from Menu Customization can start credits");
    tests\support\checks::expect(!scripts\apparition\menu\credits::can_begin(f.state, f.hud, f.layout, false, true)
        && !scripts\apparition\menu\credits::can_begin(f.state, f.hud, f.layout, true, false),
        "A closed or dead owner cannot start a scrolling HUD");
    f.state.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\credits::can_begin(f.state, f.hud, f.layout, true, true),
        "A remote target cannot receive the owner's credits HUD");
    f = fixture();
    f.state.parents[0].page = "Quick Menu";
    tests\support\checks::expect(!scripts\apparition\menu\credits::can_begin(f.state, f.hud, f.layout, true, true),
        "Credits require their source customization parent");
    f = fixture();
    f.layout.active_editor = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\credits::can_begin(f.state, f.hud, f.layout, true, true),
        "A customization editor cannot share input with credits");
    f = fixture();
    f.hud.released = true;
    tests\support\checks::expect(!scripts\apparition\menu\credits::can_begin(f.state, f.hud, f.layout, true, true),
        "A released HUD cannot allocate credits");
    f = fixture();
    f.hud.credits = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\credits::can_begin(f.state, f.hud, f.layout, true, true),
        "A second roll cannot replace the canonical credits record");
}

the_same_session_hud_page_target_and_grant_must_survive()
{
    f = active_fixture();
    tests\support\checks::expect(scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", f.grant),
        "The current source session and exact grant keep the roll owned");
    tests\support\checks::expect(!scripts\apparition\menu\credits::valid(f.active, spawnstruct(), f.hud, "Verified", f.grant)
        && !scripts\apparition\menu\credits::valid(f.active, f.state, spawnstruct(), "Verified", f.grant),
        "A replacement session or HUD invalidates captured ownership");
    tests\support\checks::expect(!scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Admin", f.grant)
        && !scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", spawnstruct()),
        "Changed access or revoke-and-regrant cannot resume old credits");
    f.state.page = "Menu Customization";
    tests\support\checks::expect(!scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", f.grant),
        "Returning to the source page invalidates delayed credit work");
    f = active_fixture();
    f.state.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", f.grant),
        "A retargeted session cannot keep creating owner text");
    f = active_fixture();
    f.hud.credits = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", f.grant),
        "A stale roll cannot act on a replacement record in the same HUD");
}

only_a_live_roll_with_owned_lines_can_continue()
{
    f = active_fixture();
    f.active.state = "Complete";
    tests\support\checks::expect(scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", f.grant),
        "A completed producer remains owned until the controller exits its page");
    f.active.state = "Retired";
    tests\support\checks::expect(!scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", f.grant),
        "A retired roll cannot create more text even if its page remains current");
    f = active_fixture();
    f.hud.released = true;
    tests\support\checks::expect(!scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", f.grant),
        "A released containing HUD cannot keep its former roll live");
    f = active_fixture();
    f.active.lines = "invalid";
    tests\support\checks::expect(!scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Verified", f.grant),
        "A malformed line owner cannot continue animation");
    f = fixture();
    f.active = scripts\apparition\menu\credits::create(f.state, f.hud, "Host", undefined);
    f.hud.credits = f.active;
    tests\support\checks::expect(scripts\apparition\menu\credits::valid(f.active, f.state, f.hud, "Host", undefined),
        "The host's native access has no guest-grant record to invent");
}

source_geometry_follows_the_applied_panel()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    geometry = scripts\apparition\menu\credits::geometry(layout);
    tests\support\checks::expect(geometry.x == 217 && geometry.start_y == 253 && geometry.end_y == 53,
        "Credits center on the source 220-pixel panel and travel from height minus eight to top plus twelve");
    layout.x = -10;
    layout.y = 70;
    layout.width = 200;
    geometry = scripts\apparition\menu\credits::geometry(layout);
    tests\support\checks::expect(geometry.x == 90 && geometry.start_y == 282 && geometry.end_y == 82,
        "Changed menu position and width move the credit path together");
}

only_melee_or_actual_completion_requests_exit()
{
    f = active_fixture();
    buttons = [];
    buttons["+melee"] = false;
    foreach (command in ["+attack", "+speed_throw", "+activate", "+frag", "+gostand", "+actionslot 1", "+actionslot 4"])
        buttons[command] = true;
    tests\support\checks::expect(!scripts\apparition\menu\credits::exit_requested(f.active, buttons),
        "Ordinary navigation and gameplay keys cannot operate the menu during credits");
    buttons["+melee"] = true;
    tests\support\checks::expect(scripts\apparition\menu\credits::exit_requested(f.active, buttons),
        "Melee exits the source credits roll");
    buttons["+melee"] = false;
    f.active.state = "Complete";
    tests\support\checks::expect(scripts\apparition\menu\credits::exit_requested(f.active, buttons),
        "Only the worker's completion receipt supplies automatic exit");
}

release_retires_only_the_current_record_and_is_repeatable()
{
    f = active_fixture();
    replacement = scripts\apparition\menu\credits::create(f.state, f.hud, "Verified", f.grant);
    f.hud.credits = replacement;
    scripts\apparition\menu\credits::release(f.hud, f.active);
    tests\support\checks::expect(f.hud.credits == replacement && f.active.state == "Playing",
        "An old producer cannot release a replacement roll");
    scripts\apparition\menu\credits::release(f.hud, replacement);
    tests\support\checks::expect(!isDefined(f.hud.credits) && replacement.state == "Retired"
        && replacement.lines.size == 0, "Release clears canonical ownership before retiring the record");
    scripts\apparition\menu\credits::release(f.hud, replacement);
    tests\support\checks::expect(!isDefined(f.hud.credits) && replacement.state == "Retired",
        "Repeated cleanup cannot revisit earlier credit handles");
}

an_already_retired_line_cannot_revisit_a_hud_handle()
{
    line = spawnstruct();
    line.marker = "preserved";
    scripts\apparition\menu\credits::retire_line(line);
    scripts\apparition\menu\credits::retire_line(line);
    tests\support\checks::expect(!isDefined(line.element) && line.marker == "preserved",
        "Repeated retirement of an empty line never reaches a native destroy");
}

fixture()
{
    f = spawnstruct();
    owner = spawnstruct();
    f.layout = scripts\apparition\menu\layout::defaults();
    f.state = scripts\apparition\menu\state::create(owner);
    f.state.page = "Menu Customization";
    scripts\apparition\menu\state::push(f.state, "Credits", owner);
    f.hud = spawnstruct();
    f.hud.owner = owner;
    f.hud.released = false;
    return f;
}

active_fixture()
{
    f = fixture();
    f.grant = spawnstruct();
    f.active = scripts\apparition\menu\credits::create(f.state, f.hud, "Verified", f.grant);
    f.hud.credits = f.active;
    return f;
}
