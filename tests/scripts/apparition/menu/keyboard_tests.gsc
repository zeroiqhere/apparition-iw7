// Keyboard sessions stay inside the current owner's menu and HUD

run()
{
    a_modal_requires_the_main_owned_scroller_and_starts_without_input_or_key_handles();
    health_numberpad_is_owner_scoped_and_requires_host_access();
    message_and_doheart_routes_keep_their_owner_scope();
    admission_requires_the_current_live_owner_hud_and_free_modal_slot();
    a_keyboard_session_captures_one_page_and_exact_current_access();
    only_the_canonical_editing_session_can_continue();
    missing_owners_are_rejected_at_entry_without_fake_player_fixtures();
    cleanup_retires_only_the_expected_keyboard_record();
    player_message_keyboards_capture_the_selected_target_and_retire_on_retarget();
}

player_message_keyboards_capture_the_selected_target_and_retire_on_retarget()
{
    selected = fixture("message");
    selected.state.page = "Options";
    selected.state.target = spawnstruct();
    tests\support\checks::expect(scripts\apparition\menu\keyboard::can_begin(
        "player_message", selected.state, selected.hud, selected.layout, true, true),
        "The selected-player Options page can open a keyboard for its current recipient");
    grant = spawnstruct();
    grant.access = "Co-Host";
    active = scripts\apparition\menu\keyboard::create_session(
        "player_message", selected.state, selected.hud, "Co-Host", grant);
    selected.hud.keyboard = active;
    tests\support\checks::expect(isDefined(active) && active.target == selected.state.target
        && active.target != selected.owner && scripts\apparition\menu\keyboard::valid(
            active, selected.state, selected.hud, "Co-Host", grant),
        "A selected-player keyboard captures its recipient separately from its HUD owner");
    active.menu_access = "Verified";
    grant.access = "Verified";
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        active, selected.state, selected.hud, "Verified", grant),
        "A player-message route rejects a non-manager even with a matching captured role and grant");
    active.menu_access = "Co-Host";
    grant.access = "Co-Host";
    selected.state.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        active, selected.state, selected.hud, "Co-Host", grant),
        "Changing the selected recipient invalidates the captured keyboard");

    lobby = fixture("message");
    lobby.state.page = "All Players";
    tests\support\checks::expect(scripts\apparition\menu\keyboard::can_begin(
        "lobby_message", lobby.state, lobby.hud, lobby.layout, true, true),
        "The All Players page opens the sender-owned lobby message keyboard");
    lobby.state.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "lobby_message", lobby.state, lobby.hud, lobby.layout, true, true),
        "A lobby keyboard rejects an unexpected selected target");
    selected.state.page = "Message Menu";
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "player_message", selected.state, selected.hud, selected.layout, true, true),
        "A selected-player message route cannot borrow the global message page");
}

message_and_doheart_routes_keep_their_owner_scope()
{
    message = fixture("message");
    doheart = fixture("doheart");
    tests\support\checks::expect(scripts\apparition\menu\keyboard::can_begin(
        "message", message.state, message.hud, message.layout, true, true),
        "The Message Menu opens its owner-scoped keyboard");
    tests\support\checks::expect(scripts\apparition\menu\keyboard::can_begin(
        "doheart", doheart.state, doheart.hud, doheart.layout, true, true),
        "The Doheart Options page opens its owner-scoped keyboard");

    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", doheart.state, doheart.hud, doheart.layout, true, true)
        && !scripts\apparition\menu\keyboard::can_begin(
            "doheart", message.state, message.hud, message.layout, true, true),
        "A keyboard kind cannot open from the other source page");
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "profile", message.state, message.hud, message.layout, true, true),
        "Unported keyboard call sites cannot start an unsupported session");
}

admission_requires_the_current_live_owner_hud_and_free_modal_slot()
{
    f = fixture("message");
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, false, true)
        && !scripts\apparition\menu\keyboard::can_begin(
            "message", f.state, f.hud, f.layout, true, false),
        "A closed menu or dead owner cannot open a keyboard");
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", undefined, f.hud, f.layout, true, true)
        && !scripts\apparition\menu\keyboard::can_begin(
            "message", f.state, undefined, f.layout, true, true)
        && !scripts\apparition\menu\keyboard::can_begin(
            "message", f.state, f.hud, undefined, true, true),
        "Missing session, HUD, or layout values cannot start a keyboard");
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", false, f.hud, f.layout, true, true)
        && !scripts\apparition\menu\keyboard::can_begin(
            "message", f.state, false, f.layout, true, true)
        && !scripts\apparition\menu\keyboard::can_begin(
            "message", f.state, f.hud, false, true, true),
        "Non-struct session, HUD, or layout values are rejected");

    f.hud.released = true;
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, true, true),
        "A released HUD cannot acquire a keyboard");
    f = fixture("message");
    f.hud.released = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, true, true),
        "A HUD without a live release marker cannot acquire a keyboard");

    f = fixture("message");
    f.state.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, true, true),
        "A session aimed at another actor cannot open the owner's keyboard");
    f = fixture("message");
    f.hud.keyboard = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, true, true),
        "A second keyboard cannot replace the HUD's canonical session");
    f = fixture("message");
    f.hud.credits = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, true, true),
        "Keyboard input cannot overlap the credits producer");
    f = fixture("message");
    f.layout.active_editor = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, true, true),
        "Keyboard input cannot overlap a customization editor");
}

a_keyboard_session_captures_one_page_and_exact_current_access()
{
    verified = active_fixture("message", "Verified");
    active = verified.active;
    tests\support\checks::expect(active.session == verified.state
        && active.hud == verified.hud && active.page == "Message Menu"
        && active.target == verified.owner,
        "A message keyboard captures the exact menu session, owner HUD, page, and owner reference");
    tests\support\checks::expect(active.menu_access == "Verified"
        && active.menu_grant == verified.grant,
        "A keyboard captures the current role and exact grant reference");
    tests\support\checks::expect(isDefined(active.model) && isstruct(active.model)
        && active.model.status == "Editing" && !isDefined(active.ready_at),
        "A captured keyboard waits for visible entry setup before its input deadline is assigned");

    doheart = active_fixture("doheart", "Co-Host");
    tests\support\checks::expect(doheart.active.page == "Doheart Options"
        && doheart.active.target == doheart.owner
        && doheart.active.menu_access == "Co-Host"
        && doheart.active.menu_grant == doheart.grant,
        "A Co-Host keyboard captures the Doheart page and its exact owner grant");
    host = active_fixture("message", "Host");
    tests\support\checks::expect(host.active.menu_access == "Host"
        && !isDefined(host.active.menu_grant),
        "A native host session preserves the undefined guest-grant state");

    f = fixture("message");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\keyboard::create_session(
        "profile", f.state, f.hud, "Verified", spawnstruct())),
        "An unsupported source keyboard kind cannot create a session");
}

only_the_canonical_editing_session_can_continue()
{
    f = active_fixture("message", "Verified");
    tests\support\checks::expect(scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", f.grant),
        "The canonical keyboard remains valid for the same menu and exact grant");

    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, spawnstruct(), f.hud, "Verified", f.grant)
        && !scripts\apparition\menu\keyboard::valid(
            f.active, f.state, spawnstruct(), "Verified", f.grant),
        "A replacement session or HUD invalidates the captured keyboard");
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Admin", f.grant)
        && !scripts\apparition\menu\keyboard::valid(
            f.active, f.state, f.hud, "Verified", undefined),
        "A changed or revoked role cannot keep an old keyboard active");
    replacement = spawnstruct();
    replacement.access = "Verified";
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", replacement),
        "A replacement grant with the same role cannot inherit the prior session");

    f = active_fixture("message", "Verified");
    f.state.page = "Doheart Options";
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", f.grant),
        "Changing the active page invalidates delayed keyboard work");
    f = active_fixture("message", "Verified");
    f.state.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", f.grant),
        "Retargeting a menu session invalidates its owner keyboard");
    f = active_fixture("message", "Verified");
    f.active.page = "Unsupported Menu";
    f.state.page = f.active.page;
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", f.grant),
        "An unknown page cannot become a keyboard consumer even when both page fields agree");
    f = active_fixture("message", "Verified");
    f.hud.keyboard = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", f.grant),
        "A stale keyboard cannot continue after the HUD installs a replacement");
    f = active_fixture("message", "Verified");
    f.hud.released = true;
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", f.grant),
        "A released HUD cannot resume its former keyboard");
    f = active_fixture("message", "Verified");
    f.active.model.status = "Confirmed";
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", f.grant),
        "A confirmed model cannot accept more keyboard input");
    f = active_fixture("message", "Verified");
    f.active.model.status = "Retired";
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(
        f.active, f.state, f.hud, "Verified", f.grant),
        "A retired model cannot resume after cleanup");
}

missing_owners_are_rejected_at_entry_without_fake_player_fixtures()
{
    // These negative cases keep native player checks ahead of owner field reads
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::begin(undefined, "message")
        && !scripts\apparition\menu\keyboard::can_continue(undefined, undefined),
        "An absent owner cannot start or continue a keyboard session");
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::begin(false, "message")
        && !scripts\apparition\menu\keyboard::can_continue(false, undefined),
        "A non-player owner value cannot start or continue a keyboard session");
    tests\support\checks::expect(scripts\apparition\menu\keyboard::tick(undefined,
        undefined, undefined) == "Invalid",
        "Invalid keyboard input stops before native player or input reads");
}

cleanup_retires_only_the_expected_keyboard_record()
{
    f = active_fixture("message", "Verified");
    f.active.elements = [];
    stale = spawnstruct();
    scripts\apparition\menu\keyboard::release(f.hud, stale);
    tests\support\checks::expect(f.hud.keyboard == f.active
        && f.active.model.status == "Editing",
        "A stale cleanup request cannot retire a replacement keyboard");
    scripts\apparition\menu\keyboard::release(f.hud, f.active);
    tests\support\checks::expect(!isDefined(f.hud.keyboard)
        && f.active.model.status == "Retired" && f.active.elements.size == 0,
        "Current cleanup clears canonical ownership and retires its model");
    scripts\apparition\menu\keyboard::release(f.hud, f.active);
    tests\support\checks::expect(f.active.model.status == "Retired",
        "Repeated cleanup remains harmless after ownership is consumed");
}

fixture(kind)
{
    owner = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    state.page = kind == "message" ? "Message Menu" : "Doheart Options";
    hud = spawnstruct();
    hud.owner = owner;
    hud.released = false;
    hud.chrome = [];
    hud.chrome["scroller"] = spawnstruct();
    hud.requested_colors = [];
    layout = spawnstruct();

    f = spawnstruct();
    f.owner = owner;
    f.state = state;
    f.hud = hud;
    f.layout = layout;
    return f;
}

active_fixture(kind, access)
{
    f = fixture(kind);
    grant = undefined;
    if (access != "Host")
    {
        grant = spawnstruct();
        grant.access = access;
    }
    f.grant = grant;
    f.active = scripts\apparition\menu\keyboard::create_session(
        kind, f.state, f.hud, access, grant);
    f.hud.keyboard = f.active;
    return f;
}

// Numeric editing shares keyboard ownership but keeps its source zero and host route
health_numberpad_is_owner_scoped_and_requires_host_access()
{
    f = fixture("message");
    f.state.page = "Zombie Options";
    tests\support\checks::expect(scripts\apparition\menu\keyboard::page_for_kind("zombie_health") == "Zombie Options"
        && scripts\apparition\menu\keyboard::can_begin("zombie_health", f.state, f.hud, f.layout, true, true),
        "Health Custom opens only from the owner-scoped Zombie Options page");
    active = scripts\apparition\menu\keyboard::create_session("zombie_health", f.state, f.hud, "Host", undefined);
    f.hud.keyboard = active;
    tests\support\checks::expect(active.page == "Zombie Options" && active.target == f.owner
        && active.model.text == "0" && active.model.cursor == 0 && !isDefined(active.ready_at)
        && scripts\apparition\menu\keyboard::valid(active, f.state, f.hud, "Host", undefined),
        "The host numberpad captures one current session with zero and pending visible entry setup");
    active.menu_access = "Co-Host";
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::valid(active, f.state, f.hud, "Co-Host", undefined),
        "A matching Co-Host role cannot continue the host-only numeric route");
    active.menu_access = "Host";
    f.state.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin("zombie_health", f.state, f.hud, f.layout, true, true)
        && !scripts\apparition\menu\keyboard::valid(active, f.state, f.hud, "Host", undefined),
        "Retargeting cannot borrow or continue the world health numberpad");
    numeric = scripts\apparition\menu\keyboard::instructions("Zombie Options");
    text = scripts\apparition\menu\keyboard::instructions("Message Menu");
    tests\support\checks::expect(numeric.size == 4 && text.size == 5
        && numeric[0] == "[{+actionslot 3}]/[{+actionslot 4}] - Scroll"
        && text[2] == "[{+frag}] - Add Space",
        "Numeric instructions omit Frag while text instructions preserve the chosen Frag-to-space control");
    tests\support\checks::expect(scripts\apparition\menu\layout::fixed_panel_height("numberpad") == 58
        && scripts\apparition\menu\layout::fixed_panel_height("keyboard") == 130,
        "The numberpad uses its source frame height without changing text keyboard height");
}

// The menu owns its scroller even while a captured modal owns the key elements
a_modal_requires_the_main_owned_scroller_and_starts_without_input_or_key_handles()
{
    f = active_fixture("message", "Verified");
    tests\support\checks::expect(isDefined(f.active.elements) && isarray(f.active.elements)
        && f.active.elements.size == 0 && !isDefined(f.active.ready_at),
        "Entry starts with an empty owned key map and no input deadline");
    scroller = f.hud.chrome["scroller"];
    scripts\apparition\menu\keyboard::release(f.hud, f.active);
    tests\support\checks::expect(f.hud.chrome["scroller"] == scroller && isDefined(scroller),
        "Retiring keyboard keys leaves the separately menu-owned scroller in place");
    f = fixture("message");
    f.hud.chrome = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, true, true),
        "An absent chrome map cannot be skipped as an undefined array test entry");
    foreach (invalid in [false, spawnstruct()])
    {
        f = fixture("message");
        f.hud.chrome = invalid;
        tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
            "message", f.state, f.hud, f.layout, true, true),
            "A missing or malformed chrome map cannot begin a borrowed-cursor modal");
    }
    f = fixture("message");
    f.hud.chrome["scroller"] = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\keyboard::can_begin(
        "message", f.state, f.hud, f.layout, true, true),
        "A modal cannot start when the main scroller handle is absent");
}
