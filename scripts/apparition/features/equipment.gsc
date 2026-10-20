// Settings configure refills; the live native power inventory owns grenade identity

enabled(player)
{
    return isDefined(player.apparition_equipment) && player.apparition_equipment;
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
    // A replacement ends the previous worker before publishing its new setting
    player notify("apparition_stop_equipment");
    player.apparition_equipment = undefined;
    if (!requested)
        return;
    player.apparition_equipment = true;
    player thread refill_worker();
}

toggle(players)
{
    if (scripts\apparition\runtime\context::actor_reason(players) != "")
        return false;
    requested = !all_enabled(players);
    // Later joins are outside this dispatch-time selection
    foreach (player in players)
        set_enabled(player, requested);
    return true;
}

probe(player)
{
    result = spawnstruct();
    result.state = "Off";
    if (!isDefined(player))
        return result;
    if (!enabled(player))
        return result;

    // A configured setting still needs a current private-session actor
    if (!scripts\apparition\runtime\context::can_dispatch(player, player, false))
    {
        result.state = "Unavailable";
        return result;
    }

    // Native modes, life and inventory share one ordered read-only decision
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, level.powers,
        scripts\apparition\menu\life::is_alive(player));
    if (isDefined(result.id))
    {
        // Native identity can be selected only while its actual weapon is present
        if (!player hasWeapon(player.powers[result.id].weaponuse))
        {
            result.state = "Missing";
            result.id = undefined;
        }
    }
    return result;
}

summary(probes)
{
    if (!isDefined(probes) || !isarray(probes) || !probes.size)
        return "Unknown";

    ready = 0;
    full = 0;
    paused = 0;
    off = 0;
    // Every sampled player belongs to one category; unknown data cannot imply readiness
    foreach (probe_result in probes)
    {
        if (!isDefined(probe_result) || !isstruct(probe_result)
            || !isDefined(probe_result.state) || !isstring(probe_result.state))
            return "Unknown";

        switch (probe_result.state)
        {
            case "Ready":
                ready++;
                break;
            case "Full":
                full++;
                break;
            case "Off":
                off++;
                break;
            case "Waiting":
            case "Paused":
            case "Unavailable":
            case "Missing":
                paused++;
                break;
            default:
                return "Unknown";
        }
    }

    return "Ready " + ready + ", full " + full + ", paused " + paused + ", off " + off;
}

refill(player)
{
    // The worker consumes a fresh read-only result instead of cached view state
    result = probe(player);
    if (result.state != "Ready" || !isDefined(result.id))
        return false;
    // The stock power refill owns charge clamping, weapon ammo and native HUD updates
    player scripts\cp\loot::recharge_power(result.id);
    return true;
}

refill_worker()
{
    self endon("disconnect");
    self endon("apparition_stop_equipment");
    level endon("game_ended");
    for (;;)
    {
        if (!scripts\apparition\runtime\context::supported())
        {
            self.apparition_equipment = undefined;
            return;
        }
        refill(self);
        // Observe committed native charges rather than infer debit from grenade_fire
        wait 0.1;
    }
}
