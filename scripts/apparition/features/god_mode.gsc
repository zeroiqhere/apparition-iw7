// Apparition behavior reference: CF4_99 and the Apparition contributors
// This module owns flags; the IW damage hook consumes playerGodmode separately

toggle_player(player)
{
    // Clearing directly avoids the original mutually recursive toggle calls
    if (isDefined(player.PlayerDemiGod) && player.PlayerDemiGod)
        player.PlayerDemiGod = undefined;

    if (isDefined(player.playerGodmode) && player.playerGodmode)
        player.playerGodmode = undefined;
    else
        player.playerGodmode = true;
}

all_enabled(players)
{
    if (!isDefined(players) || !isarray(players) || !players.size)
        return false;
    foreach (player in players)
    {
        // Undefined and false flags both represent an inactive feature
        if (!isDefined(player) || !isDefined(player.playerGodmode) || !player.playerGodmode)
            return false;
    }

    return true;
}

reason(players, hook_active)
{
    if (!isDefined(players))
        return "No current players are available";
    if (!isarray(players))
        return "Wait for a valid player roster";
    if (!players.size)
        return "No current players are available";
    foreach (player in players)
    {
        // No earlier entry may change before the whole selection is present
        if (!isDefined(player))
            return "Wait for a valid player roster";
    }
    // Clearing an existing setting remains possible after callback ownership is lost
    if (!hook_active && !all_enabled(players))
        return "Enable requires the active Apparition damage callback";
    return "";
}

toggle(players, hook_active)
{
    // The complete selection is admitted before any flag, including Demi-God, changes
    if (reason(players, hook_active) != "")
        return false;
    enable = !all_enabled(players);

    foreach (player in players)
    {
        enabled = isDefined(player.playerGodmode) && player.playerGodmode;

        // A mixed roster enables only the entries that are currently off
        if (enabled != enable)
            toggle_player(player);
    }
    return true;
}
