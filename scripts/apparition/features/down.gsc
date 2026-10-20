// Down submits native damage and leaves the game's laststand lifecycle in control

modes()
{
    return ["Down", "Kill"];
}

damage_amount(health)
{
    if (!isDefined(health) || !isnumber(health))
        return undefined;
    // Admit the source margin before converting or adding signed integer damage
    if (!(health >= 1 && health <= 2147482648) || int(health) != health)
        return undefined;
    return int(health) + 999;
}

state_reason(player)
{
    if (!isDefined(player) || (!isstruct(player) && !isent(player)))
        return "Wait for selected player state";
    if (!isDefined(player.sessionstate) || !isstring(player.sessionstate)
        || player.sessionstate != "playing")
        return "The selected player must be playing";
    if (!isDefined(player.inlaststand) || !isnumber(player.inlaststand))
        return "Wait for native laststand state";
    if (player.inlaststand)
        return "The selected player is already down";
    if (!isDefined(damage_amount(player.health))
        || !isDefined(player.origin) || !isvector(player.origin))
        return "Wait for valid native health and position";
    return "";
}

probe(players)
{
    result = spawnstruct();
    result.targets = [];
    result.hint = "";
    result.reason = scripts\apparition\runtime\context::actor_reason(players);
    if (result.reason != "")
        return result;
    result.reason = scripts\apparition\runtime\context::actor_reason(level.players);
    if (result.reason != "")
        return result;
    if (!scripts\apparition\runtime\context::supported()
        || (isDefined(level.gameended) && level.gameended))
    {
        result.reason = "An active private Spaceland game is required";
        return result;
    }
    foreach (player in players)
    {
        if (!scripts\apparition\runtime\context::in_roster(level.players, player))
        {
            result.reason = "A selected player left the current roster";
            return result;
        }
    }

    first_reason = "No living selected players are ready for Down";
    foreach (player in players)
    {
        reason = "The selected player must be alive";
        if (isAlive(player))
            reason = state_reason(player);
        if (reason == "")
            result.targets[result.targets.size] = player;
        else if (!result.targets.size)
            first_reason = reason;
    }
    result.reason = result.targets.size ? "" : first_reason;
    if (result.targets.size)
        result.hint = "Request Down for " + result.targets.size + "/" + players.size
            + " players; clears their God Mode and Demi-God; native protection may block damage";
    return result;
}

clear_menu_protection(player)
{
    // Native protection is separate from these two menu-owned settings
    if (isDefined(player.playerGodmode) && player.playerGodmode)
        player.playerGodmode = undefined;
    if (isDefined(player.PlayerDemiGod) && player.PlayerDemiGod)
        player.PlayerDemiGod = undefined;
}

request(players)
{
    selected = probe(players);
    if (selected.reason != "")
        return false;
    handled = true;
    foreach (player in selected.targets)
    {
        // Earlier native damage can change life or end the game before the next target
        current = probe([player]);
        if (current.reason != "")
        {
            handled = false;
            continue;
        }
        clear_menu_protection(player);
        // IW7 real-player callers provide the current recipient origin as argument two
        player doDamage(damage_amount(player.health), player.origin);
    }
    // Native shields and laststand branches decide the effect after submission
    return handled;
}

request_lobby(owner)
{
    // Lobby controls include a Co-Host requester and omit only the native host
    selection = scripts\apparition\runtime\player_control::without_host(owner);
    if (selection.reason != "" || !selection.targets.size)
        return false;

    // Preflight the complete current recipient set before any native damage
    admitted = probe(selection.targets);
    if (admitted.reason != "")
        return false;

    // Recheck the requester and each eligible target after every earlier damage event
    foreach (player in admitted.targets)
    {
        if (scripts\apparition\runtime\player_control::lobby_reason(owner) != ""
            || scripts\apparition\runtime\player_control::reason(owner, player) != ""
            || player isHost())
            return false;
        if (!request([player]))
            return false;
    }
    return true;
}
