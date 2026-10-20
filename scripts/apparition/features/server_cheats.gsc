// The source host control toggles the existing global native cheat setting

valid_value(value)
{
    // Missing settings must not become a newly created cheat Dvar
    return isDefined(value) && isstring(value) && (value == "0" || value == "1");
}

probe(owner)
{
    result = spawnstruct();
    result.current = undefined;
    // Admit the current actor, private session, roster and menu access first
    result.reason = scripts\apparition\features\server\context::reason(owner);
    if (result.reason != "")
        return result;
    if (!(owner isHost()))
    {
        result.reason = "Only the current host can change SV Cheats";
        return result;
    }
    current = getDvar("sv_cheats");
    if (!valid_value(current))
    {
        result.reason = "The native SV Cheats setting is unavailable or unreadable";
        return result;
    }
    result.current = current;
    return result;
}

toggle(owner)
{
    // Resolve the live setting again instead of trusting the row's captured checkbox
    current = probe(owner);
    if (current.reason != "")
        return false;
    requested = current.current == "1" ? "0" : "1";
    setDvar("sv_cheats", requested);
    // Readback confirms the setting, not acceptance of every protected command
    return getDvar("sv_cheats") == requested;
}
