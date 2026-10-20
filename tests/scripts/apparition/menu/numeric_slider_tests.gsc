// Numeric slider math stays source-shaped without creating menu state

run()
{
    clamp_preserves_fractional_values_inside_the_source_range();
    clamp_bounds_live_values_before_preview();
    move_preserves_fractional_seed_offset_for_regular_steps();
    move_clamps_overshoots_and_wraps_only_at_source_edges();
    malformed_numeric_slider_inputs_are_rejected();
}

clamp_preserves_fractional_values_inside_the_source_range()
{
    value = scripts\apparition\menu\numeric_slider::bound(70.5, 65, 85);
    tests\support\checks::expect(value == 70.5,
        "An in-range live FOV seed keeps its fractional offset");
    tests\support\checks::expect(scripts\apparition\menu\numeric_slider::bound(65, 65, 85) == 65
        && scripts\apparition\menu\numeric_slider::bound(85, 65, 85) == 85,
        "Source range endpoints remain inclusive");
}

clamp_bounds_live_values_before_preview()
{
    tests\support\checks::expect(scripts\apparition\menu\numeric_slider::bound(40, 65, 85) == 65,
        "A live seed below the source range starts at the minimum");
    tests\support\checks::expect(scripts\apparition\menu\numeric_slider::bound(120, 65, 85) == 85,
        "A live seed above the source range starts at the maximum");
}

move_preserves_fractional_seed_offset_for_regular_steps()
{
    right = scripts\apparition\menu\numeric_slider::move(70.5, 1, 65, 85, 1);
    left = scripts\apparition\menu\numeric_slider::move(70.5, -1, 65, 85, 1);
    tests\support\checks::expect(right == 71.5 && left == 69.5,
        "Ordinary left and right steps preserve a fractional live seed");
}

move_clamps_overshoots_and_wraps_only_at_source_edges()
{
    high = scripts\apparition\menu\numeric_slider::move(84.5, 1, 65, 85, 1);
    low = scripts\apparition\menu\numeric_slider::move(65.5, -1, 65, 85, 1);
    tests\support\checks::expect(high == 85 && low == 65,
        "A step crossing a source endpoint clamps to that endpoint");
    tests\support\checks::expect(scripts\apparition\menu\numeric_slider::move(84.5, -1, 65, 85, 1) == 85
        && scripts\apparition\menu\numeric_slider::move(65.5, 1, 65, 85, 1) == 65,
        "Source overshoot clamping takes precedence over the requested direction");
    tests\support\checks::expect(scripts\apparition\menu\numeric_slider::move(high, 1, 65, 85, 1) == 65
        && scripts\apparition\menu\numeric_slider::move(low, -1, 65, 85, 1) == 85,
        "A step from an endpoint wraps to the opposite source endpoint");
    tests\support\checks::expect(scripts\apparition\menu\numeric_slider::move(85, -1, 65, 85, 1) == 84
        && scripts\apparition\menu\numeric_slider::move(65, 1, 65, 85, 1) == 66,
        "A step toward the range interior moves inward from either endpoint");
    tests\support\checks::expect(scripts\apparition\menu\numeric_slider::move(40, 1, 65, 85, 1) == 66
        && scripts\apparition\menu\numeric_slider::move(120, -1, 65, 85, 1) == 84,
        "A malformed live value is first clamped before its requested step");
}

malformed_numeric_slider_inputs_are_rejected()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\numeric_slider::bound(undefined, 65, 85))
        && !isDefined(scripts\apparition\menu\numeric_slider::bound("70", 65, 85))
        && !isDefined(scripts\apparition\menu\numeric_slider::bound(70, undefined, 85))
        && !isDefined(scripts\apparition\menu\numeric_slider::bound(70, 85, 65)),
        "Missing, nonnumeric, and reversed clamp inputs are rejected");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\numeric_slider::move(70, 1, 65, 85, 0))
        && !isDefined(scripts\apparition\menu\numeric_slider::move(70, 1, 65, 85, -1))
        && !isDefined(scripts\apparition\menu\numeric_slider::move(70, 1, 65, 85, undefined)),
        "A nonpositive or missing increment is rejected");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\numeric_slider::move(70, undefined, 65, 85, 1))
        && !isDefined(scripts\apparition\menu\numeric_slider::move(70, "left", 65, 85, 1))
        && !isDefined(scripts\apparition\menu\numeric_slider::move(70, -0.5, 65, 85, 1))
        && !isDefined(scripts\apparition\menu\numeric_slider::move(70, 0, 65, 85, 1))
        && !isDefined(scripts\apparition\menu\numeric_slider::move(70, 2, 65, 85, 1)),
        "Only the two supported slider directions are admitted");
}
