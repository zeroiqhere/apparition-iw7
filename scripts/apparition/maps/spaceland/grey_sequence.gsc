// Observe the native initial spawn loop without changing its fight completion event

create()
{
    watch = spawnstruct();
    watch.state = "Waiting";
    return watch;
}

start()
{
    level endon("game_ended");
    if (isDefined(level.apparition_grey_sequence))
        return;
    watch = create();
    level.apparition_grey_sequence = watch;
    deadline = getTime() + 10000;
    while (getTime() < deadline)
    {
        if (install(level, watch))
            return;
        if (scripts\apparition\maps\spaceland\quest::current_step(level) >= 10)
            break;
        wait 0.05;
    }
    watch.state = "Unavailable";
}

entry(state)
{
    if (!isDefined(state._id_13F4D) || !isDefined(state._id_13F4D["ufo"]))
        return undefined;
    return state._id_13F4D["ufo"][10];
}

native_edges(value)
{
    return isDefined(value) && isDefined(value.init_func)
        && value.init_func == scripts\cp\maps\cp_zmb\cp_zmb_dj::init_alien_grey_fight
        && isDefined(value._id_446D) && value._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_dj::complete_grey_fight;
}

install(state, watch)
{
    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    value = entry(state);
    if (!isDefined(watch) || state.apparition_grey_sequence != watch || watch.state != "Waiting"
        || step < 0 || step >= 10 || !native_edges(value)
        || !isDefined(value._id_DB5D) || value._id_DB5D != scripts\cp\maps\cp_zmb\cp_zmb_dj::alien_grey_fight)
        return false;
    watch.entry = value;
    watch.original = value._id_DB5D;
    watch.state = "Installed";
    // Publish the wrapper last with no yield between validation and ownership
    value._id_DB5D = ::fight;
    return true;
}

owned(state, watch)
{
    value = entry(state);
    return isDefined(watch) && isDefined(state.apparition_grey_sequence) && state.apparition_grey_sequence == watch
        && native_edges(value) && isDefined(watch.entry) && value == watch.entry
        && isDefined(value._id_DB5D) && value._id_DB5D == ::fight;
}

tracked(state, watch)
{
    if (owned(state, watch))
        return true;
    value = entry(state);
    // After the native event, the restored slot can still authorize observation
    return isDefined(watch) && state.apparition_grey_sequence == watch && watch.state == "Ended"
        && native_edges(value) && isDefined(watch.entry) && value == watch.entry
        && isDefined(watch.original) && watch.original == scripts\cp\maps\cp_zmb\cp_zmb_dj::alien_grey_fight
        && isDefined(value._id_DB5D) && value._id_DB5D == watch.original;
}

fight()
{
    level endon("game_ended");
    watch = level.apparition_grey_sequence;
    if (!owned(level, watch) || watch.state != "Installed")
    {
        scripts\cp\maps\cp_zmb\cp_zmb_dj::alien_grey_fight();
        return;
    }
    watch.state = "Spawning";
    level thread run_spawns(watch);
    // Keep the native zero-argument body and its exact completion wait
    level waittill("complete_alien_grey_fight");
    watch.state = "Ended";
    restore(level, watch);
}

run_spawns(watch)
{
    level endon("game_ended");
    // A synchronous call returns after every initial native Grey has been set up
    scripts\cp\maps\cp_zmb\cp_zmb_ufo::start_grey_sequence();
    spawn_returned(watch);
}

spawn_returned(watch)
{
    if (watch.state == "Spawning")
        watch.state = "Ready";
}

restore(state, watch)
{
    // A later owner keeps its callback even if this fight has already ended
    if (owned(state, watch))
        watch.entry._id_DB5D = watch.original;
}
