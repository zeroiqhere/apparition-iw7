// Source global settings require current Co-Host access independently of player life

reason(owner)
{
    // One gate checks the actual actor, private session, complete roster and saved role
    reason = scripts\apparition\runtime\player_control::lobby_reason(owner);
    if (reason != "")
        return reason;

    if (isDefined(level.gameended) && level.gameended)
        return "The game has ended";

    // Downed or spectating managers can still clear an already configured setting
    return "";
}
