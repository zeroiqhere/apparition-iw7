// One selected player's record owns the health HUD until disable or observed death

measure(health, maximum)
{
    shape = spawnstruct();
    shape.reason = "Wait for valid native health and maximum health";
    if (!isDefined(health) || !isnumber(health)
        || !isDefined(maximum) || !isnumber(maximum))
        return shape;
    // Native health is signed integer state; reject invalid pairs instead of clamping health
    if (!(maximum >= 1 && maximum <= 2147483647 && health >= 0 && health <= maximum))
        return shape;

    // Scale before pixel conversion so even large admitted health stays within 150
    width = maximum > 150 ? (health / maximum) * 150 : health;
    shape.background_width = int(min(maximum, 150)) + 2;
    shape.fill_width = int(width);
    shape.reason = "";
    return shape;
}

configured(player)
{
    // Presence is also retained for malformed old state so Use can remove it
    return isDefined(player) && isDefined(player.apparition_health_bar);
}

is_current(player, record)
{
    return isDefined(record) && configured(player)
        && player.apparition_health_bar == record;
}

probe(owner, target)
{
    result = spawnstruct();
    result.configured = false;
    // Shared admission precedes saved-state and native health reads
    result.reason = scripts\apparition\runtime\access::fun_reason(owner, target);
    if (result.reason != "")
        return result;

    result.configured = configured(target);
    // Removing this menu's own display must not depend on health or life readiness
    if (result.configured)
        return result;
    if (!scripts\apparition\menu\life::is_alive(target))
    {
        result.reason = "The selected player must be alive";
        return result;
    }
    result.shape = measure(target.health, target.maxhealth);
    result.reason = result.shape.reason;
    return result;
}

toggle(owner, target)
{
    // This fresh probe supplies initial dimensions rather than replaying a row snapshot
    current = probe(owner, target);
    if (current.reason != "")
        return false;
    if (current.configured)
        return release(target);

    record = scripts\apparition\menu\health_bar_hud::create(target, current.shape);
    if (!isDefined(record))
        return false;
    // Publish only after both native handles exist, then start one independent worker
    target.apparition_health_bar = record;
    target thread run(record);
    return true;
}

release(player)
{
    if (!configured(player))
        return false;
    retire(player, player.apparition_health_bar);
    return true;
}

retire(player, record)
{
    if (!isDefined(record))
        return;
    // An old worker may retire its own handles but cannot clear a newer configuration
    if (is_current(player, record))
        player.apparition_health_bar = undefined;
    scripts\apparition\menu\health_bar_hud::destroy_record(record);
    // Notify last because this call may be running inside the worker being stopped
    if (isstruct(record))
        record notify("apparition_stop_health_bar");
}

run(record)
{
    self endon("disconnect");
    level endon("game_ended");
    record endon("apparition_stop_health_bar");
    while (is_current(self, record))
    {
        // Menu closure has no bearing on the source display's independent lifetime
        if (!scripts\apparition\runtime\context::supported()
            || !scripts\apparition\menu\life::is_alive(self))
            break;
        shape = measure(self.health, self.maxhealth);
        if (shape.reason != "" || !scripts\apparition\menu\health_bar_hud::paint(record, shape))
            break;
        wait 0.01;
    }
    // Observed death turns the option off, matching the source BoolVar transition
    retire(self, record);
}
