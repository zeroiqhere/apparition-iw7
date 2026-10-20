// These contracts use inert structs and never call native HUD methods

run()
{
    missing_or_malformed_inputs_stop_before_hud_commands();
    zero_fill_hides_a_positive_width_shader();
    positive_fill_restores_alpha_without_resizing_matching_elements();
    destroy_without_handles_is_safe_and_clears_record_ownership();
}

missing_or_malformed_inputs_stop_before_hud_commands()
{
    shape = shape_fixture();
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\health_bar_hud::create(undefined, shape)),
        "A missing player cannot allocate HUD elements");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\health_bar_hud::create(spawnstruct(), shape)),
        "A fixture actor cannot allocate native HUD elements");
    tests\support\checks::expect(!scripts\apparition\menu\health_bar_hud::paint(undefined, shape),
        "An absent record cannot receive paint commands");
    tests\support\checks::expect(!scripts\apparition\menu\health_bar_hud::paint("invalid", shape),
        "A malformed record cannot receive paint commands");
    tests\support\checks::expect(!scripts\apparition\menu\health_bar_hud::paint(incomplete_record(), shape),
        "A record missing either owned handle is rejected before element access");
}

zero_fill_hides_a_positive_width_shader()
{
    // Matching widths keep the fixture away from native SetShader calls
    record = valid_record();
    record.fill.width = 75;
    record.fill.alpha = 0.9;
    record.fill.color = (1, 1, 1);
    record.background.width = 102;
    record.background.alpha = 1;
    shape = shape_fixture();
    shape.background_width = 102;
    shape.fill_width = 0;

    result = scripts\apparition\menu\health_bar_hud::paint(record, shape);

    tests\support\checks::expect(result && record.fill.width == 75 && record.fill.alpha == 0,
        "Zero logical fill hides the existing positive-width shader without an unnecessary resize");
    tests\support\checks::expect(record.fill.color == (1, 1, 1)
        && record.background.width == 102 && record.background.alpha == 1,
        "Zero fill changes no unrelated color or background property");
}

positive_fill_restores_alpha_without_resizing_matching_elements()
{
    // A hidden logical fill can become visible without resizing its shader
    record = valid_record();
    record.background.width = 152;
    record.background.alpha = 1;
    record.fill.width = 75;
    record.fill.alpha = 0;
    record.fill.color = (1, 1, 1);
    shape = shape_fixture();
    shape.background_width = 152;
    shape.fill_width = 75;

    result = scripts\apparition\menu\health_bar_hud::paint(record, shape);

    tests\support\checks::expect(result && record.fill.width == 75 && record.fill.alpha == 0.9,
        "Positive fill restores source alpha when the native shader already has the desired width");
    tests\support\checks::expect(record.fill.color == (1, 1, 1)
        && record.background.width == 152 && record.background.alpha == 1,
        "A matching positive fill changes no unrelated element property");
}

destroy_without_handles_is_safe_and_clears_record_ownership()
{
    // Empty records exercise cleanup without a fake native HUD method
    absent = spawnstruct();
    absent.background = undefined;
    absent.fill = undefined;
    scripts\apparition\menu\health_bar_hud::destroy_record(undefined);
    scripts\apparition\menu\health_bar_hud::destroy_record("invalid");
    scripts\apparition\menu\health_bar_hud::destroy_record(absent);
    tests\support\checks::expect(!isDefined(absent.background) && !isDefined(absent.fill),
        "Destroying a record without handles is safe and leaves no element references");
    scripts\apparition\menu\health_bar_hud::destroy_record(absent);
    tests\support\checks::expect(!isDefined(absent.background) && !isDefined(absent.fill),
        "Repeated empty cleanup remains harmless");
}

shape_fixture()
{
    shape = spawnstruct();
    shape.background_width = 102;
    shape.fill_width = 100;
    return shape;
}

valid_record()
{
    record = spawnstruct();
    record.background = spawnstruct();
    record.background.width = 102;
    record.fill = spawnstruct();
    record.fill.width = 100;
    record.fill.alpha = 0.9;
    return record;
}

incomplete_record()
{
    record = spawnstruct();
    record.background = spawnstruct();
    record.background.width = 102;
    record.fill = undefined;
    return record;
}
