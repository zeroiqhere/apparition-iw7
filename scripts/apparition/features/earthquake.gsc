// The source sends one timed global camera quake around the selected player's position

parameters(origin)
{
    result = spawnstruct();
    result.reason = "Wait for the selected player's current position";
    if (!isDefined(origin) || !isvector(origin))
        return result;
    // This is the source's single parameter policy, shared by inspection and execution
    result.reason = "";
    result.strength = 1;
    result.duration = 15;
    result.origin = origin;
    result.radius = 750;
    return result;
}

probe(owner, target)
{
    // Shared admission precedes the selected player's position read
    reason = scripts\apparition\runtime\access::fun_reason(owner, target);
    if (reason != "")
    {
        result = spawnstruct();
        result.reason = reason;
        return result;
    }
    return parameters(target.origin);
}

request(owner, target)
{
    // Dispatch resolves the center again rather than replaying the menu snapshot
    current = probe(owner, target);
    if (current.reason != "")
        return false;
    earthquake(current.strength, current.duration, current.origin, current.radius);
    // The native call has no receipt for which nearby clients displayed the effect
    return true;
}
