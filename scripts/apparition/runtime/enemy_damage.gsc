// This provider owns the optional native zombie damage callback only while bound

binding_reason(slot)
{
    if (!isDefined(slot) || slot == ::on_damage)
        return "";
    return "The native zombie damage callback is owned by another script";
}

ready_reason()
{
    return binding_reason(level.onzombiedamage_func);
}

active()
{
    return isDefined(level.onzombiedamage_func)
        && level.onzombiedamage_func == ::on_damage;
}

install()
{
    // Recheck immediately before assignment so a foreign callback is never replaced
    if (ready_reason() != "")
        return false;
    if (!active())
        level.onzombiedamage_func = ::on_damage;
    return active();
}

release()
{
    // Game-end cleanup clears only the exact function pointer installed here
    if (!active())
        return false;
    level.onzombiedamage_func = undefined;
    return true;
}

on_damage(inflictor, attacker, amount, flags, means, weapon, point, direction, hit_location, time_offset, native_arg_10, native_arg_11)
{
    // The native slot is called only for an agent damage event
    if (!isDefined(self.agent_type) || !isstring(self.agent_type)
        || self.agent_type == "zombie_brute" || self.agent_type == "zombie_grey")
        return amount;
    if (!isDefined(attacker) || !isPlayer(attacker))
        return amount;

    record = attacker.apparition_insta_kill;
    mode = scripts\apparition\features\insta_kill::record_mode(record);
    if (mode != "All" && mode != "Melee")
        return amount;
    if (mode == "Melee" && (!isDefined(means) || !isstring(means) || means != "MOD_MELEE"))
        return amount;

    // A saved setting stays effective only while its requesting owner is authorized
    if (scripts\apparition\runtime\access::fun_grant_reason(
        record.owner, attacker, record.menu_grant) != "")
        return amount;

    is_bomber = isDefined(self.is_suicide_bomber) && self.is_suicide_bomber;
    special_scale = undefined;
    if (is_bomber && isDefined(attacker.special_zombie_damage))
        special_scale = attacker.special_zombie_damage;

    return scripts\apparition\features\insta_kill::damage_amount(
        mode, means, self.agent_type, is_bomber, amount, self.health, self.maxhealth, special_scale);
}
