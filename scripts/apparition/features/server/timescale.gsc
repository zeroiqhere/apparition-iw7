// Timescale is a global dvar setting available to current Co-Hosts and Host

values()
{
    return [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];
}

valid_value(value)
{
    if (!isDefined(value) || !isnumber(value))
        return false;

    foreach (choice in values())
    {
        if (value == choice)
            return true;
    }

    return false;
}

probe(owner)
{
    result = spawnstruct();
    result.reason = "";
    result.current = undefined;

    // Check the current actor, verification and role before reading any global setting
    result.reason = scripts\apparition\features\server\context::reason(owner);
    if (result.reason != "")
        return result;

    if (getDvar("timescale") == "")
    {
        result.reason = "The native timescale setting is unavailable";
        return result;
    }

    current = getDvarFloat("timescale");
    if (!isDefined(current) || !isnumber(current) || !(current >= 0.001 && current <= 1000.0))
    {
        result.reason = "The native timescale setting is invalid";
        return result;
    }

    result.current = current;
    return result;
}

request(owner, value)
{
    if (!valid_value(value))
        return false;

    result = probe(owner);
    if (result.reason != "")
        return false;

    // Preserve native setting when the selected value already matches
    if (result.current == value)
        return true;

    setDvar("timescale", value);
    updated = getDvarFloat("timescale");
    return isDefined(updated) && isnumber(updated) && updated == value;
}
