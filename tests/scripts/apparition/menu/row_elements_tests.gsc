// Role contracts use plain handles and never allocate native HUD elements

run()
{
    row_kinds_allocate_only_the_source_roles();
    invalid_labels_follow_the_source_space_rule();
    retained_groups_must_match_the_current_role_shape();
    ownership_returns_only_the_present_handle_map();
    shifted_windows_compare_the_retained_group_with_its_actual_row();
}

row_kinds_allocate_only_the_source_roles()
{
    layout = scripts\apparition\menu\layout::defaults();
    foreach (kind in ["action", "unavailable", "submenu", "slider", "toggle"])
    {
        row = model_row(kind, "Visible option");
        foreach (display in ["Boxes", "Text", "Text Color"])
        {
            layout.bool_display = display;
            roles = scripts\apparition\menu\row_elements::roles(row, layout);
            value = kind == "submenu" || kind == "slider" || (kind == "toggle" && display == "Text");
            boxes = kind == "toggle" && display == "Boxes";
            tests\support\checks::expect(roles.size == 1 + (value ? 1 : 0) + (boxes ? 2 : 0)
                && scripts\engine\utility::array_contains(roles, "label"),
                "Each row owns a label and only its source value or checkbox roles");
            tests\support\checks::expect(scripts\engine\utility::array_contains(roles, "value") == value
                && scripts\engine\utility::array_contains(roles, "box") == boxes
                && scripts\engine\utility::array_contains(roles, "fill") == boxes,
                "Submenus, sliders and toggle display modes select distinct optional elements");
        }
    }
    roles = scripts\apparition\menu\row_elements::roles(model_row("unavailable", "  "), layout);
    tests\support\checks::expect(roles.size == 2 && scripts\engine\utility::array_contains(roles, "invalid_line"),
        "A blank spacer retains its label and adds the source row line");
}

invalid_labels_follow_the_source_space_rule()
{
    foreach (label in ["", " ", "   "])
        tests\support\checks::expect(scripts\apparition\menu\row_elements::invalid_label(label),
            "Empty and all-space labels require an invalid-option line");
    tests\support\checks::expect(scripts\apparition\menu\row_elements::invalid_label(undefined),
        "A missing source label is invalid");
    tests\support\checks::expect(!scripts\apparition\menu\row_elements::invalid_label(spawnstruct()),
        "A defined label without a character count follows the source valid-label branch");
    foreach (label in ["Unavailable", " A ", "\t"])
        tests\support\checks::expect(!scripts\apparition\menu\row_elements::invalid_label(label),
            "The source rejects spaces rather than all whitespace or disabled labels");
}

retained_groups_must_match_the_current_role_shape()
{
    layout = scripts\apparition\menu\layout::defaults();
    row = model_row("toggle", "God Mode");
    slot = spawnstruct();
    slot.elements = [];
    slot.elements["label"] = spawnstruct();
    slot.elements["box"] = spawnstruct();
    slot.elements["fill"] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\menu\row_elements::matches(slot, row, layout),
        "A complete Boxes group can retain its current native elements");
    layout.bool_display = "Text";
    tests\support\checks::expect(!scripts\apparition\menu\row_elements::matches(slot, row, layout),
        "A changed display mode requires fresh elements rather than missing-handle writes");
    slot.elements = [];
    slot.elements["label"] = spawnstruct();
    slot.elements["value"] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\menu\row_elements::matches(slot, row, layout),
        "A complete Text group matches its value role");
    slot.elements["value"] = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\row_elements::matches(slot, row, layout),
        "A removed required handle rejects retention");
}

ownership_returns_only_the_present_handle_map()
{
    slot = spawnstruct();
    slot.elements = [];
    slot.elements["label"] = spawnstruct();
    handles = scripts\apparition\menu\row_elements::owned(slot);
    tests\support\checks::expect(handles.size == 1 && handles["label"] == slot.elements["label"],
        "The existing handle map is the sole row ownership representation");
    tests\support\checks::expect(scripts\apparition\menu\row_elements::owned(undefined).size == 0,
        "An absent outgoing group owns no native handles");
}

model_row(kind, label)
{
    row = spawnstruct();
    row.kind = kind;
    row.label = label;
    return row;
}

shifted_windows_compare_the_retained_group_with_its_actual_row()
{
    layout = scripts\apparition\menu\layout::defaults();
    rows = [model_row("action", "A"), model_row("toggle", "B"), model_row("slider", "C"), model_row("action", "D")];
    slots = [];
    for (index = 0; index < 3; index++)
    {
        slot = spawnstruct();
        slot.elements = [];
        foreach (role in scripts\apparition\menu\row_elements::roles(rows[index], layout))
            slot.elements[role] = spawnstruct();
        slots[index] = slot;
    }
    tests\support\checks::expect(scripts\apparition\menu\row_elements::window_matches(slots, rows, 1, 1, layout),
        "A downward shift compares retained Boxes and slider groups at their new indices");
    tests\support\checks::expect(!scripts\apparition\menu\row_elements::window_matches(slots, rows, 1, 0, layout),
        "The same unrotated groups cannot be mistaken for the shifted row shapes");
    tests\support\checks::expect(scripts\apparition\menu\row_elements::window_matches([slots[1], slots[2], slots[0]], rows, 0, -1, layout),
        "An upward shift ignores the replaced edge and checks the two retained groups");
    layout.bool_display = "Text";
    tests\support\checks::expect(!scripts\apparition\menu\row_elements::window_matches(slots, rows, 1, 1, layout),
        "A retained group with a changed toggle display requires a fresh draw");
}
