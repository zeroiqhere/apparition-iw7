// Result rows expose native quest observations without creating a gameplay action

run()
{
    the_current_arcade_step_opens_its_result_page_for_the_menu_owner();
    observed_results_have_source_order_and_read_only_checkmarks();
    late_history_is_unknown_until_the_native_quest_advances();
    pending_or_malformed_views_cannot_invent_results();
}

the_current_arcade_step_opens_its_result_page_for_the_menu_owner()
{
    view = result_view(3, false);
    view.ghost_progress = scripts\apparition\maps\spaceland\ghosts::progress(view.source);
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    row = rows[4];
    tests\support\checks::expect(row.label == "Arcade Critical Shots" && row.kind == "submenu"
        && row.enabled && !row.checked && row.destination == "Arcade Results"
        && row.target == view.owner && !row.lobby
        && row.callback == scripts\apparition\menu\actions::open_page,
        "The current arcade stage opens a read-only owner-scoped result page");
    tests\support\checks::expect(!view.host,
        "The result page does not require lobby mutation authority");
    view.source._id_13F1B["ghost"] = 4;
    view.ghost_progress = scripts\apparition\maps\spaceland\ghosts::progress(view.source);
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows[4].checked && !rows[4].enabled && !isDefined(rows[4].callback),
        "Only later native quest progress checks the overall arcade stage");
}

observed_results_have_source_order_and_read_only_checkmarks()
{
    view = result_view(3, true);
    watch = view.source.apparition_arcade_history;
    scripts\apparition\maps\spaceland\arcade_history::observe(view.source, watch, "zombie_zoom");
    scripts\apparition\maps\spaceland\arcade_history::observe(view.source, watch, "black_hole");
    view.arcade_results = scripts\apparition\maps\spaceland\arcade_history::inspect(view.source);
    rows = scripts\apparition\menu\model::build("Arcade Results", view);
    tests\support\checks::expect(rows.size == 6 && rows[0].label == "Arcade Results: 2/5",
        "The header counts distinct observed game results");
    tests\support\checks::expect(rows[1].label == "Zombie Zoom: Observed" && rows[1].checked
        && rows[2].label == "Bowling for Planets: Pending" && !rows[2].checked
        && rows[3].label == "Rings of Saturn: Pending"
        && rows[4].label == "Cryptid Attack: Pending"
        && rows[5].label == "Black Hole: Observed" && rows[5].checked,
        "The five native game IDs keep their source order and separate result states");
    foreach (row in rows)
        tests\support\checks::expect(!row.enabled && !isDefined(row.callback)
            && !scripts\apparition\menu\dispatch::can_start(row, false),
            "A result row cannot dispatch a score, shot, throw or quest mutation");
    tests\support\checks::expect(view.source._id_13F1B["ghost"] == 3
        && watch.seen["zombie_zoom"] && watch.seen["black_hole"],
        "Rendering preserves both native quest position and owned observation history");

    foreach (arcade in scripts\apparition\maps\spaceland\arcade_history::catalog())
        scripts\apparition\maps\spaceland\arcade_history::observe(view.source, watch, arcade.id);
    view.arcade_results = scripts\apparition\maps\spaceland\arcade_history::inspect(view.source);
    view.ghost_progress = scripts\apparition\maps\spaceland\ghosts::progress(view.source);
    overall = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(view.arcade_results.count == 5 && !overall[4].checked
        && overall[4].destination == "Arcade Results" && view.source._id_13F1B["ghost"] == 3,
        "Five observed results cannot complete or replace the native overall quest stage");
}

late_history_is_unknown_until_the_native_quest_advances()
{
    view = result_view(3, false);
    rows = scripts\apparition\menu\model::build("Arcade Results", view);
    tests\support\checks::expect(rows.size == 6 && rows[0].label == "Arcade Results: Unknown/5",
        "A late-loaded observer cannot reconstruct earlier per-game results");
    for (index = 1; index < rows.size; index++)
        tests\support\checks::expect(!rows[index].checked && isSubStr(rows[index].label, ": Unknown")
            && rows[index].description != "", "Unknown is explained instead of being presented as a confirmed missing result");
    view.source._id_13F1B["ghost"] = 4;
    view.arcade_results = scripts\apparition\maps\spaceland\arcade_history::inspect(view.source);
    rows = scripts\apparition\menu\model::build("Arcade Results", view);
    tests\support\checks::expect(rows[0].label == "Arcade Results: 5/5",
        "Later native quest progress establishes completion even without early observations");
    for (index = 1; index < rows.size; index++)
        tests\support\checks::expect(rows[index].checked && isSubStr(rows[index].label, ": Completed"),
            "Native stage advancement, rather than a menu-owned event count, confirms completion");
}

pending_or_malformed_views_cannot_invent_results()
{
    view = result_view(3, false);
    view.arcade_results = undefined;
    rows = scripts\apparition\menu\arcade_rows::build(view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled && !isDefined(rows[0].callback),
        "A missing snapshot remains a single explained unavailable row");
    foreach (bad in [17, "wrong type"])
    {
        view.arcade_results = bad;
        rows = scripts\apparition\menu\arcade_rows::build(view);
        tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
            "Scalar snapshots are rejected before result fields are read");
    }
    foreach (fault in ["games", "id", "id type", "label", "wrong label", "status", "count", "count type", "count fraction", "count negative"])
    {
        view = result_view(3, false);
        if (fault == "games")
            view.arcade_results.games = 17;
        else if (fault == "id")
            view.arcade_results.games[0].id = "foreign_game";
        else if (fault == "id type")
            view.arcade_results.games[0].id = 17;
        else if (fault == "label")
            view.arcade_results.games[0].label = 17;
        else if (fault == "wrong label")
            view.arcade_results.games[0].label = "A different game";
        else if (fault == "status")
            view.arcade_results.games[0].status = "Invented";
        else if (fault == "count type")
            view.arcade_results.count = "Wrong type";
        else if (fault == "count fraction")
            view.arcade_results.count = 2.5;
        else if (fault == "count negative")
            view.arcade_results.count = -2;
        else
            view.arcade_results.count = 6;
        rows = scripts\apparition\menu\arcade_rows::build(view);
        tests\support\checks::expect(rows.size == 1 && !rows[0].enabled && !isDefined(rows[0].callback),
            "Invalid game identity, shape, status or count cannot advertise a result");
    }
}

result_view(step, early)
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.host = false;
    view.source = tests\fixtures\ghosts::quest(early ? 2 : step);
    if (early)
    {
        watch = scripts\apparition\maps\spaceland\arcade_history::create();
        view.source.apparition_arcade_history = watch;
        // Model contracts admit a ready listener; capture scheduling has separate tests
        watch.waiting = true;
        scripts\apparition\maps\spaceland\arcade_history::begin(view.source, watch);
        view.source._id_13F1B["ghost"] = step;
    }
    view.arcade_results = scripts\apparition\maps\spaceland\arcade_history::inspect(view.source);
    return view;
}
