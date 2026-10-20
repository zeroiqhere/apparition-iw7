// Menu access uses current native host state and session-owned guest grants

catalog()
{
    return ["Bot", "None", "Verified", "VIP", "Admin", "Co-Host", "Host", "Developer"];
}

assignable()
{
    return ["None", "Verified", "VIP", "Admin", "Co-Host"];
}

resolve(host, bot, saved)
{
    // Apparition resolves bots before host and saved verification values
    if (bot)
        return "Bot";
    if (host)
        return "Host";

    if (isDefined(saved) && isstring(saved)
        && scripts\engine\utility::array_contains(assignable(), saved))
        return saved;

    return "None";
}

rank(level_name)
{
    if (!isDefined(level_name) || !isstring(level_name))
        return 1;

    levels = catalog();
    for (index = 0; index < levels.size; index++)
    {
        if (levels[index] == level_name)
            return index;
    }

    // Unknown session values inherit the source None rank
    return 1;
}

has_menu(level_name)
{
    return rank(level_name) > 1;
}

current(player)
{
    // Missing or stale references stop before native player methods
    if (!isDefined(player))
        return "None";
    if (scripts\apparition\runtime\context::actor_reason([player]) != "")
        return "None";

    return role_from_actor(player);
}

role_from_actor(player)
{
    // Bot status takes precedence over native host state and saved grants
    if (isbot(player))
        return "Bot";
    if (player isHost())
        return "Host";

    grant = player.apparition_access;
    saved = isDefined(grant) && isstruct(grant) ? grant.access : undefined;
    return resolve(false, false, saved);
}

can_open(player)
{
    if (!isDefined(player))
        return false;
    if (!scripts\apparition\runtime\context::supported())
        return false;

    // A full admitted roster makes membership and later native role reads safe
    if (scripts\apparition\runtime\context::actor_reason(level.players) != ""
        || !scripts\apparition\runtime\context::in_roster(level.players, player))
        return false;

    return has_menu(role_from_actor(player));
}

fun_reason(owner, target)
{
    // Shared admission keeps Fun rows and workers on the same actor boundary
    if (scripts\apparition\runtime\player_control::reason(owner, target) != "")
        return "Fun Scripts require a permitted current player in a private Spaceland match";
    if (rank(role_from_actor(owner)) < 3)
        return "VIP access is required for Fun Scripts";
    return "";
}

fun_grant_reason(owner, target, grant)
{
    // Recheck actor policy before inspecting a saved menu-grant reference
    reason = fun_reason(owner, target);
    if (reason != "")
        return reason;
    if (!same_grant(grant, owner.apparition_access))
        return "The requesting player's menu verification changed";
    return "";
}

grant(owner, target, value)
{
    // Reject reserved or malformed assignments before session and player checks
    if (!isDefined(value) || !isstring(value))
        return false;
    if (!scripts\engine\utility::array_contains(assignable(), value))
        return false;

    if (!scripts\apparition\runtime\context::supported())
        return false;

    // Admitted current roster references are required before native role methods
    if (scripts\apparition\runtime\context::actor_reason(level.players) != ""
        || !scripts\apparition\runtime\context::in_roster(level.players, owner)
        || !scripts\apparition\runtime\context::in_roster(level.players, target)
        || owner == target)
        return false;

    // Native bot and host identity cannot be replaced by a session grant
    if (role_from_actor(owner) != "Host")
        return false;

    target_role = role_from_actor(target);
    if (target_role == "Bot" || target_role == "Host")
        return false;
    if (target_role == value)
        return false;

    // The record lives only on this player reference for the current session
    grant = spawnstruct();
    grant.access = value;
    target.apparition_access = grant;
    target iPrintLn("Apparition verification: " + value);

    return true;
}

same_grant(first, second)
{
    // Undefined host grants are equal without comparing missing native values
    if (isDefined(first) != isDefined(second))
        return false;
    return !isDefined(first) || first == second;
}
