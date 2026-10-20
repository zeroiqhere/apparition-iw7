// Custom health keeps one value record and separates current from future scope

valid_health(value)
{
    return isDefined(health_value(value));
}

health_value(value)
{
    // Direct callers must supply a whole signed integer in the source range
    if (!isDefined(value))
        return undefined;
    if (!isnumber(value) || value < 0 || value > 2147483647
        || int(value) != value)
        return undefined;
    return int(value);
}

configuration(value, owner)
{
    normalized = health_value(value);
    if (!isDefined(normalized))
        return undefined;

    record = spawnstruct();
    record.value = normalized;
    // The requester identity is retained only for disconnect cleanup
    if (isDefined(owner))
        record.owner = owner;
    return record;
}

record_state(record)
{
    result = spawnstruct();
    result.reason = "";
    result.configured = false;
    result.value = undefined;
    if (!isDefined(record))
        return result;
    if (!isstruct(record) || !isDefined(record.value))
    {
        result.reason = "The saved zombie health configuration is malformed";
        return result;
    }

    value = health_value(record.value);
    if (!isDefined(value))
    {
        result.reason = "The saved zombie health value is outside the supported integer range";
        return result;
    }

    result.configured = true;
    result.value = value;
    return result;
}

inspect(state, agents, config)
{
    result = spawnstruct();
    result.reason = "";
    result.configured = false;
    result.value = undefined;
    result.targets = [];

    if (!isDefined(state) || !isstruct(state) || !isDefined(state.zombie_team)
        || !isstring(state.zombie_team) || state.zombie_team != "axis")
        result.reason = "The native zombie team is unavailable";
    else if (!isDefined(agents) || !isarray(agents))
        result.reason = "The native zombie roster is unavailable";
    else
    {
        status = record_state(config);
        if (status.reason != "")
            result.reason = status.reason;
        else if (!status.configured)
            result.reason = "Custom zombie health is not configured";
        else
        {
            result.configured = true;
            result.value = status.value;
            foreach (agent in agents)
            {
                if (!isDefined(agent) || !isDefined(agent.team) || agent.team != "axis"
                    || !isDefined(agent.agent_type) || !isstring(agent.agent_type)
                    || !isDefined(agent.isactive) || agent.isactive != 1
                    || !isDefined(agent.health) || !isnumber(agent.health) || agent.health <= 0)
                    continue;
                if (isDefined(agent.maxhealth) && agent.maxhealth == status.value)
                    continue;
                result.targets[result.targets.size] = agent;
            }
        }
    }

    // No partial targets escape when the input snapshot itself is malformed
    if (result.reason != "")
    {
        result.configured = false;
        result.value = undefined;
        result.targets = [];
    }
    return result;
}

probe(owner)
{
    result = empty_probe(scripts\apparition\maps\spaceland\zombie_context::owner_reason(owner));
    if (result.reason != "")
        return result;

    result.reason = scripts\apparition\runtime\zombie_health_spawn::hook_reason();
    if (result.reason != "")
        return result;

    status = record_state(level.apparition_zombie_health_config);
    result.reason = status.reason;
    result.configured = status.configured;
    result.value = status.value;
    return result;
}

empty_probe(reason)
{
    result = spawnstruct();
    result.reason = reason;
    result.configured = false;
    result.value = undefined;
    return result;
}

request(owner, value)
{
    normalized = health_value(value);
    if (!isDefined(normalized) || scripts\apparition\maps\spaceland\zombie_context::owner_reason(owner) != "")
        return false;
    if (scripts\apparition\runtime\zombie_health_spawn::hook_reason() != "")
        return false;
    pending = configuration(normalized, owner);
    if (!isDefined(pending))
        return false;

    // A newer accepted request retires every worker from the previous record
    level.apparition_zombie_health_config = undefined;
    scripts\apparition\runtime\zombie_health_spawn::release_hook();
    level.apparition_zombie_health_request = pending;
    level thread apply_request(pending);
    return true;
}

apply_request(pending)
{
    level endon("game_ended");
    wait 0.1;

    // Request identity and current host authority are checked after the delay
    if (!is_current_request(pending))
        return;
    owner = pending.owner;
    status = record_state(pending);
    if (scripts\apparition\maps\spaceland\zombie_context::owner_reason(owner) != ""
        || status.reason != "" || !status.configured
        || scripts\apparition\runtime\zombie_health_spawn::hook_reason() != "")
    {
        level.apparition_zombie_health_request = undefined;
        return;
    }

    status = record_state(pending);
    if (status.reason != "" || !status.configured
        || !scripts\apparition\runtime\zombie_health_spawn::install_hook())
    {
        level.apparition_zombie_health_request = undefined;
        return;
    }

    // Promote the same checked request record instead of duplicating value and owner
    level.apparition_zombie_health_config = pending;
    level.apparition_zombie_health_request = undefined;
    apply_current_agents(pending);
}

is_current_request(pending)
{
    return isDefined(pending) && isDefined(level.apparition_zombie_health_request)
        && level.apparition_zombie_health_request == pending;
}

apply_current_agents(record)
{
    if (!is_current_config(record))
        return;

    if (!isDefined(level.zombie_team) || !isstring(level.zombie_team)
        || level.zombie_team != "axis")
        return;
    if (!isDefined(level.agentarray) || !isarray(level.agentarray))
        return;
    agents = [];
    foreach (agent in level.agentarray)
    {
        // Native entity methods run before any candidate field is inspected
        if (!isDefined(agent) || !isent(agent) || !isAgent(agent) || !isAlive(agent)
            || !isDefined(agent.isactive) || agent.isactive != 1
            || !isDefined(agent.team) || agent.team != "axis")
            continue;
        agents[agents.size] = agent;
    }
    state = spawnstruct();
    state.zombie_team = level.zombie_team;
    snapshot = inspect(state, agents, record);
    if (snapshot.reason != "")
        return;

    foreach (agent in snapshot.targets)
    {
        if (!is_current_config(record) || !isDefined(agent) || !isent(agent) || !isAgent(agent) || !isAlive(agent))
            continue;
        receipt = scripts\apparition\runtime\zombie_health_spawn::new_receipt(agent, record);
        if (isDefined(receipt))
            agent thread scripts\apparition\runtime\zombie_health_spawn::apply_current_health(receipt);
    }
}

is_current_config(record)
{
    status = record_state(record);
    return isDefined(record) && isDefined(level.apparition_zombie_health_config)
        && level.apparition_zombie_health_config == record
        && status.reason == ""
        && isDefined(record.owner)
        && scripts\apparition\maps\spaceland\zombie_context::owner_reason(record.owner) == "";
}

retire(owner)
{
    old_config = level.apparition_zombie_health_config;
    old_request = level.apparition_zombie_health_request;
    remaining = retire_records(old_config, old_request, owner);
    level.apparition_zombie_health_config = remaining.config;
    level.apparition_zombie_health_request = remaining.pending;

    // A player disconnect cannot remove another owner's active callback
    if (!isDefined(owner) || (!isDefined(remaining.config) && !isDefined(remaining.pending)))
        scripts\apparition\runtime\zombie_health_spawn::release_hook();
}

retire_records(record, pending, owner)
{
    result = spawnstruct();
    result.config = record;
    result.pending = pending;
    if (!isDefined(owner))
    {
        result.config = undefined;
        result.pending = undefined;
        return result;
    }

    if (isDefined(record) && isDefined(record.owner) && record.owner == owner)
        result.config = undefined;
    if (isDefined(pending) && isDefined(pending.owner) && pending.owner == owner)
        result.pending = undefined;
    return result;
}
