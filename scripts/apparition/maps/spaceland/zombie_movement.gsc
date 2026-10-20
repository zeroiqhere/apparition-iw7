// Submit one requested native movement mode to the current ordinary Spaceland agents

modes()
{
    return ["Walk", "Run", "Sprint", "Super Sprint"];
}

native_mode(value)
{
    // Preview labels are exact source choices, not arbitrary native mode names
    if (!isDefined(value) || !isstring(value))
        return undefined;

    if (value == "Walk")
        return "walk";
    if (value == "Run")
        return "run";
    if (value == "Sprint")
        return "sprint";
    return undefined;
}

eligible(enemy)
{
    // Native methods are reserved for probe and request after isAgent admission
    if (!isDefined(enemy) || (!isstruct(enemy) && !isent(enemy)))
        return false;

    if (!isDefined(enemy.agent_type) || !isstring(enemy.agent_type)
        || (enemy.agent_type != "generic_zombie" && enemy.agent_type != "zombie_clown"))
        return false;
    if (!isDefined(enemy.team) || !isstring(enemy.team) || enemy.team != "axis")
        return false;
    if (!isDefined(enemy.health) || !isnumber(enemy.health) || !(enemy.health > 0))
        return false;
    if (!isDefined(enemy.movemode) || !known_native_mode(enemy.movemode))
        return false;

    // ASM and blackboard state must exist before the native request wrapper runs
    if (!isDefined(enemy.asm) || !isstruct(enemy.asm)
        || !isDefined(enemy._blackboard) || !isstruct(enemy._blackboard))
        return false;
    if (isDefined(enemy.asm.cur_move_mode) && !known_native_mode(enemy.asm.cur_move_mode))
        return false;

    if (!isDefined(enemy.aistate) || !isstring(enemy.aistate) || enemy.aistate == "traverse")
        return false;
    if (!clear_flag(enemy.statelocked) || isDefined(enemy.isfrozen))
        return false;
    if (!clear_flag(enemy.is_reserved) || !clear_flag(enemy.is_suicide_bomber)
        || !clear_flag(enemy.is_crawler) || !clear_flag(enemy.dismember_crawl))
        return false;

    return true;
}

inspect(state, agents)
{
    result = scripts\apparition\maps\spaceland\zombie_context::snapshot("Wait for native Spaceland movement data");

    if (!isDefined(state) || (!isstruct(state) && !isent(state))
        || !isDefined(state.agentarray) || !isarray(state.agentarray)
        || !isDefined(agents) || !isarray(agents))
        return result;
    if (!movement_table_ready(state))
        return result;

    result.reason = "";
    result.targets = [];
    for (index = 0; index < agents.size; index++)
    {
        enemy = agents[index];
        if (!eligible(enemy) || !scripts\engine\utility::array_contains(state.agentarray, enemy)
            || scripts\engine\utility::array_contains(result.targets, enemy))
            continue;
        result.targets[result.targets.size] = enemy;
    }

    if (result.targets.size)
        result.hint = "One-time request for " + result.targets.size
            + " eligible live ordinary agents on this pass; native callbacks and gameplay states can replace the mode";
    else
        result.hint = "No eligible live ordinary agents are available on this pass";
    return result;
}

probe(owner)
{
    reason = scripts\apparition\maps\spaceland\zombie_context::owner_reason(owner);
    if (reason != "")
        return scripts\apparition\maps\spaceland\zombie_context::snapshot(reason);
    if (!isDefined(level.agentarray) || !isarray(level.agentarray))
        return scripts\apparition\maps\spaceland\zombie_context::snapshot("Wait for the native Spaceland agent roster");

    agents = [];
    for (index = 0; index < level.agentarray.size; index++)
    {
        enemy = level.agentarray[index];
        // Reject stale or non-agent entries before reading any actor fields
        if (!isDefined(enemy) || !isent(enemy) || !isAgent(enemy) || !isAlive(enemy))
            continue;
        agents[agents.size] = enemy;
    }
    return inspect(level, agents);
}

request(owner, value)
{
    // Invalid and unsupported choices reject before player or native agent reads
    requested_mode = native_mode(value);
    if (!isDefined(requested_mode))
        return false;

    current = probe(owner);
    if (current.reason != "")
        return false;
    targets = current.targets;
    submitted = false;

    for (index = 0; index < targets.size; index++)
    {
        // Authority, agent identity, life, and roster membership are current for each setter
        if (scripts\apparition\maps\spaceland\zombie_context::owner_reason(owner) != "")
            break;
        enemy = targets[index];
        if (!isDefined(enemy) || !isent(enemy) || !isAgent(enemy) || !isAlive(enemy))
            continue;
        if (!isDefined(level.agentarray) || !isarray(level.agentarray)
            || !scripts\engine\utility::array_contains(level.agentarray, enemy)
            || !eligible(enemy))
            continue;

        enemy.movemode = requested_mode;
        enemy scripts\asm\asm_bb::bb_requestmovetype(requested_mode);
        submitted = true;
    }

    // A submitted request is not proof that the native state machine accepted or retained it
    return submitted;
}

movement_table_ready(state)
{
    // The native movement worker indexes this tuning after a mode change
    if (!isDefined(state._id_13FA8) || !isarray(state._id_13FA8))
        return false;

    foreach (mode in ["walk", "run", "sprint"])
    {
        value = state._id_13FA8[mode];
        if (!isDefined(value) || !isnumber(value) || !(value > 0))
            return false;
    }
    return true;
}

known_native_mode(value)
{
    return isDefined(value) && isstring(value)
        && (value == "slow_walk" || value == "walk" || value == "run" || value == "sprint");
}

clear_flag(value)
{
    // Missing flags use the native default; malformed values cannot clear a guard
    return !isDefined(value) || (isnumber(value) && value == 0);
}
