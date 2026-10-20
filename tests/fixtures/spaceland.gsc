// Native quest fixtures share the exact registered-line and current-step fields

wave()
{
    state = quest(5);
    entry = state._id_13F4D["ufo"][5];
    entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_dj::wait_one_wave;
    entry._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    state.spawnloopupdatefunc = scripts\cp\zombies\zombies_spawning::_id_12E29;
    state.flag["pause_wave_progression"] = 0;
    state.wave_num = 12;
    state.current_enemy_deaths = 3;
    state.desired_enemy_deaths_this_wave = 40;
    state.spawned_enemies = [];
    state.spawn_event_running = 0;
    state.event_funcs = [];
    state.event_funcs["goon"] = scripts\cp\zombies\zombies_spawning::goon_spawn_event_func;
    state.agent_funcs = agent_callbacks();
    return state;
}

agent_callbacks()
{
    callbacks = [];
    foreach (type in ["generic_zombie", "zombie_clown"])
    {
        callbacks[type] = [];
        callbacks[type]["gametype_on_killed"] = scripts\cp\agents\gametype_zombie::onzombiekilled;
        callbacks[type]["on_killed"] = scripts\mp\agents\zombie\zombie_agent::onzombiekilled;
    }
    return callbacks;
}

wave_enemy(state)
{
    enemy = spawnstruct();
    enemy.agent_type = "generic_zombie";
    enemy.team = "axis";
    enemy.health = 500;
    enemy.maxhealth = 1000;
    enemy.died_poorly = 0;
    enemy.origin = (1, 2, 3);
    state.spawned_enemies[state.spawned_enemies.size] = enemy;
    return enemy;
}

wave_job(state)
{
    job = spawnstruct();
    job.wave = state.wave_num;
    job.state = "Active";
    return job;
}

speaker(step)
{
    state = quest(step);
    initializers = [scripts\cp\maps\cp_zmb\cp_zmb_dj::init_first_speaker_defense, scripts\cp\maps\cp_zmb\cp_zmb_dj::init_second_speaker_defense, scripts\cp\maps\cp_zmb\cp_zmb_dj::init_third_speaker_defense];
    bodies = [scripts\cp\maps\cp_zmb\cp_zmb_dj::do_first_speaker_defend, scripts\cp\maps\cp_zmb\cp_zmb_dj::do_second_speaker_defend, scripts\cp\maps\cp_zmb\cp_zmb_dj::do_third_speaker_defend];
    for (index = 0; index < 3; index++)
    {
        state._id_13F4D["ufo"][index + 2].init_func = initializers[index];
        state._id_13F4D["ufo"][index + 2]._id_DB5D = bodies[index];
        state._id_13F4D["ufo"][index + 2]._id_446D = index == 2 ? scripts\cp\maps\cp_zmb\cp_zmb_dj::complete_all_speaker_defense : scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    }
    state.flag["defend_sequence"] = 1;
    state.flag["dj_request_defense_done"] = 1;
    state.flag["defense_sequence_active"] = 1;
    state.flag["pause_wave_progression"] = 1;
    state.spawn_event_running = 0;
    state.frequency_device_clip = spawnstruct();
    state.frequency_device_clip.origin = (0, 0, 0);
    state.frequency_device_clip.originalloc = (100, 0, 0);
    state.current_speaker = spawnstruct();
    state.current_speaker.model = "zmb_frequency_device";
    state.current_speaker.origin = (0, 0, 0.5);
    state.current_speaker.hit_point_left = 10;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_during_speaker_defense;
    state.interactions = [];
    entry = spawnstruct();
    entry.name = "dj_quest_speaker";
    entry.enabled = 1;
    entry.cost = 0;
    entry.spend_type = "quest";
    entry.activation_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::start_defense_sequence;
    entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::init_dj_speaker;
    state.interactions[entry.name] = entry;
    state.current_interaction_structs = [];
    return state;
}

speaker_spot()
{
    spot = spawnstruct();
    spot.script_noteworthy = "dj_quest_speaker";
    spot.origin = (0, 0, 0);
    spot.in_use = 0;
    return spot;
}

speaker_job(state)
{
    job = spawnstruct();
    job.defense = speaker_capture(state);
    state.apparition_speaker_capture = job.defense;
    job.state = "Defending";
    return job;
}

speaker_capture(state)
{
    capture = spawnstruct();
    capture.step = state._id_13F1B["ufo"];
    capture.speaker = state.current_speaker;
    capture.clip = state.frequency_device_clip;
    capture.submitted = false;
    capture.ticket = armed_ticket();
    return capture;
}

speaker_pickup(step)
{
    state = speaker(step);
    state.apparition_speaker_capture = speaker_capture(state);
    state.current_speaker = undefined;
    state.flag["defense_sequence_active"] = 0;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_pick_up_analyzer;
    return state;
}

quest(step)
{
    state = spawnstruct();
    state._id_13F4D = [];
    state._id_13F4D["ufo"] = [];
    for (index = 0; index < 12; index++)
        state._id_13F4D["ufo"][index] = spawnstruct();
    state._id_13F4D["ufo"][0].init_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::init_fetch_quest;
    state._id_13F1B = [];
    state._id_13F1B["ufo"] = step;
    state.flag = [];
    state.flag["ufo_quest_finished"] = 0;
    return state;
}

// Four placed tone generators share one native sequence fixture

tones()
{
    state = tests\fixtures\spaceland::quest(8);
    state.flag["ufo_intro_reach_center_portal"] = 1;
    state.flag["ufo_listening"] = 0;
    state.flag["tones_played_successfully"] = 0;
    state.flag["all_structs_placed"] = 1;
    state.ufo = spawnstruct();
    state.ufo.tone_array = ["03", "01", "04", "02"];
    state.alldjcenterstructs = [];
    keys = ["01", "02", "03", "04"];
    for (index = 0; index < keys.size; index++)
    {
        location = spawnstruct();
        location.origin = (index, 0, 0);
        location.model = spawnstruct();
        location.tone = "speaker_tone_playback_" + keys[index];
        location.placed = 1;
        state.alldjcenterstructs[index] = location;
    }
    state.current_interaction_structs = state.alldjcenterstructs;
    return state;
}

// Five native travel spots describe the normal four-use hidden-room unlock
portals()
{
    state = quest(1);
    state.flag["fast_travel_init_done"] = 1;
    state.flag["disable_portals"] = 0;
    state.flag["pap_portal_used"] = 0;
    state.end_portal_name = "main_street";
    state._id_8E61 = 1;
    state.interactions = [];
    state.interactions["fast_travel"] = spawnstruct();
    state.interactions["fast_travel"].activation_func = scripts\cp\zombies\zombie_fast_travel::run_fast_travel_logic;
    state.interactions["fast_travel"].enabled = 1;
    state.fast_travel_spots = [];
    foreach (area in ["arcade", "moon", "europa", "mars", "main_street"])
    {
        spot = spawnstruct();
        spot.script_area = area;
        spot.script_noteworthy = "fast_travel";
        spot.origin = (0, 0, 0);
        spot._id_D680 = spawnstruct();
        spot._id_D682 = spawnstruct();
        spot._id_D682.angles = (0, 0, 0);
        spot.light = spawnstruct();
        spot.powered_on = 1;
        spot.portal_can_be_started = 1;
        spot.portal_charging = 0;
        spot.portal_is_open = 0;
        spot.used_once = area != "main_street";
        destination = spawnstruct();
        destination.origin = (1, 2, 3);
        destination.angles = (0, 90, 0);
        spot.end_positions = [destination];
        state.fast_travel_spots[area] = spot;
    }
    return state;
}

// An armed observation ticket has no captured event before native input arrives
armed_ticket()
{
    ticket = spawnstruct();
    ticket.state = "Armed";
    return ticket;
}

// Native dropped-fuse context is shared by collection and insertion contracts

fuses()
{
    state = tests\fixtures\spaceland::quest(11);
    state.flag["fuses_inserted"] = 0;
    state.num_fuse_in_possession = 0;
    state.interactions = [];
    entry = spawnstruct();
    entry.name = "pap_upgrade";
    entry.enabled = 1;
    entry.activation_func = scripts\cp\maps\cp_zmb\cp_zmb_ufo::upgrade_pap;
    entry.can_use_override_func = scripts\cp\maps\cp_zmb\cp_zmb_ufo::can_use_pap_upgrade;
    state.interactions["pap_upgrade"] = entry;
    state.struct_class_names = [];
    state.struct_class_names["script_noteworthy"] = [];
    state.current_interaction_structs = [];
    foreach (name in ["pap_upgrade", "weapon_upgrade"])
    {
        spot = spawnstruct();
        spot.script_noteworthy = name;
        state.struct_class_names["script_noteworthy"][name] = [spot];
        if (name == "weapon_upgrade")
            state.current_interaction_structs[0] = spot;
    }
    return state;
}

// Grey fixtures retain native quest callbacks and separate actor/fuse ownership

greys()
{
    state = quest(10);
    state.flag["pause_wave_progression"] = 1;
    state.flag["tones_played_successfully"] = 1;
    state.grey_on_killed_func = scripts\cp\maps\cp_zmb\cp_zmb_ufo::grey_on_killed_func;
    state.greygetmeleedamagedfunc = scripts\cp\maps\cp_zmb\cp_zmb_ufo::remove_alien_fuse;
    state.greysetupfunc = scripts\cp\maps\cp_zmb\cp_zmb_ufo::attach_alien_fuse;
    state.spawned_grey = [];
    entry = state._id_13F4D["ufo"][10];
    entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::init_alien_grey_fight;
    entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_dj::alien_grey_fight;
    entry._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_dj::complete_grey_fight;
    return state;
}

grey()
{
    enemy = spawnstruct();
    enemy.agent_type = "zombie_grey";
    enemy.team = "axis";
    enemy.is_reserved = 1;
    enemy.health = 10000;
    enemy.maxhealth = 10000;
    enemy.origin = (0, 0, 0);
    enemy.can_do_health_regen = 1;
    enemy.current_max_health_regen_level = 10000;
    enemy.min_health_regen_level = 3300;
    enemy.max_health_regen_level_penalty = 3300;
    enemy.is_regening_health = 0;
    enemy.actually_doing_regen = 0;
    fuse = spawnstruct();
    fuse.owner = enemy;
    fuse.tag_name = "tag_back_le";
    fuse.origin = (1, 2, 3);
    enemy.available_fuse = [fuse];
    enemy.alien_fuse_exposed = fuse;
    return enemy;
}
