// Session restrictions are rechecked when actions are dispatched

private_session(online_game, private_match)
{
    return !online_game || private_match;
}

target_allowed(host, same_player, current_member)
{
    return same_player || (host && current_member);
}

in_roster(players, target)
{
    // Membership checks also serve callers that have not admitted the full roster
    if (!isDefined(players) || !isarray(players))
        return false;
    foreach (player in players)
    {
        if (player == target)
            return true;
    }
    return false;
}

other_players(players, host)
{
    selected = [];
    if (!isDefined(players) || !isarray(players) || !isDefined(host)
        || !in_roster(players, host))
        return selected;
    // The caller supplies the sole excluded player
    foreach (player in players)
    {
        if (player != host)
            selected[selected.size] = player;
    }
    return selected;
}

actor_reason(players)
{
    if (!isDefined(players))
        return "No current players are available";
    if (!isarray(players))
        return "Wait for a valid player roster";
    if (!players.size)
        return "No current players are available";
    for (index = 0; index < players.size; index++)
    {
        // Missing numeric slots cannot disappear from complete-list admission
        player = players[index];
        // Native actor operations require actual players before reading their fields
        if (!isDefined(player) || !isPlayer(player))
            return "Wait for a valid player roster";
    }
    return "";
}

supported()
{
    if (getDvar("mapname") != "cp_zmb" || !isDefined(level.onlinegame))
        return false;

    // Spaceland's Escape gametype uses a different map lifecycle
    if (scripts\cp\utility::is_escape_gametype())
        return false;

    return private_session(level.onlinegame, getDvarInt("xblive_privatematch") != 0);
}

can_dispatch(owner, target, lobby)
{
    if (!supported() || !isDefined(owner) || !isPlayer(owner))
        return false;

    if (lobby)
        return isDefined(level.players) && owner isHost();

    if (!isDefined(target) || !isPlayer(target))
        return false;

    current_member = isDefined(level.players) && in_roster(level.players, target);
    return target_allowed(owner isHost(), owner == target, current_member);
}

// All level-owned combat and pickup workers use the same live host boundary
living_host(player)
{
    return can_dispatch(player, undefined, true) && isAlive(player)
        && (!isDefined(player.inlaststand) || !player.inlaststand);
}

current_host(state)
{
    // Read native host state only from a fully admitted current roster
    if (!isDefined(state) || !isDefined(state.players)
        || actor_reason(state.players) != "")
        return undefined;

    host = undefined;
    foreach (player in state.players)
    {
        if (!player isHost())
            continue;
        if (isDefined(host))
            return undefined;
        host = player;
    }
    return host;
}
