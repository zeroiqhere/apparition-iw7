// Captured machine identities must still resolve in the current native registries

run()
{
    selected_wheel_precedes_perks_in_native_group_order();
    fire_sale_keeps_the_selected_wheel_without_selecting_every_usable_wheel();
    wheel_area_transition_rejects_the_old_selected_pointer();
    captured_entries_follow_live_vectors_without_following_replacements();
    identical_coordinates_do_not_replace_captured_identity();
    only_current_catalog_keys_and_point_pairs_resolve();
    unpowered_and_inactive_perks_remain_destinations_without_activation();
    missing_or_malformed_registries_never_publish_partial_entries();
    known_empty_registries_have_no_invented_destinations();
}

selected_wheel_precedes_perks_in_native_group_order()
{
    fixture = tests\fixtures\entity_teleports::ready();
    first = fixture.state.struct_class_names["script_noteworthy"]["perk_machine_revive"][0];
    second = tests\fixtures\spawn_points::point((11, 22, 33), (0, 270, 0));
    second.script_noteworthy = first.script_noteworthy;
    fixture.state.struct_class_names["script_noteworthy"][first.script_noteworthy] = [second, first, second];
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason == "" && result.entries.size == 4,
        "One selected wheel and every native perk index form the catalog");
    if (result.entries.size != 4)
        return;
    tests\support\checks::expect(result.entries[0].label == "Mystery Box"
        && result.entries[0].kind == "wheel" && result.entries[0].id == "magic_wheel"
        && result.entries[0].point == fixture.wheels[0],
        "The source Mystery Box row identifies the selected native Mystery Wheel");
    tests\support\checks::expect(result.entries[1].label == "Up N' Atoms"
        && result.entries[1].kind == "perk" && result.entries[1].id == first.script_noteworthy
        && result.entries[1].point == second && result.entries[2].point == first
        && result.entries[3].point == second,
        "Perk labels come from the shared catalog and preserve each native group index without deduplication");
    tests\support\checks::expect(!isDefined(result.entries[0].origin)
        && !isDefined(result.entries[1].angles),
        "Catalog entries keep point references instead of copied coordinates");
}

fire_sale_keeps_the_selected_wheel_without_selecting_every_usable_wheel()
{
    fixture = tests\fixtures\entity_teleports::ready();
    fixture.state.flag = [];
    fixture.state.flag["fire_sale"] = true;
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason == "" && result.entries.size == 2
        && result.entries[0].point == fixture.wheels[0],
        "Fire Sale does not turn every temporarily usable wheel into the selected wheel");
    tests\support\checks::expect(fixture.state.current_active_wheel == fixture.wheels[0]
        && fixture.state.flag["fire_sale"],
        "Catalog reads leave native wheel and Fire Sale state untouched");
}

wheel_area_transition_rejects_the_old_selected_pointer()
{
    fixture = tests\fixtures\entity_teleports::ready();
    captured = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels).entries[0];
    // Native activation changes the area before replacing the selected pointer
    fixture.state._id_A8E2 = "polar";
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason != "" && result.entries.size == 0,
        "A changed native area cannot authorize the old pointer during activation");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\entity_teleports::resolve(
        fixture.state, fixture.wheels, captured)), "A displayed old wheel cannot dispatch during an area switch");
    fixture.state.current_active_wheel = fixture.wheels[1];
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason == "" && result.entries[0].point == fixture.wheels[1],
        "The newly selected native pointer becomes available after matching its area");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\entity_teleports::resolve(
        fixture.state, fixture.wheels, captured)), "A completed area switch still rejects the previously displayed wheel");
}

captured_entries_follow_live_vectors_without_following_replacements()
{
    fixture = tests\fixtures\entity_teleports::ready();
    captured = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels).entries[1];
    point = captured.point;
    point.origin = (101, 102, 103);
    resolved = scripts\apparition\maps\spaceland\entity_teleports::resolve(fixture.state, fixture.wheels, captured);
    tests\support\checks::expect(isDefined(resolved) && resolved.point == point
        && resolved.point.origin == (101, 102, 103),
        "A current native point supplies its live vectors at dispatch");
    fixture.state.struct_class_names["script_noteworthy"][captured.id] = [];
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\entity_teleports::resolve(
        fixture.state, fixture.wheels, captured)), "A removed point is rejected instead of resolving a new numeric index");
}

identical_coordinates_do_not_replace_captured_identity()
{
    fixture = tests\fixtures\entity_teleports::ready();
    captured = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels).entries[1];
    replacement = tests\fixtures\spawn_points::point(captured.point.origin, captured.point.angles);
    replacement.script_noteworthy = captured.id;
    // Matching vectors cannot stand in for the object that the displayed row captured
    fixture.state.struct_class_names["script_noteworthy"][captured.id] = [replacement];
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\entity_teleports::resolve(
        fixture.state, fixture.wheels, captured)), "Equal coordinates on a replacement struct do not satisfy the captured identity");
}

only_current_catalog_keys_and_point_pairs_resolve()
{
    fixture = tests\fixtures\entity_teleports::ready();
    captured = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels).entries[1];
    captured.label = "Display text does not grant authority";
    tests\support\checks::expect(isDefined(scripts\apparition\maps\spaceland\entity_teleports::resolve(
        fixture.state, fixture.wheels, captured)), "A display label is not an authorization key");
    captured.kind = "wheel";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\entity_teleports::resolve(
        fixture.state, fixture.wheels, captured)), "A native point cannot be used under another target kind");
    captured.kind = "perk";
    captured.id = "perk_machine_tough";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\entity_teleports::resolve(
        fixture.state, fixture.wheels, captured)), "A point must remain in its exact perk registry");
    foreach (invalid in [7, "wheel", [], spawnstruct()])
        tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\entity_teleports::resolve(
            fixture.state, fixture.wheels, invalid)), "Malformed captured entries do not resolve");
}

unpowered_and_inactive_perks_remain_destinations_without_activation()
{
    fixture = tests\fixtures\entity_teleports::ready();
    point = fixture.state.struct_class_names["script_noteworthy"]["perk_machine_revive"][0];
    point.powered_on = false;
    fixture.state.current_interaction_structs = [];
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason == "" && result.entries.size == 2
        && result.entries[1].point == point,
        "A direct source teleport includes a registered perk even outside the current powered interaction set");
    tests\support\checks::expect(!point.powered_on && fixture.state.current_interaction_structs.size == 0,
        "Reading a destination neither powers its machine nor activates its area");
}

missing_or_malformed_registries_never_publish_partial_entries()
{
    fixture = tests\fixtures\entity_teleports::ready();
    foreach (invalid in [7, "wheels", spawnstruct()])
    {
        result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, invalid);
        tests\support\checks::expect(result.reason != "" && result.entries.size == 0,
            "The live wheel query must supply an array before membership is checked");
    }
    fixture.state.struct_class_names["script_noteworthy"]["perk_machine_tough"] = [7];
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason != "" && result.entries.size == 0,
        "A later malformed perk cannot expose a valid prefix of the catalog");
    fixture = tests\fixtures\entity_teleports::ready();
    fixture.wheels[0].angles = undefined;
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason != "" && result.entries.size == 0,
        "Missing native angles do not receive a guessed orientation");
    fixture = tests\fixtures\entity_teleports::ready();
    fixture.state.current_active_wheel = tests\fixtures\spawn_points::point((1, 2, 3), (0, 0, 0));
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason != "" && result.entries.size == 0,
        "An unregistered selected wheel cannot become a destination");
    fixture = tests\fixtures\entity_teleports::ready();
    fixture.state.struct_class_names["script_noteworthy"]["perk_machine_revive"][0].script_noteworthy = "perk_machine_tough";
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason != "" && result.entries.size == 0,
        "A changed point type must still match its classified perk key");
    fixture = tests\fixtures\entity_teleports::ready();
    sparse = [];
    sparse[3] = fixture.state.struct_class_names["script_noteworthy"]["perk_machine_revive"][0];
    fixture.state.struct_class_names["script_noteworthy"]["perk_machine_revive"] = sparse;
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason != "" && result.entries.size == 0,
        "A sparse classified group cannot silently retarget numeric registry order");
}

known_empty_registries_have_no_invented_destinations()
{
    fixture = tests\fixtures\entity_teleports::ready();
    fixture.wheels = [];
    fixture.state.current_active_wheel = undefined;
    fixture.state.struct_class_names["script_noteworthy"] = [];
    result = scripts\apparition\maps\spaceland\entity_teleports::inspect(fixture.state, fixture.wheels);
    tests\support\checks::expect(result.reason == "" && result.entries.size == 0,
        "Known empty native registries do not invent BGB, crafting or other destinations");
}
