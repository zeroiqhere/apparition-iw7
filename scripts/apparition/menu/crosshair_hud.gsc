// This client-owned text element has its own lifetime outside the menu HUD pool

create(player, text, color)
{
    if (!isDefined(player))
        return undefined;
    element = newClientHudElem(player);
    if (!isDefined(element))
        return undefined;

    // Native center anchors avoid treating BO3 LUI coordinates as IW7 HUD units
    element.horzAlign = "center";
    element.vertAlign = "middle";
    element.alignX = "center";
    element.alignY = "middle";
    element.x = 0;
    element.y = 0;
    element.font = "default";
    element.fontScale = 1;
    element.sort = 5;
    element.alpha = 1;
    element.color = color;
    element.hideWhenInMenu = true;
    element.foreground = true;
    element.archived = false;
    element setText(text);
    return element;
}

write(element, text)
{
    if (!isDefined(element))
        return false;
    element setText(text);
    // The return reports a command, not confirmation that the client drew it
    return true;
}

tint(layout, rainbow)
{
    if (isDefined(layout) && isstruct(layout))
    {
        if (isDefined(layout.smooth_rainbow) && layout.smooth_rainbow
            && isDefined(rainbow) && isvector(rainbow))
            return rainbow;
        if (isDefined(layout.accent) && isvector(layout.accent))
            return layout.accent;
    }
    return scripts\apparition\menu\customization\palette::color("Dodger Blue");
}

paint(element, color)
{
    if (!isDefined(element))
        return;
    // Crosshair colors change immediately, so no separate fade-target cache is needed
    if (element.color != color)
        element.color = color;
}

destroy_element(element)
{
    if (isDefined(element))
        element destroy();
}
