// Ownership checks use plain handles without creating or destroying native HUDs

run()
{
    traversal_uses_current_rows_without_a_second_handle_registry();
    traversal_includes_only_a_present_outgoing_group();
    delayed_retirement_requires_the_same_live_outgoing_group();
    traversal_includes_optional_spacer_lines_without_value_or_boxes();
    active_row_redraw_preserves_the_outgoing_fade_owner();
}

traversal_uses_current_rows_without_a_second_handle_registry()
{
    hud = ownership_hud();
    replaced = hud.rows[0];
    hud.rows[0] = ownership_row();
    handles = scripts\apparition\menu\ownership::elements(hud);
    tests\support\checks::expect(handles.size == 10 && handles[0] == hud.fixed_elements[0]
        && handles[1] == hud.fixed_elements[1],
        "Traversal includes the fixed elements once before the current row handles");
    foreach (row in hud.rows)
    {
        foreach (element in row.elements)
            tests\support\checks::expect(occurrences(handles, element) == 1,
                "Every present handle in the replacement and retained groups is traversed once");
    }
    foreach (handle in handles)
        tests\support\checks::expect(handle != replaced.elements["label"] && handle != replaced.elements["value"]
            && handle != replaced.elements["box"] && handle != replaced.elements["fill"],
            "A replaced group cannot remain in the cleanup or reposition traversal");
    tests\support\checks::expect(hud.fixed_elements.size == 2 && hud.rows.size == 2
        && occurrences(handles, hud.rows[0].elements["label"]) == 1,
        "Traversal does not append row handles to the fixed registry or change row ownership");
}

traversal_includes_only_a_present_outgoing_group()
{
    hud = ownership_hud();
    outgoing = ownership_row();
    hud.spare = outgoing;
    handles = scripts\apparition\menu\ownership::elements(hud);
    tests\support\checks::expect(handles.size == 14,
        "A fading outgoing group adds only its own present handles");
    foreach (element in outgoing.elements)
        tests\support\checks::expect(occurrences(handles, element) == 1,
            "Every outgoing handle participates in cleanup and repositioning exactly once");
    hud.spare = undefined;
    handles = scripts\apparition\menu\ownership::elements(hud);
    tests\support\checks::expect(handles.size == 10,
        "An already retired outgoing group contributes no stale handles");
    tests\support\checks::expect(scripts\apparition\menu\row_elements::owned(undefined).size == 0,
        "An absent outgoing group has no physical elements to visit");
}

delayed_retirement_requires_the_same_live_outgoing_group()
{
    hud = ownership_hud();
    outgoing = ownership_row();
    tests\support\checks::expect(!scripts\apparition\menu\ownership::can_retire_spare(hud, outgoing),
        "An absent spare rejects a delayed retirement");
    hud.spare = outgoing;
    tests\support\checks::expect(scripts\apparition\menu\ownership::can_retire_spare(hud, outgoing),
        "The current outgoing group can retire from its live HUD");
    hud.spare = ownership_row();
    tests\support\checks::expect(!scripts\apparition\menu\ownership::can_retire_spare(hud, outgoing),
        "An earlier timer cannot retire a replacement outgoing group");
    hud.spare = outgoing;
    hud.released = true;
    tests\support\checks::expect(!scripts\apparition\menu\ownership::can_retire_spare(hud, outgoing),
        "A closed HUD rejects its outstanding retirement timer");
}

ownership_hud()
{
    hud = spawnstruct();
    hud.released = false;
    hud.fixed_elements = [spawnstruct(), spawnstruct()];
    hud.rows = [ownership_row(), ownership_row()];
    return hud;
}

ownership_row()
{
    row = spawnstruct();
    row.elements = [];
    row.elements["label"] = spawnstruct();
    row.elements["value"] = spawnstruct();
    row.elements["box"] = spawnstruct();
    row.elements["fill"] = spawnstruct();
    return row;
}

occurrences(handles, expected)
{
    count = 0;
    foreach (element in handles)
    {
        if (element == expected)
            count++;
    }
    return count;
}

active_row_redraw_preserves_the_outgoing_fade_owner()
{
    hud = ownership_hud();
    active = spawnstruct();
    active.elements = [];
    outgoing = spawnstruct();
    outgoing.elements = [];
    hud.rows = [active];
    hud.spare = outgoing;
    // Empty handle maps isolate the ownership transition from native destruction
    scripts\apparition\menu\ownership::release_rows(hud);
    tests\support\checks::expect(hud.rows.size == 0 && hud.spare == outgoing
        && scripts\apparition\menu\ownership::can_retire_spare(hud, outgoing),
        "A full option redraw leaves the outgoing group with its original fade timer");
}

traversal_includes_optional_spacer_lines_without_value_or_boxes()
{
    hud = ownership_hud();
    row = spawnstruct();
    row.elements = [];
    row.elements["label"] = spawnstruct();
    row.elements["invalid_line"] = spawnstruct();
    hud.rows = [row];
    handles = scripts\apparition\menu\ownership::elements(hud);
    tests\support\checks::expect(handles.size == 4 && occurrences(handles, row.elements["label"]) == 1
        && occurrences(handles, row.elements["invalid_line"]) == 1,
        "A spacer contributes its label and line without any unused optional handles");
}
