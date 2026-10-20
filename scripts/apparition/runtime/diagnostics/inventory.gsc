// Optional inventory details share the ammo observer's host and lifetime checks
// Raw method IDs distinguish two native methods with the same decoded name

sample()
{
    // Stock CP uses these methods on players, including last-stand transitions
    if (!isDefined(self.sessionstate) || self.sessionstate != "playing")
        return "inventory=skipped(session)";
    // Spectator inventory queries lack a checked stock precedent
    if (isDefined(self.spectating) && self.spectating)
        return "inventory=skipped(spectating)";

    list8173 = self _meth_8173();
    list8176 = self _meth_8176();
    primaries = self getweaponslistprimaries();
    // Names describe the queried IDs without claiming complete list membership
    return "inventory8173=" + describe_list(list8173)
        + " inventory8176=" + describe_list(list8176)
        + " primaries=" + describe_list(primaries)
        + " script_primary=" + describe_item(self.powerprimarygrenade)
        + " script_secondary=" + describe_item(self.powersecondarygrenade)
        + " script_special=" + describe_item(self.specialoffhandgrenade);
}

describe_list(values)
{
    if (!isDefined(values) || !isarray(values))
        return "unknown";
    text = "count=" + values.size + "[";
    // Keep indices and duplicates so native overlap and order remain visible
    for (index = 0; index < values.size && index < 16; index++)
    {
        if (index)
            text += ",";
        text += index + "=" + describe_item(values[index]);
    }
    // A bounded prefix must never be presented as a complete native result
    if (values.size > 16)
        text += ",truncated";
    return text + "]";
}

describe_item(value)
{
    // Missing script markers are not evidence of an empty native offhand slot
    if (!isDefined(value))
        return "<undefined>";
    if (!isstring(value))
        return "<non-string>";
    return value;
}
