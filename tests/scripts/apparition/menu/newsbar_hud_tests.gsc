// The opt-in VM suite inspects a real global HUD pair and releases it without waits

run()
{
    real_global_pair_keeps_numeric_geometry_and_releases_owned_handles();
}

real_global_pair_keeps_numeric_geometry_and_releases_owned_handles()
{
    record = scripts\apparition\menu\newsbar_hud::create();
    tests\support\checks::expect(isDefined(record) && isDefined(record.background)
        && isDefined(record.text),
        "Native Newsbar allocation returns both global HUD handles");
    if (!isDefined(record))
        return;
    if (isDefined(record.background) && isDefined(record.text))
    {
        background = record.background;
        text = record.text;
        tests\support\checks::expect(background.x == 320 && background.y == 8
            && background.width == 1000 && background.height == 18,
            "The global background keeps the source position and rectangle size");
        tests\support\checks::expect(background.alpha == 0.6 && background.sort == 1
            && background.color == (0, 0, 0),
            "The global background keeps the source opacity, layer and black color");
        tests\support\checks::expect(background.elemType == "icon" && background.hidden == 0
            && background.hideWhenInMenu && background.foreground && background.archived,
            "The global rectangle keeps source type and visibility metadata");
        tests\support\checks::expect(background.horzAlign == "fullscreen"
            && background.vertAlign == "top" && background.alignX == "center"
            && background.alignY == "middle",
            "The background uses the source fullscreen horizontal anchor and explicit IW7 vertical origin");
        tests\support\checks::expect(text.x == 320 && text.y == -15
            && text.fontScale == 1 && text.sort == 3 && text.alpha == 1,
            "The global text starts above the bar at the source scale and layer");
        tests\support\checks::expect(text.color == (1, 1, 1)
            && text.horzAlign == "left" && text.vertAlign == "top"
            && text.alignX == "center" && text.alignY == "middle",
            "The text keeps the source white color with explicit centered left-screen IW7 anchors");
        tests\support\checks::expect(text.elemType == "font" && text.font == "default"
            && text.width == 0 && text.height == int(level.fontheight) && text.hidden == 0
            && text.hideWhenInMenu && text.foreground && text.archived,
            "The global font keeps source size and visibility metadata");
    }

    // Cleanup is unconditional after allocation, including a failed field assertion
    scripts\apparition\menu\newsbar_hud::destroy_record(record);
    tests\support\checks::expect(!isDefined(record.background) && !isDefined(record.text),
        "Native cleanup consumes both owned handle references");
    scripts\apparition\menu\newsbar_hud::destroy_record(record);
    tests\support\checks::expect(!isDefined(record.background) && !isDefined(record.text),
        "Repeated cleanup leaves the consumed record empty");
}
