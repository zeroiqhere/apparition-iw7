// Per-player crosshair text owns one native HUD handle and one theme worker

choices(name)
{
    // Keep the source slider order stable before adding its optional player name
    values = ["Disable", "+", "@", "x", "o", "> <", "CF4_99", "Extinct",
        "Daltax", "GBP", "AOC", "Apparition", "discord.gg/apparitionbo3"];
    cleaned_name = scripts\apparition\player_name::clean(name);
    if (cleaned_name != "")
        values[values.size] = cleaned_name;
    return values;
}

valid_choice(text, name)
{
    if (!isDefined(text) || !isstring(text))
        return false;

    foreach (choice in choices(name))
    {
        if (text == choice)
            return true;
    }
    return false;
}

configured(player)
{
    if (!isDefined(player) || !isDefined(player.apparition_crosshair))
        return "Disable";

    record = player.apparition_crosshair;
    if (!isstruct(record) || !isDefined(record.text) || !isstring(record.text))
        return "Unknown";

    return record.text;
}

operation(record, text)
{
    if (text == "Disable")
        return "Disable";
    if (!isDefined(record) || !isstruct(record) || !isDefined(record.element))
        return "Create";
    return "Update";
}

set(player, text)
{
    // Reject non-players before reading a name, record, or native HUD field
    if (scripts\apparition\runtime\context::actor_reason([player]) != "")
        return false;
    if (!scripts\apparition\runtime\context::supported())
        return false;

    // IW7 player snapshots expose the current display name through the name field
    name = player.name;
    if (!valid_choice(text, name))
        return false;

    record = isDefined(player.apparition_crosshair) ? player.apparition_crosshair : undefined;
    action = operation(record, text);
    if (action == "Disable")
    {
        release(player);
        return true;
    }

    color = scripts\apparition\menu\crosshair_hud::tint(
        player.apparition_layout, level.RGBFadeColor);

    if (action == "Update")
    {
        if (!scripts\apparition\menu\crosshair_hud::write(record.element, text))
            return false;
        record.text = text;
        scripts\apparition\menu\crosshair_hud::paint(record.element, color);
        return true;
    }

    // Allocate first so a failed create leaves the current record untouched
    element = scripts\apparition\menu\crosshair_hud::create(player, text, color);
    if (!isDefined(element))
        return false;

    release(player);
    next_record = spawnstruct();
    next_record.text = text;
    next_record.element = element;
    player.apparition_crosshair = next_record;
    player thread follow_theme(next_record);
    return true;
}

release(player)
{
    if (!isDefined(player) || !isDefined(player.apparition_crosshair))
        return;

    record = player.apparition_crosshair;
    player notify("apparition_stop_crosshair");
    retire(player, record);
}

retire(player, record)
{
    if (!isDefined(record))
        return;

    // A stale worker may only clear the record it still owns
    if (isDefined(player) && isDefined(player.apparition_crosshair)
        && player.apparition_crosshair == record)
        player.apparition_crosshair = undefined;

    // Clear malformed saved state without treating it as an owned HUD handle
    if (!isstruct(record))
        return;

    if (isDefined(record.element))
        scripts\apparition\menu\crosshair_hud::destroy_element(record.element);
    record.element = undefined;
}

follow_theme(record)
{
    self endon("disconnect");
    self endon("apparition_stop_crosshair");
    level endon("game_ended");

    for (;;)
    {
        // Retire only this worker's handle if a newer record took ownership
        if (!isDefined(self.apparition_crosshair)
            || self.apparition_crosshair != record)
        {
            retire(self, record);
            return;
        }

        // Keep saved text so a later valid choice can recreate a missing element
        if (!isDefined(record.element))
            return;

        color = scripts\apparition\menu\crosshair_hud::tint(
            self.apparition_layout, level.RGBFadeColor);
        scripts\apparition\menu\crosshair_hud::paint(record.element, color);
        wait 0.01;
    }
}
