// Observe only the native two-step cabinet retry line

native_callback()
{
    return scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::reactive_ghost_n_skull_cabinet;
}

registered_entries(state)
{
    if (!isDefined(state) || !isDefined(state._id_13F4D) || !isarray(state._id_13F4D))
        return undefined;
    entries = state._id_13F4D["reactivateghost"];
    if (!isDefined(entries) || !isarray(entries) || entries.size != 2)
        return undefined;
    if (!first_entry_matches(entries[0]) || !activation_entry_matches(entries[1]))
        return undefined;
    result = spawnstruct();
    result.first = entries[0];
    result.activation = entries[1];
    return result;
}

first_entry_matches(entry)
{
    return isDefined(entry) && isDefined(entry.init_func)
        && entry.init_func == scripts\cp\maps\cp_zmb\cp_zmb_ghost_wave::reactivate_cabinet
        && isDefined(entry._id_DB5D)
        && entry._id_DB5D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::brute_hit_arcade_cabinet_with_laser
        && isDefined(entry._id_446D)
        && entry._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_brute_hit_arcade_cabinet_with_laser;
}

activation_entry_matches(entry)
{
    return isDefined(entry) && isDefined(entry.init_func)
        && entry.init_func == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank
        && isDefined(entry._id_DB5D)
        && entry._id_DB5D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::wait_for_player_activation
        && isDefined(entry._id_446D)
        && entry._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet;
}

registry_present(state)
{
    if (!isDefined(state) || !isDefined(state._id_13F4D))
        return false;
    if (!isarray(state._id_13F4D))
        return true;
    return isDefined(state._id_13F4D["reactivateghost"]);
}

native_step(state)
{
    if (!isDefined(state) || !isDefined(state._id_13F1B) || !isarray(state._id_13F1B)
        || !isDefined(state._id_13F1B["reactivateghost"]))
        return -1;
    index = state._id_13F1B["reactivateghost"];
    if (index == 0 || index == 1)
        return index;
    return -1;
}

step(state)
{
    if (!isDefined(registered_entries(state)))
        return -1;
    return native_step(state);
}

current(state)
{
    if (!owns(state))
        return undefined;
    watch = state.apparition_reactivation_history;
    attempt = watch.attempt;
    entries = registered_entries(state);
    if (!isDefined(attempt) || !isDefined(attempt.ready) || !attempt.ready || !isDefined(entries))
        return undefined;
    if (native_step(state) < 0 || attempt.first != entries.first || attempt.activation != entries.activation)
        return undefined;
    return attempt;
}

install(state, watch)
{
    if (!isDefined(state) || !isDefined(watch)
        || !isDefined(state.apparition_reactivation_history) || state.apparition_reactivation_history != watch
        || isDefined(watch.original) || !isDefined(state.ghost_n_skull_reactivate_func)
        || state.ghost_n_skull_reactivate_func != native_callback())
        return false;
    watch.original = native_callback();
    state.ghost_n_skull_reactivate_func = ::on_reactivation;
    return owns(state);
}

owns(state)
{
    if (!isDefined(state) || !isDefined(state.apparition_reactivation_history))
        return false;
    watch = state.apparition_reactivation_history;
    return isDefined(watch) && isDefined(watch.original)
        && watch.original == native_callback()
        && isDefined(state.ghost_n_skull_reactivate_func)
        && state.ghost_n_skull_reactivate_func == ::on_reactivation;
}

start()
{
    level endon("game_ended");
    if (!scripts\apparition\runtime\context::supported()
        || isDefined(level.apparition_reactivation_history))
        return;
    watch = spawnstruct();
    level.apparition_reactivation_history = watch;
    // Map setup assigns the known callback after the menu lifecycle starts
    for (;;)
    {
        if (!scripts\apparition\runtime\context::supported()
            || level.apparition_reactivation_history != watch)
            return;
        callback = level.ghost_n_skull_reactivate_func;
        if (isDefined(callback))
        {
            if (callback == native_callback())
                install(level, watch);
            return;
        }
        wait 0.05;
    }
}

on_reactivation()
{
    watch = level.apparition_reactivation_history;
    // Production always delegates the exact callback assigned by map setup
    return route(level, watch, native_callback(), scripts\apparition\runtime\context::supported);
}

route(state, watch, original, session_check)
{
    route_owned = isDefined(state) && isDefined(watch)
        && isDefined(state.apparition_reactivation_history)
        && state.apparition_reactivation_history == watch && owns(state);
    attempt = undefined;
    safe_prior = false;
    prior_registry = false;
    prior_entries = undefined;
    session_before = false;
    if (route_owned)
    {
        // Replace old work before native code can start another retry
        attempt = spawnstruct();
        attempt.ready = false;
        watch.attempt = attempt;
        prior_registry = registry_present(state);
        prior_step = step(state);
        safe_prior = !prior_registry || prior_step == 1;
        if (prior_registry && prior_step == 1)
            prior_entries = registered_entries(state);
        session_before = [[session_check]]();
    }

    // Native registration and quest-thread startup remain authoritative
    result = [[original]]();
    if (!route_owned)
        return result;
    session_after = [[session_check]]();
    if (!session_before || !session_after || !safe_prior
        || !isDefined(state.apparition_reactivation_history)
        || state.apparition_reactivation_history != watch
        || !isDefined(watch.attempt) || watch.attempt != attempt || !owns(state))
        return result;

    entries_after = registered_entries(state);
    if (!isDefined(entries_after))
        return result;
    if (prior_registry && (!isDefined(prior_entries)
        || entries_after.first != prior_entries.first || entries_after.activation != prior_entries.activation))
        return result;

    // Only a stable native registry can be associated with this callback epoch
    attempt.first = entries_after.first;
    attempt.activation = entries_after.activation;
    attempt.ready = true;
    return result;
}
