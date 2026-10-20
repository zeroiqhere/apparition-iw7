// Each saved gun grant owns one supervisor and its selected player's shot waiter

configured(player)
{
    return isDefined(player) && isDefined(player.apparition_teleport_gun);
}

is_current(player, record)
{
    return isDefined(record) && configured(player)
        && player.apparition_teleport_gun == record;
}

release(player, expected_record)
{
    if (!configured(player))
        return false;
    record = player.apparition_teleport_gun;
    // A stale worker cannot clear or stop a newer generation
    if (isDefined(expected_record) && record != expected_record)
        return false;

    // Clear first because the stop event can end this worker's call stack
    player.apparition_teleport_gun = undefined;
    // Each record is its own stop source, so old stops cannot reach a new grant
    if (isstruct(record))
        record notify("apparition_stop_teleport_gun");
    return true;
}

toggle(owner, target)
{
    // Admission also applies to disabling an existing grant
    if (scripts\apparition\features\teleport::authority_reason(owner, target) != "")
        return false;
    if (configured(target))
        return release(target);

    // Native movement readiness pauses shots rather than preventing configuration
    record = spawnstruct();
    record.owner = owner;
    record.menu_grant = owner.apparition_access;
    target.apparition_teleport_gun = record;
    target thread run(record);
    return true;
}

run(record)
{
    self endon("disconnect");
    record endon("apparition_stop_teleport_gun");
    level endon("game_ended");

    // IW childthreads end with this supervisor on stop or lifetime termination
    self childthread on_shot(record);
    while (is_current(self, record))
    {
        // An idle gun must also stop after its requester's permission is lost
        if (scripts\apparition\features\teleport::grant_reason(record.owner, self, record.menu_grant) != "")
        {
            release(self, record);
            return;
        }
        wait 0.05;
    }
}

on_shot(record)
{
    for (;;)
    {
        self waittill("weapon_fired");
        if (!is_current(self, record)
            || scripts\apparition\features\teleport::grant_reason(record.owner, self, record.menu_grant) != "")
            return;

        // Reuse fresh grant and movement checks, with the firing player's own aim
        scripts\apparition\features\teleport::request(record.owner, self, "Crosshairs", true);
    }
}
