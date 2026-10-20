// Native cabinet damage checks Brute credit and the bullet damage type

scope(state)
{
    selected = spawnstruct();
    selected.reason = "";
    selected.line = "";
    selected.route = "Unavailable";
    if (scripts\apparition\maps\spaceland\ghosts::current_step(state) == 5)
    {
        selected.line = "ghost";
        selected.route = "Initial Unlock";
    }
    else
    {
        attempt = scripts\apparition\maps\spaceland\reactivation_history::current(state);
        if (!isDefined(attempt) || scripts\apparition\maps\spaceland\reactivation_history::step(state) != 0)
        {
            selected.reason = "Wait for a native Brute cabinet stage or an observed reactivation attempt";
            return selected;
        }
        // A later native restart has its own observed identity and input history
        selected.line = "reactivateghost";
        selected.route = "Reactivation";
        selected.attempt = attempt;
    }
    // The native live-agent query reads this roster directly
    if (!isDefined(state.agentarray) || !isarray(state.agentarray))
        selected.reason = "Wait for the native agent roster";
    return selected;
}

reason(state, selected)
{
    if (!isDefined(selected))
        selected = scope(state);
    if (selected.reason != "")
        return selected.reason;
    job = state.apparition_brute_cabinet_job;
    // A new route cannot silently reinterpret an unknown submitted record
    if (isDefined(job) && isDefined(job.submitted) && job.submitted)
    {
        if (!isDefined(job.line) || (job.line != "ghost" && job.line != "reactivateghost")
            || (job.line == "reactivateghost" && !isDefined(job.attempt)))
            return "Cabinet input history is unknown; normal Brute laser hits remain available";
        if (job.line == selected.line && (selected.line == "ghost" || job.attempt == selected.attempt))
            return "A hit was already submitted for this cabinet attempt; normal Brute laser hits remain available";
    }
    return "";
}

target(triggers)
{
    if (triggers.size != 1 || !isDefined(triggers[0])
        || !isDefined(triggers[0].targetname) || triggers[0].targetname != "ghost_arcade_damage_trigger"
        || !isDefined(triggers[0].origin))
        return undefined;
    return triggers[0];
}

eligible(attacker)
{
    // Real entity and live-agent checks happen at the native input boundary
    return isDefined(attacker) && isDefined(attacker.agent_type) && attacker.agent_type == "zombie_brute"
        && isDefined(attacker.team) && attacker.team == "axis"
        && isDefined(attacker.health) && attacker.health > 0;
}

probe(player)
{
    result = scope(level);
    result.reason = reason(level, result);
    if (result.reason != "")
        return result;
    if (!scripts\apparition\runtime\context::living_host(player))
    {
        result.reason = "Only the current living host can request the cabinet hit";
        return result;
    }
    result.target = target(getEntArray("ghost_arcade_damage_trigger", "targetname"));
    if (!isDefined(result.target))
    {
        result.reason = "Wait for one initialized native cabinet damage trigger";
        return result;
    }
    foreach (attacker in scripts\cp\cp_agent_utils::getaliveagentsofteam("axis"))
    {
        if (!isDefined(attacker) || !isAgent(attacker) || !isAlive(attacker) || !eligible(attacker))
            continue;
        // Any actual living native Brute can supply the required attacker credit
        result.attacker = attacker;
        return result;
    }
    result.reason = "Bring an existing living native Brute into the match";
    return result;
}

outcome(state, job, authorized, expired)
{
    if (!isDefined(state.apparition_brute_cabinet_job) || state.apparition_brute_cabinet_job != job)
        return "Unavailable";
    if (!isDefined(job.line))
        return "Unavailable";
    if (job.line == "ghost")
    {
        // Earlier normal completion never substitutes for a reactivation receipt
        if (scripts\apparition\maps\spaceland\ghosts::current_step(state) > 5)
            return "Completed";
    }
    else if (job.line == "reactivateghost")
    {
        attempt = scripts\apparition\maps\spaceland\reactivation_history::current(state);
        if (!isDefined(attempt) || !isDefined(job.attempt) || attempt != job.attempt)
            return "Unavailable";
        if (scripts\apparition\maps\spaceland\reactivation_history::step(state) == 1)
            return "Completed";
    }
    else
        return "Unavailable";
    selected = scope(state);
    if (!authorized || selected.reason != "" || selected.line != job.line
        || (job.line == "reactivateghost" && selected.attempt != job.attempt))
        return "Unavailable";
    return expired ? "Pending" : "";
}

start(player)
{
    if (scripts\apparition\maps\spaceland\ghost_hit_observer::running(level.apparition_brute_cabinet_job))
        return false;
    live = probe(player);
    if (live.reason != "")
        return false;
    job = spawnstruct();
    job.owner = player;
    job.target = live.target;
    job.line = live.line;
    job.attempt = live.attempt;
    job.state = "Observing";
    // Reserve the level slot before starting the input worker
    level.apparition_brute_cabinet_job = job;
    level thread scripts\apparition\maps\spaceland\brute_cabinet_worker::run(job);
    return true;
}
