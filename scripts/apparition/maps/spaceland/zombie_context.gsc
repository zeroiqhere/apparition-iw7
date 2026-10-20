// Current host admission applies to each ordinary zombie control request

owner_reason(owner)
{
    if (!isDefined(owner))
        return "The current host reference is unavailable";
    if (!scripts\apparition\runtime\context::supported())
        return "Only private Spaceland sessions are supported";
    if (scripts\apparition\runtime\context::actor_reason(level.players) != "")
        return "Wait for a valid native player roster";
    if (!scripts\apparition\runtime\context::in_roster(level.players, owner))
        return "The current host is not in the native player roster";
    if (!scripts\apparition\runtime\context::living_host(owner)
        || scripts\apparition\runtime\access::current(owner) != "Host")
        return "Only the current living host can change zombies";
    return "";
}

snapshot(reason)
{
    // Every response owns a fresh target list, including rejected requests
    result = spawnstruct();
    result.reason = reason;
    result.hint = reason;
    result.targets = [];
    return result;
}
