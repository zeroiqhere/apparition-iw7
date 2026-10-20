// Multi-Jump tracks each selected player's GoStand command through native events

configured(player)
{
    if (!isDefined(player))
        return false;

    return isDefined(player.MultiJump) && player.MultiJump;
}

advance(phase, grounded, held)
{
    result = spawnstruct();
    result.phase = phase;
    result.boost = false;

    // A detected hold completes on release even if the player has landed
    if (phase == "first_held" || phase == "boost_held")
    {
        if (held)
            return result;

        result.phase = "ready";
        result.boost = phase == "boost_held";
        return result;
    }

    // The worker and reducer produce only the four phases above
    if (grounded)
    {
        result.phase = "first";
        return result;
    }

    if (held)
        result.phase = phase == "first" ? "first_held" : "boost_held";
    else
        result.phase = phase;
    return result;
}

toggle(player)
{
    // Actor and private-session admission precede flags, events and workers
    if (scripts\apparition\runtime\context::actor_reason([player]) != ""
        || !scripts\apparition\runtime\context::supported())
        return false;

    if (configured(player))
    {
        player notify("apparition_stop_multi_jump");
        player.MultiJump = undefined;
        return true;
    }
    if (!scripts\apparition\runtime\jump_input::input_ready(player))
        return false;

    // Stop any older generation before starting one worker for this setting
    player notify("apparition_stop_multi_jump");
    player.MultiJump = true;
    player thread worker();
    return true;
}

worker()
{
    self endon("disconnect");
    self endon("apparition_stop_multi_jump");
    level endon("game_ended");
    phase = "first";

    for (;;)
    {
        if (!configured(self) || !scripts\apparition\runtime\jump_input::input_ready(self))
            return;
        if (!scripts\apparition\runtime\context::supported())
        {
            // Do not leave a checked request without its supported worker
            self.MultiJump = undefined;
            return;
        }
        if (scripts\apparition\runtime\context::actor_reason([self]) != "")
            return;

        receipt = self.apparition_jump_input;
        result = advance(phase, self isonground(), receipt.held);
        phase = result.phase;
        // No wait separates this pass's admission from the native velocity write
        if (result.boost && scripts\apparition\menu\life::is_alive(self))
            self setvelocity(self getvelocity() + (0, 0, 250));

        if (phase == "first_held" || phase == "boost_held")
            wait 0.01;
        else
            wait 0.05;
    }
}
