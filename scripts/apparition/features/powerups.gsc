// Spawn stock Spaceland loot through the native pickup pipeline

locations()
{
    return ["Crosshairs", "Self"];
}

valid_location(location)
{
    if (!isDefined(location) || !isstring(location))
        return false;
    return location == "Crosshairs" || location == "Self";
}

configured_location(player)
{
    if (!isDefined(player))
        return "Crosshairs";
    if (isDefined(player.PowerUpSpawnLocation) && isstring(player.PowerUpSpawnLocation)
        && player.PowerUpSpawnLocation == "Self")
        return "Self";
    return "Crosshairs";
}

set_location(player, location)
{
    if (!valid_location(location) || !isDefined(player))
        return false;
    if (scripts\apparition\runtime\context::actor_reason([player]) != "")
        return false;
    if (!scripts\apparition\runtime\context::supported())
        return false;

    player.PowerUpSpawnLocation = location;
    return true;
}

trace_reason(trace)
{
    if (!isDefined(trace) || !isarray(trace))
        return "Wait for a valid crosshair trace";
    if (!isDefined(trace["position"]) || !isvector(trace["position"]))
        return "Wait for a valid crosshair position";
    // Reject both original names and the aliases used by IW7 trace scripts
    if (!isDefined(trace["surfacetype"]) || !isstring(trace["surfacetype"])
        || trace["surfacetype"] == "" || trace["surfacetype"] == "none"
        || trace["surfacetype"] == "default" || trace["surfacetype"] == "surftype_none"
        || trace["surfacetype"] == "surftype_default")
        return "Aim at a valid surface";
    return "";
}

probe(player)
{
    result = spawnstruct();
    result.reasons = [];

    // Actor admission is captured once and remains separate from host readiness
    if (!isDefined(player))
    {
        result.actor_reason = scripts\apparition\runtime\context::actor_reason([]);
        result.reason = result.actor_reason;
        return result;
    }
    result.actor_reason = scripts\apparition\runtime\context::actor_reason([player]);
    if (result.actor_reason != "")
    {
        result.reason = result.actor_reason;
        return result;
    }

    // The stock loot fallback needs a complete live roster and a valid first player
    if (!scripts\apparition\runtime\context::living_host(player)
        || !scripts\apparition\menu\life::is_alive(player))
    {
        result.reason = "A living host in private Spaceland is required";
        return result;
    }
    if (!isDefined(level.players) || !isarray(level.players) || !level.players.size)
    {
        result.reason = "Wait for a complete native player roster";
        return result;
    }
    roster_reason = scripts\apparition\runtime\context::actor_reason(level.players);
    if (roster_reason != "" || !isDefined(level.players[0])
        || !scripts\apparition\runtime\context::in_roster(level.players, player))
    {
        result.reason = "Wait for the current host in the native player roster";
        return result;
    }

    // Keep row-specific map failures while retaining the actor admission result
    inspection = scripts\apparition\maps\spaceland\powerups::inspect(level);
    result.reason = inspection.reason;
    result.reasons = inspection.reasons;
    if (result.reason != "")
        return result;

    requested_origin = configured_location(player) == "Self"
        ? player.origin
        : crosshair_origin(player, result);
    if (result.reason != "")
        return result;
    if (!isDefined(requested_origin) || !isvector(requested_origin))
    {
        result.reason = "Wait for a valid power-up spawn point";
        return result;
    }

    // Native drops require a navmesh point outside exclusions and inside active play space
    snapped_origin = getclosestpointonnavmesh(requested_origin);
    if (!isDefined(snapped_origin) || !isvector(snapped_origin))
    {
        result.reason = "Wait for a valid power-up navmesh point";
        return result;
    }
    if (!scripts\cp\cp_weapon::isinvalidzone(snapped_origin,
        level.invalid_spawn_volume_array, undefined, undefined, 1))
    {
        result.reason = "Choose a point outside the native power-up exclusion zones";
        return result;
    }
    if (!scripts\cp\loot::is_in_active_volume(snapped_origin))
    {
        result.reason = "Choose a point inside the active play area";
        return result;
    }

    result.origin = snapped_origin;
    return result;
}

crosshair_origin(player, result)
{
    eye = player getEye();
    angles = player getPlayerAngles();
    if (!isDefined(eye) || !isvector(eye) || !isDefined(angles) || !isvector(angles))
    {
        result.reason = "Wait for valid player view data";
        return undefined;
    }

    // Match the original long forward trace and reject misses before navmesh lookup
    trace = BulletTrace(eye, eye + AnglesToForward(angles) * 1000000, 0, player);
    result.reason = trace_reason(trace);
    if (result.reason != "")
        return undefined;
    return trace["position"];
}

request(player, id)
{
    // Resolve only catalog IDs before reading world state or issuing a native command
    entry = scripts\apparition\maps\spaceland\powerups::find(id);
    if (!isDefined(entry))
        return false;

    result = probe(player);
    if (result.reason != "" || result.reasons[id] != "")
        return false;

    // Undefined attribution preserves stock fallback ownership and avoids card notification
    created = level scripts\cp\loot::drop_loot(result.origin, undefined, entry.id,
        undefined, undefined, 1);
    return created == 1;
}
