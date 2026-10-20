// Invisibility preserves Apparition's saved flag and direct visibility calls

configured(player)
{
    if (!isDefined(player))
        return false;

    return isDefined(player.Invisibility) && player.Invisibility;
}

toggle(player)
{
    // Validate the actor before changing its flag or native visibility
    if (scripts\apparition\runtime\context::actor_reason([player]) != "")
        return false;

    // The saved flag records this command, not a later native visibility state
    requested = !configured(player);
    if (requested)
    {
        player.Invisibility = true;
        // Portal and camera scripts use this player-specific native pair
        player playerhide();
    }
    else
    {
        player.Invisibility = undefined;
        player playershow();
    }

    return true;
}
