// Numeric HUD elements borrow the main menu scroller and own only text handles

geometry(layout)
{
    // Input and row offsets are shared with the source text keyboard
    shape = scripts\apparition\menu\keyboard_hud::geometry(layout);
    shape.first_x = shape.center_x - 67.5;
    return shape;
}

cursor(index, shape)
{
    position = spawnstruct();
    position.x = shape.first_x - 7 + 15 * index;
    position.y = shape.keys_y - 7;
    return position;
}

create(owner, layout)
{
    if (!isDefined(owner) || !isPlayer(owner))
        return undefined;
    elements = [];
    shape = geometry(layout);
    elements["input"] = scripts\apparition\menu\hud::text(shape.center_x,
        shape.input_y, "center", 1.2, (1, 1, 1), 5, owner);
    if (!isDefined(elements["input"]))
        return undefined;
    elements["input"].font = "objective";
    // Literal digits stay visible until the shared checked parser admits confirmation
    elements["input"] setText("0");
    for (index = 0; index < 10; index++)
    {
        key = "digit" + index;
        elements[key] = scripts\apparition\menu\hud::text(shape.first_x + 15 * index,
            shape.keys_y, "center", 1.2, (1, 1, 1), 5, owner);
        if (!isDefined(elements[key]))
        {
            scripts\apparition\menu\keyboard_hud::release_elements(elements);
            return undefined;
        }
        elements[key].font = "objective";
        elements[key] setValue(index);
    }
    return elements;
}

place_cursor(hud, layout)
{
    position = cursor(0, geometry(layout));
    scripts\apparition\menu\keyboard_hud::move_cursor(hud, position, 0.01);
}

update(elements, layout, model, action, hud)
{
    if (action == "select" || action == "back")
        elements["input"] setText(model.text);
    if (action == "left" || action == "right")
    {
        position = cursor(model.cursor, geometry(layout));
        scripts\apparition\menu\keyboard_hud::move_cursor(hud, position, 0.05);
    }
}
