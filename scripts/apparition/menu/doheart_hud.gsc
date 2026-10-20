// One global text element follows the source's supported Doheart sequences

create(text, style)
{
    if (scripts\apparition\features\server\doheart::configuration_reason(text, style) != "")
        return undefined;
    font_height = level.fontheight;
    // Stock CP supplies this value; bound the doubled integer conversion before allocation
    if (!isDefined(font_height) || !isnumber(font_height)
        || !(font_height > 0 && font_height < 1073741824))
        return undefined;
    element = newHudElem();
    if (!isDefined(element))
        return undefined;
    element.elemType = "font";
    // Explicit IW7 screen origins need later visual comparison with the BO3 HUD
    element.horzAlign = "left";
    element.vertAlign = "top";
    element.alignX = "center";
    element.alignY = "middle";
    element.x = 320;
    element.y = 27;
    element.font = "objective";
    element.fontScale = 2;
    element.sort = 1;
    element.alpha = 1;
    element.color = (1, 1, 1);
    element.width = 0;
    element.height = int(font_height * 2);
    element.hidden = false;
    element.hideWhenInMenu = true;
    element.foreground = true;
    element.archived = true;
    element setText(text);
    // Fade Effect chooses an initial color before its first fade, as in the source
    if (style == "Fade Effect")
        element.color = random_color();
    record = spawnstruct();
    record.text = element;
    return record;
}

random_color()
{
    // Preserve the source expression without assuming runtime numeric coercion
    return (randomInt(255) / 255, randomInt(255) / 255, randomInt(255) / 255);
}

cycle(record, style)
{
    text = record.text;
    if (!isDefined(text))
        return false;
    if (style == "Pulsing")
    {
        text changeFontScaleOverTime(0.6);
        text.fontScale = 2.8;
        text fadeOverTime(0.6);
        text.color = random_color();
        wait 0.6;
        if (!isDefined(text))
            return false;
        text changeFontScaleOverTime(0.6);
        text.fontScale = 1.5;
        text fadeOverTime(0.6);
        text.color = random_color();
        wait 0.6;
    }
    else if (style == "Moving")
    {
        // The source starts a fade without setting an alpha target
        text fadeOverTime(2);
        text.color = random_color();
        text moveOverTime(2);
        text.x = randomIntRange(-100, 475);
        text.y = randomIntRange(20, 460);
        // The source's helper thread has no work after its two-second wait
        wait 1.98;
    }
    else if (style == "Fade Effect")
    {
        text fadeOverTime(1);
        text.alpha = 0;
        wait 1;
        if (!isDefined(text))
            return false;
        text.color = random_color();
        wait 0.25;
        if (!isDefined(text))
            return false;
        text fadeOverTime(1);
        text.alpha = 1;
        wait 1;
        // Each source fade finishes before the quarter-second gap begins
        wait 0.25;
    }
    else
        return false;
    return isDefined(text);
}

destroy_record(record)
{
    if (!isDefined(record) || !isstruct(record))
        return;
    text = record.text;
    // Consume the sole owned reference before native destruction or notification
    record.text = undefined;
    if (isDefined(text))
        text destroy();
}
