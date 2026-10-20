// One player-owned record keeps the source coordinate display independent of menus

valid_position(value)
{
    return isDefined(value) && isVector(value);
}

configured(owner)
{
    // Presence also permits removal of an older malformed configuration
    return isDefined(owner) && isDefined(owner.apparition_origin_display);
}

is_current(owner, record)
{
    return isDefined(record) && configured(owner)
        && owner.apparition_origin_display == record;
}

reason(owner)
{
    // Actor admission precedes native role methods and saved display reads
    reason = scripts\apparition\runtime\context::actor_reason([owner]);
    if (reason != "")
        return reason;
    if (!scripts\apparition\runtime\access::can_open(owner))
        return "Show Origin requires a current player in a private Spaceland match";
    if (!(owner isHost()))
        return "Only the current host can use Show Origin";
    return "";
}

probe(owner)
{
    result = spawnstruct();
    result.configured = false;
    result.reason = reason(owner);
    if (result.reason != "")
        return result;
    result.configured = configured(owner);
    // Turning the owned display off does not require a readable position
    if (!result.configured && !valid_position(owner.origin))
        result.reason = "Wait for native player coordinates";
    return result;
}

toggle(owner)
{
    current = probe(owner);
    if (current.reason != "")
        return false;
    if (current.configured)
        return release(owner);
    record = scripts\apparition\menu\origin_hud::create(owner);
    if (!isDefined(record))
        return false;
    // All three handles must exist before this record becomes the current owner
    owner.apparition_origin_display = record;
    owner thread run(record);
    return true;
}

release(owner)
{
    if (!configured(owner))
        return false;
    retire(owner, owner.apparition_origin_display);
    return true;
}

retire(owner, record)
{
    if (!isDefined(record))
        return;
    // A stale worker may destroy its own handles but cannot clear a replacement
    if (is_current(owner, record))
        owner.apparition_origin_display = undefined;
    scripts\apparition\menu\origin_hud::destroy_record(record);
    if (isstruct(record))
        record notify("apparition_stop_origin_display");
}

run(record)
{
    self endon("disconnect");
    level endon("game_ended");
    record endon("apparition_stop_origin_display");
    while (is_current(self, record))
    {
        // The source display persists through death and menu closure
        if (reason(self) != "")
            break;
        position = self.origin;
        if (!scripts\apparition\menu\origin_hud::paint(record, position))
            break;
        wait 0.01;
    }
    // Lifecycle owners also release handles when an endon stops this worker
    retire(self, record);
}
