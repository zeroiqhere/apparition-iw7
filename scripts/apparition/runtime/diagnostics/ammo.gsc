// Optional host-only ammo observations for a private normal Spaceland test
// This entry never refills ammo or changes a player, weapon or quest

start()
{
    // Register only this owned setting so deferred startup options can find it
    setDvarIfUninitialized("apparition_trace_ammo", 0);
    mode = getDvarInt("apparition_trace_ammo");
    if (!mode)
        return;
    // Mode 1 retains ammo-only output; only mode 2 adds native inventory reads
    level thread await_host(mode == 2);
}

await_host(include_inventory)
{
    level endon("game_ended");
    if (getDvar("mapname") != "cp_zmb")
    {
        printLn("Apparition ammo trace refused: normal private Spaceland is required");
        return;
    }
    // Allow the native roster to appear without an endless startup worker
    deadline = getTime() + 120000;
    while (getTime() < deadline)
    {
        if (isDefined(level.gameended) && level.gameended)
            return;
        if (scripts\apparition\runtime\context::supported())
        {
            host = scripts\apparition\runtime\context::current_host(level);
            if (isDefined(host))
            {
                host thread observe(include_inventory);
                return;
            }
        }
        wait 0.1;
    }
    printLn("Apparition ammo trace stopped: no supported current host within 120 seconds");
}

observe(include_inventory)
{
    self endon("disconnect");
    level endon("game_ended");
    ticket = new_ticket(include_inventory);
    previous = undefined;
    reason = "time limit";
    printLn("Apparition ammo trace START: current host only; 180 seconds or 512 records; script-visible reads");
    // Child listeners cannot outlive this observer on disconnect or game end
    foreach (event in events())
        self childthread capture(ticket, event);
    while (getTime() < ticket.deadline && ticket.count < ticket.limit)
    {
        // Admission is repeated before any native player or ammo reads
        if (isDefined(level.gameended) && level.gameended)
        {
            reason = "game ended";
            break;
        }
        if (!scripts\apparition\runtime\context::supported())
        {
            reason = "unsupported session";
            break;
        }
        if (scripts\apparition\runtime\context::current_host(level) != self)
        {
            reason = "host changed";
            break;
        }
        state = self sample_state(ticket.include_inventory);
        // Polling records changes only; relevant events are recorded separately
        if (!isDefined(previous) || state != previous)
        {
            emit(ticket, "sample", state);
            previous = state;
        }
        wait 0.1;
    }
    if (ticket.count >= ticket.limit)
        reason = "record limit";
    // Normal return also cancels blocked listeners immediately
    ticket notify("apparition_ammo_trace_stop");
    printLn("Apparition ammo trace STOP: " + reason + "; records=" + ticket.count);
}

new_ticket(include_inventory)
{
    ticket = spawnstruct();
    ticket.count = 0;
    ticket.started = getTime();
    // The polling worker and every event listener share these fixed bounds
    ticket.deadline = ticket.started + 180000;
    ticket.limit = 512;
    // The same ticket owns the optional detail flag and all observation limits
    ticket.include_inventory = isDefined(include_inventory) && isnumber(include_inventory)
        && include_inventory == 1;
    return ticket;
}

events()
{
    // The first three wake the current ammo worker; the last two test transitions
    return ["weapon_fired", "weapon_change", "spawned_player", "last_stand", "revive"];
}

capture(ticket, event)
{
    ticket endon("apparition_ammo_trace_stop");
    while (ticket.count < ticket.limit)
    {
        self waittill(event);
        if (ticket.count >= ticket.limit || getTime() >= ticket.deadline
            || (isDefined(level.gameended) && level.gameended)
            || !scripts\apparition\runtime\context::supported()
            || scripts\apparition\runtime\context::current_host(level) != self)
            return;
        // Event-time reads may precede the ammo worker in the same native frame
        emit(ticket, event, self sample_state(ticket.include_inventory));
    }
}

sample_state(include_inventory)
{
    // Keep native life and the script last-stand marker separate in the log
    alive = isAlive(self);
    last_stand = "unknown";
    if (isDefined(self.inlaststand) && isnumber(self.inlaststand))
        last_stand = self.inlaststand;
    session = isDefined(self.sessionstate) && isstring(self.sessionstate)
        ? self.sessionstate : "unknown";
    mode = isDefined(self.apparition_ammo_mode) && isstring(self.apparition_ammo_mode)
        ? self.apparition_ammo_mode : "unset";
    weapon = self getCurrentWeapon();
    ammo = "clip=unknown stock=unknown";
    if (isDefined(weapon) && isstring(weapon) && weapon != "" && weapon != "none")
    {
        // Do not gate these reads on alive: last-stand behavior is the open question
        ammo = "clip=" + self getWeaponAmmoClip(weapon)
            + " stock=" + self getWeaponAmmoStock(weapon);
        if (self isDualWielding())
            ammo += " left=" + self getWeaponAmmoClip(weapon, "left")
                + " right=" + self getWeaponAmmoClip(weapon, "right");
    }
    else
        weapon = "none";
    state = "alive=" + alive + " laststand=" + last_stand + " session=" + session
        + " mode=" + mode + " weapon=" + weapon + " " + ammo;
    // Native inventory methods run only for the separately selected detail mode
    if (include_inventory)
        state += " " + self scripts\apparition\runtime\diagnostics\inventory::sample();
    return state;
}

emit(ticket, event, state)
{
    // Event bursts share the same cap as periodic samples
    if (ticket.count >= ticket.limit)
        return false;
    ticket.count++;
    printLn("Apparition ammo trace #" + ticket.count + " t=" + (getTime() - ticket.started)
        + " event=" + event + " " + state);
    return true;
}
