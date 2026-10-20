// Apparition's three refill modes are retained without a global ammo override

modes()
{
    return ["Continuous", "Reload", "Disable"];
}

valid_mode(mode)
{
    if (!isDefined(mode) || !isstring(mode))
        return false;

    foreach (supported in modes())
    {
        if (mode == supported)
            return true;
    }

    return false;
}

current_mode(player)
{
    if (!isDefined(player.apparition_ammo_mode))
        return "Disable";

    return player.apparition_ammo_mode;
}

lobby_mode(players)
{
    // Missing roster data is different from a known disabled configuration
    if (!isDefined(players) || !isarray(players) || !players.size)
        return "Unavailable";
    mode = current_mode(players[0]);
    foreach (player in players)
    {
        if (current_mode(player) != mode)
            return "Mixed";
    }
    return mode;
}

set_mode(players, mode)
{
    // Validate mode and the entire actor set before any worker or state changes
    if (!valid_mode(mode))
        return false;
    if (scripts\apparition\runtime\context::actor_reason(players) != "")
        return false;

    // Every target was validated before the first notification or write
    foreach (player in players)
    {
        player notify("apparition_stop_ammo");
        player.apparition_ammo_mode = mode;

        if (mode != "Disable")
            player thread refill_worker(mode);
    }

    return true;
}

refill_worker(mode)
{
    self endon("disconnect");
    self endon("apparition_stop_ammo");
    level endon("game_ended");

    for (;;)
    {
        if (!scripts\apparition\runtime\context::supported())
        {
            self.apparition_ammo_mode = "Disable";
            return;
        }
        // Keep the same worker across respawns without refilling dead actors
        if (isAlive(self))
        {
            weapon = self getCurrentWeapon();

            if (isDefined(weapon) && weapon != "" && weapon != "none")
            {
                self giveMaxAmmo(weapon);

                if (mode == "Continuous")
                {
                    clip_size = weaponClipSize(weapon);

                    if (clip_size > 0)
                    {
                        self setWeaponAmmoClip(weapon, clip_size);

                        // Dual-wield stocks share a weapon ID but have separate clips
                        if (self isDualWielding())
                        {
                            self setWeaponAmmoClip(weapon, clip_size, "left");
                            self setWeaponAmmoClip(weapon, clip_size, "right");
                        }
                    }
                }
            }
        }

        // Use native weapon/spawn events instead of polling every frame
        self wait_for_refresh();
    }
}

wait_for_refresh()
{
    ticket = spawnstruct();
    foreach (event in ["weapon_fired", "weapon_change", "spawned_player"])
        self childthread capture_refresh(ticket, event);
    // A stored receipt also covers an event delivered before the join reaches its wait
    while (!isDefined(ticket.event))
        ticket waittill("apparition_ammo_refresh");
    ticket notify("apparition_cancel_ammo_refresh");
    return ticket.event;
}

capture_refresh(ticket, event)
{
    // IW childthreads end with the parent worker on stop, disconnect or game end
    ticket endon("apparition_cancel_ammo_refresh");
    self waittill(event);
    if (!isDefined(ticket.event))
        ticket.event = event;
    ticket notify("apparition_ammo_refresh");
}
