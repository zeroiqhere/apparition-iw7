// HUD visibility preserves Apparition's saved intent and client omnvar command

configured(player)
{
    if (!isDefined(player))
        return false;

    return isDefined(player.DisablePlayerHUD) && player.DisablePlayerHUD;
}

toggle(player)
{
    // Validate the current actor before changing its flag or client omnvar
    if (scripts\apparition\runtime\context::actor_reason([player]) != "")
        return false;

    requested = !configured(player);
    if (requested)
        player.DisablePlayerHUD = true;
    else
        player.DisablePlayerHUD = undefined;

    // The saved flag records the command, not a later native UI value
    player setclientomnvar("ui_hide_hud", requested ? 1 : 0);
    return true;
}
