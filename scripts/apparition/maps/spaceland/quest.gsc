// Native Spaceland UFO quest progress
// Encoded _id_ names preserve stock token IDs in the IW7 compiler

steps()
{
    return ["Collect DJ Parts", "Use Pack-a-Punch Portal", "Speaker Defense I", "Speaker Defense II", "Speaker Defense III", "Wait One Wave", "Obtain Tone Generators", "Place Tone Generators", "Match UFO Tones", "Defeat Suicide Bombers", "Defeat Alien Grey", "Destroy UFO"];
}

current_step(state)
{
    if (!isDefined(state)
        || !isDefined(state._id_13F4D) || !isarray(state._id_13F4D)
        || !isDefined(state._id_13F4D["ufo"]) || !isarray(state._id_13F4D["ufo"])
        || !isDefined(state._id_13F4D["ufo"][0]) || !isstruct(state._id_13F4D["ufo"][0])
        || !isDefined(state._id_13F4D["ufo"][0].init_func)
        || state._id_13F4D["ufo"][0].init_func != scripts\cp\maps\cp_zmb\cp_zmb_dj::init_fetch_quest
        || !isDefined(state._id_13F1B) || !isarray(state._id_13F1B)
        || !isDefined(state._id_13F1B["ufo"]) || !isnumber(state._id_13F1B["ufo"]))
        return -1;
    native_step = state._id_13F1B["ufo"];
    labels = steps();
    if (!(native_step >= 0 && native_step < labels.size))
        return -1;
    // The native runner stores integer array keys; normalize only exact whole values
    step = int(native_step);
    // Step zero already passed its shape and native initializer checks
    if (step != native_step || (step != 0 && (!isDefined(state._id_13F4D["ufo"][step])
        || !isstruct(state._id_13F4D["ufo"][step]))))
        return -1;
    return step;
}

progress(state)
{
    progress = spawnstruct();
    progress.step = current_step(state);
    // The current final index alone does not establish final completion
    progress.finished = progress.step == 11 && isDefined(state.flag)
        && isarray(state.flag) && isDefined(state.flag["ufo_quest_finished"])
        && state.flag["ufo_quest_finished"];
    return progress;
}

stage_completed(progress, index)
{
    if (progress.step < 0)
        return false;
    return index < progress.step || progress.finished;
}
