// One level-owned record applies the source's broad half-second hide policy

configured(state)
{
    return isDefined(state) && isDefined(state.apparition_zombie_visibility);
}

owns(state, record)
{
    return isDefined(record) && configured(state)
        && state.apparition_zombie_visibility == record;
}

roster_reason(state)
{
    // The stock team helper expects the native pool to have been initialized
    if (!isDefined(state) || (!isstruct(state) && !isent(state))
        || !isDefined(state.zombie_team) || !isstring(state.zombie_team) || state.zombie_team != "axis"
        || !isDefined(state.agentarray) || !isarray(state.agentarray))
        return "Wait for the native Axis agent roster";
    return "";
}

probe(owner)
{
    result = spawnstruct();
    result.configured = false;
    // Current membership, verification and private context precede all saved-state reads
    result.reason = scripts\apparition\features\server\context::reason(owner);
    if (result.reason != "")
        return result;
    if (!(owner isHost()))
    {
        result.reason = "Only the current host can change zombie visibility";
        return result;
    }
    result.configured = configured(level);
    // The off action remains available even if native roster readiness was lost
    if (!result.configured)
        result.reason = roster_reason(level);
    return result;
}

toggle(owner)
{
    current = probe(owner);
    if (current.reason != "")
        return false;
    if (current.configured)
    {
        stop(level.apparition_zombie_visibility);
        // Show affects the current living set, without restoring earlier visibility
        return apply_current(false);
    }
    record = spawnstruct();
    level.apparition_zombie_visibility = record;
    level thread run(record);
    return true;
}

stop(record)
{
    if (!isDefined(record))
        return;
    // Stale workers may stop their own record but cannot clear a replacement
    if (owns(level, record))
        level.apparition_zombie_visibility = undefined;
    if (isstruct(record))
        record notify("apparition_stop_zombie_visibility");
}

apply_current(hidden)
{
    if (roster_reason(level) != "")
        return false;
    // This native helper includes every living team member, without profile exclusions
    agents = scripts\cp\cp_agent_utils::getaliveagentsofteam("axis");
    foreach (agent in agents)
    {
        // Inactive pool slots stay untouched until native activation shows their model
        if (!isDefined(agent) || !isent(agent) || !isAgent(agent)
            || !isDefined(agent.isactive) || agent.isactive != 1)
            continue;
        if (hidden)
            agent hide(1);
        else
            agent show();
    }
    return true;
}

run(record)
{
    level endon("game_ended");
    record endon("apparition_stop_zombie_visibility");
    while (owns(level, record))
    {
        // The global setting continues through menu closure and host life changes
        if (!scripts\apparition\runtime\context::supported()
            || (isDefined(level.gameended) && level.gameended))
            break;
        apply_current(true);
        wait 0.5;
    }
    stop(record);
}
