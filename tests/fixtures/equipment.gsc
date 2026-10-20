// Minimal native-shaped power records keep contracts away from live player state

registry(id, weaponuse, maxcharges)
{
    values = [];
    entry = spawnstruct();
    entry.weaponuse = weaponuse;
    entry.maxcharges = maxcharges;
    values[id] = entry;
    return values;
}

power(slot, weaponuse, charges, active, locked, permanent)
{
    record = spawnstruct();
    record.slot = slot;
    record.weaponuse = weaponuse;
    record.charges = charges;
    record.active = active;
    record._id_55AB = locked;
    record.permanent = permanent;
    return record;
}

player(id, weaponuse, charges, permanent)
{
    state = spawnstruct();
    state.powers = [];
    state.powers[id] = power("primary", weaponuse, charges, 0, undefined, permanent);
    state.powerprimarygrenade = weaponuse;
    return state;
}
