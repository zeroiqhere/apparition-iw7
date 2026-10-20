// Submit one native Death damage request to each currently eligible countable zombie

modes()
{
    return ["Death", "Head Gib", "Flame", "Delete"];
}

damage_amount(enemy)
{
    // Entity and struct guards run before any health field lookup
    if (!isDefined(enemy) || (!isstruct(enemy) && !isent(enemy))
        || !isDefined(enemy.health) || !isnumber(enemy.health)
        || !isDefined(enemy.maxhealth) || !isnumber(enemy.maxhealth))
        return -1;

    health = enemy.health;
    maximum = enemy.maxhealth;

    // Bound health before integer conversion and read the native cap without casting
    if (!(health > 0 && health <= 2147482981 && maximum >= health))
        return -1;

    // Recheck as integers after any float promotion of the first range comparison
    health_integer = int(health);
    if (health_integer != health || health_integer > 2147482981)
        return -1;

    // Native damage handling caps the packet at the actor's maximum health
    return health_integer + 666;
}

inspect(state, agents)
{
    result = scripts\apparition\maps\spaceland\zombie_context::snapshot("Wait for the native Spaceland zombie roster");
    // Native level entities and test structs are the only accepted state containers
    if (!isDefined(state) || (!isstruct(state) && !isent(state))
        || !isDefined(state.spawned_enemies) || !isarray(state.spawned_enemies)
        || !isDefined(agents) || !isarray(agents))
        return result;

    // Ordinary zombies establish the current native kill path without a quest-stage gate
    if (!scripts\apparition\maps\spaceland\zombie_targets::death_path(state, "generic_zombie"))
        return result;

    result.reason = "";
    result.targets = [];
    for (index = 0; index < agents.size; index++)
    {
        enemy = agents[index];
        if (!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy))
            continue;
        if (damage_amount(enemy) < 0 || scripts\engine\utility::array_contains(result.targets, enemy))
            continue;
        result.targets[result.targets.size] = enemy;
    }

    if (result.targets.size)
        result.hint = "One-time Death request for " + result.targets.size
            + " countable native zombies on this pass; reserved and protected actors are skipped, and native protection may still reject damage";
    else
        result.hint = "No countable native zombies are available on this pass; reserved and protected actors are skipped";
    return result;
}

probe(owner)
{
    reason = scripts\apparition\maps\spaceland\zombie_context::owner_reason(owner);
    if (reason != "")
        return scripts\apparition\maps\spaceland\zombie_context::snapshot(reason);

    if (!isDefined(level.spawned_enemies) || !isarray(level.spawned_enemies))
        return scripts\apparition\maps\spaceland\zombie_context::snapshot("Wait for the native Spaceland zombie roster");

    // Native entity checks happen before the pure selector reads any actor fields
    agents = [];
    foreach (enemy in level.spawned_enemies)
    {
        if (!isDefined(enemy) || !isent(enemy) || !isAgent(enemy) || !isAlive(enemy))
            continue;
        agents[agents.size] = enemy;
    }

    return inspect(level, agents);
}

request(owner, mode)
{
    // Unsupported choices reject before context reads or native calls
    if (!isDefined(mode) || !isstring(mode) || mode != "Death")
        return false;

    current = probe(owner);
    if (current.reason != "")
        return false;

    // Probe already detached this private list from the live native roster
    targets = current.targets;

    submitted = false;
    for (index = 0; index < targets.size; index++)
    {
        enemy = targets[index];
        // Authority and target membership are fresh for every packet
        if (scripts\apparition\maps\spaceland\zombie_context::owner_reason(owner) != "")
            break;
        if (!isDefined(enemy) || !isent(enemy) || !isAgent(enemy) || !isAlive(enemy))
            continue;

        if (!isDefined(level.spawned_enemies) || !isarray(level.spawned_enemies))
            break;
        if (!scripts\apparition\maps\spaceland\zombie_targets::eligible(level, enemy))
            continue;
        amount = damage_amount(enemy);
        if (amount < 0)
            continue;

        // The player attribution keeps the native player kill-handler branch active
        enemy doDamage(amount, enemy.origin, owner, owner, "MOD_UNKNOWN");
        submitted = true;
    }

    // Submission reports a command path, not native callback or kill confirmation
    return submitted;
}
