// Native node progress stays separate from observed input history

run()
{
    only_unique_complete_node_assets_can_be_used();
    admission_requires_native_stage_fuses_and_early_history();
    submitted_unconfirmed_nodes_cannot_receive_a_second_menu_hit();
    native_destruction_is_the_only_success_result();
}

state()
{
    state = tests\fixtures\spaceland::fuses();
    state.flag["fuses_inserted"] = 1;
    state.flag["ufo_destroyed"] = 0;
    state._id_13F4D["ufo"][11].init_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::init_ufo_projectile_attack;
    state.struct_class_names["targetname"] = [];
    for (index = 1; index <= 5; index++)
    {
        node = spawnstruct();
        node.targetname = "main_gate_powernode_" + index;
        node.origin = (index * 200, 0, 0);
        node.is_activated = 0;
        node.target = "node_arc_target_" + index;
        target = spawnstruct();
        target.targetname = node.target;
        target.origin = node.origin + (0, 0, 20);
        state.struct_class_names["targetname"][node.targetname] = [node];
        state.struct_class_names["targetname"][node.target] = [target];
    }
    state.struct_class_names["targetname"]["main_gate_powernode_1"][0].is_activated = 1;
    return state;
}

watch(state)
{
    watch = scripts\apparition\maps\spaceland\node_history::create(scripts\apparition\maps\spaceland\nodes::registry(state), spawnstruct());
    watch.state = "Listening";
    return watch;
}

only_unique_complete_node_assets_can_be_used()
{
    state = state();
    nodes = scripts\apparition\maps\spaceland\nodes::registry(state);
    tests\support\checks::expect(isDefined(nodes) && nodes.size == 5, "All five canonical native nodes are resolved in source order");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::index(nodes, nodes[4]) == 4, "Native mapping resolves only a canonical node identity");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::index(nodes, spawnstruct()) == -1, "An unrelated mapped struct cannot enter node history");
    state.struct_class_names["targetname"]["main_gate_powernode_2"][1] = spawnstruct();
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\nodes::registry(state)), "Duplicate node registration blocks the adapter");
    state = state();
    state.struct_class_names["targetname"]["node_arc_target_3"] = [];
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\nodes::registry(state)), "A missing native arc endpoint blocks input before its callback can fail");
    state = state();
    state.struct_class_names["targetname"]["main_gate_powernode_5"][0].origin = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\nodes::registry(state)), "A node without a native hit position cannot be targeted");
}

admission_requires_native_stage_fuses_and_early_history()
{
    state = state();
    watch = watch(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) == "", "One native charged node and known early history allow admission");
    watch.nodes[0].is_activated = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) != "", "At least one native charge must prove the damage monitor has handled an input");
    watch.nodes[0].is_activated = 1;
    watch.state = "Arming";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) != "", "Unready history cannot prove that no firing sequence is in flight");
    watch.state = "Unavailable";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) != "", "Late or failed observation remains closed");
    watch.state = "Listening";
    state.flag["fuses_inserted"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) != "", "The normal PAP fuse prerequisite must be complete");
    state.flag["fuses_inserted"] = 1;
    state._id_13F1B["ufo"] = 10;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) != "", "An earlier quest stage cannot activate final nodes");
    state._id_13F1B["ufo"] = 11;
    state._id_13F4D["ufo"][11].init_func = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) != "", "Changed final-stage initialization cannot be bypassed");
}

submitted_unconfirmed_nodes_cannot_receive_a_second_menu_hit()
{
    state = state();
    watch = watch(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\node_history::claim(watch, 1), "An untouched node admits one menu input");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\node_history::claim(watch, 1), "A submitted node cannot receive a repeated menu hit");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) != "", "Unconfirmed native activation blocks a new worker");
    watch.nodes[1].is_activated = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) == "", "Native activation allows a later worker to continue other untouched nodes");
    watch.cycle_spent = true;
    watch.nodes[1].is_activated = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::reason(state, watch) != "", "Reset native flags cannot reopen a potentially firing cycle");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\node_history::claim(watch, 2), "A spent cycle rejects even an untouched menu node");
}

native_destruction_is_the_only_success_result()
{
    state = state();
    watch = watch(state);
    job = spawnstruct();
    job.state = "Active";
    watch.cycle_spent = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::outcome(state, watch, job, true, false) == "", "Input history alone leaves native destruction under observation");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::outcome(state, watch, job, true, true) == "Pending", "Expired native observation is unconfirmed rather than successful");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::outcome(state, watch, job, true, false) == "Cancelled", "Cancel stops further menu damage without resetting the native cycle");
    job.state = "Active";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::outcome(state, watch, job, false, false) == "Unavailable", "Owner loss stops submissions while preserving native progress");
    state.flag["ufo_destroyed"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\nodes::outcome(state, watch, job, false, true) == "Destroyed", "Native destruction confirms success even after observer permission or time expires");
    tests\support\checks::expect(!state.flag["ufo_quest_finished"], "A node observer never completes the quest or awards its reward");
}
