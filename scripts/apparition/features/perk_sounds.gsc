// Perk audio requests use native aliases without entering the purchase routine

valid_selection(id, kind)
{
    if (!isDefined(id) || !isstring(id)
        || !isDefined(kind) || !isstring(kind) || (kind != "Jingle" && kind != "Quote"))
        return false;
    // A raw alias cannot bypass the shared map catalog
    foreach (perk in scripts\apparition\maps\spaceland\perks::catalog())
    {
        if (perk.id == id)
            return true;
    }
    return false;
}

alias_reason(alias)
{
    // Missing voice data disables only the quote that depends on it
    if (!isDefined(alias) || !isstring(alias) || alias == "" || !soundexists(alias))
        return "Native sound alias is unavailable";
    return "";
}

probe(owner, target)
{
    reason = scripts\apparition\runtime\access::fun_reason(owner, target);
    // No native machine, roster-size or voice read can precede this actor gate
    if (reason != "")
    {
        result = spawnstruct();
        result.reason = reason;
        result.entries = [];
        return result;
    }

    result = scripts\apparition\maps\spaceland\perk_sounds::inspect(level,
        level.players.size < 2, target.vo_prefix);
    if (result.reason != "")
        return result;
    foreach (entry in result.entries)
    {
        entry.jingle_reason = alias_reason(entry.jingle);
        entry.quote_reason = alias_reason(entry.quote);
    }
    return result;
}

request(owner, target, id, kind)
{
    if (!valid_selection(id, kind))
        return false;
    // Resolve current placement, voice and alias readiness again at selection time
    current = probe(owner, target);
    if (current.reason != "")
        return false;
    foreach (entry in current.entries)
    {
        if (entry.id != id)
            continue;
        reason = kind == "Jingle" ? entry.jingle_reason : entry.quote_reason;
        if (reason != "")
            return false;
        alias = kind == "Jingle" ? entry.jingle : entry.quote;

        // Preserve the source event and player receiver without a completion worker
        target notify("sndDone");
        target playSound(alias, "sndDone");
        // Submission does not confirm audibility or native playback completion
        return true;
    }
    return false;
}
