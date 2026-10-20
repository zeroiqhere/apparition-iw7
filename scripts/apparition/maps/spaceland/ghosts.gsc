// Native Ghosts N Skulls progress stays separate from cabinet and arena outcomes

catalog()
{
    steps = [];
    steps[steps.size] = entry("Pop Spawn Balloons", scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::pop_all_balloons_in_beginning_area, scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_pop_all_balloons_in_beginning_area);
    steps[steps.size] = entry("Spell GHOST", scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::spell_the_word_ghost, scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_spell_the_word_ghost);
    steps[steps.size] = entry("1984 Dance-Floor Kills", scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::get_1_9_8_4_kills_on_dance_floor, scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_get_1_9_8_4_kills_on_dance_floor);
    steps[steps.size] = entry("Arcade Critical Shots", scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::play_arcade_games_and_make_critical_shot, scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_play_arcade_games_and_make_critical_shot);
    steps[steps.size] = entry("Hit Floating Skull", scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::hit_the_floating_skull_with_spaceland_laser, scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_hit_the_floating_skull_with_spaceland_laser);
    steps[steps.size] = entry("Brute Laser at Cabinet", scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::brute_hit_arcade_cabinet_with_laser, scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_brute_hit_arcade_cabinet_with_laser);
    steps[steps.size] = entry("Activate Cabinet", scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::wait_for_player_activation, scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet);
    return steps;
}

entry(label, body, complete)
{
    step = spawnstruct();
    step.label = label;
    step.body = body;
    step.complete = complete;
    return step;
}

current_step(state)
{
    if (!isDefined(state)
        || !isDefined(state._id_13F4D) || !isarray(state._id_13F4D)
        || !isDefined(state._id_13F4D["ghost"]) || !isarray(state._id_13F4D["ghost"])
        || !isDefined(state._id_13F1B) || !isarray(state._id_13F1B)
        || !isDefined(state._id_13F1B["ghost"]) || !isnumber(state._id_13F1B["ghost"]))
        return -1;
    native_step = state._id_13F1B["ghost"];
    steps = catalog();
    // The native line uses bounded integer indices, never fractional array keys
    if (!(native_step >= 0 && native_step < steps.size))
        return -1;
    step = int(native_step);
    if (step != native_step)
        return -1;
    if (!valid_entry(state, 0, steps[0])
        || (step != 0 && !valid_entry(state, step, steps[step])))
        return -1;
    return step;
}

valid_entry(state, index, expected)
{
    if (!isDefined(state._id_13F4D["ghost"][index]))
        return false;
    native = state._id_13F4D["ghost"][index];
    if (!isstruct(native) || !isDefined(native.init_func) || native.init_func != scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank
        || !isDefined(native._id_DB5D) || native._id_DB5D != expected.body)
        return false;
    // Only the owned final callback observer may replace the expected completion
    return (isDefined(native._id_446D) && native._id_446D == expected.complete)
        || (index == 6 && scripts\apparition\maps\spaceland\ghost_history::owns(state));
}

progress(state)
{
    progress = spawnstruct();
    progress.step = current_step(state);
    // Unknown table shape cannot enter the observer's native registration reads
    progress.activated = progress.step >= 0
        && scripts\apparition\maps\spaceland\ghost_history::observed(state);
    progress.active = isDefined(state.gns_active) && state.gns_active;
    progress.last_result = "Unconfirmed";
    if (isDefined(state.ghostskulls_complete_status))
    {
        if (state.ghostskulls_complete_status == 1)
            progress.last_result = "Won";
        // Zero is also the native initial value, so it needs failure-path evidence
        else if (state.ghostskulls_complete_status == 0
            && isDefined(state.processing_ghost_wave_failing) && state.processing_ghost_wave_failing)
            progress.last_result = "Failed";
    }
    // The native counter spans all arena attempts in this map
    progress.waves = isDefined(state.ghostskulls_total_waves) ? state.ghostskulls_total_waves : -1;
    progress.next_floor = "";
    progress.remaining_kills = -1;
    if (progress.step == 2 && isDefined(state.onzombiekilledfunc)
        && state.onzombiekilledfunc == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::check_kill_on_dance_floor
        && isDefined(state.kill_order_on_dance_floor))
    {
        progress.remaining_kills = state.kill_order_on_dance_floor.size;
        if (progress.remaining_kills > 0)
            progress.next_floor = state.kill_order_on_dance_floor[0];
    }
    return progress;
}

stage_completed(progress, index)
{
    return progress.step >= 0 && (index < progress.step
        || (index == 6 && progress.step == 6 && progress.activated));
}

skull_sites()
{
    // Each pair is one native random position for a letter of GHOST
    return [(3930, 308, 336), (2379, 1247, 302), (-3530, 650, 676), (-651, -946, 625),
        (-2675, -2532, 524), (1276, 719, 203), (3791, -602, 368), (3602, 2189, 387),
        (-1047, 1084, 408), (-1467, -307, 548)];
}

skull(models)
{
    return scripts\apparition\maps\spaceland\pickup_models::select(models, "zmb_8_bit_price", skull_sites());
}

look_reason(state)
{
    step = current_step(state);
    if (step == -1)
        return "The Ghosts N Skulls quest is not initialized";
    if (step != 1)
        return "Face Current Skull requires the Spell GHOST stage";
    return "";
}

sight_reason(eye, target, trace_position)
{
    if (!isDefined(eye) || !isDefined(target) || !isDefined(trace_position))
        return "Wait for a clear native skull trace";
    if (distanceSquared(eye, target) == 0)
        return "Move away from the current skull before facing it";
    // Native player_look_at_skull accepts this inclusive squared-distance limit
    if (distanceSquared(trace_position, target) > 6400)
        return "Move until the current skull has a clear line of sight";
    return "";
}

probe(player)
{
    result = spawnstruct();
    result.reason = look_reason(level);
    if (result.reason != "")
        return result;
    if (!scripts\apparition\runtime\context::living_host(player))
    {
        result.reason = "Only the current living host can face a quest skull";
        return result;
    }
    result.target = skull(getEntArray("script_model", "classname"));
    if (!isDefined(result.target))
    {
        result.reason = "Wait for one native GHOST skull at a known location";
        return result;
    }
    result.eye = player getEye();
    trace = bulletTrace(result.eye, result.target.origin, 0, player);
    trace_position = isDefined(trace) ? trace["position"] : undefined;
    result.reason = sight_reason(result.eye, result.target.origin, trace_position);
    return result;
}

face(player)
{
    // The menu row's earlier probe is never reused for a native view change
    result = probe(player);
    if (result.reason != "")
        return false;
    player setPlayerAngles(vectorToAngles(result.target.origin - result.eye));
    player iPrintLn("Facing the skull; keep it in view for the native 1.5-second hold");
    return true;
}
