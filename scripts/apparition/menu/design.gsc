// Each design plan keeps its final source HUD geometry in one place

frame(layout, row_count, mode)
{
    x = layout.x;
    y = layout.y;
    width = layout.width;
    design = layout.design;
    // Fixed source modals share one height table; ordinary pages use visible rows
    fixed_height = scripts\apparition\menu\layout::fixed_panel_height(mode);
    height = isDefined(fixed_height) ? fixed_height
        : scripts\apparition\menu\layout::panel_height(row_count, layout);

    roles = [];
    alpha = design == "Apparition" ? 0.5 : design == "Classic" ? 0.85 : 0.45;
    roles["panel"] = rectangle_role(x, y, width, height, alpha, 3);
    roles["banner"] = empty_rectangle(x, y);
    roles["separator"] = empty_rectangle(x, y);
    roles["bottom"] = empty_rectangle(x, y);
    roles["scroller"] = empty_rectangle(x, y);
    roles["outer"] = empty_rectangle(x, y);
    roles["title"] = empty_text(x, y);
    roles["name"] = empty_text(x, y);

    if (design == "Apparition")
    {
        // The source final draw adds 35 pixels to this banner
        roles["banner"] = rectangle_role(x, y - 20, width, height + 35, 1, 2);
        roles["separator"] = rectangle_role(x, y - 1, width, 1, 1, 5);
        roles["bottom"] = rectangle_role(x, y + height - modal_inset(mode), width, 1, 1, 5);
        roles["title"] = text_role(x + width / 2, y - 12, "center", 1.5, 1, 7);
    }
    else if (design == "Classic")
    {
        // Classic keeps a one-pixel side overhang and adds 14 pixels below the panel
        roles["banner"] = rectangle_role(x - 1, y - 13, width + 2, height + 14, 1, 2);
        roles["title"] = text_role(x + 4, y - 7, "left", 1.2, 1, 7);
    }
    else if (design == "Native")
    {
        // Native keeps its fixed banner and black title strip during panel resizing
        roles["separator"] = rectangle_role(x, y - 17, width, 17, 1, 5);
        roles["banner"] = rectangle_role(x, y - 55, width, 38, 0.9, 2);
        roles["title"] = text_role(x + 4, y - 9.5, "left", 1, 0.7, 7);
        roles["name"] = text_role(x + width / 2, y - 36, "center", 1.6, 1, 7);
    }
    else if (design == "AIO")
    {
        // AIO keeps 25-pixel bars and SoftLockMenu subtracts one outer pixel
        roles["separator"] = rectangle_role(x, y - 25, width, 25, 1, 5);
        roles["bottom"] = rectangle_role(x, y + height - modal_inset(mode), width, 25, 1, 5);
        roles["outer"] = rectangle_role(x - 2, y - 27, width + 4, height + 54 - modal_inset(mode), 0.3, 1);
        roles["title"] = text_role(x + 4, y - 13.5, "left", 1.4, 1, 7);
        name_y = roles["bottom"].y + 11.5;
        roles["name"] = text_role(x + 2, name_y, "left", 1.4, 1, 7);
    }
    else if (design == "Basic")
    {
        // Basic keeps its fixed title banner as menu rows change
        roles["banner"] = rectangle_role(x, y, width, 20, 1, 4);
        roles["title"] = text_role(x + width / 2, y + 9, "center", 1.4, 1, 7);
    }

    row_y = scripts\apparition\menu\layout::row_y(0, layout);
    // The source places each scroller above its selected text row
    scroll_offset = design == "AIO" ? 11 : 8;
    scroller_width = design == "AIO" ? 2 : width;
    scroller_height = design == "AIO" ? 23 : 18;
    scroller_alpha = design == "Native" ? 0.7 : 1;
    roles["scroller"] = rectangle_role(x, row_y - scroll_offset, scroller_width, scroller_height,
        isDefined(fixed_height) ? 0 : scroller_alpha, 4);

    if (mode == "width")
    {
        // Width Editor removes both source title elements
        roles["title"].alpha = 0;
        roles["name"].alpha = 0;
    }

    result = spawnstruct();
    result.roles = roles;
    result.description_y = y + height + (design == "AIO" ? 35 : 23);
    return result;
}

colors(layout)
{
    design = layout.design;
    // Every role gets a vector so one HUD color pass can update the full chrome
    colors = [];
    colors["panel"] = design == "Apparition" || design == "Classic" || design == "Native"
        ? (25 / 255.0, 25 / 255.0, 25 / 255.0) : (0, 0, 0);
    colors["banner"] = design == "Apparition" ? (55 / 255.0, 55 / 255.0, 55 / 255.0)
        : design == "Classic" || design == "Native" ? layout.accent : (0, 0, 0);
    colors["separator"] = design == "Native" ? (0, 0, 0) : layout.accent;
    colors["bottom"] = layout.accent;
    colors["scroller"] = design == "AIO" ? layout.accent : colors["banner"];
    colors["outer"] = (0, 0, 0);
    colors["title"] = design == "Apparition" || design == "Basic" ? layout.accent : (1, 1, 1);
    colors["name"] = (1, 1, 1);
    return colors;
}

page_title(page, design, view)
{
    if (page == "Main")
        return design == "Native" ? "Main Menu" : "Apparition";
    if (page == "Options")
        return scripts\apparition\menu\player_rows::title(view);
    if (page == "Weapon Options")
        return "Options";
    if (page == "All Players Verification")
        return "Verification";
    if (page == "All Players")
        return "All Players Menu";
    // Source preset pages keep shorter titles than their navigation keys
    if (page == "Miscellaneous Messages")
        return "Miscellaneous";
    if (page == "Advertisements Messages")
        return "Advertisements";
    return page;
}

rectangle_role(x, y, width, height, alpha, sort)
{
    role = spawnstruct();
    role.x = x;
    role.y = y;
    role.width = width;
    role.height = height;
    role.alpha = alpha;
    role.sort = sort;
    role.align_x = "left";
    return role;
}

text_role(x, y, align_x, scale, alpha, sort)
{
    role = spawnstruct();
    role.x = x;
    role.y = y;
    role.alpha = alpha;
    role.sort = sort;
    role.align_x = align_x;
    role.scale = scale;
    return role;
}

empty_rectangle(x, y)
{
    return rectangle_role(x, y, 1, 1, 0, 0);
}

empty_text(x, y)
{
    return text_role(x, y, "left", 1, 0, 7);
}

modal_inset(mode)
{
    return isDefined(scripts\apparition\menu\layout::fixed_panel_height(mode)) ? 1 : 0;
}
