// Direct current-weapon removal keeps source exclusions and native CP bookkeeping

role_reason(access)
{
    return scripts\apparition\runtime\access::rank(access) >= 3
        ? "" : "VIP access is required for Weaponry";
}

access_reason(owner, target)
{
    reason = scripts\apparition\runtime\player_control::reason(owner, target);
    if (reason != "")
        return reason;
    return role_reason(scripts\apparition\runtime\access::role_from_actor(owner));
}

valid_name(value)
{
    // Native no-weapon and absent names cannot supply an inventory operation
    return isDefined(value) && isstring(value) && value != "" && value != "none";
}

weapon_reason(weapon, base_melee)
{
    if (!valid_name(weapon))
        return "No current weapon is available to remove";
    if (!valid_name(base_melee))
        return "Wait for the native base melee weapon";
    // The source preserves base melee and knife names without a broader melee classifier
    if (weapon == base_melee || isSubStr(weapon, "_knife"))
        return "Base melee and knife weapons are preserved";
    return "";
}

temporary_reason(player, gns_active)
{
    // Reuse the map's canonical native inventory ownership flags
    if (scripts\apparition\maps\spaceland\equipment::blocked(player)
        || (isDefined(gns_active) && gns_active))
        return "Wait until native Last Stand, arcade or temporary inventory handling ends";
    // last_weapon is written before the supercard cleanup worker starts
    if ((isDefined(player.isusingsupercard) && player.isusingsupercard)
        || isDefined(player.mpsuperpreviousweapon) || isDefined(player.last_weapon))
        return "Wait until the native temporary card weapon is released";
    if (isDefined(player.wor_phase_shift) && player.wor_phase_shift)
        return "Wait until native phase shifting ends";
    return "";
}

ephemeral_reason(current_base, ephemeral)
{
    if (!isDefined(ephemeral))
        return "";
    if (!isstring(ephemeral) || ephemeral == "")
        return "Wait for valid native temporary weapon ownership";
    // An unrelated held weapon is not owned by this delayed downgrade
    if (current_base == ephemeral)
        return "Wait until the held weapon's native temporary upgrade ends";
    return "";
}

bookkeeping_reason(player, last_stand_weapons)
{
    // The stock updater reads these fields even when no replacement pistol is owned
    if (!isDefined(player) || !valid_name(player.last_stand_pistol)
        || !valid_name(player.default_starting_pistol)
        || !isDefined(player.weapon_build_models) || !isarray(player.weapon_build_models)
        || !isDefined(player.weaponkitinitialized) || !isnumber(player.weaponkitinitialized)
        || player.weaponkitinitialized != 1
        || !isDefined(last_stand_weapons) || !isarray(last_stand_weapons))
        return "Wait for native weapon and Last Stand loadout initialization";
    return "";
}

probe(owner, target)
{
    result = spawnstruct();
    result.reason = access_reason(owner, target);
    if (result.reason != "")
        return result;
    if ((isDefined(level.gameended) && level.gameended)
        || !scripts\apparition\menu\life::is_alive(target))
    {
        result.reason = "An active game and living selected player are required";
        return result;
    }
    result.reason = temporary_reason(target, level.gns_active);
    if (result.reason != "")
        return result;
    // Native linkage and an in-flight switch retain control of the held slot
    if (target isLinked() || target isSwitchingWeapon())
    {
        result.reason = "Wait until native linkage and weapon switching end";
        return result;
    }
    result.weapon = target getCurrentWeapon();
    result.reason = weapon_reason(result.weapon, target.default_starting_melee_weapon);
    if (result.reason != "")
        return result;
    if (isDefined(target.ephemeralweapon))
    {
        result.reason = ephemeral_reason(getWeaponBaseName(result.weapon), target.ephemeralweapon);
        if (result.reason != "")
            return result;
    }
    result.reason = bookkeeping_reason(target, level.last_stand_weapons);
    return result;
}

take_current(owner, target)
{
    // A fresh probe resolves permission, native ownership and the actual held weapon
    current = probe(owner, target);
    if (current.reason != "")
        return false;
    target takeWeapon(current.weapon);
    // This synchronous stock repair changes only the tracked Last Stand pistol
    target scripts\cp\utility::updatelaststandpistol();
    return true;
}
