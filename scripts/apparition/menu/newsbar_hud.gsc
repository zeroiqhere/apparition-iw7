// The Newsbar uses one native global rectangle and text element for the level

create()
{
    font_height = level.fontheight;
    // Stock CP font height must fit the source integer metadata before allocation
    if (!isDefined(font_height) || !isnumber(font_height)
        || !(font_height > 0 && font_height < 2147483648.0))
        return undefined;
    background = newHudElem();
    if (!isDefined(background))
        return undefined;

    // Keep the source fullscreen bar with an explicit IW7 top-screen origin
    background.elemType = "icon";
    background.hidden = false;
    background.horzAlign = "fullscreen";
    background.vertAlign = "top";
    background.alignX = "center";
    background.alignY = "middle";
    background.x = 320;
    background.y = 8;
    background.sort = 1;
    background.alpha = 0.6;
    background.color = (0, 0, 0);
    background.hideWhenInMenu = true;
    background.foreground = true;
    background.archived = true;
    background setShader("white", 1000, 18);

    // Failure of the second allocation must not leave a global bar behind
    text = newHudElem();
    if (!isDefined(text))
    {
        background destroy();
        return undefined;
    }

    // The IW7 origin is explicit; native rendering still needs visual comparison
    text.elemType = "font";
    text.hidden = false;
    text.horzAlign = "left";
    text.vertAlign = "top";
    text.alignX = "center";
    text.alignY = "middle";
    text.x = 320;
    text.y = -15;
    text.font = "default";
    text.fontScale = 1;
    text.width = 0;
    text.height = int(font_height);
    text.sort = 3;
    text.alpha = 1;
    text.color = (1, 1, 1);
    text.hideWhenInMenu = true;
    text.foreground = true;
    text.archived = true;
    text setText("");

    record = spawnstruct();
    record.background = background;
    record.text = text;
    return record;
}

cycle(record, message)
{
    text = record.text;
    if (!isDefined(text))
        return false;

    // Source hudMoveY waits for the entrance before starting the scale and dwell
    text setText(message);
    text moveOverTime(0.55);
    text.y = 8;
    wait 0.55;
    if (!isDefined(text))
        return false;

    text changeFontScaleOverTime(0.75);
    text.fontScale = 1.2;
    wait 5;
    if (!isDefined(text))
        return false;

    // The scale reset finishes before the outgoing movement begins
    text changeFontScaleOverTime(0.3);
    text.fontScale = 1;
    wait 0.3;
    if (!isDefined(text))
        return false;

    text moveOverTime(0.55);
    text.y = -15;
    wait 0.55;
    return isDefined(text);
}

destroy_record(record)
{
    if (!isDefined(record) || !isstruct(record))
        return;

    background = record.background;
    text = record.text;
    // Consume the sole owned references before destruction or stop notification
    record.background = undefined;
    record.text = undefined;
    if (isDefined(background))
        background destroy();
    if (isDefined(text))
        text destroy();
}
