// The result page reads one current snapshot and has no gameplay callbacks

build(view)
{
    snapshot = isDefined(view) && isstruct(view) ? view.arcade_results : undefined;
    catalog = scripts\apparition\maps\spaceland\arcade_history::catalog();
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.games) || !isarray(snapshot.games)
        || snapshot.games.size != catalog.size
        || !isDefined(snapshot.count) || !isnumber(snapshot.count)
        || int(snapshot.count) != snapshot.count || snapshot.count < -1 || snapshot.count > catalog.size)
        return pending();

    rows = [];
    count = snapshot.count < 0 ? "Unknown" : snapshot.count;
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Arcade Results: " + count + "/" + catalog.size,
        snapshot.reason != "" ? snapshot.reason : "Play each game normally; the quest records successful results");
    for (index = 0; index < catalog.size; index++)
    {
        arcade = snapshot.games[index];
        // Complete known identities prevent a partial or foreign result list
        if (!isDefined(arcade) || !isstruct(arcade) || !isDefined(arcade.id)
            || !isstring(arcade.id) || arcade.id != catalog[index].id
            || !isDefined(arcade.label) || !isstring(arcade.label)
            || arcade.label != catalog[index].label
            || !isDefined(arcade.status) || !isstring(arcade.status))
            return pending();
        row = scripts\apparition\menu\model::unavailable(arcade.label + ": " + arcade.status);
        row.kind = "toggle";
        row.checked = false;
        switch (arcade.status)
        {
            case "Observed":
                row.checked = true;
                row.description = "A result was observed for this game; the quest must still advance to complete this stage";
                break;
            case "Completed":
                row.checked = true;
                row.description = "The native quest has advanced past the five-game arcade stage";
                break;
            case "Pending":
                row.description = "No result observed yet; play this game's quest challenge normally";
                break;
            case "Not Started":
                row.description = "Reach Arcade Critical Shots in the Ghosts N Skulls quest first";
                break;
            case "Unknown":
                row.description = "Earlier results are unknown; an unchecked row does not mean this game is unfinished";
                break;
            default:
                return pending();
        }
        rows[rows.size] = row;
    }
    return rows;
}

pending()
{
    // Missing data stays inert and never changes a native or observed result
    return [scripts\apparition\menu\model::unavailable("Arcade Results", "Wait for native arcade result data")];
}
