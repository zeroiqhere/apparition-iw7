// The game owns node lights, weapon firing and UFO destruction

lookup(state, name)
{
    if (!isDefined(state.struct_class_names) || !isDefined(state.struct_class_names["targetname"]))
        return undefined;
    matches = state.struct_class_names["targetname"][name];
    if (!isDefined(matches) || matches.size != 1 || !isDefined(matches[0])
        || !isDefined(matches[0].targetname) || matches[0].targetname != name || !isDefined(matches[0].origin))
        return undefined;
    return matches[0];
}

registry(state)
{
    nodes = [];
    for (number = 1; number <= 5; number++)
    {
        node = lookup(state, "main_gate_powernode_" + number);
        if (!isDefined(node))
            return undefined;
        // Only the first four nodes look up an arc endpoint in the native handler
        if (number < 5 && (!isDefined(node.target) || !isDefined(lookup(state, node.target))))
            return undefined;
        nodes[nodes.size] = node;
    }
    return nodes;
}

index(nodes, mapped)
{
    for (index = 0; index < nodes.size; index++)
    {
        if (isDefined(mapped) && nodes[index] == mapped)
            return index;
    }
    return -1;
}

activated(node)
{
    return isDefined(node.is_activated) && node.is_activated;
}

sequence_reason(state, watch)
{
    if (scripts\apparition\maps\spaceland\quest::current_step(state) != 11)
        return "Final power nodes require the final UFO stage";
    if (!isDefined(state._id_13F4D["ufo"][11].init_func)
        || state._id_13F4D["ufo"][11].init_func != scripts\cp\maps\cp_zmb\cp_zmb_dj::init_ufo_projectile_attack)
        return "The native final-stage initializer has changed";
    if (!isDefined(state.flag) || !isDefined(state.flag["fuses_inserted"]) || !state.flag["fuses_inserted"]
        || !isDefined(state.flag["ufo_destroyed"]))
        return "Insert the alien fuses and wait for the native final stage";
    if (!isDefined(watch) || watch.state != "Listening")
        return "Final-node history is unknown; normal weapon shots remain available";
    nodes = registry(state);
    if (!isDefined(nodes))
        return "The native power-node assets are not ready";
    for (index = 0; index < nodes.size; index++)
    {
        if (watch.nodes[index] != nodes[index])
            return "The native node registry changed after history observation began";
    }
    return "";
}

reason(state, watch)
{
    reason = sequence_reason(state, watch);
    if (reason != "")
        return reason;
    if (state.flag["ufo_destroyed"])
        return "The native UFO is already destroyed";
    // Potential firing history remains closed even after the game's node flags reset
    if (watch.cycle_spent)
        return "Mapped hits reached all five nodes; remote inputs are locked for this match";
    monitor_ready = false;
    for (index = 0; index < watch.nodes.size; index++)
    {
        if (activated(watch.nodes[index]))
            monitor_ready = true;
        if (isDefined(watch.menu_inputs[index]) && !activated(watch.nodes[index]))
            return "A node hit is unconfirmed; the menu cannot repeat it";
    }
    // A native charge proves its asynchronous damage monitor has handled input
    if (!monitor_ready)
        return "Charge one node normally to confirm the native damage monitor is ready";
    return "";
}

live_reason(watch)
{
    triggers = getEntArray("main_gate_powernode_damage_trigger", "targetname");
    if (triggers.size != 1 || !isDefined(watch.trigger) || triggers[0] != watch.trigger || !isDefined(level.ufo))
        return "The native node trigger or UFO is not available";
    lights = [];
    for (number = 1; number <= 5; number++)
    {
        matches = getEntArray("gate_light_0" + number, "targetname");
        if (matches.size != 1 || !isDefined(matches[0].origin))
            return "The native gate lights are not ready";
        lights[lights.size] = matches[0];
    }
    foreach (node in watch.nodes)
    {
        // The native resolver selects the first node within range, not the nearest
        if (scripts\cp\maps\cp_zmb\cp_zmb_ufo::get_power_node_struct(node.origin) != node)
            return "A node origin does not map to its intended native target";
        matched = false;
        foreach (light in lights)
        {
            if (distanceSquared(node.origin, light.origin) < 10000)
            {
                matched = true;
                break;
            }
        }
        if (!matched)
            return "A native node has no gate light in its source lookup range";
    }
    foreach (effect in ["powernode_arc_small", "powernode_arc_medium", "powernode_arc_big", "ufo_elec_beam_impact"])
    {
        if (!isDefined(level._effect) || !isDefined(level._effect[effect]))
            return "The native power-node effects are not initialized";
    }
    return "";
}

actor_reason(player)
{
    if (!scripts\apparition\runtime\context::living_host(player))
        return "The host must be alive, out of last stand and in a supported private session";
    if (!scripts\cp\maps\cp_zmb\cp_zmb_ufo::can_charge_power_nodes(player getCurrentWeapon(), player))
        return "Equip a double-upgraded Spaceland wonder weapon";
    return "";
}

running(job)
{
    return isDefined(job) && (job.state == "Active" || job.state == "Cancelling");
}

outcome(state, watch, job, authorized, expired)
{
    if (isDefined(state.flag) && isDefined(state.flag["ufo_destroyed"]) && state.flag["ufo_destroyed"])
        return "Destroyed";
    if (job.state == "Cancelling")
        return "Cancelled";
    if (!authorized || sequence_reason(state, watch) != "")
        return "Unavailable";
    return expired ? "Pending" : "";
}

start(player)
{
    watch = level.apparition_node_history;
    if (running(level.apparition_node_job) || reason(level, watch) != "" || actor_reason(player) != "" || live_reason(watch) != "")
        return false;
    job = spawnstruct();
    job.owner = player;
    job.state = "Active";
    // Reserve one level worker before any native damage can yield
    level.apparition_node_job = job;
    level thread scripts\apparition\maps\spaceland\node_worker::run(job, watch);
    return true;
}

cancel()
{
    job = level.apparition_node_job;
    if (!running(job) || job.state == "Cancelling")
        return false;
    job.state = "Cancelling";
    return true;
}
