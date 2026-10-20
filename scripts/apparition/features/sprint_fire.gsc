// Sprint-fire reads and toggles the CP utility's perk mirror

configured(player)
{
    if (!isDefined(player))
        return false;

    // The CP helper reports script-managed state, not a general native getter
    return player scripts\cp\utility::_hasperk("specialty_sprintfire");
}

toggle(player)
{
    // Reject invalid actors before checking mode support or reading perk state
    if (scripts\apparition\runtime\context::actor_reason([player]) != "")
        return false;

    // Keep the native perk write inside the supported private Zombies session
    if (!scripts\apparition\runtime\context::supported())
        return false;

    // Keep the CP mirror and native perk bit on the same wrapper path
    if (configured(player))
        player scripts\cp\utility::_unsetperk("specialty_sprintfire");
    else
        player scripts\cp\utility::giveperk("specialty_sprintfire");

    // Success means the source command path was applied, not native acknowledgement
    return true;
}
