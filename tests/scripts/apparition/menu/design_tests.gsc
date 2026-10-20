// Design contracts follow the source constructor and final draw geometry

run()
{
    apparition_uses_resized_panel_banner_and_row_aligned_scroller();
    classic_uses_its_final_padding_and_banner_override();
    native_keeps_its_fixed_header_and_counter_title_alignment();
    aio_keeps_its_outer_frame_and_narrow_scroller();
    basic_keeps_its_fixed_title_banner_and_row_gap();
    shifted_width_layout_moves_each_design_with_its_source_geometry();
    width_editor_uses_source_chrome_overrides_for_each_design();
    reposition_editor_keeps_title_and_source_aio_outer_height();
    credits_uses_the_source_soft_lock_height_and_hidden_scroller();
    every_design_returns_stable_role_slots_and_source_colors();
    page_titles_keep_the_source_main_and_all_players_names();
}

apparition_uses_resized_panel_banner_and_row_aligned_scroller()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    plan = scripts\apparition\menu\design::frame(layout, 1, undefined);
    roles = plan.roles;
    tests\support\checks::expect(roles["panel"].x == 17 && roles["panel"].y == 41 && roles["panel"].width == 400 && roles["panel"].height == 18, "Apparition uses its final one-row panel size");
    tests\support\checks::expect(roles["banner"].x == 17 && roles["banner"].y == 21 && roles["banner"].width == 400 && roles["banner"].height == 53, "Apparition resizes its banner to panel height plus 35");
    tests\support\checks::expect(roles["separator"].y == 40 && roles["separator"].height == 1 && roles["bottom"].y == 59 && roles["bottom"].height == 1, "Apparition draws accent rules above and below the panel");
    tests\support\checks::expect(roles["scroller"].x == 17 && roles["scroller"].y == 41 && roles["scroller"].width == 400 && roles["scroller"].height == 18, "Apparition aligns the full-width scroller with the panel");
    tests\support\checks::expect(roles["title"].x == 217 && roles["title"].y == 29 && roles["title"].align_x == "center" && roles["title"].scale == 1.5, "Apparition centers its 1.5-scale title above the panel");
    tests\support\checks::expect(plan.description_y == 82, "The footer stays below the resized Apparition panel");
}

classic_uses_its_final_padding_and_banner_override()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.design = "Classic";
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    roles = scripts\apparition\menu\design::frame(layout, 1, undefined).roles;
    tests\support\checks::expect(roles["panel"].height == 25 && roles["panel"].alpha == 0.85, "Classic keeps the final 25-pixel one-row panel and source alpha");
    tests\support\checks::expect(roles["banner"].x == 16 && roles["banner"].y == 28 && roles["banner"].width == 402 && roles["banner"].height == 39, "Classic keeps its two-pixel wider banner and final height plus 14");
    tests\support\checks::expect(roles["scroller"].y == 44 && roles["scroller"].width == 400 && roles["scroller"].height == 18, "Classic scroller starts three pixels below the panel top");
    tests\support\checks::expect(roles["title"].x == 21 && roles["title"].y == 34 && roles["title"].align_x == "left" && roles["title"].scale == 1.2, "Classic keeps its left-aligned title position and scale");
    tests\support\checks::expect(roles["separator"].alpha == 0 && roles["bottom"].alpha == 0 && roles["outer"].alpha == 0 && roles["name"].alpha == 0, "Classic omits lines, outer frame and menu name");
}

native_keeps_its_fixed_header_and_counter_title_alignment()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.design = "Native";
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    roles = scripts\apparition\menu\design::frame(layout, 1, undefined).roles;
    tests\support\checks::expect(roles["panel"].height == 18 && roles["panel"].alpha == 0.45, "Native keeps the source panel size and opacity");
    tests\support\checks::expect(roles["separator"].x == 17 && roles["separator"].y == 24 && roles["separator"].width == 400 && roles["separator"].height == 17, "Native uses its fixed black title separator");
    tests\support\checks::expect(roles["banner"].x == 17 && roles["banner"].y == -14 && roles["banner"].height == 38 && roles["banner"].alpha == 0.9, "Native keeps its fixed 38-pixel accent banner");
    tests\support\checks::expect(roles["scroller"].y == 41 && roles["scroller"].width == 400 && roles["scroller"].height == 18 && roles["scroller"].alpha == 0.7, "Native keeps the translucent full-width scroller");
    tests\support\checks::expect(roles["title"].x == 21 && roles["title"].y == 31.5 && roles["title"].scale == 1 && roles["title"].alpha == 0.7, "Native places its page title inside the separator");
    tests\support\checks::expect(roles["name"].x == 217 && roles["name"].y == 5 && roles["name"].align_x == "center" && roles["name"].scale == 1.6, "Native centers the menu name inside its banner");
}

aio_keeps_its_outer_frame_and_narrow_scroller()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.design = "AIO";
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    plan = scripts\apparition\menu\design::frame(layout, 1, undefined);
    roles = plan.roles;
    tests\support\checks::expect(roles["panel"].height == 31 && roles["panel"].alpha == 0.45, "AIO keeps its final one-row panel size and source opacity");
    tests\support\checks::expect(roles["separator"].y == 16 && roles["separator"].height == 25 && roles["bottom"].y == 72 && roles["bottom"].height == 25, "AIO uses 25-pixel accent bars around the panel");
    tests\support\checks::expect(roles["outer"].x == 15 && roles["outer"].y == 14 && roles["outer"].width == 404 && roles["outer"].height == 85 && roles["outer"].alpha == 0.3, "AIO outer frame includes both bars and four source border pixels");
    tests\support\checks::expect(roles["scroller"].x == 17 && roles["scroller"].y == 45 && roles["scroller"].width == 2 && roles["scroller"].height == 23, "AIO uses its narrow scroller eleven pixels above the text row");
    tests\support\checks::expect(roles["title"].x == 21 && roles["title"].y == 27.5 && roles["title"].scale == 1.4, "AIO title sits on the accent separator");
    tests\support\checks::expect(roles["name"].x == 19 && roles["name"].y == 83.5 && roles["name"].scale == 1.4 && plan.description_y == 107, "AIO menu name and footer follow the lower chrome");
}

basic_keeps_its_fixed_title_banner_and_row_gap()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.design = "Basic";
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    roles = scripts\apparition\menu\design::frame(layout, 1, undefined).roles;
    tests\support\checks::expect(roles["panel"].height == 40 && roles["panel"].alpha == 0.45, "Basic reserves its final 40-pixel one-row panel");
    tests\support\checks::expect(roles["banner"].x == 17 && roles["banner"].y == 41 && roles["banner"].height == 20 && roles["scroller"].y == 63, "Basic keeps its fixed banner and 22-pixel scroller offset");
    tests\support\checks::expect(roles["title"].x == 217 && roles["title"].y == 50 && roles["title"].align_x == "center" && roles["title"].scale == 1.4, "Basic centers its title inside the banner");
    tests\support\checks::expect(roles["separator"].alpha == 0 && roles["bottom"].alpha == 0 && roles["outer"].alpha == 0 && roles["name"].alpha == 0, "Basic omits lines, outer frame and menu name");
}

shifted_width_layout_moves_each_design_with_its_source_geometry()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.x = -13;
    layout.y = 70;
    foreach (width in [200, 500])
    {
        layout.width = width;
        foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
        {
            layout.design = design;
            roles = scripts\apparition\menu\design::frame(layout, 3, undefined).roles;
            tests\support\checks::expect(roles["panel"].x == -13 && roles["panel"].y == 70 && roles["panel"].width == width, "Every design follows the applied origin and width");
            tests\support\checks::expect(roles["scroller"].x == -13 && roles["scroller"].width == (design == "AIO" ? 2 : width), "Scroller width follows the design-specific source width");
        }
    }
}

width_editor_uses_source_chrome_overrides_for_each_design()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
    {
        layout.design = design;
        roles = scripts\apparition\menu\design::frame(layout, 1, "width").roles;
        tests\support\checks::expect(roles["panel"].height == 120 && roles["scroller"].alpha == 0, "Width Editor locks each design to a 120-pixel panel and hides the scroller");
        tests\support\checks::expect(roles["title"].alpha == 0 && roles["name"].alpha == 0, "Width Editor hides each design title and menu name");
        if (design == "Apparition" || design == "AIO")
            tests\support\checks::expect(roles["bottom"].y == 160, "Width Editor applies the source bottom inset when a bottom line exists");
    }
    layout.design = "Apparition";
    roles = scripts\apparition\menu\design::frame(layout, 1, "width").roles;
    tests\support\checks::expect(roles["banner"].height == 155, "Apparition Width Editor resizes the banner to panel plus 35");
    layout.design = "Classic";
    roles = scripts\apparition\menu\design::frame(layout, 1, "width").roles;
    tests\support\checks::expect(roles["banner"].height == 134, "Classic Width Editor resizes the banner to panel plus 14");
    layout.design = "Native";
    tests\support\checks::expect(scripts\apparition\menu\design::frame(layout, 1, "width").roles["banner"].height == 38, "Native Width Editor keeps its fixed banner");
    layout.design = "Basic";
    tests\support\checks::expect(scripts\apparition\menu\design::frame(layout, 1, "width").roles["banner"].height == 20, "Basic Width Editor keeps its fixed banner");
}

reposition_editor_keeps_title_and_source_aio_outer_height()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.x = 17;
    layout.y = 41;
    layout.width = 400;
    foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
    {
        layout.design = design;
        roles = scripts\apparition\menu\design::frame(layout, 1, "reposition").roles;
        tests\support\checks::expect(roles["panel"].height == 122 && roles["scroller"].alpha == 0, "Reposition Menu locks each design to a 122-pixel panel and hides the scroller");
        tests\support\checks::expect(roles["title"].alpha == (design == "Native" ? 0.7 : 1), "Reposition Menu retains each source page title and its original opacity");
    }
    layout.design = "Apparition";
    roles = scripts\apparition\menu\design::frame(layout, 1, "reposition").roles;
    tests\support\checks::expect(roles["banner"].height == 157 && roles["bottom"].y == 162, "Apparition Reposition uses its 157-pixel banner and bottom inset");
    layout.design = "Classic";
    tests\support\checks::expect(scripts\apparition\menu\design::frame(layout, 1, "reposition").roles["banner"].height == 136, "Classic Reposition resizes the banner to panel plus 14");
    layout.design = "AIO";
    roles = scripts\apparition\menu\design::frame(layout, 1, "reposition").roles;
    tests\support\checks::expect(roles["outer"].height == 175 && roles["name"].alpha == 1 && roles["name"].y == 173.5, "AIO Reposition uses the three-pixel outer inset and moves its retained name to the locked bottom bar");
}

every_design_returns_stable_role_slots_and_source_colors()
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.accent = (0.25, 0.5, 0.75);
    foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
    {
        layout.design = design;
        plan = scripts\apparition\menu\design::frame(layout, 1, undefined);
        colors = scripts\apparition\menu\design::colors(layout);
        foreach (key in ["panel", "banner", "separator", "bottom", "scroller", "outer", "title", "name"])
        {
            role = plan.roles[key];
            tests\support\checks::expect(isDefined(role) && isDefined(colors[key]), "Every design exposes stable geometry and color roles");
            if (role.alpha == 0 && (key == "panel" || key == "banner" || key == "separator" || key == "bottom" || key == "scroller" || key == "outer"))
                tests\support\checks::expect(role.width == 1 && role.height == 1, "Unused rectangle roles keep a valid one-pixel size");
        }
    }
    layout.design = "Apparition";
    colors = scripts\apparition\menu\design::colors(layout);
    tests\support\checks::expect(colors["panel"] == (25 / 255.0, 25 / 255.0, 25 / 255.0) && colors["banner"] == (55 / 255.0, 55 / 255.0, 55 / 255.0), "Apparition keeps its source gray panel and banner colors");
    tests\support\checks::expect(colors["separator"] == layout.accent && colors["bottom"] == layout.accent && colors["title"] == layout.accent, "Apparition applies the selected accent to its source components");
    layout.design = "Classic";
    colors = scripts\apparition\menu\design::colors(layout);
    tests\support\checks::expect(colors["panel"] == (25 / 255.0, 25 / 255.0, 25 / 255.0) && colors["banner"] == layout.accent && colors["scroller"] == layout.accent && colors["title"] == (1, 1, 1), "Classic keeps its dark panel, accent banner and scroller, and white title");
    layout.design = "Native";
    colors = scripts\apparition\menu\design::colors(layout);
    tests\support\checks::expect(colors["separator"] == (0, 0, 0) && colors["banner"] == layout.accent && colors["scroller"] == layout.accent, "Native keeps the black separator and accent header and scroller");
    layout.design = "AIO";
    colors = scripts\apparition\menu\design::colors(layout);
    tests\support\checks::expect(colors["panel"] == (0, 0, 0) && colors["outer"] == (0, 0, 0) && colors["separator"] == layout.accent && colors["bottom"] == layout.accent, "AIO keeps black panels and accent rules");
    layout.design = "Basic";
    colors = scripts\apparition\menu\design::colors(layout);
    tests\support\checks::expect(colors["panel"] == (0, 0, 0) && colors["banner"] == (0, 0, 0) && colors["scroller"] == (0, 0, 0) && colors["title"] == layout.accent, "Basic keeps black chrome and an accent title");
}

credits_uses_the_source_soft_lock_height_and_hidden_scroller()
{
    layout = scripts\apparition\menu\layout::defaults();
    foreach (design in ["Apparition", "Classic", "Native", "AIO", "Basic"])
    {
        layout.design = design;
        roles = scripts\apparition\menu\design::frame(layout, 1, "credits").roles;
        tests\support\checks::expect(roles["panel"].height == 220 && roles["scroller"].alpha == 0,
            "Credits use the source 220-pixel SoftLockMenu height and hide ordinary scrolling");
        if (design == "Apparition" || design == "AIO")
            tests\support\checks::expect(roles["bottom"].y == layout.y + 219,
                "Credits retain the source soft-lock bottom-line inset");
        if (design == "AIO")
            tests\support\checks::expect(roles["outer"].height == 273,
                "AIO credits keep the source outer frame around both bars");
    }
}

page_titles_keep_the_source_main_and_all_players_names()
{
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Main", "Apparition") == "Apparition", "Apparition uses its menu name on the main page");
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Main", "Native") == "Main Menu", "Native uses the source Main Menu title");
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("All Players", "Classic") == "All Players Menu", "Every design names the All Players page consistently");
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Menu Customization", "AIO") == "Menu Customization", "Other page titles remain unchanged");
    tests\support\checks::expect(scripts\apparition\menu\design::page_title("Miscellaneous Messages", "Apparition") == "Miscellaneous"
        && scripts\apparition\menu\design::page_title("Advertisements Messages", "Apparition") == "Advertisements",
        "Preset pages use their source visible titles while retaining distinct navigation keys");
}
