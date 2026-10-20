// FOV contracts avoid writing a live native setting

run()
{
    source_range_accepts_fractional_preview_values();
    invalid_values_and_owners_cannot_reach_the_native_setter();
}

source_range_accepts_fractional_preview_values()
{
    range = scripts\apparition\features\fov::range();
    tests\support\checks::expect(range.minimum == 65 && range.maximum == 85 && range.increment == 1,
        "The host FOV slider retains the original inclusive range and increment");
    foreach (value in [65, 70.5, 85])
        tests\support\checks::expect(scripts\apparition\features\fov::valid_value(value),
            "Source-range integer and fractional previews are accepted");
}

invalid_values_and_owners_cannot_reach_the_native_setter()
{
    tests\support\checks::expect(!scripts\apparition\features\fov::valid_value(undefined)
        && !scripts\apparition\features\fov::request(undefined, undefined),
        "An absent preview cannot reach native FOV state");
    foreach (value in [64.5, 85.5, "80", [], spawnstruct()])
    {
        tests\support\checks::expect(!scripts\apparition\features\fov::valid_value(value)
            && !scripts\apparition\features\fov::request(undefined, value),
            "Invalid previews are rejected before actor or native-setting work");
    }
    snapshot = scripts\apparition\features\fov::probe(undefined);
    tests\support\checks::expect(snapshot.reason != "" && !isDefined(snapshot.current),
        "An absent owner receives a typed denial before native setting reads");
    tests\support\checks::expect(!scripts\apparition\features\fov::request(undefined, 70.5),
        "A valid preview cannot bypass the current native host boundary");
}
