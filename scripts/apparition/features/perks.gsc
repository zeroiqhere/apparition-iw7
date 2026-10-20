// Native perk callbacks own effects and HUD data; inventory drives checked rows

owns(player, perk_id)
{
    if (!isDefined(player) || !isDefined(perk_id) || !isstring(perk_id) || perk_id == "")
        return false;
    // Ownership is unreadable until the native inventory has its array shape
    if (!isDefined(player.zombies_perks) || !isarray(player.zombies_perks))
        return false;
    return isDefined(player.zombies_perks[perk_id]) && player.zombies_perks[perk_id];
}

all_owned(players, perk_ids)
{
    // Empty inputs cannot claim that any current player owns the selection
    if (!isDefined(players) || !isarray(players) || !players.size
        || !isDefined(perk_ids) || !isarray(perk_ids) || !perk_ids.size)
        return false;
    foreach (player in players)
    {
        foreach (perk_id in perk_ids)
        {
            if (!owns(player, perk_id))
                return false;
        }
    }
    return true;
}

inventory_reason(inventory)
{
    // Native grant initializes an absent inventory; defined inventories must be arrays
    if (!isDefined(inventory) || isarray(inventory))
        return "";
    return "Wait for native perk inventory";
}

callback_reason(callbacks, perk_ids)
{
    if (!isDefined(perk_ids) || !isarray(perk_ids) || !perk_ids.size)
        return "No perks selected";
    // Native registration stores an array of plain callback records
    if (!isDefined(callbacks) || !isarray(callbacks))
        return "Wait for native perk callbacks";
    foreach (perk_id in perk_ids)
    {
        // Both directions must be registered before any selected perk changes
        if (!isDefined(perk_id) || !isstring(perk_id) || perk_id == ""
            || !isDefined(callbacks[perk_id])
            || !isstruct(callbacks[perk_id])
            || !isDefined(callbacks[perk_id].set)
            || !isDefined(callbacks[perk_id].unset))
            return "Wait for native perk callbacks";
    }
    return "";
}

life_reason(alive, last_stand)
{
    if (!alive)
        return "Players must be alive and out of spectator mode for native perk changes";
    // Last stand keeps positive health while native perk callbacks can replace it
    if (isDefined(last_stand) && last_stand)
        return "Wait until players are out of last stand for native perk changes";
    return "";
}

temporary_reason(gns_active, playing_ghosts_n_skulls, dontremoveperks, keep_perks)
{
    // Stock arcade teardown restores perks before clearing its player markers
    if ((isDefined(gns_active) && gns_active)
        || (isDefined(playing_ghosts_n_skulls) && playing_ghosts_n_skulls)
        || (isDefined(dontremoveperks) && dontremoveperks))
        return "Wait until native temporary perk handling is finished";
    // Preservation may stay pending after a revive until a later native loadout
    if (isDefined(keep_perks) && keep_perks)
        return "Native perk preservation is pending; another spawn may be needed";
    return "";
}

roster_reason(players)
{
    reason = scripts\apparition\runtime\context::actor_reason(players);
    if (reason != "")
        return reason;
    foreach (player in players)
    {
        // Immediate perk changes need normal life; future retention settings do not
        reason = life_reason(scripts\apparition\menu\life::is_alive(player), player.inlaststand);
        if (reason != "")
            return reason;
        // Respawn restoration can be pending after every arcade marker has cleared
        reason = temporary_reason(level.gns_active, player.playing_ghosts_n_skulls, player.dontremoveperks, player.keep_perks);
        if (reason != "")
            return reason;
    }
    // Check inventory only after every actor passes the existing life gate
    foreach (player in players)
    {
        reason = inventory_reason(player.zombies_perks);
        if (reason != "")
            return reason;
    }
    return "";
}

set_owned(player, perk_id, enabled)
{
    // Recheck at the native boundary if an earlier callback changed admission
    if (roster_reason([player]) != ""
        || callback_reason(level.coop_perk_callbacks, [perk_id]) != "")
        return false;
    if (owns(player, perk_id) == enabled)
        return true;

    // Immediate stock variants apply effects and icons without career analytics
    if (enabled)
        player scripts\cp\zombies\zombies_perk_machines::give_zombies_perk_immediate(perk_id, 1);
    else
        player scripts\cp\zombies\zombies_perk_machines::take_zombies_perk_immediate(perk_id);
    return owns(player, perk_id) == enabled;
}

toggle(players, perk_ids)
{
    // Check the complete roster and selection before changing the first actor
    if (roster_reason(players) != ""
        || callback_reason(level.coop_perk_callbacks, perk_ids) != "")
        return false;
    enabled = !all_owned(players, perk_ids);
    succeeded = true;
    foreach (player in players)
    {
        foreach (perk_id in perk_ids)
        {
            // Native callbacks have no verified rollback; actual inventory stays visible
            if (!set_owned(player, perk_id, enabled))
                succeeded = false;
        }
    }
    return succeeded;
}
