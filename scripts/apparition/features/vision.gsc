// Source vision choices use only profiles referenced by Spaceland's native scripts

values()
{
    return ["Default", "zombie_last_stand", "zombie_death", "flashbang",
        "zm_bgb_candy_bluez", "zm_bgb_candy_greenz", "zm_bgb_candy_purplez",
        "zm_bgb_candy_yellowz", "zm_bgb_now_you_see_me", "zombie_noire"];
}

choice(value, current_override)
{
    result = spawnstruct();
    result.reason = "Select an original Set Vision choice";
    if (!isDefined(value) || !isstring(value)
        || !scripts\engine\utility::array_contains(values(), value))
        return result;

    result.reason = "This BO3 vision has no verified IW7 profile";
    switch (value)
    {
        case "Default":
            // Restoration accepts the game's current override, including other stock profiles
            result.profile = isDefined(current_override) && isstring(current_override)
                ? current_override : "";
            break;
        case "zombie_last_stand":
            result.profile = "last_stand_cp_zmb";
            break;
        case "zombie_noire":
            result.profile = "cp_zmb_bw";
            break;
        default:
            return result;
    }
    result.reason = "";
    return result;
}

phase_reason(last_stand, afterlife, gns_active, playing_gns, glasses, current_override)
{
    if ((isDefined(last_stand) && last_stand)
        || (isDefined(afterlife) && afterlife))
        return "Wait until the player's native Last Stand or Afterlife phase ends";
    // The minigame gate leaves native transitions in control throughout Ghosts N Skulls
    if ((isDefined(gns_active) && gns_active)
        || (isDefined(playing_gns) && playing_gns))
        return "Set Vision is unavailable during Ghosts N Skulls";
    if (isDefined(glasses) && glasses)
        return "Remove the native Dischord glasses before changing vision";
    if (isDefined(current_override) && !isstring(current_override))
        return "Wait for a valid native vision override";
    return "";
}

probe(owner, target)
{
    result = spawnstruct();
    // Admission checks actual actors, the complete roster and current verification first
    result.reason = scripts\apparition\runtime\player_control::reason(owner, target);
    if (result.reason != "")
        return result;
    if ((isDefined(level.gameended) && level.gameended)
        || !scripts\apparition\menu\life::is_alive(target))
    {
        result.reason = "An active game and living selected player are required";
        return result;
    }

    result.reason = phase_reason(target.inlaststand, target.in_afterlife_arcade,
        level.gns_active, target.playing_ghosts_n_skulls,
        target.wearing_dischord_glasses, level.vision_set_override);
    // This read-only snapshot is never placed in an action payload
    result.override = level.vision_set_override;
    return result;
}

request(owner, target, value)
{
    // Resolve permission, native phases and the game-owned reset value at dispatch
    current = probe(owner, target);
    if (current.reason != "")
        return false;
    selected = choice(value, current.override);
    if (selected.reason != "")
        return false;

    target visionSetNakedForPlayer(selected.profile, 0);
    // Native transitions can replace this one-time request and provide no render receipt
    return true;
}
