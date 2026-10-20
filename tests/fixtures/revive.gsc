// Minimal native-shaped values keep revive admission tests away from live actors

context()
{
    state = spawnstruct();
    state.gameended = 0;
    state.wait_to_be_revived_func = scripts\cp\maps\cp_zmb\cp_zmb::cp_zmb_wait_to_be_revived_func;
    state.only_one_player = 0;
    state.the_hoff_revive = 0;
    return state;
}

player()
{
    target = spawnstruct();
    target.inlaststand = 1;
    target.sessionstate = "playing";
    target.health = 1;
    return target;
}

revive_trigger(owner)
{
    body = spawnstruct();
    body.owner = owner;
    body.targetname = "revive_trigger";
    return body;
}
