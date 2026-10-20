// Resolve only a registered Spaceland primary explosive for the effect layer

powers()
{
    // The map replaces the generic pillage list with this exact set
    return [
        "power_bioSpike",
        "power_c4",
        "power_clusterGrenade",
        "power_concussionGrenade",
        "power_frag",
        "power_gasGrenade",
        "power_semtex",
        "power_splashGrenade",
        // The native map grants Cryobomb directly into the same primary slot
        "power_cryobomb"
    ];
}

supported(id)
{
    // Never infer ordinary equipment from an unknown quest power
    foreach (power_id in powers())
    {
        if (power_id == id)
            return true;
    }
    return false;
}

candidate(player, registry)
{
    // Missing or malformed native tables cannot prove the equipped identity
    if (!isDefined(player) || !isDefined(player.powers) || !isarray(player.powers)
        || !isDefined(registry) || !isarray(registry))
        return undefined;

    // Reject a second primary entry before applying the allowlist
    primary_id = undefined;
    foreach (id in getarraykeys(player.powers))
    {
        record = player.powers[id];
        if (!isDefined(record) || !isstruct(record)
            || !isDefined(record.slot) || !isstring(record.slot) || record.slot == "")
            return undefined;

        if (record.slot == "primary")
        {
            if (isDefined(primary_id))
                return undefined;
            primary_id = id;
        }
    }

    // A missing or duplicated slot assignment is ambiguous
    if (!isDefined(primary_id) || !supported(primary_id))
        return undefined;

    // The entry and player record must describe the same registered weapon
    primary = player.powers[primary_id];
    native = registry[primary_id];
    if (!isDefined(native) || !isstruct(native)
        || !isDefined(primary.weaponuse) || !isstring(primary.weaponuse) || primary.weaponuse == ""
        || !isDefined(native.weaponuse) || !isstring(native.weaponuse) || native.weaponuse == ""
        || !isDefined(player.powerprimarygrenade) || !isstring(player.powerprimarygrenade)
        || player.powerprimarygrenade == ""
        || primary.weaponuse != native.weaponuse || player.powerprimarygrenade != primary.weaponuse)
        return undefined;

    // Native charge values are numbers; malformed values fail closed
    if (!isDefined(primary.charges) || !isnumber(primary.charges) || primary.charges < 0
        || !isDefined(native.maxcharges) || !isnumber(native.maxcharges) || native.maxcharges <= 0)
        return undefined;

    // An active or locked throw is still owned by native power logic
    if (!isDefined(primary.active) || !isnumber(primary.active) || primary.active
        || (isDefined(primary._id_55AB)
            && (!isnumber(primary._id_55AB) || primary._id_55AB)))
        return undefined;

    // False permanent entries have a delayed native removal worker at zero
    if (isDefined(primary.permanent)
        && (!isnumber(primary.permanent) || !primary.permanent))
        return undefined;

    // Keep full and above-cap entries visible so callers never downgrade them
    return primary_id;
}

inspect(player, registry, living)
{
    result = spawnstruct();
    // Native modes own inventory even when the ordinary primary is unavailable
    result.state = "Paused";
    if (blocked(player))
        return result;

    // Native mode ownership remains clearer when its actor is also down
    result.state = "Waiting";
    if (!isDefined(living) || !living)
        return result;

    result.state = "Unavailable";
    id = candidate(player, registry);
    if (!isDefined(id))
        return result;

    // A valid target can still be full; both the worker and view use this decision
    result.id = id;
    result.state = player.powers[id].charges >= registry[id].maxcharges ? "Full" : "Ready";
    return result;
}

blocked(player)
{
    // A missing actor cannot authorize an effect
    if (!isDefined(player))
        return true;

    // Native arcade and temporary equipment modes own their inventory
    if ((isDefined(player.inlaststand) && player.inlaststand)
        || (isDefined(player.in_afterlife_arcade) && player.in_afterlife_arcade)
        || (isDefined(player.playing_ghosts_n_skulls) && player.playing_ghosts_n_skulls)
        || (isDefined(player.playing_game) && player.playing_game)
        || (isDefined(player.linked_to_coaster) && player.linked_to_coaster)
        || (isDefined(player.disable_consumables) && player.disable_consumables))
        return true;

    return false;
}
