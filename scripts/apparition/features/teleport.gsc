// Direct menu moves preserve source coordinates and respect native travel owners

modes()
{
    return ["Crosshairs", "Sky", "Random Player"];
}

valid_mode(mode)
{
    if (!isDefined(mode) || !isstring(mode))
        return false;
    return scripts\engine\utility::array_contains(modes(), mode);
}

destination(mode, current_origin, aimed_origin, peer_origin)
{
    // Request admits an exact source mode before resolving its destination
    // Each source choice uses exactly one input and has no fallback destination
    switch (mode)
    {
        case "Crosshairs":
            if (isDefined(aimed_origin) && isvector(aimed_origin))
                return aimed_origin;
            break;
        case "Sky":
            if (isDefined(current_origin) && isvector(current_origin))
                return current_origin + (0, 0, 35000);
            break;
        case "Random Player":
            if (isDefined(peer_origin) && isvector(peer_origin))
                return peer_origin;
            break;
    }
    return undefined;
}

saved_reason(record)
{
    if (!isDefined(record) || !isstruct(record)
        || !isDefined(record.origin) || !isvector(record.origin)
        || !isDefined(record.angles) || !isvector(record.angles))
        return "Save a complete location and view angle first";
    return "";
}

ownership_reason(player, arena_active)
{
    if (isDefined(arena_active) && arena_active)
        return "Finish the native Ghosts N Skulls arena first";

    // Native cleanup owns these markers and the movement they protect
    if ((isDefined(player.linked_to_coaster) && player.linked_to_coaster)
        || (isDefined(player.linked_to_player) && player.linked_to_player)
        || (isDefined(player.playing_game) && player.playing_game)
        || (isDefined(player.in_afterlife_arcade) && player.in_afterlife_arcade))
        return "Finish the native ride, player link or arcade game first";
    if ((isDefined(player.is_fast_traveling) && player.is_fast_traveling)
        || (isDefined(player.is_in_pap) && player.is_in_pap)
        || (isDefined(player.teleporting) && player.teleporting))
        return "Finish the native portal trip first";
    if ((isDefined(player.onslide) && player.onslide)
        || (isDefined(player.flung) && player.flung)
        || (isDefined(player.isrewinding) && player.isrewinding))
        return "Finish the native slide, launch or rewind first";
    return "";
}

authority_reason(owner, target)
{
    // Shared authority admits actual actors and current menu policy before travel reads
    return scripts\apparition\runtime\player_control::reason(owner, target);
}

grant_reason(owner, target, grant)
{
    // Shared continuous controls must retain both actor authority and their original grant
    reason = authority_reason(owner, target);
    if (reason != "")
        return reason;
    if (!scripts\apparition\runtime\access::same_grant(grant, owner.apparition_access))
        return "The requesting player's menu verification changed";
    return "";
}

movement_reason(player)
{
    // Callers admit actual current players before reaching these native methods
    if (!isAlive(player) || !isDefined(player.inlaststand) || player.inlaststand)
        return "The player must be alive and out of last stand";
    reason = ownership_reason(player, level.gns_active);
    if (reason != "")
        return reason;
    if (player isInPhase() || player isLinked())
        return "Finish the player's native phase or linked movement first";
    if (!player scripts\cp\utility::isteleportenabled())
        return "Wait until the game allows the player to teleport";
    return "";
}

ready_reason(owner, target)
{
    reason = authority_reason(owner, target);
    return reason != "" ? reason : movement_reason(target);
}

eligible_peers(target)
{
    peers = [];
    // The admitted live roster makes this bounded even when no peer is eligible
    foreach (player in level.players)
    {
        if (player == target || movement_reason(player) != ""
            || scripts\apparition\runtime\context::in_roster(peers, player))
            continue;
        if (isDefined(player.origin) && isvector(player.origin))
            peers[peers.size] = player;
    }
    return peers;
}

probe_movement(owner, target)
{
    result = spawnstruct();
    result.actor_reason = authority_reason(owner, target);
    result.reason = result.actor_reason;
    if (result.actor_reason == "")
        result.reason = movement_reason(target);
    return result;
}

probe(owner, target)
{
    // The full page extends the same two-field snapshot used by entity destinations
    result = probe_movement(owner, target);
    result.aim_reason = result.reason;
    result.random_reason = result.reason;
    result.load_reason = result.reason;
    if (result.reason != "")
        return result;

    // The menu stores reasons only; actions resolve all coordinates again
    if (owner != target)
        result.aim_reason = movement_reason(owner);
    if (!eligible_peers(target).size)
        result.random_reason = "No other current player is ready to receive a teleport";
    result.load_reason = saved_reason(target.apparition_saved_position);
    return result;
}

aim_origin(player)
{
    // Match Apparition's ray endpoint without an invented offset or navmesh snap
    eye = player getEye();
    end = eye + anglesToForward(player getPlayerAngles()) * 1000000;
    trace = bulletTrace(eye, end, false, player);
    if (!isDefined(trace) || !isDefined(trace["position"]) || !isvector(trace["position"]))
        return undefined;
    return trace["position"];
}

request(owner, target, mode, target_aim)
{
    if (!valid_mode(mode) || ready_reason(owner, target) != "")
        return false;

    aimed_origin = undefined;
    peer_origin = undefined;
    if (mode == "Crosshairs")
    {
        // Menu moves use the owner; a fired Teleport Gun uses the selected player
        aimer = isDefined(target_aim) && target_aim ? target : owner;
        if (aimer != target && movement_reason(aimer) != "")
            return false;
        aimed_origin = aim_origin(aimer);
    }
    else if (mode == "Random Player")
    {
        peers = eligible_peers(target);
        if (!peers.size)
            return false;
        peer_origin = peers[randomInt(peers.size)].origin;
    }

    origin = destination(mode, target.origin, aimed_origin, peer_origin);
    if (!isDefined(origin))
        return false;
    // No yield separates current admission, destination lookup and the write
    write_position(target, origin, undefined);
    return true;
}

save(owner, target)
{
    if (ready_reason(owner, target) != "")
        return false;
    record = spawnstruct();
    record.origin = target.origin;
    record.angles = target.angles;
    if (saved_reason(record) != "")
        return false;

    // Publish the complete pair once; no half-save can replace the old position
    target.apparition_saved_position = record;
    return true;
}

load(owner, target)
{
    if (ready_reason(owner, target) != "")
        return false;
    record = target.apparition_saved_position;
    if (saved_reason(record) != "")
        return false;
    write_position(target, record.origin, record.angles);
    return true;
}

official(owner, target, point)
{
    if (ready_reason(owner, target) != "")
        return false;
    catalog = scripts\apparition\maps\spaceland\spawn_points::inspect(level);
    if (catalog.reason != "" || !scripts\engine\utility::array_contains(catalog.points, point))
        return false;

    // This is a direct menu move, using the current struct rather than respawn policy
    write_position(target, point.origin, point.angles);
    return true;
}

entity_origin(kind, origin, angles)
{
    // Retain the source equation without guessing an IW machine-front direction
    if (kind == "wheel")
        return origin - anglesToRight(angles) * 70;
    if (kind == "perk")
        return origin + anglesToRight(angles) * 70;
    return undefined;
}

entity_angles(origin, eye)
{
    return vectorToAngles((origin + (0, 0, 55)) - eye);
}

entity(owner, target, captured)
{
    if (ready_reason(owner, target) != "")
        return false;
    // The displayed reference must survive a fresh native query and registry check
    current = scripts\apparition\maps\spaceland\entity_teleports::resolve(level,
        getEntArray("magic_wheel", "script_noteworthy"), captured);
    if (!isDefined(current))
        return false;
    point = current.point;
    origin = entity_origin(current.kind, point.origin, point.angles);
    // The writer samples the actual eye after moving, as the source callback does
    write_position(target, origin, undefined, point.origin);
    return true;
}

exchange(owner, target, to_self)
{
    if (ready_reason(owner, target) != "" || movement_reason(owner) != "")
        return false;

    // A current player exchanging position with themself already reached the destination
    if (owner == target)
        return true;

    // To Self moves the selected target; To Player moves the menu owner
    destination_player = to_self ? owner : target;
    moving_player = to_self ? target : owner;
    origin = destination_player.origin;
    if (!isDefined(origin) || !isvector(origin))
        return false;
    write_position(moving_player, origin, undefined);
    return true;
}

write_position(player, origin, angles, look_origin)
{
    // Internal callers validate the destination and both actors without yielding
    // Native ownership flags, permission counters and quest state stay untouched
    player setOrigin(origin);
    if (isDefined(look_origin))
        angles = entity_angles(look_origin, player getEye());
    if (isDefined(angles))
        player setPlayerAngles(angles);
}
