// Weapon pages retain source positions and never carry a cached weapon into dispatch

run()
{
    root_keeps_the_non_verko_source_order_and_options_link();
    options_keep_the_original_four_controls_and_drop_choices();
    current_weapon_action_uses_only_the_selected_actor();
    source_role_and_actor_denials_win_over_captured_inventory();
    missing_malformed_and_denied_weapon_snapshots_stay_disabled();
    main_and_selected_player_links_keep_the_requested_target();
}

ready_view()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.host = true;
    view.access = "Host";
    view.target_actor_reason = "";
    view.weapon_current = spawnstruct();
    view.weapon_current.reason = "";
    view.weapon_current.weapon = "iw7_rifle_zm";
    return view;
}

root_keeps_the_non_verko_source_order_and_options_link()
{
    view = ready_view();
    expected = ["Options", "Attachments", "Loadout", "Camo", "AAT", "", "Equipment",
        "Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles",
        "Shotguns", "Pistols", "Launchers", "Specials"];
    rows = scripts\apparition\menu\model::build("Weaponry", view);
    tests\support\checks::expect(rows.size == expected.size,
        "The root keeps the original options group, spacer, equipment and eight categories");
    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(rows[index].label == expected[index],
            "Original non-Verko weapon labels stay in physical order");
        if (index != 0)
            tests\support\checks::expect(!rows[index].enabled,
                "Unbound inventory, catalog and customization controls remain unavailable");
    }
    tests\support\checks::expect(rows[0].enabled && rows[0].destination == "Weapon Options"
        && rows[0].target == view.target,
        "The root Options link keeps the selected actor rather than the menu owner");
}

options_keep_the_original_four_controls_and_drop_choices()
{
    rows = scripts\apparition\menu\weapon_rows::build("Weapon Options", ready_view());
    tests\support\checks::expect(rows.size == 4 && rows[0].label == "Take Current Weapon"
        && rows[1].label == "Take All Weapons" && rows[2].label == "Drop Current Weapon"
        && rows[3].label == "Pack 'a' Punch Current Weapon",
        "The source Options page keeps its four controls in order");
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[3].enabled,
        "Unresolved All, drop/regrant and Pack-a-Punch bindings cannot be dispatched");
    tests\support\checks::expect(rows[2].kind == "slider" && rows[2].values.size == 2
        && rows[2].values[0] == "Take" && rows[2].values[1] == "Don't Take",
        "The unavailable drop control still shows its exact original choices");
    state = scripts\apparition\menu\state::create(spawnstruct());
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, rows[2]) == "Take",
        "The disabled source drop slider keeps its first choice as the initial preview");
}

current_weapon_action_uses_only_the_selected_actor()
{
    view = ready_view();
    rows = scripts\apparition\menu\model::build("Weapon Options", view);
    row = rows[0];
    tests\support\checks::expect(row.enabled && row.kind == "action" && !row.lobby
        && row.target == view.target && row.callback == scripts\apparition\menu\actions::take_current_weapon,
        "Take Current keeps the selected player and calls the one fresh native action");
    tests\support\checks::expect(!isDefined(row.weapon) && !isDefined(row.checked),
        "The held weapon is only a display snapshot, not cached dispatch or toggle state");
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Weapon Options", "Apparition", view) == "Options",
        "The source Options title stays separate from its unique navigation key");
}

source_role_and_actor_denials_win_over_captured_inventory()
{
    view = ready_view();
    view.access = "Verified";
    tests\support\checks::expect(!scripts\apparition\menu\weapon_rows::build("Weaponry", view)[0].enabled
        && !scripts\apparition\menu\weapon_rows::build("Weapon Options", view)[0].enabled,
        "A lower source role cannot open Options or enable removal");
    view = ready_view();
    view.target_actor_reason = "Selected player left";
    row = scripts\apparition\menu\weapon_rows::build("Weapon Options", view)[0];
    tests\support\checks::expect(!row.enabled && row.description == view.target_actor_reason,
        "The current actor denial wins over a previously ready weapon snapshot");
}

missing_malformed_and_denied_weapon_snapshots_stay_disabled()
{
    tests\support\checks::expect(!scripts\apparition\menu\weapon_rows::build("Weapon Options", undefined)[0].enabled,
        "A missing view cannot enable native weapon removal");
    view = ready_view();
    view.weapon_current = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\weapon_rows::build("Weapon Options", view)[0].enabled,
        "Missing native inventory readiness cannot authorize removal");
    foreach (value in [7, [], spawnstruct(), "ready"])
    {
        view.weapon_current = value;
        tests\support\checks::expect(!scripts\apparition\menu\weapon_rows::build("Weapon Options", view)[0].enabled,
            "Malformed snapshots cannot authorize removal");
    }
    view = ready_view();
    view.weapon_current.reason = "Wait for a temporary weapon owner";
    row = scripts\apparition\menu\weapon_rows::build("Weapon Options", view)[0];
    tests\support\checks::expect(!row.enabled && row.description == view.weapon_current.reason,
        "The native denial remains visible on the unavailable action");
}

main_and_selected_player_links_keep_the_requested_target()
{
    view = ready_view();
    rows = scripts\apparition\menu\main_rows::build(view);
    tests\support\checks::expect(rows[7].enabled && rows[7].destination == "Weaponry"
        && rows[7].target == view.target,
        "The original main Weaponry link keeps the selected target");
    view.players = [view.owner, view.target];
    view.actor_reason = "";
    view.player_access = [];
    foreach (player in view.players)
    {
        entry = spawnstruct();
        entry.player = player;
        entry.access = player == view.owner ? "Host" : "None";
        view.player_access[view.player_access.size] = entry;
    }
    rows = scripts\apparition\menu\player_rows::options(view);
    tests\support\checks::expect(rows[4].enabled && rows[4].destination == "Weaponry"
        && rows[4].target == view.target,
        "The selected-player Weaponry link retains its target and original position");
}
