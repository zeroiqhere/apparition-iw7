// One selected-player record owns the Save and Load shortcut poller

configured(player)
{
    return isDefined(player) && isDefined(player.apparition_position_shortcuts);
}

release(player, expected_record)
{
    if (!configured(player))
        return false;
    record = player.apparition_position_shortcuts;
    // A stale poller cannot clear or stop a newer shortcut setting
    if (isDefined(expected_record) && record != expected_record)
        return false;

    // Clear intent before notifying because the event ends the worker
    player.apparition_position_shortcuts = undefined;
    if (isstruct(record))
        record notify("apparition_stop_position_shortcuts");
    return true;
}

outside_menu(player)
{
    if (!isDefined(player))
        return false;
    // Pending opens suppress input before the controller marks its menu visible
    if ((isDefined(player.apparition_open) && player.apparition_open)
        || isDefined(player.apparition_open_request))
        return false;
    return true;
}

toggle(owner, target)
{
    // Admission applies to both enabling and disabling the selected player's poller
    if (scripts\apparition\features\teleport::authority_reason(owner, target) != "")
        return false;

    if (configured(target))
        return release(target);

    // The owner and exact grant bind this worker to the current menu session
    record = spawnstruct();
    record.owner = owner;
    record.menu_grant = owner.apparition_access;
    target.apparition_position_shortcuts = record;
    // Show both source bindings before the poller can perform its first action
    target iPrintlnBold("Press [{+actionslot 3}] To ^2Save Current Location");
    target iPrintlnBold("Press [{+actionslot 2}] To ^2Load Saved Location");
    target thread run(record);
    return true;
}

run(record)
{
    self endon("disconnect");
    record endon("apparition_stop_position_shortcuts");
    level endon("game_ended");

    for (;;)
    {
        // Source checks save first, then samples load again after the save delay
        foreach (operation in ["save", "load"])
        {
            if (!configured(self) || self.apparition_position_shortcuts != record)
                return;

            reason = scripts\apparition\features\teleport::grant_reason(record.owner, self,
                record.menu_grant);
            if (reason != "")
            {
                release(self, record);
                return;
            }

            // The selected player's main or quick menu owns its current controls
            if (!outside_menu(self))
                continue;

            if (operation == "save")
            {
                if (self scripts\apparition\menu\input::held("+actionslot 3"))
                {
                    scripts\apparition\features\teleport::save(record.owner, self);
                    wait 0.05;
                }
            }
            else if (self scripts\apparition\menu\input::held("+actionslot 2")
                && scripts\apparition\features\teleport::saved_reason(self.apparition_saved_position) == "")
            {
                scripts\apparition\features\teleport::load(record.owner, self);
                wait 0.05;
            }
        }

        // Preserve the source's shared poll interval after per-action delays
        wait 0.05;
    }
}
