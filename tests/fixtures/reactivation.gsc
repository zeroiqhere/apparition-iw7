// Native reactivation entries are represented without starting their bodies

state()
{
    value = spawnstruct();
    value._id_13F4D = [];
    value._id_13F4D["reactivateghost"] = [first_entry(), activation_entry()];
    value._id_13F1B = [];
    value._id_13F1B["reactivateghost"] = 0;
    value.ghost_n_skull_reactivate_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::reactive_ghost_n_skull_cabinet;
    return value;
}

unregistered_state()
{
    value = spawnstruct();
    value._id_13F4D = [];
    value._id_13F1B = [];
    value.ghost_n_skull_reactivate_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::reactive_ghost_n_skull_cabinet;
    return value;
}

first_entry()
{
    entry = spawnstruct();
    entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_wave::reactivate_cabinet;
    entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::brute_hit_arcade_cabinet_with_laser;
    entry._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_brute_hit_arcade_cabinet_with_laser;
    return entry;
}

activation_entry()
{
    entry = spawnstruct();
    entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::wait_for_player_activation;
    entry._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet;
    return entry;
}
