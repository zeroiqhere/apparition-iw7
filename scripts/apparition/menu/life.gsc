// Menu life uses Apparition's native-life and non-spectator session rule

active(native_alive, session_state)
{
    return native_alive && isDefined(session_state) && session_state != "spectator";
}

is_alive(player)
{
    if (!isDefined(player))
        return false;
    // Keep one rule for input routing, visible rows and delayed menu actions
    return active(isAlive(player), player.sessionstate);
}
