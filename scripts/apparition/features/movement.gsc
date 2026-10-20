// Movement Speed preserves Apparition's direct scale override

scales()
{
    return [0, 0.5, 1, 1.5, 2, 2.5, 3];
}

valid_scale(scale)
{
    if (!isDefined(scale) || !isnumber(scale))
        return false;

    // Exact finite menu choices also reject NaN and either infinity
    foreach (supported in scales())
    {
        if (scale == supported)
            return true;
    }

    return false;
}

configured_scale(player)
{
    if (!isDefined(player))
        return "Unknown";
    if (!isDefined(player.MovementSpeed))
        return 1;
    if (!valid_scale(player.MovementSpeed))
        return "Unknown";

    return player.MovementSpeed;
}

set_scale(player, scale)
{
    // Reject the value and complete target before the first state change
    if (!valid_scale(scale))
        return false;
    if (scripts\apparition\runtime\context::actor_reason([player]) != "")
        return false;

    player notify("apparition_stop_movement_scale");
    if (scale == 1)
        player.MovementSpeed = undefined;
    else
        player.MovementSpeed = scale;
    player thread scale_worker(scale);
    return true;
}

scale_worker(scale)
{
    self endon("disconnect");
    self endon("apparition_stop_movement_scale");
    level endon("game_ended");

    for (;;)
    {
        // The session can change after dispatch and before this native call
        if (!scripts\apparition\runtime\context::supported())
        {
            // Unsupported-session cleanup cannot erase a newer selection
            if (scale != 1 && isDefined(self.MovementSpeed) && self.MovementSpeed == scale)
                self.MovementSpeed = undefined;
            return;
        }

        // A cleared or replaced selection stops this worker before replay
        if (scale != 1 && (!isDefined(self.MovementSpeed) || self.MovementSpeed != scale))
            return;

        self setmovespeedscale(scale);
        if (scale == 1)
            return;

        wait 0.5;
    }
}
