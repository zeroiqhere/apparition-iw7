// Main navigation follows the source verification thresholds and host-only pages

run()
{
    source_groups_follow_verified_vip_admin_and_cohost_thresholds();
    unknown_and_unverified_access_have_no_main_links();
    role_navigation_preserves_the_existing_host_control_boundary();
    server_modifications_opens_for_cohost_as_an_owner_scoped_page();
    game_modes_placeholder_stays_unavailable_without_a_mode_provider();
    vip_fun_navigation_opens_the_selected_actor_page();
    zombie_world_controls_keep_the_owner_when_another_player_is_selected();
}

vip_fun_navigation_opens_the_selected_actor_page()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = view.owner;
    view.access = "VIP";
    view.host = false;
    rows = scripts\apparition\menu\main_rows::build(view);
    tests\support\checks::expect(rows[9].label == "Fun Scripts" && rows[9].enabled
        && rows[9].destination == "Fun Scripts" && rows[9].target == view.target && !rows[9].lobby,
        "A source VIP's personal Fun Scripts page is reachable without native-host status");
}

source_groups_follow_verified_vip_admin_and_cohost_thresholds()
{
    base = ["Basic Scripts", "Menu Customization", "Message Menu", "Teleport Menu"];
    vip = ["Power-Up Menu", "Profile Management", "Model Manipulation", "Weaponry", "Bullet Menu", "Fun Scripts", "Aimbot Menu"];
    admin = ["Forge Options", "Entity Options", "Advanced Scripts", "Spaceland Scripts"];
    cohost = ["Server Modifications", "Server Tweakables", "Zombie Options", "Spawnables", "Players Menu", "All Players Menu"];
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = view.owner;
    view.host = false;
    expected = base;
    foreach (access in ["Verified", "VIP", "Admin", "Co-Host"])
    {
        view.access = access;
        added = access == "VIP" ? vip : access == "Admin" ? admin : access == "Co-Host" ? cohost : [];
        foreach (label in added)
            expected[expected.size] = label;
        rows = scripts\apparition\menu\main_rows::build(view);
        tests\support\checks::expect(rows.size == expected.size,
            "Each source role exposes only its own and earlier navigation groups");
        if (rows.size != expected.size)
            return;
        for (index = 0; index < rows.size; index++)
            tests\support\checks::expect(rows[index].label == expected[index],
                "Role-filtered links retain the source order");
    }
    view.access = "Host";
    view.host = true;
    rows = scripts\apparition\menu\main_rows::build(view);
    tests\support\checks::expect(rows.size == 23 && rows[19].label == "Host Menu"
        && rows[20].label == "Players Menu" && rows[21].label == "All Players Menu"
        && rows[22].label == "Game Modes", "The native host keeps the complete source main order");
}

unknown_and_unverified_access_have_no_main_links()
{
    view = spawnstruct();
    view.host = false;
    foreach (access in ["Bot", "None", "unknown", 7, [], spawnstruct()])
    {
        view.access = access;
        tests\support\checks::expect(scripts\apparition\menu\main_rows::build(view).size == 0,
            "Unverified or malformed access cannot produce main navigation");
    }
    view.access = undefined;
    tests\support\checks::expect(scripts\apparition\menu\main_rows::build(view).size == 0,
        "An absent role cannot inherit host or guest navigation");
}

role_navigation_preserves_the_existing_host_control_boundary()
{
    view = spawnstruct();
    view.access = "Co-Host";
    view.host = false;
    view.owner = spawnstruct();
    view.target = view.owner;
    rows = scripts\apparition\menu\main_rows::build(view);
    tests\support\checks::expect(rows.size == 21 && rows[19].label == "Players Menu" && rows[19].enabled
        && rows[20].label == "All Players Menu" && rows[20].enabled,
        "Co-Host can open source Players and All Players pages without becoming native Host");
    tests\support\checks::expect(rows[19].destination == "Players" && rows[20].destination == "All Players"
        && rows[19].target == view.target && rows[20].target == view.target,
        "Co-Host navigation keeps the same page destinations and current target");
    tests\support\checks::expect(rows[1].target == view.owner && rows[4].target == view.owner
        && rows[3].target == view.target, "Role filtering preserves personal page ownership");
}

server_modifications_opens_for_cohost_as_an_owner_scoped_page()
{
    view = spawnstruct();
    view.access = "Co-Host";
    view.host = false;
    view.owner = spawnstruct();
    view.target = spawnstruct();
    rows = scripts\apparition\menu\main_rows::build(view);
    row = rows[15];
    tests\support\checks::expect(row.label == "Server Modifications" && row.enabled
        && row.kind == "submenu" && row.destination == "Server Modifications"
        && row.target == view.owner && !row.lobby,
        "Co-Host can browse the owner-scoped server page without becoming native Host");
    tests\support\checks::expect(row.target != view.target,
        "Global server settings do not follow the currently selected player");
}

game_modes_placeholder_stays_unavailable_without_a_mode_provider()
{
    view = spawnstruct();
    view.access = "Host";
    view.host = true;
    view.owner = spawnstruct();
    view.target = view.owner;
    rows = scripts\apparition\menu\main_rows::build(view);
    tests\support\checks::expect(rows.size == 23 && rows[22].label == "Game Modes"
        && rows[22].kind == "unavailable" && !rows[22].enabled,
        "The host keeps the source Game Modes row as an unavailable placeholder without a ported mode provider");
}

zombie_world_controls_keep_the_owner_when_another_player_is_selected()
{
    view = spawnstruct();
    view.access = "Host";
    view.host = true;
    view.owner = spawnstruct();
    view.target = spawnstruct();
    rows = scripts\apparition\menu\main_rows::build(view);
    tests\support\checks::expect(rows[17].label == "Zombie Options"
        && rows[17].target == view.owner && rows[17].target != view.target,
        "World zombie controls open for the menu owner independently of player selection");
}
