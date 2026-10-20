// Insta-Kill changes the native damage amount while leaving native death handling intact

modes()
{
    return ["Disable", "All", "Melee"];
}

valid_mode(mode)
{
    // These names stay in the same order as the source slider
    if (!isDefined(mode) || !isstring(mode))
        return false;

    foreach (supported in modes())
    {
        if (mode == supported)
            return true;
    }
    return false;
}

record_mode(record)
{
    // No record means disabled; malformed live records stay visible as Unknown
    if (!isDefined(record))
        return "Disable";
    if (!isstruct(record) || !isDefined(record.owner)
        || !isDefined(record.mode) || !isstring(record.mode))
        return "Unknown";
    if (record.mode == "All" || record.mode == "Melee")
        return record.mode;
    return "Unknown";
}

damage_amount(mode, means, agent_type, suicide_bomber, amount, health, maximum, special_scale)
{
    // Native Brute and Grey rules remain the final owners of their damage
    if (!isDefined(mode) || (mode != "All" && mode != "Melee"))
        return amount;
    if (!isDefined(agent_type) || !isstring(agent_type)
        || agent_type == "zombie_brute" || agent_type == "zombie_grey")
        return amount;
    // Melee means the native damage string, not a weapon-name guess
    if (mode == "Melee" && (!isDefined(means) || !isstring(means) || means != "MOD_MELEE"))
        return amount;

    // Keep conversion below the largest float that rounds safely to a signed int
    if (!isDefined(amount) || !isnumber(amount) || !(amount >= 0 && amount <= 2147483520)
        || !isDefined(health) || !isnumber(health)
        || !isDefined(maximum) || !isnumber(maximum)
        || !(maximum > 0 && maximum <= 2147483520 && health > 0 && health <= maximum))
        return amount;

    // The engine truncates damage after capping it to maxhealth
    native_damage = int(maximum);
    if (native_damage < health)
        return amount;

    // Suicide bombers receive a native attacker multiplier after this callback
    if (suicide_bomber && isDefined(special_scale))
    {
        if (!isnumber(special_scale) || !(special_scale > 0))
            return amount;

        scaled_damage = native_damage;
        if (special_scale < 1)
            scaled_damage = int(maximum * special_scale);
        if (scaled_damage < health)
            return amount;
    }

    return maximum;
}

probe(owner, target)
{
    result = spawnstruct();
    result.reason = scripts\apparition\runtime\access::fun_reason(owner, target);
    result.mode = "Unknown";
    result.hook_reason = "";
    if (result.reason != "")
        return result;

    // Only an admitted target can expose its saved feature record
    record = target.apparition_insta_kill;
    result.mode = record_mode(record);
    result.hook_reason = scripts\apparition\runtime\enemy_damage::ready_reason();
    return result;
}

set_mode(owner, target, mode)
{
    // Invalid menu input cannot reach actor checks or mutate a stored selection
    if (!valid_mode(mode))
        return false;
    if (scripts\apparition\runtime\access::fun_reason(owner, target) != "")
        return false;

    // Disable remains available after the optional global hook is lost
    if (mode == "Disable")
    {
        target.apparition_insta_kill = undefined;
        return true;
    }

    if (scripts\apparition\runtime\enemy_damage::ready_reason() != ""
        || !scripts\apparition\runtime\enemy_damage::install())
        return false;

    // Capture the current requesting grant before publishing a live mode
    record = spawnstruct();
    record.owner = owner;
    record.menu_grant = owner.apparition_access;
    record.mode = mode;
    target.apparition_insta_kill = record;
    return true;
}
