// The native activation callback remains responsible for starting Ghosts N Skulls

registered_entry(state)
{
    if (!isDefined(state) || !isDefined(state._id_13F4D) || !isDefined(state._id_13F4D["ghost"]))
        return undefined;
    return state._id_13F4D["ghost"][6];
}

native_entry(entry)
{
    return isDefined(entry)
        && isDefined(entry.init_func)
        && entry.init_func == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank
        && isDefined(entry._id_DB5D)
        && entry._id_DB5D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::wait_for_player_activation
        && isDefined(entry._id_446D)
        && entry._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet;
}

install(state, watch)
{
    if (!isDefined(state) || !isDefined(watch)
        || !isDefined(state.apparition_ghost_history) || state.apparition_ghost_history != watch
        || isDefined(watch.entry) || isDefined(watch.original) || !isDefined(watch.observed) || watch.observed)
        return false;
    entry = registered_entry(state);
    if (!native_entry(entry))
        return false;
    // Retain the exact callback before publishing this one-field observer
    watch.entry = entry;
    watch.original = entry._id_446D;
    entry._id_446D = ::on_activation;
    return owns(state);
}

owns(state)
{
    if (!isDefined(state) || !isDefined(state.apparition_ghost_history))
        return false;
    watch = state.apparition_ghost_history;
    if (!isDefined(watch)
        || !isDefined(watch.entry) || !isDefined(watch.original)
        || watch.original != scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet)
        return false;
    entry = registered_entry(state);
    // The source body and initializer remain part of the hook identity
    return isDefined(entry) && entry == watch.entry
        && isDefined(entry.init_func)
        && entry.init_func == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank
        && isDefined(entry._id_DB5D)
        && entry._id_DB5D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::wait_for_player_activation
        && isDefined(entry._id_446D)
        && entry._id_446D == ::on_activation;
}

observed(state)
{
    if (!isDefined(state) || !isDefined(state.apparition_ghost_history))
        return false;
    watch = state.apparition_ghost_history;
    return owns(state) && isDefined(watch.observed) && watch.observed;
}

start()
{
    level endon("game_ended");
    if (!scripts\apparition\runtime\context::supported()
        || isDefined(level.apparition_ghost_history))
        return;
    watch = spawnstruct();
    watch.observed = false;
    level.apparition_ghost_history = watch;
    // The quest table is filled by map setup after the menu lifecycle starts
    for (;;)
    {
        if (!scripts\apparition\runtime\context::supported())
            return;
        entry = registered_entry(level);
        if (isDefined(entry))
        {
            install(level, watch);
            return;
        }
        wait 0.05;
    }
}

on_activation()
{
    watch = level.apparition_ghost_history;
    // Only this exact native callback can have installed the observer
    return route(level, watch, scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet,
        scripts\apparition\runtime\context::supported);
}

route(state, watch, original, session_check)
{
    // Capture ownership before native work can yield or replace quest state
    valid_before = [[session_check]]() && isDefined(state) && isDefined(watch)
        && isDefined(state.apparition_ghost_history) && state.apparition_ghost_history == watch
        && owns(state)
        && scripts\apparition\maps\spaceland\ghosts::current_step(state) == 6;
    entry_before = valid_before ? watch.entry : undefined;
    result = [[original]]();
    // A callback return is evidence only while its session and watch remain current
    if (valid_before && [[session_check]]()
        && isDefined(state.apparition_ghost_history)
        && state.apparition_ghost_history == watch && owns(state) && watch.entry == entry_before
        && scripts\apparition\maps\spaceland\ghosts::current_step(state) == 6)
        watch.observed = true;
    return result;
}
