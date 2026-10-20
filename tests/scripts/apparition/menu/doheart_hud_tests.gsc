// The optional native HUD check allocates one element and destroys it immediately

run()
{
    unsupported_input_is_rejected_before_allocation();
    valid_style_allocates_source_geometry_and_releases_its_handle();
}

unsupported_input_is_rejected_before_allocation()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\doheart_hud::create(undefined, "Pulsing"))
        && !isDefined(scripts\apparition\menu\doheart_hud::create(17, "Pulsing")),
        "Missing or nonstring Doheart text is rejected before HUD allocation");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\doheart_hud::create("Apparition", undefined))
        && !isDefined(scripts\apparition\menu\doheart_hud::create("Apparition", "Pulse Effect"))
        && !isDefined(scripts\apparition\menu\doheart_hud::create("Apparition", "Type Writer")),
        "Unsupported Doheart styles are rejected before HUD allocation");
}

valid_style_allocates_source_geometry_and_releases_its_handle()
{
    record = scripts\apparition\menu\doheart_hud::create("Apparition", "Pulsing");
    tests\support\checks::expect(isDefined(record) && isDefined(record.text),
        "A supported Doheart style allocates its owned global text element");
    if (!isDefined(record) || !isDefined(record.text))
        return;

    text = record.text;
    tests\support\checks::expect(text.elemType == "font" && text.font == "objective"
        && text.fontScale == 2 && text.sort == 1,
        "Doheart text keeps the source font, scale, and layer");
    tests\support\checks::expect(text.alignX == "center" && text.alignY == "middle"
        && text.horzAlign == "left" && text.vertAlign == "top"
        && text.x == 320 && text.y == 27,
        "Doheart text keeps source alignment and position");
    tests\support\checks::expect(text.alpha == 1 && text.color == (1, 1, 1)
        && text.foreground && text.hideWhenInMenu && text.archived && text.width == 0
        && text.hidden == 0 && text.height == int(level.fontheight * 2),
        "Doheart text starts white and visible with source HUD flags");

    // Cleanup runs immediately without starting a style worker or waiting
    scripts\apparition\menu\doheart_hud::destroy_record(record);
    tests\support\checks::expect(!isDefined(record.text),
        "Doheart cleanup consumes its owned text reference");
    scripts\apparition\menu\doheart_hud::destroy_record(record);
    tests\support\checks::expect(!isDefined(record.text),
        "Repeated Doheart cleanup leaves no owned handle");
}
