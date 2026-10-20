// Fuse windows use native idle edges, cap changes, and model ownership

eligible(enemy)
{
    // Native agent identity and life checks remain the worker's responsibility
    return scripts\apparition\maps\spaceland\greys::identity(enemy)
        && (!isDefined(enemy.i_am_clone) || !enemy.i_am_clone)
        && isDefined(enemy.can_do_health_regen) && enemy.can_do_health_regen
        && isDefined(enemy.current_max_health_regen_level)
        && isDefined(enemy.min_health_regen_level) && isDefined(enemy.max_health_regen_level_penalty)
        && isDefined(enemy.available_fuse);
}

record(enemy)
{
    record = spawnstruct();
    record.enemy = enemy;
    // Every new actor or restarted job must first observe native idle
    record.ready = false;
    return record;
}

observe(record)
{
    enemy = record.enemy;
    if (!eligible(enemy))
        return undefined;
    if (!isDefined(enemy.is_regening_health) || !enemy.is_regening_health)
    {
        // A changed cap later reveals accepted melee whose stop event was missed
        record.regen_cap = enemy.current_max_health_regen_level;
        record.ready = true;
        return undefined;
    }
    return record.ready ? exposed(enemy) : undefined;
}

exposed(enemy)
{
    if (!eligible(enemy) || !isDefined(enemy.is_regening_health) || !enemy.is_regening_health
        || !isDefined(enemy.actually_doing_regen) || !enemy.actually_doing_regen)
        return undefined;
    fuse = enemy.alien_fuse_exposed;
    if (!isDefined(fuse) || !isDefined(fuse.owner) || fuse.owner != enemy
        || !isDefined(fuse.tag_name) || (fuse.tag_name != "tag_back_le" && fuse.tag_name != "tag_back_ri")
        || !isDefined(fuse.origin) || !scripts\engine\utility::array_contains(enemy.available_fuse, fuse))
        return undefined;
    return fuse;
}

ready_to_strike(record, ticket, fuse)
{
    // Arming may yield while another actor removes or changes the selected model
    return ticket.state == "Armed" && record.ready && isDefined(fuse)
        && record.enemy.current_max_health_regen_level == record.regen_cap && exposed(record.enemy) == fuse;
}

removed(enemy, fuse)
{
    // A stop event alone does not prove the native removal callback finished
    return !isDefined(fuse) || (isDefined(enemy) && isDefined(enemy.available_fuse)
        && !scripts\engine\utility::array_contains(enemy.available_fuse, fuse));
}

