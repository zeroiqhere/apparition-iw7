// The native last-stand callback remains responsible for every normal effect

install()
{
    if (isDefined(level.apparition_saved_perk_laststand))
        return active();
    // Only the audited normal Zombies callback is replaced
    if (!isDefined(level.laststand_enter_gamemodespecificaction)
        || level.laststand_enter_gamemodespecificaction != scripts\cp\gametypes\zombie::_id_13F1F)
        return false;
    level.apparition_saved_perk_laststand = level.laststand_enter_gamemodespecificaction;
    level.laststand_enter_gamemodespecificaction = ::on_laststand;
    return true;
}

active()
{
    return isDefined(level.laststand_enter_gamemodespecificaction)
        && level.laststand_enter_gamemodespecificaction == ::on_laststand;
}

on_laststand(player)
{
    route(player, level.apparition_saved_perk_laststand,
        scripts\apparition\runtime\context::supported());
}

route(player, original, session_allowed)
{
    // This player marker brackets native GNS perk removal and restoration
    // Global arcade activity and native protection alone can still have normal inventory
    if (session_allowed && (!isDefined(player.playing_ghosts_n_skulls) || !player.playing_ghosts_n_skulls))
        scripts\apparition\features\perk_retention::capture(player);
    // Keep the inherited receiver as well as the exact player argument
    [[original]](player);
}
