// Quest fixtures use the native registered callbacks without executing them

activation(retry)
{
    state = retry ? reactivation_cabinet() : quest(6);
    if (retry)
        state._id_13F1B["reactivateghost"] = 1;
    // Only a source-shaped marker is created; no native FX is spawned
    state.gns_game_console_vfx = spawnstruct();
    state.gns_game_console_vfx.origin = (2859, -553, 286);
    return state;
}

cabinet()
{
    state = quest(5);
    state.agentarray = [];
    state.apparition_brute_cabinet_job = spawnstruct();
    state.apparition_brute_cabinet_job.state = "Observing";
    state.apparition_brute_cabinet_job.line = "ghost";
    return state;
}

cabinet_trigger()
{
    trigger = spawnstruct();
    trigger.targetname = "ghost_arcade_damage_trigger";
    trigger.origin = (1, 2, 3);
    return trigger;
}

reactivation_cabinet()
{
    // Native callback-history contracts separately establish this ready receipt
    state = tests\fixtures\reactivation::state();
    normal = quest(6);
    state._id_13F4D["ghost"] = normal._id_13F4D["ghost"];
    state._id_13F1B["ghost"] = 6;
    state.agentarray = [];
    watch = spawnstruct();
    state.apparition_reactivation_history = watch;
    scripts\apparition\maps\spaceland\reactivation_history::install(state, watch);
    attempt = spawnstruct();
    attempt.ready = true;
    attempt.first = state._id_13F4D["reactivateghost"][0];
    attempt.activation = state._id_13F4D["reactivateghost"][1];
    watch.attempt = attempt;
    state.apparition_brute_cabinet_job = spawnstruct();
    state.apparition_brute_cabinet_job.state = "Observing";
    state.apparition_brute_cabinet_job.line = "reactivateghost";
    state.apparition_brute_cabinet_job.attempt = attempt;
    return state;
}

brute()
{
    attacker = spawnstruct();
    attacker.agent_type = "zombie_brute";
    attacker.team = "axis";
    attacker.health = 1000;
    return attacker;
}

floating()
{
    state = quest(4);
    state.flag = [];
    state.flag["ufo_destroyed"] = true;
    state.apparition_floating_skull_job = spawnstruct();
    state.apparition_floating_skull_job.state = "Observing";
    return state;
}

floating_model()
{
    model = spawnstruct();
    model.model = "zmb_pixel_skull";
    model.origin = (1007, 621, 901);
    model.health = 999999;
    return model;
}

dance()
{
    state = quest(2);
    state.onzombiekilledfunc = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::check_kill_on_dance_floor;
    state.kill_order_on_dance_floor = ["green", "blue", "pink", "black"];
    state.spawned_enemies = [];
    state.agent_funcs = tests\fixtures\spaceland::agent_callbacks();
    state.apparition_dance_job = spawnstruct();
    state.apparition_dance_job.state = "Active";
    return state;
}

quest(step)
{
    state = spawnstruct();
    state._id_13F4D = [];
    state._id_13F4D["ghost"] = [];
    state._id_13F1B = [];
    state._id_13F1B["ghost"] = step;
    catalog = scripts\apparition\maps\spaceland\ghosts::catalog();
    for (index = 0; index < catalog.size; index++)
    {
        entry = spawnstruct();
        entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
        entry._id_DB5D = catalog[index].body;
        entry._id_446D = catalog[index].complete;
        state._id_13F4D["ghost"][index] = entry;
    }
    return state;
}
