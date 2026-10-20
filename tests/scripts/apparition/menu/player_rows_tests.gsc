// Player navigation preserves the selected actor through the source Options page

run()
{
    source_options_keep_fourteen_labels_and_only_supported_links();
    main_players_options_teleports_and_back_keep_the_target();
    fun_navigation_keeps_the_selected_actor_and_options_parent();
    guest_missing_and_stale_roster_snapshots_disable_navigation();
    cohost_can_manage_current_players_without_opening_host_controls();
    cohost_role_snapshots_fail_closed_for_missing_or_protected_targets();
    missing_views_produce_only_disabled_options();
    invalid_roster_snapshots_never_read_player_names();
    player_rows_clean_names_and_keep_reference_keys();
    options_title_tracks_the_current_selected_name();
    unavailable_selection_titles_never_read_stale_names();
}

player_rows_clean_names_and_keep_reference_keys()
{
    view = ready_view();
    view.owner.name = "^1^AHost";
    view.target.name = "j=^2Guest^7";
    rows = scripts\apparition\menu\player_rows::players(view);
    tests\support\checks::expect(rows[0].label == "[^2Host^7]Host" && rows[1].label == "[^2None^7]Guest",
        "Roster labels use the canonical source formatting-token cleanup");
    tests\support\checks::expect(rows[0].selection_key == view.owner
        && rows[1].selection_key == view.target && rows[1].target == view.target,
        "Each roster row has the current player reference as its stable identity");
    foreach (name in ["", "^A^Bj=", 7, spawnstruct()])
    {
        view.target.name = name;
        rows = scripts\apparition\menu\player_rows::players(view);
        tests\support\checks::expect(rows[1].label == "[^2None^7]Unnamed Player"
            && rows[1].selection_key == view.target,
            "An empty or malformed name retains a visible row and its player reference");
    }
    view.target.name = undefined;
    rows = scripts\apparition\menu\player_rows::players(view);
    tests\support\checks::expect(rows[1].label == "[^2None^7]Unnamed Player",
        "A player still connecting has a visible fallback name");
}

options_title_tracks_the_current_selected_name()
{
    view = ready_view();
    view.target.name = "^1Guest";
    foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
        tests\support\checks::expect(scripts\apparition\menu\design::page_title("Options", design, view) == "[^2None^7]Guest",
            "Every design shows the cleaned selected player's name on Options");
    view.target.name = "Renamed Guest";
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Options", "Apparition", view) == "[^2None^7]Renamed Guest",
        "An Options rebuild reads the current name without caching display identity");
    view.target.name = "^A^B";
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Options", "Apparition", view) == "[^2None^7]Unnamed Player",
        "An empty cleaned name has the same fallback in the roster and title");
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Basic Scripts", "Apparition", view) == "Basic Scripts",
        "A selected actor does not rename unrelated pages");
}

unavailable_selection_titles_never_read_stale_names()
{
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Options", "Apparition", undefined) == "Selected player unavailable",
        "A missing view cannot supply a selected-player title");
    view = ready_view();
    view.target = 7;
    view.actor_reason = "Wait for a valid player roster";
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Options", "Apparition", view) == "Selected player unavailable",
        "Rejected actor admission precedes any selected-name field read");
    view = ready_view();
    view.players = [view.owner];
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Options", "Apparition", view) == "Selected player unavailable",
        "A departed selected actor cannot leave its old name in the title");
    view = ready_view();
    view.players = [view.target];
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Options", "Apparition", view) == "Selected player unavailable",
        "A departed owner cannot supply a ready selected-player title");
    view = ready_view();
    view.host = false;
    view.access = "VIP";
    view.player_access[0].access = "VIP";
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Options", "Apparition", view) == "Selected player unavailable",
        "Lost host authority removes the selected-player title with its navigation");
}

cohost_can_manage_current_players_without_opening_host_controls()
{
    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[0].access = "Co-Host";
    host_target = spawnstruct();
    host_target.name = "Current Host";
    view.players[view.players.size] = host_target;
    host_entry = spawnstruct();
    host_entry.player = host_target;
    host_entry.access = "Host";
    view.player_access[view.player_access.size] = host_entry;
    rows = scripts\apparition\menu\player_rows::players(view);
    tests\support\checks::expect(rows.size == 3 && rows[0].enabled && rows[1].enabled && !rows[2].enabled,
        "Co-Host can select self and a current guest while the current Host stays protected");
    tests\support\checks::expect(rows[2].description == "Only the current host can open the host's player controls"
        && rows[1].target == view.target && rows[1].selection_key == view.target,
        "The protected Host row explains the boundary and the guest row keeps its actor reference");

    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[0].enabled && rows[1].enabled && rows[2].enabled && rows[6].enabled,
        "Co-Host receives selected-player Basic, Teleport and Fun controls but not Verification");
    tests\support\checks::expect(rows[1].target == view.target && rows[2].target == view.target
        && rows[6].target == view.target && rows[1].destination == "Basic Scripts"
        && rows[2].destination == "Teleport Menu" && rows[6].destination == "Fun Scripts",
        "Every supported Co-Host option remains scoped to the selected current guest");

    view.target = host_target;
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[6].enabled
        && rows[1].description == "Only the current host can open the host's player controls",
        "Co-Host cannot open a protected Host target through the Options route");
}

cohost_role_snapshots_fail_closed_for_missing_or_protected_targets()
{
    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[0].access = "Co-Host";
    view.player_access = undefined;
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[6].enabled,
        "Missing target-role capture cannot enable a Co-Host personal page");

    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[0].access = "Co-Host";
    view.player_access[1].access = "unknown";
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[6].enabled,
        "An unrecognized captured target role cannot pass Co-Host admission");

    view = ready_view();
    view.host = false;
    view.access = "Co-Host";
    view.player_access[0].access = "Co-Host";
    view.player_access[1].access = "Host";
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[6].enabled,
        "A captured current Host role stays protected even when the target is a current roster member");

    view = ready_view();
    view.host = false;
    view.access = "VIP";
    view.player_access[0].access = "VIP";
    rows = scripts\apparition\menu\player_rows::players(view);
    tests\support\checks::expect(rows.size == 2 && !rows[0].enabled && !rows[1].enabled,
        "A verified non-Co-Host cannot use the Players control page");
}

source_options_keep_fourteen_labels_and_only_supported_links()
{
    view = ready_view();
    rows = scripts\apparition\menu\player_rows::options(view);
    expected = ["Verification", "Basic Scripts", "Teleport Menu", "Profile Management", "Weaponry",
        "Bullet Menu", "Fun Scripts", "Model Manipulation", "Aimbot Menu", "Model Attachment",
        "Malicious Options", "Send Message", "Freeze", "Kick"];
    tests\support\checks::expect(rows.size == expected.size, "Options retains all fourteen source labels");
    if (rows.size != expected.size)
        return;
    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(rows[index].label == expected[index],
            "Player Options keeps the source order");
        if (index == 0 || index == 1 || index == 2 || index == 6)
            tests\support\checks::expect(rows[index].kind == "submenu" && rows[index].enabled
                && rows[index].target == view.target && !rows[index].lobby
                && rows[index].destination == expected[index]
                && rows[index].callback == scripts\apparition\menu\actions::open_page,
                "The supported personal page keeps its selected actor");
        else if (index == 11)
            tests\support\checks::expect(rows[index].enabled && rows[index].kind == "action"
                && rows[index].target == view.target && !rows[index].lobby
                && rows[index].callback == scripts\apparition\menu\actions::open_player_message_keyboard,
                "Send Message opens the selected recipient keyboard in its source position");
        else
            tests\support\checks::expect(!rows[index].enabled && !isDefined(rows[index].callback),
                "Unported player controls cannot invoke game actions");
    }
}

main_players_options_teleports_and_back_keep_the_target()
{
    view = ready_view();
    owner = view.owner;
    target = view.target;
    state = scripts\apparition\menu\state::create(owner);
    view.target = owner;
    rows = scripts\apparition\menu\model::build(state.page, view);
    row = rows[20];
    tests\support\checks::expect(row.label == "Players Menu" && row.destination == "Players"
        && row.enabled, "The source main Players Menu entry opens the roster");
    scripts\apparition\menu\state::push(state, row.destination, row.target);
    rows = scripts\apparition\menu\model::build(state.page, view);
    row = rows[1];
    tests\support\checks::expect(row.label == "[^2None^7]Guest" && row.destination == "Options"
        && row.target == target && row.enabled, "Selecting a player reaches Options rather than trapping navigation in Basic Scripts");
    scripts\apparition\menu\state::push(state, row.destination, row.target);
    view.target = state.target;
    rows = scripts\apparition\menu\model::build(state.page, view);
    row = rows[2];
    tests\support\checks::expect(row.label == "Teleport Menu" && row.target == target && row.enabled,
        "The source Options teleport link retains the selected remote actor");
    scripts\apparition\menu\state::push(state, row.destination, row.target);
    rows = scripts\apparition\menu\model::build(state.page, view);
    tests\support\checks::expect(state.page == "Teleport Menu" && state.target == target
        && rows.size == 10 && rows[8].target == target && rows[9].target == target,
        "The complete visible route reaches both remote teleport directions");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Options" && state.target == target,
        "Back from Teleport Menu returns to the same player's Options");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Players" && state.target == owner,
        "Back from Options restores the roster owner's prior target");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Main" && state.target == owner && state.parents.size == 0,
        "Back from Players restores the original owner root without a stale target");
}

fun_navigation_keeps_the_selected_actor_and_options_parent()
{
    view = ready_view();
    state = scripts\apparition\menu\state::create(view.owner);
    state.page = "Options";
    state.target = view.target;
    rows = scripts\apparition\menu\player_rows::options(view);
    row = rows[6];
    tests\support\checks::expect(row.enabled && row.label == "Fun Scripts"
        && row.destination == "Fun Scripts" && row.target == view.target,
        "The host's source Options link offers the selected player's Fun page");
    scripts\apparition\menu\state::push(state, row.destination, row.target);
    view.target = state.target;
    rows = scripts\apparition\menu\model::build(state.page, view);
    tests\support\checks::expect(state.page == "Fun Scripts" && state.target == view.players[1]
        && rows.size == 37 && rows[0].target == state.target,
        "Fun Scripts reaches the selected actor without replacing the target with the host");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Options" && state.target == view.players[1],
        "Back from the Fun page restores that same selected player's Options");
}

guest_missing_and_stale_roster_snapshots_disable_navigation()
{
    view = ready_view();
    view.host = false;
    view.access = "VIP";
    view.player_access[0].access = "VIP";
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[6].enabled,
        "Guests cannot enter remote Basic, Teleport or Fun controls");
    view = ready_view();
    view.actor_reason = undefined;
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[6].enabled,
        "A missing roster admission cannot enable player links");
    view = ready_view();
    view.players = [view.owner];
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[6].enabled,
        "A departed selected actor cannot retain enabled Options links");
    view = ready_view();
    view.players = [view.target];
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[6].enabled,
        "The menu owner must also remain a current roster member");
}

invalid_roster_snapshots_never_read_player_names()
{
    view = ready_view();
    view.players = [7];
    view.actor_reason = "Wait for a valid player roster";
    rows = scripts\apparition\menu\player_rows::players(view);
    tests\support\checks::expect(rows.size == 0,
        "Rejected actor snapshots return before reading any name field");
    view.players = "invalid";
    view.actor_reason = "";
    rows = scripts\apparition\menu\player_rows::players(view);
    tests\support\checks::expect(rows.size == 0,
        "A malformed roster cannot be iterated even with a stale ready reason");
    view = ready_view();
    view.host = false;
    view.access = "VIP";
    view.player_access[0].access = "VIP";
    rows = scripts\apparition\menu\player_rows::players(view);
    tests\support\checks::expect(rows.size == 2 && !rows[0].enabled && !rows[1].enabled,
        "A valid guest snapshot can display names without granting player navigation");
}

missing_views_produce_only_disabled_options()
{
    rows = scripts\apparition\menu\player_rows::options(undefined);
    tests\support\checks::expect(rows.size == 14 && !rows[1].enabled && !rows[2].enabled && !rows[6].enabled
        && !isDefined(rows[1].target) && !isDefined(rows[2].target) && !isDefined(rows[6].target),
        "An absent view cannot supply a target to a supported player page");
    rows = scripts\apparition\menu\player_rows::players(undefined);
    tests\support\checks::expect(rows.size == 0,
        "An absent roster view returns without player-name reads");
}

ready_view()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.owner.name = "Host";
    view.target = spawnstruct();
    view.target.name = "Guest";
    view.players = [view.owner, view.target];
    view.actor_reason = "";
    view.host = true;
    view.access = "Host";
    view.player_access = [];
    foreach (player in view.players)
    {
        entry = spawnstruct();
        entry.player = player;
        entry.access = player == view.owner ? "Host" : "None";
        view.player_access[view.player_access.size] = entry;
    }
    return view;
}
