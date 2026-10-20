// Native Dvars retain one settings snapshot per known player identity

key(identity)
{
    if (!isDefined(identity) || !isString(identity) || identity.size == 0 || identity.size > 64)
        return undefined;
    nonzero = false;
    for (index = 0; index < identity.size; index++)
    {
        character = getSubStr(identity, index, index + 1);
        if (!isSubStr("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", character))
            return undefined;
        nonzero = nonzero || character != "0";
    }
    // Missing identities never fall back to a shared player-slot or name key
    return nonzero ? "apparition_iw_settings_" + identity : undefined;
}

load(owner)
{
    restored = undefined;
    if (isDefined(owner) && isPlayer(owner))
    {
        name = key(owner getXUID());
        if (isDefined(name))
            restored = scripts\apparition\menu\customization\settings::decode(getDvar(name));
    }
    // Allocate fallback defaults only when a complete restored layout is absent
    return isDefined(restored) ? restored : scripts\apparition\menu\layout::defaults();
}

save(owner)
{
    if (!isDefined(owner) || !isPlayer(owner) || !isDefined(owner.apparition_layout))
        return false;
    name = key(owner getXUID());
    if (!isDefined(name))
        return false;
    record = scripts\apparition\menu\customization\settings::encode(owner.apparition_layout);
    if (!isDefined(record))
        return false;
    // A single native write cannot expose an old/new mixture of separate fields
    setDvar(name, record);
    return getDvar(name) == record;
}
