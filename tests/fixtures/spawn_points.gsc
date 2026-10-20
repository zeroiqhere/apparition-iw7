// Small native-shaped registries keep spawn contracts independent from map data

point(origin, angles)
{
    entry = spawnstruct();
    entry.origin = origin;
    entry.angles = angles;
    return entry;
}

ready_state()
{
    state = spawnstruct();
    state.struct_class_names = [];
    state.struct_class_names["targetname"] = [];
    state.struct_class_names["targetname"]["player_respawn_loc"] = [
        point((1, 2, 3), (4, 5, 6)), point((7, 8, 9), (10, 11, 12))];
    return state;
}
