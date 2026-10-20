// One native handler and protection policy defines all ordinary zombie targets

death_path(state, type)
{
    if (!isDefined(type) || !isstring(type)
        || (type != "generic_zombie" && type != "zombie_clown"))
        return false;
    if (!isDefined(state) || (!isstruct(state) && !isent(state))
        || !isDefined(state.agent_funcs) || !isarray(state.agent_funcs)
        || !isDefined(state.agent_funcs[type]) || !isarray(state.agent_funcs[type]))
        return false;
    callbacks = state.agent_funcs[type];
    // The official token path is retained across friendly source-dump aliases
    return isDefined(callbacks["gametype_on_killed"])
        && callbacks["gametype_on_killed"] == scripts\cp\agents\gametype_zombie::onzombiekilled
        && isDefined(callbacks["on_killed"])
        && callbacks["on_killed"] == scripts\mp\agents\zombie\zombie_agent::onzombiekilled;
}

eligible(state, enemy)
{
    // Live callers separately admit actual agents before entering this pure policy
    if (!isDefined(state) || (!isstruct(state) && !isent(state))
        || !isDefined(state.spawned_enemies) || !isarray(state.spawned_enemies)
        || !isDefined(enemy) || (!isstruct(enemy) && !isent(enemy)))
        return false;
    return isDefined(enemy.agent_type) && isstring(enemy.agent_type)
        && isDefined(enemy.team) && isstring(enemy.team) && enemy.team == "axis"
        && isDefined(enemy.health) && isnumber(enemy.health) && enemy.health > 0
        && isDefined(enemy.maxhealth) && isnumber(enemy.maxhealth) && enemy.maxhealth > 0
        && isDefined(enemy.origin) && isvector(enemy.origin)
        && isDefined(enemy.died_poorly) && isnumber(enemy.died_poorly) && enemy.died_poorly == 0
        && (!isDefined(enemy.is_reserved) || (isnumber(enemy.is_reserved) && enemy.is_reserved == 0))
        // Protection is presence-based, including a field whose value is zero
        && !isDefined(enemy.dont_scriptkill)
        && death_path(state, enemy.agent_type)
        && scripts\engine\utility::array_contains(state.spawned_enemies, enemy);
}
