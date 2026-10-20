// Per-choice reasons gate slider commands without changing row state

run()
{
    absent_maps_keep_existing_row_behavior();
    numeric_sliders_keep_existing_behavior_without_using_map_keys();
    ranged_numeric_preview_is_required_before_dispatch();
    whole_numeric_choices_use_their_own_reason();
    fractional_and_out_of_range_numeric_keys_fail_before_lookup();
    selected_choices_use_their_own_reason();
    malformed_maps_and_unknown_choices_fail_closed();
    disabled_rows_keep_their_base_description();
    availability_reads_do_not_mutate_rows();
    dispatch_requires_the_selected_choice_to_be_available();
}

ranged_numeric_preview_is_required_before_dispatch()
{
    row = slider(undefined);
    row.range = scripts\apparition\features\fov::range();
    tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false, 70.5),
        "An available fractional preview can dispatch without an enumerated catalog");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, false, undefined)
        && !scripts\apparition\menu\dispatch::can_start(row, false, "70.5"),
        "Missing and nonnumeric range previews cannot start a worker");
    tests\support\checks::expect(scripts\apparition\menu\availability::description(row, undefined)
        == "Wait for a valid numeric preview",
        "The footer explains an unavailable numeric preview before Use can run");
}

absent_maps_keep_existing_row_behavior()
{
    row = slider(["Crosshairs", "Sky"]);
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Sky") == ""
        && scripts\apparition\menu\availability::description(row, "Sky") == row.description
        && scripts\apparition\menu\dispatch::can_start(row, false, "Sky"),
        "Rows without per-choice reasons retain their original availability");
}

selected_choices_use_their_own_reason()
{
    row = slider(["Crosshairs", "Sky"]);
    row.choice_reasons = [];
    row.choice_reasons["Crosshairs"] = "";
    row.choice_reasons["Sky"] = "Sky travel is pending";
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Crosshairs") == ""
        && scripts\apparition\menu\availability::choice_reason(row, "Sky") == "Sky travel is pending",
        "String choices use their own map keys");
}

numeric_sliders_keep_existing_behavior_without_using_map_keys()
{
    row = slider([0.5, 1, 1.5]);
    tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false, 0.5)
        && scripts\apparition\menu\availability::description(row, 1.5) == row.description,
        "Existing numeric previews remain usable without a per-choice map");
    row.choice_reasons = [];
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, 0.5) != ""
        && scripts\apparition\menu\availability::choice_reason(row, 1) != "",
        "Fractional map keys and missing integer entries remain unavailable");
}

malformed_maps_and_unknown_choices_fail_closed()
{
    row = slider(["Crosshairs", "Sky"]);
    row.choice_reasons = 7;
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Crosshairs") != "",
        "A non-array choice map reports pending availability");

    row = slider(["Crosshairs", "Sky"]);
    row.choice_reasons = [];
    row.choice_reasons["Crosshairs"] = "";
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Sky") != "",
        "A selected choice without a reason entry reports pending availability");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Other") != ""
        && scripts\apparition\menu\availability::choice_reason(row, 4) != "",
        "Values outside the source catalog cannot inherit another choice's reason");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, spawnstruct()) != "",
        "Non-numeric and non-string selected values report pending availability");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, undefined) != "",
        "An undefined selected value reports pending availability when a map is present");

    row.choice_reasons["Sky"] = 7;
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Sky") != "",
        "A non-string selected reason reports pending availability");
    row.choice_reasons["Sky"] = "";
    row.choice_reasons["Stale"] = "";
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Crosshairs") == ""
        && scripts\apparition\menu\availability::choice_reason(row, "Stale") != "",
        "An unrelated stale key does not block a valid choice, but cannot be selected");

    row = slider(7);
    row.choice_reasons = [];
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Crosshairs") != "",
        "A choice map cannot validate against a malformed row catalog");
}

disabled_rows_keep_their_base_description()
{
    row = slider(["Crosshairs", "Sky"]);
    row.enabled = false;
    row.description = "Target movement is blocked";
    row.choice_reasons = 7;
    tests\support\checks::expect(scripts\apparition\menu\availability::description(row, "Sky") == row.description,
        "A disabled base row keeps its reason ahead of per-choice readiness");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, false, "Sky"),
        "A choice reason cannot enable a disabled base row");
}

availability_reads_do_not_mutate_rows()
{
    row = slider(["Crosshairs", "Sky"]);
    row.choice_reasons = [];
    row.choice_reasons["Crosshairs"] = "";
    row.choice_reasons["Sky"] = "Sky travel is pending";
    original_description = row.description;
    scripts\apparition\menu\availability::choice_reason(row, "Sky");
    scripts\apparition\menu\availability::description(row, "Sky");
    tests\support\checks::expect(row.values[0] == "Crosshairs" && row.values[1] == "Sky"
        && row.choice_reasons["Crosshairs"] == ""
        && row.choice_reasons["Sky"] == "Sky travel is pending"
        && row.description == original_description,
        "Availability reads leave row choices, reasons, and description unchanged");
}

dispatch_requires_the_selected_choice_to_be_available()
{
    row = slider(["Crosshairs", "Sky"]);
    row.choice_reasons = [];
    row.choice_reasons["Crosshairs"] = "";
    row.choice_reasons["Sky"] = "Sky travel is pending";
    tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false, "Crosshairs"),
        "An available slider choice can start while idle");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, false, "Sky"),
        "A blocked slider choice cannot start");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, false, "Other"),
        "An unknown slider choice cannot start when choice readiness is present");
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, true, "Crosshairs"),
        "Busy admission still rejects an otherwise available choice");
    row.enabled = false;
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, false, "Crosshairs"),
        "Base row enablement still gates an otherwise available choice");
    row.enabled = true;
    row.callback = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\dispatch::can_start(row, false, "Crosshairs"),
        "A slider choice cannot start without its callback");
}

slider(values)
{
    row = spawnstruct();
    row.kind = "slider";
    row.enabled = true;
    row.callback = ::record;
    row.description = "Slider command description";
    row.values = values;
    return row;
}

record(row, value)
{
    return true;
}

whole_numeric_choices_use_their_own_reason()
{
    row = slider([0, 1, 2]);
    row.choice_reasons = [];
    row.choice_reasons[0] = "";
    row.choice_reasons[1] = "";
    row.choice_reasons[2] = "This duration does not fit";
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, 0) == ""
        && scripts\apparition\menu\availability::choice_reason(row, 1.0) == "",
        "Nonnegative whole numeric choices use their normalized integer map keys");
    tests\support\checks::expect(scripts\apparition\menu\dispatch::can_start(row, false, 1)
        && !scripts\apparition\menu\dispatch::can_start(row, false, 2)
        && scripts\apparition\menu\availability::description(row, 2) == "This duration does not fit",
        "The selected numeric reason gates both dispatch and its displayed blocker");
    row.choice_reasons[3] = "";
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, 3) != "",
        "A stale numeric key cannot authorize a value outside the row catalog");
}

fractional_and_out_of_range_numeric_keys_fail_before_lookup()
{
    row = slider([0.5, -1, 2147483647, 2147483648.0]);
    row.choice_reasons = [];
    foreach (value in row.values)
        tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, value) != "",
            "Fractional, negative and out-of-range numeric map keys are rejected before conversion or lookup");
}
