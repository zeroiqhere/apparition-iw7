// Demi-God keeps Apparition's saved flag and requires directional feedback

enabled(player)
{
    if (!isDefined(player) || (!isstruct(player) && !isent(player)))
        return false;
    if (!isDefined(player.PlayerDemiGod))
        return false;

    return player.PlayerDemiGod;
}

reason(player, hook_active, feedback_ready)
{
    if (!isDefined(player) || (!isstruct(player) && !isent(player)))
        return "No current player is available";

    // Clearing a saved setting remains possible when its callback or FX is gone
    if (isDefined(player.PlayerDemiGod) && player.PlayerDemiGod)
        return "";
    if (!hook_active)
        return "Enable requires the active Apparition damage callback";
    if (!isDefined(feedback_ready) || !isstring(feedback_ready))
        return "Wait for directional damage feedback readiness";

    return feedback_ready;
}

toggle(player, hook_active, feedback_ready)
{
    if (reason(player, hook_active, feedback_ready) != "")
        return false;

    if (isDefined(player.PlayerDemiGod) && player.PlayerDemiGod)
    {
        player.PlayerDemiGod = undefined;
        return true;
    }

    // Clear conflicting God Mode only after the complete enable admission passes
    player.playerGodmode = undefined;
    player.PlayerDemiGod = true;
    return true;
}

feedback_reason(player)
{
    // Reject non-player actors before reading player fields or native effects
    reason = scripts\apparition\runtime\context::actor_reason([player]);
    if (reason != "")
        return reason;

    // A player ref can outlive the current roster, so verify current membership
    if (!isDefined(level.players) || !isarray(level.players))
        return "Wait for the current player roster";
    if (!scripts\apparition\runtime\context::in_roster(level.players, player))
        return "The player is no longer in the current roster";

    if (!isDefined(player.angles) || !isvector(player.angles))
        return "Wait for the player's native view angles";
    if (!isDefined(player.model) || !isstring(player.model) || player.model == "")
        return "Wait for the player's native model";
    if (!scripts\cp\utility::has_tag(player.model, "tag_eye"))
        return "Directional feedback is unavailable for this player model";

    if (!isDefined(level._effect) || !isarray(level._effect))
        return "Wait for native directional feedback effects";
    if (!isDefined(level._effect["vfx_melee_blood_spray"])
        || !isDefined(level._effect["vfx_blood_hit_left"])
        || !isDefined(level._effect["vfx_blood_hit_right"]))
        return "Wait for native directional feedback effects";

    return "";
}

feedback(player, direction)
{
    // Reject missing direction before actor, model, or effect lookups
    if (!isDefined(direction) || !isvector(direction))
        return false;

    if (feedback_reason(player) != "")
        return false;

    // Reuse IW7's player-relative direction and screen FX helpers
    direction_name = player scripts\cp\cp_hud_util::get_damage_direction(direction);
    player scripts\cp\cp_hud_util::play_basic_pain_overlay(direction_name);
    return true;
}
