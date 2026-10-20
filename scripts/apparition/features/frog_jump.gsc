// Each selected player's Frog grant owns one cancellable airborne boost worker

can_boost(held, grounded, stance, alive)
{
    return held && !grounded && isDefined(stance) && stance == "stand" && alive;
}

advance(waiting_landing, grounded, requested)
{
    result = spawnstruct();
    // Landing ends the source inner wait before another outer pass may boost
    result.boost = !waiting_landing && !grounded && requested;
    result.waiting_landing = (!grounded && waiting_landing) || result.boost;
    result.delay = result.waiting_landing ? 0.05 : 0.01;
    return result;
}

may_launch(owner_reason, linked, phased, teleport_enabled)
{
    // The native launch counter outlives its timed flung marker until landing
    return owner_reason == "" && !linked && !phased && teleport_enabled;
}

velocity(angles)
{
    if (!isDefined(angles) || !isvector(angles))
        return undefined;
    // Keep the source pitch effect on XY rather than normalizing a flat direction
    forward = anglesToForward(angles);
    return (forward[0] * 550, forward[1] * 550, 400);
}

configured(player)
{
    return isDefined(player) && isDefined(player.apparition_frog_jump);
}

is_current(player, record)
{
    return isDefined(record) && configured(player)
        && player.apparition_frog_jump == record;
}

probe(owner, target)
{
    result = spawnstruct();
    result.configured = false;
    result.reason = scripts\apparition\runtime\access::fun_reason(owner, target);
    if (result.reason != "")
        return result;

    result.configured = configured(target);
    // Removal stays available when a bound input observer is no longer readable
    if (!result.configured && !scripts\apparition\runtime\jump_input::input_ready(target))
        result.reason = "Wait for jump input setup";
    return result;
}

toggle(owner, target)
{
    current = probe(owner, target);
    if (current.reason != "")
        return false;
    if (current.configured)
        return release(target);

    record = spawnstruct();
    record.owner = owner;
    record.menu_grant = owner.apparition_access;
    target.apparition_frog_jump = record;
    target thread run(record);
    return true;
}

release(player, expected_record)
{
    if (!configured(player))
        return false;
    record = player.apparition_frog_jump;
    // A cancelled airborne generation cannot clear a later off/on replacement
    if (isDefined(expected_record) && record != expected_record)
        return false;
    player.apparition_frog_jump = undefined;
    if (isstruct(record))
        record notify("apparition_stop_frog_jump");
    return true;
}

run(record)
{
    self endon("disconnect");
    level endon("game_ended");
    record endon("apparition_stop_frog_jump");
    waiting_landing = false;
    while (is_current(self, record))
    {
        // Every landing-wait pass remains cancellable and rechecks the original grant
        if (scripts\apparition\runtime\access::fun_grant_reason(
            record.owner, self, record.menu_grant) != ""
            || !scripts\apparition\runtime\jump_input::input_ready(self))
        {
            release(self, record);
            return;
        }

        grounded = self isOnGround();
        launch = undefined;
        if (!waiting_landing && can_boost(self.apparition_jump_input.held, grounded,
            self getStance(), scripts\apparition\menu\life::is_alive(self)))
        {
            // Native slides, launches, rides, phase and links keep their own velocity
            reason = scripts\apparition\features\teleport::ownership_reason(self, level.gns_active);
            if (may_launch(reason, self isLinked(), self isInPhase(),
                self scripts\cp\utility::isteleportenabled()))
                launch = velocity(self getPlayerAngles());
        }

        next = advance(waiting_landing, grounded, isDefined(launch));
        // No wait separates this pass's authority and movement admission from its write
        if (next.boost)
            self setVelocity(launch);
        waiting_landing = next.waiting_landing;
        wait next.delay;
    }
}
