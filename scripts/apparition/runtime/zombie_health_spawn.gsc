// The native generic-zombie setup callback forwards stock work before one receipt-bound write

stock_callback()
{
    return scripts\mp\agents\zombie\zombie_agent::setupagent;
}

wrapper_callback()
{
    return ::setupagent_wrapper;
}

callback_slot()
{
    // Native profile callbacks are string-keyed arrays, not struct fields
    if (!isDefined(level.agent_definition) || !isarray(level.agent_definition)
        || !isDefined(level.agent_definition["generic_zombie"])
        || !isarray(level.agent_definition["generic_zombie"])
        || !isDefined(level.agent_definition["generic_zombie"]["setup_func"]))
        return undefined;
    return level.agent_definition["generic_zombie"]["setup_func"];
}

can_install_callback(callback)
{
    return isDefined(callback) && (callback == stock_callback() || callback == wrapper_callback());
}

hook_reason()
{
    callback = callback_slot();
    if (!isDefined(callback))
        return "The native generic zombie setup callback is not ready";
    if (!can_install_callback(callback))
        return "The native generic zombie setup callback belongs to another script";
    return "";
}

hook_owned()
{
    callback = callback_slot();
    return isDefined(callback) && callback == wrapper_callback();
}

install_hook()
{
    // Keep the exact stock function as the only accepted preexisting callback
    if (hook_reason() != "")
        return false;
    if (!hook_owned())
        level.agent_definition["generic_zombie"]["setup_func"] = wrapper_callback();
    return hook_owned();
}

release_hook()
{
    // Restore only the callback installed by this feature
    if (!hook_owned())
        return false;
    level.agent_definition["generic_zombie"]["setup_func"] = stock_callback();
    return true;
}

new_receipt(agent, config)
{
    // The profile is checked before entity fields are retained by a delayed worker
    if (!isDefined(agent) || !isDefined(agent.agent_type) || !isstring(agent.agent_type))
        return undefined;

    receipt = spawnstruct();
    receipt.agent = agent;
    receipt.config = config;
    receipt.agent_type = agent.agent_type;
    agent.apparition_zombie_health_receipt = receipt;
    return receipt;
}

receipt_matches(agent, receipt, config, active_config)
{
    return isDefined(agent) && isDefined(receipt) && isDefined(config)
        && isDefined(active_config) && config == active_config
        && isDefined(receipt.agent) && receipt.agent == agent
        && isDefined(receipt.config) && receipt.config == config
        && isDefined(agent.apparition_zombie_health_receipt)
        && agent.apparition_zombie_health_receipt == receipt
        && isDefined(agent.agent_type) && isstring(agent.agent_type)
        && isDefined(receipt.agent_type) && agent.agent_type == receipt.agent_type;
}

eligible_current(agent, receipt, config, active_config, rostered, alive)
{
    return receipt_matches(agent, receipt, config, active_config)
        && isDefined(agent.team) && agent.team == "axis"
        && isDefined(agent.isactive) && agent.isactive == 1
        && rostered == true && alive == true;
}

eligible_future(agent, receipt, config, active_config, rostered, alive)
{
    return eligible_current(agent, receipt, config, active_config, rostered, alive)
        && agent.agent_type == "generic_zombie";
}

rostered(agent)
{
    if (!isDefined(level.agentarray) || !isarray(level.agentarray))
        return false;
    return scripts\engine\utility::array_contains(level.agentarray, agent);
}

setupagent_wrapper()
{
    // Capture a new generation before stock setup can yield or mutate profile fields
    config = level.apparition_zombie_health_config;
    receipt = new_receipt(self, config);

    // Installed IW7 bytecode calls this self-bound stock callback with no arguments
    self scripts\mp\agents\zombie\zombie_agent::setupagent();

    if (isDefined(receipt) && isDefined(config) && receipt.config == config)
        self thread apply_spawn_health(receipt);
}

policy_ready(agent, receipt, config, future)
{
    state = scripts\apparition\maps\spaceland\zombie_health::record_state(config);
    if (state.reason != "" || !state.configured || !isDefined(config.owner)
        || scripts\apparition\maps\spaceland\zombie_context::owner_reason(config.owner) != ""
        || !hook_owned() || !isDefined(agent) || !isent(agent) || !isAgent(agent))
        return false;
    if (future)
        return eligible_future(agent, receipt, config, level.apparition_zombie_health_config,
            rostered(agent), isAlive(agent));
    return eligible_current(agent, receipt, config, level.apparition_zombie_health_config,
        rostered(agent), isAlive(agent));
}

apply_spawn_health(receipt)
{
    self endon("agent_in_use");
    level endon("game_ended");
    waittillframeend;

    if (!isDefined(receipt) || !isDefined(receipt.config))
        return;
    config = receipt.config;
    if (!policy_ready(self, receipt, config, true) || !isDefined(self.maxhealth))
        return;

    // No yield separates the final policy check from this one native health pair
    self.maxhealth = config.value;
    self.health = config.value;
}

apply_current_health(receipt)
{
    self endon("agent_in_use");
    level endon("game_ended");
    if (!isDefined(receipt) || !isDefined(receipt.config))
        return;
    config = receipt.config;

    // Current source targets may not expose maxhealth until their spawn completes
    for (;;)
    {
        if (!policy_ready(self, receipt, config, false))
            return;
        if (!isDefined(self.maxhealth))
        {
            wait 0.1;
            continue;
        }
        if (self.maxhealth == config.value)
            return;

        // No yield separates the policy check from this one native health pair
        self.maxhealth = config.value;
        self.health = config.value;
        return;
    }
}
