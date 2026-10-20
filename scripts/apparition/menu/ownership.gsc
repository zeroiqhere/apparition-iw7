// Fixed chrome and current row groups are the only stored HUD owners

elements(hud)
{
    handles = [];
    foreach (element in hud.fixed_elements)
        handles[handles.size] = element;
    // Resolve row handles when needed so replacement leaves no stale registry
    foreach (row in hud.rows)
    {
        foreach (element in scripts\apparition\menu\row_elements::owned(row))
            handles[handles.size] = element;
    }
    foreach (element in scripts\apparition\menu\row_elements::owned(hud.spare))
        handles[handles.size] = element;
    return handles;
}

destroy_elements(handles)
{
    foreach (element in handles)
    {
        if (isDefined(element))
            element destroy();
    }
}

release_spare(hud)
{
    destroy_elements(scripts\apparition\menu\row_elements::owned(hud.spare));
    hud.spare = undefined;
}

release_rows(hud)
{
    foreach (row in hud.rows)
        destroy_elements(scripts\apparition\menu\row_elements::owned(row));
    hud.rows = [];
    // Source redraws leave detached outgoing elements with their fade timer
}

can_retire_spare(hud, row)
{
    // A former timer must never touch a newer outgoing group or a closed HUD
    return !hud.released && isDefined(hud.spare) && hud.spare == row;
}

retire_spare(hud, row, fade_time)
{
    self endon("disconnect");
    level endon("game_ended");
    // The outgoing group is captured by the caller before this worker starts
    wait fade_time;
    if (!can_retire_spare(hud, row))
        return;
    release_spare(hud);
}
