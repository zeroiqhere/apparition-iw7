// One level phase feeds every owner's smooth rainbow theme

color(hue)
{
    value = 0.95;
    // Six equal hue ranges fade one channel at a time
    scaled = hue * 6;
    step = int(scaled) % 6;
    fraction = scaled - step;
    switch (step)
    {
        // Red stays full as green rises
        case 0: return (value, fraction * value, 0);
        // Green stays full as red falls
        case 1: return ((1 - fraction) * value, value, 0);
        // Green stays full as blue rises
        case 2: return (0, value, fraction * value);
        // Blue stays full as green falls
        case 3: return (0, (1 - fraction) * value, value);
        // Blue stays full as red rises
        case 4: return (fraction * value, 0, value);
        // Red stays full as blue falls
        default: return (value, 0, (1 - fraction) * value);
    }
}

advance_hue(hue)
{
    // The source moves one thousandth of the hue range per sample
    hue += 0.001;
    if (hue >= 1)
        hue -= 1;
    return hue;
}

start_rgb_fade()
{
    // The source uses the shared color itself to keep this producer idempotent
    if (isDefined(level.RGBFadeColor))
        return false;
    hue = randomFloatRange(0, 1);
    level.RGBFadeColor = color(hue);
    level thread rgb_fade(hue);
    return true;
}

rgb_fade(hue)
{
    level endon("game_ended");
    for (;;)
    {
        // Publish before advancing, then keep the source ten millisecond cadence
        level.RGBFadeColor = color(hue);
        hue = advance_hue(hue);
        wait 0.01;
    }
}

color_target_changed(previous, requested)
{
    // Compare requested colors instead of native values that may still be fading
    if (!isDefined(previous))
        return true;
    return previous != requested;
}

enable(layout)
{
    // The source checkbox enables rainbow; a named color is the off action
    layout.smooth_rainbow = true;
    layout.theme_fade_pending = false;
    return true;
}

sample(layout, color)
{
    if (!layout.smooth_rainbow || !isDefined(color))
        return false;
    // Each owner keeps its selected accent in the same layout field
    layout.accent = color;
    return true;
}
