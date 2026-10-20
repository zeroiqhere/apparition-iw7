// Native-shaped records keep registry tests separate from real map actors

ready()
{
    fixture = spawnstruct();
    fixture.state = spawnstruct();
    fixture.state.struct_class_names = [];
    fixture.state.struct_class_names["script_noteworthy"] = [];
    first = tests\fixtures\spawn_points::point((10, 20, 30), (0, 0, 0));
    first.script_noteworthy = "magic_wheel";
    first.area_name = "wonderland";
    other = tests\fixtures\spawn_points::point((40, 50, 60), (0, 90, 0));
    other.script_noteworthy = "magic_wheel";
    other.area_name = "polar";
    fixture.wheels = [first, other];
    // The settled native wheel pointer and selected area describe the same place
    fixture.state.current_active_wheel = first;
    fixture.state._id_A8E2 = "wonderland";
    perk = tests\fixtures\spawn_points::point((70, 80, 90), (0, 180, 0));
    perk.script_noteworthy = "perk_machine_revive";
    // Classification uses the same native object that the interaction system reads
    fixture.state.struct_class_names["script_noteworthy"][perk.script_noteworthy] = [perk];
    return fixture;
}
