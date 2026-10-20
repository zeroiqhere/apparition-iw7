// Sound pages expose only current perk-machine rows with verified aliases

run()
{
    sounds_page_links_only_when_perk_rows_are_available();
    sounds_page_explains_empty_and_unmapped_categories();
    rejected_actor_reason_precedes_sound_snapshot_reads();
    absent_or_nonstruct_views_fail_closed();
    perk_page_emits_catalog_ordered_jingle_and_quote_actions();
    perk_page_accepts_a_valid_sparse_subset_and_empty_catalog();
    pending_or_malformed_snapshots_publish_no_partial_actions();
    malformed_entries_reject_the_whole_snapshot();
    rendering_keeps_sound_state_and_aliases_out_of_rows();
}

sounds_page_links_only_when_perk_rows_are_available()
{
    view = ready_view();
    catalog = scripts\apparition\maps\spaceland\perks::catalog();
    view.perk_sounds = snapshot([sound_entry(catalog[0], "", "")]);
    rows = scripts\apparition\menu\sound_rows::build("Sounds & Jingles", view);
    row = rows[0];

    tests\support\checks::expect(rows.size == 2 && row.label == "Perk Jingles & Quotes"
        && row.kind == "submenu" && row.destination == "Perk Jingles & Quotes"
        && row.callback == scripts\apparition\menu\actions::open_page
        && row.target == view.target && !row.lobby && row.enabled,
        "A valid native perk snapshot enables the selected-player perk sound page");
    tests\support\checks::expect(rows[1].label == "Player Dialogue Categories"
        && rows[1].kind == "unavailable" && !rows[1].enabled
        && !isDefined(rows[1].callback),
        "Unmapped player dialogue categories remain explicitly unavailable");
}

sounds_page_explains_empty_and_unmapped_categories()
{
    view = ready_view();
    view.perk_sounds = snapshot([]);
    rows = scripts\apparition\menu\sound_rows::build("Sounds & Jingles", view);
    tests\support\checks::expect(rows.size == 2 && !rows[0].enabled
        && rows[0].description == "No placed perk machines were found",
        "An empty but valid native catalog explains why the perk page link is disabled");
    tests\support\checks::expect(rows[1].label == "Player Dialogue Categories"
        && rows[1].description == "BO3 sndplayervox has no verified IW7 category map",
        "The unsupported dynamic category tree remains visible with its evidence gap");

    view.perk_sounds = undefined;
    rows = scripts\apparition\menu\sound_rows::build("Sounds & Jingles", view);
    tests\support\checks::expect(!rows[0].enabled
        && rows[0].description == "Wait for current perk sound data"
        && rows[1].label == "Player Dialogue Categories",
        "Pending native data blocks only the perk-page link and keeps the unsupported row visible");
}

rejected_actor_reason_precedes_sound_snapshot_reads()
{
    view = ready_view();
    view.target = 17;
    view.target_actor_reason = "The player is no longer in the current roster";
    view.perk_sounds = "malformed snapshot";
    rows = scripts\apparition\menu\sound_rows::build("Sounds & Jingles", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].target == view.target
        && rows[0].description == view.target_actor_reason,
        "Rejected actor admission wins before parent readiness data is inspected");

    rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled
        && rows[0].kind == "unavailable" && rows[0].description == view.target_actor_reason,
        "Rejected actor admission returns one blocked perk row before snapshot members are read");
}

absent_or_nonstruct_views_fail_closed()
{
    assert_missing_view("Sounds & Jingles", undefined);
    assert_missing_view("Perk Jingles & Quotes", undefined);
    foreach (invalid in [0, "view", (1, 2, 3), []])
    {
        assert_missing_view("Sounds & Jingles", invalid);
        assert_missing_view("Perk Jingles & Quotes", invalid);
    }
}

assert_missing_view(page, view)
{
    rows = scripts\apparition\menu\sound_rows::build(page, view);
    if (page == "Sounds & Jingles")
    {
        tests\support\checks::expect(rows.size == 2 && !rows[0].enabled
            && !isDefined(rows[0].target) && rows[0].description == "Wait for a valid player roster"
            && rows[1].label == "Player Dialogue Categories",
            "A missing or non-struct parent view returns an inert link and keeps the evidence row");
    }
    else
    {
        tests\support\checks::expect(rows.size == 1 && !rows[0].enabled
            && rows[0].kind == "unavailable" && rows[0].description == "Wait for a valid player roster",
            "A missing or non-struct perk view returns one inert roster row");
    }
}

perk_page_emits_catalog_ordered_jingle_and_quote_actions()
{
    catalog = scripts\apparition\maps\spaceland\perks::catalog();
    view = ready_view();
    view.perk_sounds = snapshot([
        sound_entry(catalog[1], "", "Character quote alias is unavailable"),
        sound_entry(catalog[6], "Jingle alias is unavailable", "")
    ]);
    rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
    tests\support\checks::expect(rows.size == 4,
        "Each supported perk emits an alternating jingle and quote action");
    if (rows.size != 4)
        return;

    tests\support\checks::expect(rows[0].label == "Tuff Nuff Jingle"
        && rows[0].perk_id == catalog[1].id && rows[0].sound_kind == "Jingle"
        && rows[0].selection_key == catalog[1].id + ":Jingle" && rows[0].enabled,
        "A ready jingle uses the canonical ID and stable selection key");
    tests\support\checks::expect(rows[1].label == "Tuff Nuff Quote"
        && rows[1].perk_id == catalog[1].id && rows[1].sound_kind == "Quote"
        && rows[1].selection_key == catalog[1].id + ":Quote" && !rows[1].enabled
        && rows[1].description == "Character quote alias is unavailable",
        "An unavailable quote alias blocks only its own action");
    tests\support\checks::expect(rows[2].label == "Mule Munchies Jingle"
        && rows[2].perk_id == catalog[6].id && rows[2].sound_kind == "Jingle"
        && !rows[2].enabled && rows[2].description == "Jingle alias is unavailable"
        && rows[3].label == "Mule Munchies Quote" && rows[3].enabled,
        "The later canonical perk stays in order with independent jingle readiness");
    foreach (row in rows)
        tests\support\checks::expect(row.kind == "action"
            && row.callback == scripts\apparition\menu\actions::play_perk_sound
            && row.target == view.target && !row.lobby,
            "Each sound action targets the selected player in personal scope");
    tests\support\checks::expect(rows[0].description == "Request the native sound for this player; nearby players may hear it. Playback completion is not confirmed",
        "Ready actions describe a request without claiming playback completion");
}

perk_page_accepts_a_valid_sparse_subset_and_empty_catalog()
{
    catalog = scripts\apparition\maps\spaceland\perks::catalog();
    view = ready_view();
    view.perk_sounds = snapshot([sound_entry(catalog[0], "", ""), sound_entry(catalog[9], "", "")]);
    rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
    tests\support\checks::expect(rows.size == 4 && rows[0].label == "Up N' Atoms Jingle"
        && rows[2].label == "Slappy Taffy Jingle",
        "A sparse native machine catalog keeps its canonical relative order");

    view.perk_sounds = snapshot([]);
    rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].kind == "unavailable"
        && rows[0].label == "Perk Jingles & Quotes"
        && rows[0].description == "No placed perk machines were found",
        "An empty valid registry returns one explanatory row instead of a blank page");
}

pending_or_malformed_snapshots_publish_no_partial_actions()
{
    view = ready_view();
    view.perk_sounds = undefined;
    expect_pending(view, "A missing snapshot returns one inert pending row");
    foreach (invalid in [7, "snapshot", (1, 2, 3), []])
    {
        view.perk_sounds = invalid;
        rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
        tests\support\checks::expect(rows.size == 1 && !rows[0].enabled
            && rows[0].kind == "unavailable"
            && rows[0].description == "Wait for current perk sound data",
            "Missing or non-struct snapshots return one inert pending row");
    }

    view.perk_sounds = spawnstruct();
    view.perk_sounds.reason = 17;
    view.perk_sounds.entries = [];
    expect_pending(view, "A non-string readiness reason fails closed");

    view.perk_sounds.reason = "Wait for native perk machines";
    view.perk_sounds.entries = 17;
    rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].description == "Wait for native perk machines"
        && !rows[0].enabled,
        "A typed pending reason is preserved without publishing actions");
    view.perk_sounds.entries = undefined;
    rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].description == "Wait for native perk machines"
        && !rows[0].enabled,
        "A typed pending reason is preserved before absent entry data is inspected");

    view.perk_sounds.reason = "";
    view.perk_sounds.entries = undefined;
    expect_pending(view, "A missing entries array cannot imply an empty valid catalog");

    view.perk_sounds.entries = 17;
    expect_pending(view, "A non-array entries value fails closed");
}

malformed_entries_reject_the_whole_snapshot()
{
    catalog = scripts\apparition\maps\spaceland\perks::catalog();
    view = ready_view();
    good = sound_entry(catalog[0], "", "");
    late = sound_entry(catalog[8], "", "");

    entries = [];
    entries[0] = good;
    entries[2] = late;
    view.perk_sounds = snapshot(entries);
    expect_pending(view, "A sparse entries array cannot publish any partial sound actions");

    expect_bad_entries(view, [good, sound_entry(catalog[0], "", "")],
        "A duplicate canonical ID rejects the entire snapshot");
    expect_bad_entries(view, [late, good],
        "Out-of-order canonical IDs reject the entire snapshot");
    unknown = sound_entry(catalog[0], "", "");
    unknown.id = "unknown_perk_machine";
    expect_bad_entries(view, [unknown], "An unknown perk ID rejects the entire snapshot");
    wrong_label = sound_entry(catalog[0], "", "");
    wrong_label.label = "Foreign Label";
    expect_bad_entries(view, [wrong_label], "A label that does not match its canonical ID is rejected");
    malformed_reason = sound_entry(catalog[0], "", "");
    malformed_reason.quote_reason = 1;
    expect_bad_entries(view, [malformed_reason], "Every alias readiness reason must be a string");
    missing_jingle_reason = sound_entry(catalog[0], "", "");
    missing_jingle_reason.jingle_reason = undefined;
    expect_bad_entries(view, [missing_jingle_reason], "A missing jingle reason rejects the full snapshot");
}

rendering_keeps_sound_state_and_aliases_out_of_rows()
{
    catalog = scripts\apparition\maps\spaceland\perks::catalog();
    view = ready_view();
    entry = sound_entry(catalog[0], "", "");
    entry.native_machine = "must not be copied";
    view.perk_sounds = snapshot([entry]);
    view.target.SoundSentinel = "unchanged";
    rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
    row = rows[0];

    tests\support\checks::expect(view.target.SoundSentinel == "unchanged"
        && entry.native_machine == "must not be copied",
        "Rendering does not mutate the selected player or captured entry");
    tests\support\checks::expect(!isDefined(row.checked) && !isDefined(row.playing)
        && !isDefined(row.jingle) && !isDefined(row.quote) && !isDefined(row.alias)
        && !isDefined(row.native_machine) && !isDefined(row.handle) && !isDefined(row.element),
        "Sound rows store no toggle state, raw alias, native reference or handle");
}

expect_pending(view, message)
{
    rows = scripts\apparition\menu\sound_rows::build("Perk Jingles & Quotes", view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled
        && rows[0].kind == "unavailable"
        && rows[0].description == "Wait for current perk sound data", message);
}

expect_bad_entries(view, entries, message)
{
    view.perk_sounds = snapshot(entries);
    expect_pending(view, message);
}

ready_view()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.target_actor_reason = "";
    return view;
}

snapshot(entries)
{
    result = spawnstruct();
    result.reason = "";
    result.entries = entries;
    return result;
}

sound_entry(perk, jingle_reason, quote_reason)
{
    result = spawnstruct();
    result.id = perk.id;
    result.label = perk.label;
    result.jingle_reason = jingle_reason;
    result.quote_reason = quote_reason;
    return result;
}
