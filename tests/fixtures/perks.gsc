// Perk fixtures hold inventory and callback data without changing live players

owned_player(perk_ids)
{
    player = spawnstruct();
    player.zombies_perks = [];
    foreach (perk_id in perk_ids)
        player.zombies_perks[perk_id] = 1;
    return player;
}

retaining_player(perk_ids)
{
    player = owned_player(perk_ids);
    // The record is a setting plus a saved selection, not a second live inventory
    player.apparition_perk_retention = spawnstruct();
    player.apparition_perk_retention.saved = [];
    return player;
}

callbacks(perk_ids)
{
    registry = [];
    foreach (perk_id in perk_ids)
    {
        // Function references model registration without invoking native effects
        registry[perk_id] = spawnstruct();
        registry[perk_id].set = ::callback;
        registry[perk_id].unset = ::callback;
    }
    return registry;
}

callback()
{
    // The fixture supplies references only; these callbacks are never executed
}
