// Player messages use the source sender prefix and current recipients

format_text(name, text)
{
    // Text admission belongs to send before any player or native state is read
    return "^2" + scripts\apparition\player_name::clean(name) + ": ^7" + text;
}

reason(owner, target, lobby)
{
    if (!isDefined(lobby) || !isnumber(lobby) || !(lobby == 0 || lobby == 1))
        return "Wait for a valid player message route";
    // Both source pages require manager access, including a self-selected recipient
    blocked = scripts\apparition\runtime\player_control::lobby_reason(owner);
    if (blocked != "" || lobby)
        return blocked;
    return scripts\apparition\runtime\player_control::reason(owner, target);
}

send(owner, target, text, lobby)
{
    // A canceled, empty or malformed keyboard value never reaches native admission
    if (!scripts\apparition\menu\keyboard_model::valid_text(text)
        || reason(owner, target, lobby) != "")
        return false;

    // All Players excludes the sender, as in Apparition, and includes the current host
    targets = lobby ? scripts\apparition\runtime\context::other_players(level.players, owner) : [target];
    submitted = false;
    foreach (recipient in targets)
    {
        // The detached list cannot authorize a departed player or a changed requester
        if (reason(owner, recipient, lobby) != "")
            break;
        if (!scripts\apparition\runtime\context::in_roster(level.players, recipient)
            || (lobby && recipient == owner))
            continue;
        message = format_text(owner.name, text);
        recipient iprintlnbold(message);
        submitted = true;
    }
    // Submission has no native delivery receipt and never changes saved message mode
    return submitted;
}
