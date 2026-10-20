// Main links keep the original role groups and the current native host boundary

build(view)
{
    rows = [];
    if (!isDefined(view) || !isstruct(view))
        return rows;
    labels = labels(view.access, scripts\apparition\menu\model::truth(view.host));
    foreach (label in labels)
    {
        switch (label)
        {
            case "Basic Scripts":
            case "Fun Scripts":
            case "Weaponry":
            case "Teleport Menu":
            case "Spaceland Scripts":
                row = scripts\apparition\menu\model::link(label, label, view.target);
                break;
            case "Menu Customization":
            case "Zombie Options":
            case "Message Menu":
            case "Power-Up Menu":
            case "Host Menu":
            case "Server Modifications":
                row = scripts\apparition\menu\model::link(label, label, view.owner);
                break;
            // Player pages use the verified role; Host Menu still uses native identity
            case "Players Menu":
                row = scripts\apparition\menu\model::link(label, "Players", view.target);
                row.enabled = scripts\apparition\runtime\player_control::can_manage(view.access);
                if (!row.enabled)
                    row.description = "Co-Host access is required to open player controls";
                break;
            case "All Players Menu":
                row = scripts\apparition\menu\model::link(label, "All Players", view.target);
                row.enabled = scripts\apparition\runtime\player_control::can_manage(view.access);
                if (!row.enabled)
                    row.description = "Co-Host access is required to open player controls";
                break;
            default:
                row = scripts\apparition\menu\model::unavailable(label);
                break;
        }
        rows[rows.size] = row;
    }
    return rows;
}

labels(access, host)
{
    rank = scripts\apparition\runtime\access::rank(access);
    if (rank < 2)
        return [];
    result = ["Basic Scripts", "Menu Customization", "Message Menu", "Teleport Menu"];
    // Each source tier adds one consecutive group after earlier groups
    if (rank >= 3)
    {
        foreach (label in ["Power-Up Menu", "Profile Management", "Model Manipulation", "Weaponry", "Bullet Menu", "Fun Scripts", "Aimbot Menu"])
            result[result.size] = label;
    }
    if (rank >= 4)
    {
        foreach (label in ["Forge Options", "Entity Options", "Advanced Scripts", "Spaceland Scripts"])
            result[result.size] = label;
    }
    if (rank >= 5)
    {
        foreach (label in ["Server Modifications", "Server Tweakables", "Zombie Options", "Spawnables"])
            result[result.size] = label;
        if (host)
            result[result.size] = "Host Menu";
        result[result.size] = "Players Menu";
        result[result.size] = "All Players Menu";
        if (host)
            result[result.size] = "Game Modes";
    }
    return result;
}
