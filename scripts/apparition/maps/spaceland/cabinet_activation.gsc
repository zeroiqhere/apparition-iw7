// Read the native collective hold requirements without supplying activation input

scope(state)
{
    result = spawnstruct();
    result.route = "Unavailable";
    result.reason = "Wait for the native cabinet activation stage";
    if (!isDefined(state) || (isDefined(state.gns_active) && state.gns_active))
        return result;

    // A retry registry must never fall back to the persistent initial final index
    if (scripts\apparition\maps\spaceland\reactivation_history::registry_present(state))
    {
        attempt = scripts\apparition\maps\spaceland\reactivation_history::current(state);
        if (!isDefined(attempt) || scripts\apparition\maps\spaceland\reactivation_history::step(state) != 1)
            return result;
        result.route = "Reactivation";
    }
    else
    {
        if (scripts\apparition\maps\spaceland\ghosts::current_step(state) != 6
            || scripts\apparition\maps\spaceland\ghost_history::observed(state))
            return result;
        result.route = "Initial Unlock";
    }

    // Both normal routes delete this marker before returning on their success path
    marker = state.gns_game_console_vfx;
    if (!isDefined(marker) || !isDefined(marker.origin) || !isvector(marker.origin)
        || marker.origin != (2859, -553, 286))
    {
        result.reason = "Wait for the normal native cabinet activation marker";
        return result;
    }
    // This identifies a source-shaped context, not a running-thread or completion receipt
    result.reason = "";
    return result;
}

member_reason(origin, down, carrying, using)
{
    // Keep native blocker priority while making unavailable position/input explicit
    if (isDefined(down) && down)
        return "Leave last stand";
    if (isDefined(carrying) && carrying)
        return "Finish carrying the current item";
    if (!isDefined(origin) || !isvector(origin))
        return "Wait for native player position";
    if (distanceSquared(origin, (2874, -542, 242)) > 2500)
        return "Move within 50 units of the cabinet corner";
    if (!isDefined(using))
        return "Wait for native Use input";
    if (!using)
        return "Hold [{+activate}]";
    return "";
}

probe()
{
    result = scope(level);
    result.members = [];
    if (!scripts\apparition\runtime\context::supported())
        result.reason = "Cabinet snapshots require private normal Spaceland";
    if (result.reason != "")
        return result;

    players = level.players;
    result.reason = scripts\apparition\runtime\context::actor_reason(players);
    if (result.reason != "")
        return result;
    // Admit the complete roster before any native per-player input query
    foreach (index, player in players)
    {
        member = spawnstruct();
        member.name = isDefined(player.name) && isstring(player.name) && player.name != ""
            ? player.name : "Player " + (index + 1);
        member.reason = member_reason(player.origin, player.inlaststand,
            player.iscarrying, player useButtonPressed());
        result.members[result.members.size] = member;
    }
    return result;
}
