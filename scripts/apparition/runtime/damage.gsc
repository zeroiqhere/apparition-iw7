// The saved callback belongs only to this wrapper
// Reusing another menu's saved callback slot can cause recursive delegation

install()
{
    if (isDefined(level.apparition_saved_damage))
        return active();

    if (!isDefined(level.callbackPlayerDamage))
        return false;

    level.apparition_saved_damage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::on_damage;
    return true;
}

active()
{
    return isDefined(level.callbackPlayerDamage)
        && level.callbackPlayerDamage == ::on_damage;
}

on_damage(inflictor, attacker, amount, flags, means, weapon, point, direction, location, time_offset, native_arg_10, native_arg_11)
{
    // The native callback remains responsible for all unblocked damage behavior
    route(self, level.apparition_saved_damage,
        inflictor, attacker, amount, flags, means, weapon, point, direction, location, time_offset, native_arg_10, native_arg_11,
        scripts\apparition\runtime\context::supported(), scripts\apparition\features\demi_god::feedback);
}

route(player, original, inflictor, attacker, amount, flags, means, weapon, point, direction, location, time_offset, native_arg_10, native_arg_11, session_allowed, demi_feedback)
{
    // A missing direction must not trigger the native helper's random fallback
    if (session_allowed && scripts\apparition\features\demi_god::enabled(player))
    {
        if (isDefined(direction) && isvector(direction) && isDefined(demi_feedback))
            [[demi_feedback]](player, direction);
        return;
    }

    if (session_allowed && isDefined(player.playerGodmode) && player.playerGodmode)
        return;

    // IW7 owns the explosive category; no copied BO3 damage-kind list is used
    if (session_allowed && scripts\apparition\features\explosive_protection::enabled(player)
        && isDefined(means) && isexplosivedamagemod(means))
        return;

    // The last two native values are opaque and must pass through unchanged
    player [[original]](inflictor, attacker, amount, flags, means, weapon, point, direction, location, time_offset, native_arg_10, native_arg_11);
}
