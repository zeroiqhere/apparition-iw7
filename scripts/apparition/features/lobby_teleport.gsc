// Lobby Teleport moves every current non-host player through existing teleport writers

modes()
{
    return ["Self", "Crosshairs", "Sky"];
}

valid_mode(mode)
{
    if (!isDefined(mode) || !isstring(mode))
        return false;
    return scripts\engine\utility::array_contains(modes(), mode);
}

ordered_targets(targets, owner, mode)
{
    if (mode != "Crosshairs")
        return targets;

    ordered = [];
    // Keep every other player's source order and defer an included requester
    foreach (target in targets)
    {
        if (target != owner)
            ordered[ordered.size] = target;
    }
    foreach (target in targets)
    {
        if (target == owner)
            ordered[ordered.size] = target;
    }
    return ordered;
}

probe(owner)
{
    result = spawnstruct();
    result.owner_reason = "Wait for owner movement readiness";
    result.targets = [];

    // One authority snapshot includes the requester when they are a Co-Host
    selection = scripts\apparition\runtime\player_control::without_host(owner);
    if (selection.reason != "")
    {
        result.reason = selection.reason;
        return result;
    }
    if (isDefined(level.gameended) && level.gameended)
    {
        result.reason = "An active private Spaceland game is required";
        return result;
    }

    // The requester must be ready for modes that use their origin or aim
    result.owner_reason = scripts\apparition\features\teleport::movement_reason(owner);
    if (result.owner_reason == ""
        && (!isDefined(owner.origin) || !isvector(owner.origin)))
        result.owner_reason = "Wait for a valid requester position";

    targets = selection.targets;
    if (!targets.size)
    {
        result.reason = "No current non-host players are available";
        return result;
    }

    // Preflight the complete non-host set before any destination can be written
    foreach (target in targets)
    {
        reason = scripts\apparition\runtime\player_control::reason(owner, target);
        if (reason != "" || target isHost())
        {
            result.reason = reason != "" ? reason : "The current native host stays in place";
            return result;
        }
        reason = scripts\apparition\features\teleport::movement_reason(target);
        if (reason != "")
        {
            result.reason = reason;
            return result;
        }
        if (!isDefined(target.origin) || !isvector(target.origin))
        {
            result.reason = "Wait for a valid selected-player position";
            return result;
        }
    }

    result.reason = "";
    result.targets = targets;
    return result;
}

request(owner, mode)
{
    // Invalid UI values cannot trigger actor, roster or destination reads
    if (!valid_mode(mode))
        return false;

    selected = probe(owner);
    if (selected.reason != "")
        return false;
    if (mode != "Sky" && selected.owner_reason != "")
        return false;

    // An included Co-Host stays at the ray origin until everyone else is moved
    targets = ordered_targets(selected.targets, owner, mode);
    foreach (target in targets)
    {
        // Recheck lobby access and the selected actor immediately before the writer
        if (scripts\apparition\runtime\player_control::lobby_reason(owner) != ""
            || scripts\apparition\runtime\player_control::reason(owner, target) != ""
            || target isHost())
            return false;

        if (mode == "Self")
        {
            if (!scripts\apparition\features\teleport::exchange(owner, target, true))
                return false;
        }
        else if (!scripts\apparition\features\teleport::request(owner, target, mode))
            return false;
    }
    return true;
}
