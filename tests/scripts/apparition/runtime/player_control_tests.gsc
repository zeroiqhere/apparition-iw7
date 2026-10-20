// Player permissions keep Co-Host access separate from native host identity

run()
{
    management_requires_the_source_cohost_tier();
    verified_personal_access_does_not_allow_remote_control();
    cohosts_can_select_current_nonhost_players();
    cohosts_cannot_select_the_native_host();
    missing_verification_rejects_selection();
    missing_actors_cannot_read_or_change_target_settings();
    missing_lobby_owners_return_a_rejected_empty_selection();
}

management_requires_the_source_cohost_tier()
{
    foreach (role in ["Bot", "None", "Verified", "VIP", "Admin", "unknown", 17, [], spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\runtime\player_control::can_manage(role),
            "A role below Co-Host or malformed role cannot manage other players");
    tests\support\checks::expect(!scripts\apparition\runtime\player_control::can_manage(undefined),
        "An absent role grants no player-management access");
    foreach (role in ["Co-Host", "Host", "Developer"])
        tests\support\checks::expect(scripts\apparition\runtime\player_control::can_manage(role),
            "The source Co-Host tier and higher roles may manage player controls");
}

verified_personal_access_does_not_allow_remote_control()
{
    foreach (role in ["Verified", "VIP", "Admin"])
    {
        tests\support\checks::expect(scripts\apparition\runtime\player_control::target_reason(role, true, false) == "",
            "A current verified player retains personal controls");
        tests\support\checks::expect(scripts\apparition\runtime\player_control::target_reason(role, false, false)
            == "Co-Host access is required to change another player",
            "Personal menu access cannot change another player");
    }
}

cohosts_can_select_current_nonhost_players()
{
    tests\support\checks::expect(scripts\apparition\runtime\player_control::target_reason("Co-Host", false, false) == "",
        "A Co-Host may control another current nonhost player");
    tests\support\checks::expect(scripts\apparition\runtime\player_control::target_reason("Co-Host", true, false) == "",
        "A Co-Host retains personal controls");
}

cohosts_cannot_select_the_native_host()
{
    tests\support\checks::expect(scripts\apparition\runtime\player_control::target_reason("Co-Host", false, true)
        == "Only the current host can open the host's player controls",
        "The source selected-player guard protects the native host from Co-Host control");
    tests\support\checks::expect(scripts\apparition\runtime\player_control::target_reason("Host", true, true) == "",
        "The native host retains its own controls");
    tests\support\checks::expect(scripts\apparition\runtime\player_control::target_reason("Host", false, false) == "",
        "The native host retains control of current guests");
}

missing_verification_rejects_selection()
{
    foreach (role in ["None", "Bot", "unknown", 17])
        tests\support\checks::expect(scripts\apparition\runtime\player_control::target_reason(role, true, false)
            == "Menu verification is required",
            "An unverified or malformed role cannot retain personal control");
}

missing_actors_cannot_read_or_change_target_settings()
{
    target = spawnstruct();
    target.saved_setting = "unchanged";
    tests\support\checks::expect(scripts\apparition\runtime\player_control::reason(undefined, target) != "",
        "A missing requester fails before target settings are read");
    tests\support\checks::expect(scripts\apparition\runtime\player_control::reason(undefined, undefined) != "",
        "Missing requester and target are rejected");
    tests\support\checks::expect(target.saved_setting == "unchanged",
        "Rejected permission checks do not mutate the proposed target");
}

missing_lobby_owners_return_a_rejected_empty_selection()
{
    tests\support\checks::expect(scripts\apparition\runtime\player_control::lobby_reason(undefined) != "",
        "A missing requester cannot manage lobby players");
    selected = scripts\apparition\runtime\player_control::without_host(undefined);
    tests\support\checks::expect(selected.reason != "" && selected.targets.size == 0,
        "A rejected lobby owner cannot expose any target references");
}
