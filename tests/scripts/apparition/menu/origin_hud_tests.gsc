// HUD planning and empty cleanup checks never allocate a native element

run()
{
    three_rows_keep_the_original_coordinate_geometry();
    missing_handles_cannot_receive_numeric_values();
    cleanup_consumes_empty_ownership_before_repeated_release();
}

three_rows_keep_the_original_coordinate_geometry()
{
    positions = scripts\apparition\menu\origin_hud::positions();
    tests\support\checks::expect(positions.size == 3
        && positions[0] == (320, 315, 0) && positions[1] == (320, 331, 0)
        && positions[2] == (320, 347, 0),
        "The original three values keep their center x and sixteen-pixel spacing");
}

missing_handles_cannot_receive_numeric_values()
{
    tests\support\checks::expect(!scripts\apparition\menu\origin_hud::paint(undefined, (1, 2, 3)),
        "A missing record stops before native SetValue");
    record = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\origin_hud::paint(record, (1, 2, 3)),
        "A missing handle list cannot paint a coordinate display");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\origin_hud::create(undefined))
        && !isDefined(scripts\apparition\menu\origin_hud::create(spawnstruct())),
        "Missing and fixture actors cannot allocate native HUD elements");
    record.elements = [];
    tests\support\checks::expect(!scripts\apparition\menu\origin_hud::paint(record, (1, 2, 3)),
        "An empty handle list cannot claim a successful update");
}

cleanup_consumes_empty_ownership_before_repeated_release()
{
    scripts\apparition\menu\origin_hud::destroy_record(undefined);
    scripts\apparition\menu\origin_hud::destroy_record(7);
    record = spawnstruct();
    record.elements = [];
    scripts\apparition\menu\origin_hud::destroy_record(record);
    scripts\apparition\menu\origin_hud::destroy_record(record);
    tests\support\checks::expect(isDefined(record.elements) && record.elements.size == 0,
        "Repeated cleanup retains no owned HUD handles");
}
