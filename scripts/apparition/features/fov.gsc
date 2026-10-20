// The original host slider writes cg_fov globally and leaves camera effects native

range()
{
    limits = spawnstruct();
    limits.minimum = 65;
    limits.maximum = 85;
    limits.increment = 1;
    return limits;
}

valid_value(value)
{
    limits = range();
    return isDefined(value) && isnumber(value)
        && value >= limits.minimum && value <= limits.maximum;
}

probe(owner)
{
    result = spawnstruct();
    result.current = undefined;
    // Admit the current actor, private session, saved access and game state first
    result.reason = scripts\apparition\features\server\context::reason(owner);
    if (result.reason != "")
        return result;
    if (!(owner isHost()))
    {
        result.reason = "Only the current host can change Field Of View Scale";
        return result;
    }
    if (getDvar("cg_fov") == "")
    {
        result.reason = "The native field-of-view setting is unavailable";
        return result;
    }
    current = getDvarFloat("cg_fov");
    limits = range();
    // The preview bounds are separate from the exact current native reading
    if (!isDefined(scripts\apparition\menu\numeric_slider::bound(current, limits.minimum, limits.maximum)))
    {
        result.reason = "Wait for a numeric native field-of-view setting";
        return result;
    }
    result.current = current;
    return result;
}

request(owner, value)
{
    if (!valid_value(value))
        return false;
    current = probe(owner);
    if (current.reason != "")
        return false;
    // Use repeats the source setter even when the requested value already matches
    setDvar("cg_fov", value);
    updated = getDvarFloat("cg_fov");
    // Readback confirms the setting rather than a rendered camera change
    return isDefined(updated) && isnumber(updated) && updated == value;
}
