// Geometry tests describe the source numeric row without allocating native HUD objects

run()
{
    all_menu_designs_keep_the_source_input_and_digit_offsets();
    every_cursor_center_tracks_its_source_digit();
    missing_or_fixture_actors_cannot_allocate_numeric_hud_elements();
}

layout(design)
{
    result = spawnstruct();
    result.x = 10;
    result.y = 20;
    result.width = 210;
    result.design = design;
    result.accent = (0, 1, 0);
    return result;
}

all_menu_designs_keep_the_source_input_and_digit_offsets()
{
    foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
    {
        shape = scripts\apparition\menu\numberpad_hud::geometry(layout(design));
        tests\support\checks::expect(shape.center_x == 115 && shape.first_x == 47.5,
            "Ten digits have fifteen-pixel spacing around the actual menu center");
        tests\support\checks::expect(shape.input_y == (design == "Basic" ? 48 : 32)
            && shape.keys_y == shape.input_y + 20,
            "Only Basic moves numeric input down by the original sixteen extra pixels");
    }
}

every_cursor_center_tracks_its_source_digit()
{
    shape = scripts\apparition\menu\numberpad_hud::geometry(layout("Apparition"));
    for (index = 0; index < 10; index++)
    {
        position = scripts\apparition\menu\numberpad_hud::cursor(index, shape);
        tests\support\checks::expect(position.x == shape.first_x + 15 * index - 7
            && position.y == shape.keys_y - 7,
            "The borrowed scroller follows each source digit with its seven-pixel inset");
    }
    moved = layout("Apparition");
    moved.x = -40;
    moved.y = 100;
    moved.width = 250;
    shape = scripts\apparition\menu\numberpad_hud::geometry(moved);
    tests\support\checks::expect(shape.center_x == 85 && shape.first_x == 17.5
        && shape.input_y == 112 && shape.keys_y == 132,
        "Numeric geometry follows moved and resized menus without fixed screen coordinates");
}

missing_or_fixture_actors_cannot_allocate_numeric_hud_elements()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\numberpad_hud::create(undefined, layout("Apparition")))
        && !isDefined(scripts\apparition\menu\numberpad_hud::create(spawnstruct(), layout("Apparition"))),
        "Native client HUD creation requires an actual admitted player");
}
