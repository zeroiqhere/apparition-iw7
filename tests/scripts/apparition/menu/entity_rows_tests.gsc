// Entity teleport rows preserve validated native entry identities

run()
{
    ready_entries_keep_source_order_and_native_references();
    blocked_rows_show_precedence_without_exposing_entries();
    missing_and_malformed_snapshots_fail_closed();
    ready_empty_catalog_has_an_explanatory_row();
    model_routes_entity_teleports_to_the_row_builder();
}

ready_entries_keep_source_order_and_native_references()
{
    view = view();
    original_entries = view.entity_teleports.entries;
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == original_entries.size,
        "The page contains only the native wheel and perk entries supplied by the catalog");
    if (rows.size != original_entries.size)
        return;

    tests\support\checks::expect(rows[0].label == "Mystery Box"
        && rows[0].kind == "action" && rows[0].callback == scripts\apparition\menu\actions::entity_teleport
        && rows[0].target == view.target && !rows[0].lobby && rows[0].enabled
        && rows[0].teleport_entry == original_entries[0]
        && rows[0].selection_key == original_entries[0].point,
        "The source Mystery Box action targets the selected player and keeps its native entry");
    tests\support\checks::expect(isSubStr(rows[0].description, "native Mystery Wheel")
        && isSubStr(rows[0].description, "70 units") && isSubStr(rows[0].description, "face it")
        && isSubStr(rows[0].description, "rechecked on Use"),
        "The wheel description identifies the native entity and rechecks movement readiness");

    tests\support\checks::expect(rows[1].label == "Up N' Atoms"
        && original_entries[1].id == "perk_machine_revive"
        && rows[1].callback == scripts\apparition\menu\actions::entity_teleport
        && rows[1].target == view.target && !rows[1].lobby && rows[1].enabled
        && rows[1].teleport_entry == original_entries[1]
        && rows[1].selection_key == original_entries[1].point,
        "Perk entries keep their source label, order, target, and point identity");
    tests\support\checks::expect(isSubStr(rows[1].description, "native perk point")
        && isSubStr(rows[1].description, "70 units") && isSubStr(rows[1].description, "face it")
        && isSubStr(rows[1].description, "rechecked on Use"),
        "Perk rows describe native movement and the dispatch-time readiness check");
    tests\support\checks::expect(rows[2].label == rows[1].label
        && rows[2].teleport_entry == original_entries[2]
        && rows[2].selection_key == original_entries[2].point
        && rows[2].selection_key != rows[1].selection_key,
        "Same-label native perk machines keep distinct point selection keys");
    tests\support\checks::expect(rows[3].label == rows[1].label
        && rows[3].teleport_entry == original_entries[3]
        && rows[3].selection_key == rows[1].selection_key,
        "Repeated labels and point references remain as separate source rows");
    tests\support\checks::expect(view.entity_teleports.entries.size == 4
        && view.entity_teleports.entries[0] == original_entries[0]
        && view.entity_teleports.reason == ""
        && original_entries[0].id == "magic_wheel"
        && original_entries[1].label == "Up N' Atoms"
        && original_entries[1].point != original_entries[2].point
        && original_entries[3].point == original_entries[1].point,
        "Building rows leaves the catalog and native entries unchanged");
}

blocked_rows_show_precedence_without_exposing_entries()
{
    view = view();
    view.teleport.actor_reason = "Selected player authorization is pending";
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 4 && !rows[0].enabled
        && rows[0].description == view.teleport.actor_reason
        && rows[0].selection_key == view.entity_teleports.entries[0].point
        && !isDefined(rows[0].teleport_entry),
        "Actor-blocked actions keep selection keys but withhold native entry payloads");

    view = view();
    view.teleport.actor_reason = "Selected player authorization is pending";
    view.teleport.reason = "Selected player is not ready to move";
    view.entity_teleports.reason = "Native entity catalog is pending";
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 4 && !rows[0].enabled
        && rows[0].description == view.teleport.actor_reason
        && rows[0].selection_key == view.entity_teleports.entries[0].point
        && !isDefined(rows[0].teleport_entry),
        "Actor authorization takes precedence and blocked rows withhold native entries");
    tests\support\checks::expect(!rows[1].enabled && rows[1].description == view.teleport.actor_reason
        && rows[1].selection_key == view.entity_teleports.entries[1].point
        && !isDefined(rows[1].teleport_entry),
        "Every blocked action keeps its selection key but no teleport payload");

    view = view();
    view.teleport.actor_reason = "";
    view.teleport.reason = "Selected player is not ready to move";
    view.entity_teleports.reason = "Native entity catalog is pending";
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 4 && !rows[0].enabled
        && rows[0].description == view.teleport.reason
        && !isDefined(rows[0].teleport_entry)
        && rows[0].selection_key == view.entity_teleports.entries[0].point,
        "Movement readiness disables each action without exposing native entries");

    view = view();
    view.teleport.actor_reason = "";
    view.entity_teleports.reason = "Native entity catalog is pending";
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 4 && !rows[0].enabled
        && rows[0].description == view.entity_teleports.reason
        && rows[0].selection_key == view.entity_teleports.entries[0].point
        && !isDefined(rows[0].teleport_entry),
        "Catalog readiness disables valid entries and withholds their payloads");

    view = view();
    view.teleport.actor_reason = "";
    view.teleport.reason = "";
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 4 && rows[0].enabled
        && rows[0].teleport_entry == view.entity_teleports.entries[0],
        "Ready actor and movement context publishes the native entry payload");
}

missing_and_malformed_snapshots_fail_closed()
{
    rows = scripts\apparition\menu\entity_rows::build(undefined);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && !rows[0].enabled && isSubStr(rows[0].description, "Wait"),
        "A missing view has an explicit pending placeholder");

    view = view();
    view.entity_teleports = undefined;
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && rows[0].label == "Entity Teleports" && !rows[0].enabled
        && isSubStr(rows[0].description, "Wait"),
        "A missing native snapshot leaves an explicit pending placeholder");

    view = view();
    view.teleport = undefined;
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && !rows[0].enabled && isSubStr(rows[0].description, "Wait"),
        "Missing actor readiness fails closed before any native entry is published");

    view = view();
    view.teleport.actor_reason = 7;
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && !rows[0].enabled && !isDefined(rows[0].teleport_entry),
        "Malformed actor readiness rejects the complete row set");

    view = view();
    view.teleport.reason = 7;
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && !rows[0].enabled && !isDefined(rows[0].teleport_entry),
        "Malformed movement readiness rejects the complete row set");

    view = view();
    view.entity_teleports.reason = 7;
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && !rows[0].enabled && !isDefined(rows[0].teleport_entry),
        "Malformed catalog readiness rejects the complete row set");

    view = view();
    view.entity_teleports.entries = 7;
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && !rows[0].enabled && !isDefined(rows[0].teleport_entry),
        "A malformed entry list cannot publish a partial page");

    view = view();
    view.entity_teleports.entries = [];
    view.entity_teleports.reason = "Wait for native entity destinations";
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Entity Teleports"
        && rows[0].kind == "unavailable" && !rows[0].enabled
        && rows[0].description == view.entity_teleports.reason,
        "An empty pending catalog keeps an explicit unavailable placeholder");

    view = view();
    view.entity_teleports.entries[2] = undefined;
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && !rows[0].enabled && !isDefined(rows[0].teleport_entry),
        "A sparse entry list cannot publish its valid prefix");

    foreach (invalid in [7, spawnstruct()])
    {
        view = view();
        view.entity_teleports.entries[1] = invalid;
        rows = scripts\apparition\menu\entity_rows::build(view);
        tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
            && !rows[0].enabled && !isDefined(rows[0].teleport_entry),
            "An invalid entry invalidates the complete catalog");
    }

    foreach (invalid_kind in ["bgb", "crafting"])
    {
        view = view();
        view.entity_teleports.entries[1].kind = invalid_kind;
        rows = scripts\apparition\menu\entity_rows::build(view);
        tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
            && !isDefined(rows[0].teleport_entry),
            "Unsupported entity families are rejected rather than invented");
    }

    foreach (invalid_field in ["id", "label", "point"])
    {
        view = view();
        if (invalid_field == "id")
            view.entity_teleports.entries[1].id = "";
        else if (invalid_field == "label")
            view.entity_teleports.entries[1].label = "";
        else
            view.entity_teleports.entries[1].point = undefined;
        rows = scripts\apparition\menu\entity_rows::build(view);
        tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
            && !isDefined(rows[0].teleport_entry),
            "An incomplete native entry rejects the complete catalog");
    }
}

ready_empty_catalog_has_an_explanatory_row()
{
    view = view();
    view.entity_teleports.entries = [];
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "No Native Entity Destinations"
        && rows[0].kind == "unavailable" && !rows[0].enabled
        && !isDefined(rows[0].callback)
        && isSubStr(rows[0].description, "wheel") && isSubStr(rows[0].description, "perk"),
        "A ready empty catalog explains that no supported destinations exist");

    view = view();
    view.entity_teleports.entries = [];
    view.teleport.actor_reason = "Selected player authorization is pending";
    view.teleport.reason = "Selected player is not ready to move";
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "No Native Entity Destinations"
        && rows[0].description == view.teleport.actor_reason,
        "Actor readiness takes precedence over the empty-catalog explanation");

    view = view();
    view.entity_teleports.entries = [];
    view.teleport.actor_reason = "";
    view.teleport.reason = "Selected player is not ready to move";
    rows = scripts\apparition\menu\entity_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "No Native Entity Destinations"
        && rows[0].description == view.teleport.reason,
        "Movement readiness takes precedence over the empty-catalog explanation");
}

model_routes_entity_teleports_to_the_row_builder()
{
    view = view();
    rows = scripts\apparition\menu\model::build("Entity Teleports", view);
    tests\support\checks::expect(rows.size == view.entity_teleports.entries.size
        && rows[0].label == "Mystery Box"
        && rows[0].callback == scripts\apparition\menu\actions::entity_teleport
        && rows[0].teleport_entry == view.entity_teleports.entries[0],
        "The Entity Teleports page route returns the native destination rows");
}

view()
{
    result = spawnstruct();
    result.owner = spawnstruct();
    result.target = spawnstruct();
    result.teleport = spawnstruct();
    result.teleport.actor_reason = "";
    result.teleport.reason = "";
    fixture = tests\fixtures\entity_teleports::ready();
    perk = fixture.state.struct_class_names["script_noteworthy"]["perk_machine_revive"][0];
    other = tests\fixtures\spawn_points::point((100, 110, 120), (0, 270, 0));
    other.script_noteworthy = "perk_machine_revive";
    fixture.state.struct_class_names["script_noteworthy"]["perk_machine_revive"] = [other, perk, other];
    result.entity_teleports = scripts\apparition\maps\spaceland\entity_teleports::inspect(
        fixture.state, fixture.wheels);
    return result;
}
