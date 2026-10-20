// Player-control permission does not replace native host identity or world authority

can_manage(access)
{
    return scripts\apparition\runtime\access::rank(access) >= 5;
}

target_reason(access, same_player, target_host)
{
    if (!scripts\apparition\runtime\access::has_menu(access))
        return "Menu verification is required";
    if (same_player)
        return "";
    if (!can_manage(access))
        return "Co-Host access is required to change another player";
    // The source protects a selected host even though lobby God Mode includes it
    if (target_host && access != "Host" && access != "Developer")
        return "Only the current host can open the host's player controls";
    return "";
}

reason(owner, target)
{
    // Actual actors are admitted before native identity or saved menu roles are read
    actor_reason = scripts\apparition\runtime\context::actor_reason([owner, target]);
    if (actor_reason != "")
        return actor_reason;
    // Menu admission also checks the complete roster and current owner membership
    if (!scripts\apparition\runtime\access::can_open(owner))
        return "A verified current player in private Spaceland is required";
    // A departed player can remain a native actor after leaving the current roster
    if (!scripts\apparition\runtime\context::in_roster(level.players, target))
        return "The player is no longer in the current roster";
    return target_reason(scripts\apparition\runtime\access::role_from_actor(owner),
        owner == target, target isHost());
}

lobby_reason(owner)
{
    actor_reason = scripts\apparition\runtime\context::actor_reason([owner]);
    if (actor_reason != "")
        return actor_reason;
    if (!scripts\apparition\runtime\access::can_open(owner))
        return "A verified current player in private Spaceland is required";
    // Source lobby player actions and global server controls share this scoped permission
    if (!can_manage(scripts\apparition\runtime\access::role_from_actor(owner)))
        return "Co-Host access is required for lobby player controls";
    return "";
}

without_host(owner)
{
    result = spawnstruct();
    result.reason = lobby_reason(owner);
    result.targets = [];
    if (result.reason != "")
        return result;

    host = undefined;
    // This loop uses the actual host identity after full current-roster admission
    foreach (player in level.players)
    {
        if (!player isHost())
            continue;
        if (isDefined(host) && host != player)
        {
            result.reason = "Wait for one current native host";
            return result;
        }
        host = player;
    }
    if (!isDefined(host))
    {
        result.reason = "Wait for the current native host";
        return result;
    }
    // A Co-Host requester remains a recipient under the selected host-only exemption
    result.targets = scripts\apparition\runtime\context::other_players(level.players, host);
    return result;
}
