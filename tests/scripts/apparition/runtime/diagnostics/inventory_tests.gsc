// Formatting contracts preserve native ordering without changing inventory

run()
{
    missing_and_invalid_lists_are_not_reported_as_empty();
    empty_and_ordered_lists_retain_count_and_indices();
    duplicate_and_non_string_entries_are_visible();
    the_sixteenth_entry_is_included_without_a_truncation_marker();
    later_entries_are_explicitly_truncated();
    script_slot_markers_keep_missing_and_non_string_values_distinct();
}

missing_and_invalid_lists_are_not_reported_as_empty()
{
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_list(undefined) == "unknown",
        "An absent native list is unknown rather than empty");
    foreach (invalid in [0, "weapon", spawnstruct()])
    {
        tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_list(invalid) == "unknown",
            "A non-array native result is unknown rather than empty");
    }
}

empty_and_ordered_lists_retain_count_and_indices()
{
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_list([]) == "count=0[]",
        "A known empty list records its zero count");
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_list(["second", "first"]) == "count=2[0=second,1=first]",
        "Native order remains visible through the recorded indices");
}

duplicate_and_non_string_entries_are_visible()
{
    values = ["weapon", "weapon", 7];
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_list(values) == "count=3[0=weapon,1=weapon,2=<non-string>]",
        "Duplicate names are preserved and invalid entry types are marked");
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_list([""]) == "count=1[0=]",
        "A defined empty string remains different from a missing list");
}

the_sixteenth_entry_is_included_without_a_truncation_marker()
{
    values = [];
    for (index = 0; index < 16; index++)
        values[index] = "w";
    expected = "count=16[0=w,1=w,2=w,3=w,4=w,5=w,6=w,7=w,8=w,9=w,10=w,11=w,12=w,13=w,14=w,15=w]";
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_list(values) == expected,
        "The final admitted entry is retained without claiming truncation");
}

later_entries_are_explicitly_truncated()
{
    values = [];
    for (index = 0; index < 17; index++)
        values[index] = "w";
    values[16] = "omitted";
    expected = "count=17[0=w,1=w,2=w,3=w,4=w,5=w,6=w,7=w,8=w,9=w,10=w,11=w,12=w,13=w,14=w,15=w,truncated]";
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_list(values) == expected,
        "The original count and truncation marker disclose omitted entries");
}

script_slot_markers_keep_missing_and_non_string_values_distinct()
{
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_item(undefined) == "<undefined>",
        "A missing bookkeeping marker remains explicit");
    foreach (invalid in [0, [], spawnstruct()])
    {
        tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_item(invalid) == "<non-string>",
            "A non-string bookkeeping value is never presented as a weapon name");
    }
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\inventory::describe_item("weapon+alt") == "weapon+alt",
        "A native name keeps its alternate-mode suffix");
}
