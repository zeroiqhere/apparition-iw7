// This native HUD pair has a player-owned lifetime independent of the menu

create(player, shape)
{
    if (!isDefined(player) || !isPlayer(player))
        return undefined;

    background = newClientHudElem(player);
    if (!isDefined(background))
        return undefined;

    place(background, 24, -60, shape.background_width, 14, (0, 0, 0), 1, 4);

    // Native shader widths stay positive while alpha represents an empty fill
    fill_width = shape.fill_width > 0 ? shape.fill_width : 1;
    fill_alpha = shape.fill_width > 0 ? 0.9 : 0;
    fill = newClientHudElem(player);
    if (!isDefined(fill))
    {
        background destroy();
        return undefined;
    }

    place(fill, 25, -61, fill_width, 12, (1, 1, 1), fill_alpha, 5);

    record = spawnstruct();
    record.background = background;
    record.fill = fill;
    return record;
}

paint(record, shape)
{
    if (!isDefined(record) || !isstruct(record)
        || !isDefined(record.background) || !isDefined(record.fill))
        return false;

    background = record.background;
    fill = record.fill;
    if (!isDefined(background.width) || background.width != shape.background_width)
        background setShader("white", shape.background_width, 14);

    // Hidden fill keeps its last positive shader width until health becomes visible
    if (shape.fill_width > 0 && (!isDefined(fill.width) || fill.width != shape.fill_width))
        fill setShader("white", shape.fill_width, 12);

    target_alpha = shape.fill_width > 0 ? 0.9 : 0;
    if (!isDefined(fill.alpha) || fill.alpha != target_alpha)
        fill.alpha = target_alpha;

    return true;
}

destroy_record(record)
{
    if (!isDefined(record) || !isstruct(record))
        return;

    background = record.background;
    fill = record.fill;
    // Drop the only owned references before native destruction can trigger cleanup
    record.background = undefined;
    record.fill = undefined;

    if (isDefined(fill))
        fill destroy();
    if (isDefined(background))
        background destroy();
}

place(element, x, y, width, height, color, alpha, sort)
{
    // The feature's measurement supplies bounded pixels and creation supplies a handle
    // Native lower-left anchors are independent of the original LUI canvas
    element.horzAlign = "left";
    element.vertAlign = "bottom";
    element.alignX = "left";
    element.alignY = "bottom";
    element.x = x;
    element.y = y;
    element.color = color;
    element.alpha = alpha;
    element.sort = sort;
    element.hideWhenInMenu = true;
    element.foreground = true;
    element.archived = false;
    element setShader("white", width, height);
}
