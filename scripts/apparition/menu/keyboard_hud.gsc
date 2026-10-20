// The keyboard owns only its input and key labels; selection borrows main chrome

geometry(layout)
{
    shape = spawnstruct();
    shape.center_x = layout.x + layout.width / 2;
    shape.input_y = layout.y + (layout.design == "Basic" ? 28 : 12);
    shape.keys_y = shape.input_y + 20;
    shape.first_x = shape.center_x - 90;
    return shape;
}

cursor(x, y, shape)
{
    position = spawnstruct();
    position.x = shape.first_x - 8 + 15 * x;
    position.y = shape.keys_y - 8 + 14.5 * y;
    return position;
}

column_text(column)
{
    text = "";
    for (index = 0; index < column.size; index++)
        text += column[index] + "\n";
    return text;
}

create(owner, layout)
{
    elements = [];
    shape = geometry(layout);
    elements["input"] = scripts\apparition\menu\hud::text(shape.center_x,
        shape.input_y, "center", 1.1, (1, 1, 1), 5, owner);
    if (!isDefined(elements["input"]))
        return undefined;
    elements["input"].font = "objective";
    grid = scripts\apparition\menu\keyboard_model::columns();
    for (index = 0; index < grid.size; index++)
    {
        key = "column" + index;
        elements[key] = scripts\apparition\menu\hud::text(shape.first_x + 15 * index,
            shape.keys_y, "center", 1.2, (1, 1, 1), 5, owner);
        if (!isDefined(elements[key]))
        {
            release_elements(elements);
            return undefined;
        }
        elements[key].font = "objective";
        elements[key] setText(column_text(grid[index]));
    }
    return elements;
}

resize_cursor(hud, size)
{
    element = hud.chrome["scroller"];
    // The native size target owns the animation; no duplicate size fields are saved
    element scaleOverTime(0.1, size, size);
}

move_cursor(hud, position, time)
{
    element = hud.chrome["scroller"];
    element moveOverTime(time);
    element.x = position.x;
    element.y = position.y;
}

place_cursor(hud, layout)
{
    position = cursor(0, 0, geometry(layout));
    move_cursor(hud, position, 0.01);
}

show_frame(hud, layout, mode)
{
    scripts\apparition\menu\ownership::release_rows(hud);
    scripts\apparition\menu\ownership::release_spare(hud);
    foreach (element in [hud.description, hud.counter_separator, hud.counter_index, hud.counter_total])
        element.alpha = 0;
    frame = scripts\apparition\menu\design::frame(layout, 1, mode);
    // Modal selection borrows the same source scroller used by menu rows
    hud.chrome["scroller"] FadeOverTime(0.1);
    hud.chrome["scroller"].color = layout.accent;
    // Normal rendering must reapply the page color after the modal releases
    hud.requested_colors["scroller"] = undefined;
    scripts\apparition\menu\hud::apply_frame(hud, frame, false, true);
}

update(elements, layout, model, action, hud)
{
    if (action == "select" || action == "space" || action == "back")
        elements["input"] setText(model.text);
    if (action == "up" || action == "down" || action == "left" || action == "right")
    {
        position = cursor(model.x, model.y, geometry(layout));
        move_cursor(hud, position, 0.05);
    }
}

release_elements(elements)
{
    // A detached key list remains valid while the owned map is being cleared
    keys = getArrayKeys(elements);
    foreach (key in keys)
    {
        element = elements[key];
        if (!isDefined(element))
            continue;
        // Consume the sole owned handle before native destruction or later cleanup
        elements[key] = undefined;
        element destroy();
    }
}
