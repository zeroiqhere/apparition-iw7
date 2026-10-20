// The damage callback consumes this original Apparition setting
// This option stays independent from the two God Mode flags

enabled(player)
{
    return isDefined(player) && isDefined(player.NoExplosiveDamage)
        && player.NoExplosiveDamage;
}

reason(player, hook_active)
{
    if (!isDefined(player))
        return "No current player is available";
    // Hook loss must still allow clearing an existing saved setting
    if (!hook_active && !enabled(player))
        return "Enable requires the active Apparition damage callback";
    return "";
}

toggle(player, hook_active)
{
    if (reason(player, hook_active) != "")
        return false;

    player.NoExplosiveDamage = enabled(player) ? undefined : true;
    return true;
}
