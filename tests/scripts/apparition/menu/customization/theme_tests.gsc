// The theme module follows the source hue curve and one shared RGB phase

run()
{
    source_hue_segments_match_the_reference_curve();
    hue_advances_at_the_source_rate_and_wraps();
    only_smooth_rainbow_samples_change_the_applied_accent();
    color_target_changes_only_for_a_new_requested_value();
}

source_hue_segments_match_the_reference_curve()
{
    tests\support\checks::expect(scripts\apparition\menu\customization\theme::color(0) == (0.95, 0, 0), "Hue zero starts at the source dim red");
    color = scripts\apparition\menu\customization\theme::color(0.1);
    tests\support\checks::expect(color[0] == 0.95 && color[1] > 0.56 && color[1] < 0.58 && color[2] == 0, "The red to yellow segment raises green at the source brightness");
    color = scripts\apparition\menu\customization\theme::color(0.2);
    tests\support\checks::expect(color[0] > 0.75 && color[0] < 0.77 && color[1] == 0.95 && color[2] == 0, "The yellow to green segment lowers red");
    color = scripts\apparition\menu\customization\theme::color(0.4);
    tests\support\checks::expect(color[0] == 0 && color[1] == 0.95 && color[2] > 0.37 && color[2] < 0.39, "The green to cyan segment raises blue");
    color = scripts\apparition\menu\customization\theme::color(0.6);
    tests\support\checks::expect(color[0] == 0 && color[1] > 0.37 && color[1] < 0.39 && color[2] == 0.95, "The cyan to blue segment lowers green");
    color = scripts\apparition\menu\customization\theme::color(0.75);
    tests\support\checks::expect(color[0] > 0.47 && color[0] < 0.48 && color[1] == 0 && color[2] == 0.95, "The blue to magenta segment raises red");
    color = scripts\apparition\menu\customization\theme::color(0.9);
    tests\support\checks::expect(color[0] == 0.95 && color[1] == 0 && color[2] > 0.56 && color[2] < 0.58, "The magenta to red segment lowers blue");
}

hue_advances_at_the_source_rate_and_wraps()
{
    tests\support\checks::expect(scripts\apparition\menu\customization\theme::advance_hue(0.5) == 0.501, "Each source step advances hue by 0.001");
    hue = scripts\apparition\menu\customization\theme::advance_hue(0.9999);
    tests\support\checks::expect(hue > 0.00089 && hue < 0.00091, "The source step wraps hue back into its unit interval");
}

only_smooth_rainbow_samples_change_the_applied_accent()
{
    layout = scripts\apparition\menu\layout::defaults();
    original = layout.accent;
    tests\support\checks::expect(!scripts\apparition\menu\customization\theme::sample(layout, (0, 0, 1)) && layout.accent == original, "A static theme ignores rainbow samples");
    scripts\apparition\menu\customization\theme::enable(layout);
    tests\support\checks::expect(scripts\apparition\menu\customization\theme::sample(layout, (0, 0, 1)) && layout.accent == (0, 0, 1), "An active rainbow sample becomes the applied accent");
}

color_target_changes_only_for_a_new_requested_value()
{
    tests\support\checks::expect(scripts\apparition\menu\customization\theme::color_target_changed(undefined, (1, 1, 1)), "An unset HUD target requests its first color");
    tests\support\checks::expect(!scripts\apparition\menu\customization\theme::color_target_changed((1, 1, 1), (1, 1, 1)), "A refresh keeps an unchanged requested target through an active fade");
    tests\support\checks::expect(scripts\apparition\menu\customization\theme::color_target_changed((1, 1, 1), (0, 0, 0)), "A changed requested target updates its HUD element");
}
