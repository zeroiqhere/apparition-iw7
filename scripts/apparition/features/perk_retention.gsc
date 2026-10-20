// A connection-owned record keeps the setting and the last normal down's saved IDs

enabled(player)
{
    return isDefined(player) && isDefined(player.apparition_perk_retention);
}

all_enabled(players)
{
    if (!isDefined(players) || !players.size)
        return false;
    foreach (player in players)
    {
        if (!enabled(player))
            return false;
    }
    return true;
}

set_enabled(player, requested)
{
    if (enabled(player) == requested)
        return;
    // Disabling ends only this feature's listener and pending restore workers
    player notify("apparition_stop_perk_retention");
    player.apparition_perk_retention = undefined;
    if (!requested)
        return;
    record = spawnstruct();
    record.saved = [];
    player.apparition_perk_retention = record;
    player thread watch_spawns(record);
}

capture(player)
{
    if (!enabled(player))
        return;
    saved = [];
    foreach (perk_id in scripts\apparition\maps\spaceland\perks::ids())
    {
        if (scripts\apparition\features\perks::owns(player, perk_id))
            saved[saved.size] = perk_id;
    }
    // The router admits normal inventory before replacing the previous down's snapshot
    player.apparition_perk_retention.saved = saved;
}

toggle(players)
{
    if (scripts\apparition\runtime\context::actor_reason(players) != "")
        return false;
    requested = !all_enabled(players);
    // An existing setting can still be disabled if another hook replaces this one
    if (requested && !scripts\apparition\runtime\perk_retention::active())
        return false;
    foreach (player in players)
        set_enabled(player, requested);
    return true;
}

watch_spawns(record)
{
    self endon("disconnect");
    self endon("apparition_stop_perk_retention");
    level endon("game_ended");
    for (;;)
    {
        self waittill("spawned_player");
        // The source retains this snapshot until the next down or disable
        if (record.saved.size)
            self thread restore_saved(record, record.saved);
    }
}

restore_saved(record, saved)
{
    self endon("disconnect");
    self endon("apparition_stop_perk_retention");
    self endon("spawned_player");
    self endon("last_stand");
    self endon("death");
    level endon("game_ended");
    if (!self restore(record, saved))
        self iPrintLn("Retained perks were not fully restored; current inventory remains visible");
}

restore(record, saved)
{
    // Native loadout preservation reapplies effects before clearing keep_perks
    deadline = getTime() + 5000;
    while ((isDefined(self.keep_perks) && self.keep_perks)
        && ready(self, record) && getTime() < deadline)
        wait 0.05;
    if (!ready(self, record) || (isDefined(self.keep_perks) && self.keep_perks)
        || scripts\apparition\features\perks::callback_reason(level.coop_perk_callbacks, saved) != "")
        return false;
    succeeded = true;
    foreach (perk_id in saved)
    {
        // Each native call gets fresh admission after any earlier callback wait
        if (!ready(self, record))
            return false;
        if (!scripts\apparition\features\perks::set_owned(self, perk_id, true))
            succeeded = false;
    }
    return succeeded;
}

ready(player, record)
{
    return isDefined(record) && enabled(player)
        && player.apparition_perk_retention == record
        && scripts\apparition\runtime\context::can_dispatch(player, player, false)
        && scripts\apparition\menu\life::is_alive(player)
        && !(isDefined(player.inlaststand) && player.inlaststand)
        && !(isDefined(player.in_afterlife_arcade) && player.in_afterlife_arcade)
        && !(isDefined(player.playing_ghosts_n_skulls) && player.playing_ghosts_n_skulls)
        && !(isDefined(player.dontremoveperks) && player.dontremoveperks);
}
