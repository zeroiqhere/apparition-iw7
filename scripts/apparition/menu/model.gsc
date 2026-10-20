// Source labels retain their order while each supported row binds one action
// Unported BO3 features remain visibly unavailable instead of invoking guesses

build(page, view)
{
    rows = [];
    switch (page)
    {
        case "Main":
            rows = scripts\apparition\menu\main_rows::build(view);
            break;
        case "Basic Scripts":
            rows = basic_rows(view);
            break;
        case "Quick Menu":
            rows = quick_rows(view);
            break;
        case "Fun Scripts":
            rows = scripts\apparition\menu\fun_rows::build(view);
            break;
        case "Sounds & Jingles":
        case "Perk Jingles & Quotes":
            rows = scripts\apparition\menu\sound_rows::build(page, view);
            break;
        case "Message Menu":
        case "Miscellaneous Messages":
        case "Advertisements Messages":
            rows = scripts\apparition\menu\message_rows::build(page, view);
            break;
        case "Perk Menu":
        case "All Players Perks":
            rows = perk_rows(view, page == "All Players Perks");
            break;
        case "Power-Up Menu":
            rows = scripts\apparition\menu\powerup_rows::build(view);
            break;
        case "Weaponry":
        case "Weapon Options":
            rows = scripts\apparition\menu\weapon_rows::build(page, view);
            break;
        case "Host Menu":
            rows = scripts\apparition\menu\host_rows::build(view);
            break;
        case "Server Modifications":
            rows = scripts\apparition\menu\server_rows::build(view);
            break;
        case "Lobby Timer Options":
            rows = scripts\apparition\menu\server_rows::timer_rows(view);
            break;
        case "Doheart Options":
            rows = scripts\apparition\menu\doheart_rows::build(view);
            break;
        case "Teleport Menu":
            rows = scripts\apparition\menu\teleport_rows::build(view);
            break;
        case "Entity Teleports":
            rows = scripts\apparition\menu\entity_rows::build(view);
            break;
        case "Players":
            rows = scripts\apparition\menu\player_rows::players(view);
            break;
        case "Options":
            rows = scripts\apparition\menu\player_rows::options(view);
            break;
        case "Verification":
            rows = scripts\apparition\menu\verification_rows::build(view, false);
            break;
        case "All Players Verification":
            rows = scripts\apparition\menu\verification_rows::build(view, true);
            break;
        case "All Players":
            row = link("Verification", "All Players Verification", view.owner);
            row.enabled = truth(view.host);
            if (!row.enabled)
                row.description = "Only the current host can manage verification";
            rows[rows.size] = row;
            rows[rows.size] = scripts\apparition\menu\lobby_teleport_row::build(view);
            foreach (label in ["Profile Management", "Model Manipulation", "Malicious Options"])
                rows[rows.size] = unavailable(label);
            rows[rows.size] = god_row(view, true);
            rows[rows.size] = scripts\apparition\menu\player_message_row::build(view, true);
            rows[rows.size] = unavailable("Kick");
            rows[rows.size] = scripts\apparition\menu\death_row::build(view, true);
            rows[rows.size] = revive_row(view, true);
            rows[rows.size] = unavailable("Respawn");
            // Requested IW features extend the original lobby menu
            rows[rows.size] = ammo_row(view, true);
            rows[rows.size] = equipment_row(view, true);
            row = link("Perk Menu", "All Players Perks", undefined);
            row.enabled = truth(view.host);
            rows[rows.size] = row;
            break;
        case "Spaceland Scripts":
            rows[rows.size] = scripts\apparition\menu\power_row::build(view);
            rows[rows.size] = scripts\apparition\menu\dj_parts_row::build(view);
            rows[rows.size] = link("UFO Quest Steps", "UFO Quest Steps", view.target);
            rows[rows.size] = link("Portal Controls", "Portal Controls", view.target);
            rows[rows.size] = link("Ghosts N Skulls", "Ghosts N Skulls", view.target);
            break;
        case "Portal Controls":
            rows = portal_rows(view);
            break;
        case "UFO Quest Steps":
            rows = ufo_rows(view);
            break;
        case "Ghosts N Skulls":
            rows = ghost_rows(view);
            break;
        case "Cabinet Activation":
            rows = scripts\apparition\menu\cabinet_rows::build(view);
            break;
        case "Arcade Results":
            rows = scripts\apparition\menu\arcade_rows::build(view);
            break;
        case "Spawn Balloons":
            rows = scripts\apparition\menu\balloon_rows::build(view);
            break;
        case "Speaker Defense Controls":
            rows = speaker_rows(view);
            break;
        case "Native Wave Controls":
            rows = wave_rows(view);
            break;
        case "UFO Tone Controls":
            rows = tone_rows(view);
            break;
        case "UFO Bomber Controls":
            rows = bomber_rows(view);
            break;
        case "Grey Fight Controls":
            rows = grey_rows(view);
            break;
        case "Grey Fuse Controls":
            rows = grey_fuse_rows(view);
            break;
        case "UFO Finale Controls":
            rows = finale_rows(view);
            break;
        case "Final Power Nodes":
            rows = node_rows(view);
            break;
        case "Soul Key Controls":
            rows = soul_key_rows(view);
            break;
        case "Zombie Options":
            rows = scripts\apparition\menu\zombie_rows::build(view);
            break;
        case "Menu Customization":
            rows = scripts\apparition\menu\customization\rows::root_rows(view);
            break;
        case "Main Design Color":
            rows = scripts\apparition\menu\customization\rows::color_rows(view);
            break;
        case "Menu Preferences":
            rows = scripts\apparition\menu\customization\rows::preference_rows(view);
            break;
        case "Open Controls":
            rows = scripts\apparition\menu\customization\rows::binding_rows(view);
            break;
        case "Menu Instructions":
            rows = scripts\apparition\menu\customization\rows::instruction_rows(view);
            break;
    }
    return for_display(rows);
}

ufo_rows(view)
{
    rows = [];
    steps = scripts\apparition\maps\spaceland\quest::steps();
    for (index = 0; index < steps.size; index++)
    {
        row = unavailable(steps[index], "This stage currently requires normal in-game play");
        row.kind = "toggle";
        row.checked = scripts\apparition\maps\spaceland\quest::stage_completed(view.ufo, index);
        if (index == 11 && view.ufo.step == 11)
        {
            // Completion stays visible while the reward page remains reachable
            row.kind = row.checked ? "toggle" : "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.target;
            row.lobby = false;
            row.destination = "UFO Finale Controls";
            row.enabled = true;
            row.description = row.checked ? "Native quest completed; open finale and Soul Key controls" : "Collect dropped fuses and inspect native finale progress";
        }
        else if (row.checked)
            row.description = "The native quest has completed this stage";
        else if (view.ufo.step < 0)
            row.description = "The Spaceland UFO quest is not initialized";
        else if (index != view.ufo.step)
            row.description = "Complete the current quest stage first";
        else if (index == 0)
        {
            row = scripts\apparition\menu\dj_parts_row::build(view);
            row.kind = "toggle";
            // The native quest advances the stage after all three pickups register
            row.checked = false;
        }
        else if (index == 1)
        {
            row = pap_action(view);
            row.kind = "toggle";
            // The active stage stays pending until the native wave-start check advances it
            row.checked = false;
        }
        else if (index >= 2 && index <= 4)
        {
            // The submenu remains viewable while native progress owns its checkbox
            row.kind = "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.target;
            row.lobby = false;
            row.destination = "Speaker Defense Controls";
            row.enabled = true;
            row.description = "Inspect speaker placement, defense assistance and native progress";
        }
        else if (index == 5)
        {
            // The native quest checkbox stays pending until its own wave check advances
            row.kind = "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.target;
            row.lobby = false;
            row.destination = "Native Wave Controls";
            row.enabled = true;
            row.description = "Inspect regular-wave clearing and native quest progress";
        }
        else if (index == 6)
        {
            // The later tone-generator request keeps its original direct DJ action
            row = dj_row(view, steps[index], false);
            row.kind = "toggle";
            row.checked = false;
        }
        else if (index == 7)
        {
            row.callback = scripts\apparition\menu\actions::place_generators;
            row.lobby = true;
            row.enabled = truth(view.host) && truth(view.generators_ready);
            row.description = view.generators_hint;
        }
        else if (index == 8)
        {
            row.kind = "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.target;
            row.lobby = false;
            row.destination = "UFO Tone Controls";
            row.enabled = true;
            row.description = "Open native tone matching controls and job status";
        }
        else if (index == 9)
        {
            row.kind = "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.target;
            row.lobby = false;
            row.destination = "UFO Bomber Controls";
            row.enabled = true;
            row.description = "Open native bomber damage controls and live quest progress";
        }
        else if (index == 10)
        {
            row.kind = "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.target;
            row.lobby = false;
            row.destination = "Grey Fight Controls";
            row.enabled = true;
            row.description = "Open full-fight and exposed-fuse assists with native readiness status";
        }
        rows[rows.size] = row;
    }
    return rows;
}

ghost_rows(view)
{
    rows = [];
    probe = view.ghost_probe;
    probe_reason = "";
    if (!truth(view.host))
        probe_reason = "Only the current host can face the native skull";
    else if (!isDefined(probe) || !isDefined(probe.reason))
        probe_reason = "Wait for native Ghosts N Skulls view data";
    else
        probe_reason = probe.reason;

    // The callback probes again before changing the host's view
    row = action("Face Current Skull", scripts\apparition\menu\actions::face_ghost_skull, undefined, true);
    row.enabled = probe_reason == "";
    row.description = probe_reason != "" ? probe_reason
        : "Face the skull, then keep it in view for the native 1.5-second check";
    rows[rows.size] = row;

    steps = scripts\apparition\maps\spaceland\ghosts::catalog();
    for (index = 0; index < steps.size; index++)
    {
        // Native quest progress is the only source of completion checkmarks
        row = unavailable(steps[index].label, "Progress follows the native Ghosts N Skulls quest");
        row.kind = "toggle";
        if (isDefined(view.ghost_progress))
            row.checked = scripts\apparition\maps\spaceland\ghosts::stage_completed(view.ghost_progress, index);
        else
            row.checked = false;
        if (index == 0 && isDefined(view.ghost_progress)
            && view.ghost_progress.step == 0 && isDefined(view.owner))
        {
            // Opening authored targets never marks a native balloon as popped
            row.kind = "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.owner;
            row.lobby = false;
            row.destination = "Spawn Balloons";
            row.enabled = true;
            row.description = "Open host aiming requests for authored balloon locations; native pops still own completion";
        }
        if (index == 3 && isDefined(view.ghost_progress)
            && view.ghost_progress.step == 3 && isDefined(view.owner))
        {
            // Result inspection leaves the native five-game challenge in control
            row.kind = "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.owner;
            row.lobby = false;
            row.destination = "Arcade Results";
            row.enabled = true;
            row.description = "Inspect each game's quest results; play uses normal game controls";
        }
        if (index == 6 && isDefined(view.ghost_progress)
            && view.ghost_progress.step == 6 && isDefined(view.owner))
        {
            // Opening requirements never supplies the collective native hold
            row.kind = row.checked ? "toggle" : "submenu";
            row.callback = scripts\apparition\menu\actions::open_page;
            row.target = view.owner;
            row.lobby = false;
            row.destination = "Cabinet Activation";
            row.enabled = true;
            row.description = "Inspect each current player's cabinet hold requirements; native input still activates the game";
        }
        rows[rows.size] = row;
    }

    progress = view.ghost_progress;
    active = isDefined(progress) && isDefined(progress.active) && progress.active;
    row = unavailable("Native Arena Active", "Native arena activity is separate from quest-step completion");
    row.kind = "toggle";
    row.checked = active;
    rows[rows.size] = row;

    waves = isDefined(progress) && isDefined(progress.waves) ? progress.waves : -1;
    waves_label = waves >= 0 ? waves : "unknown";
    rows[rows.size] = unavailable("Map Waves Started: " + waves_label,
        "Counts started native waves across all arena attempts");

    // The last arena result can outlive the current quest session
    last_result = isDefined(progress) && isDefined(progress.last_result) ? progress.last_result : "Unconfirmed";
    rows[rows.size] = unavailable("Last Recorded Arena Result: " + last_result,
        "This result may be from an earlier arena game");

    // Dance hints are tied to the native stage and kill callback, never cached
    if (isDefined(progress) && isDefined(progress.step) && progress.step == 2)
    {
        next_color = isDefined(progress.next_floor) && progress.next_floor != "" ? progress.next_floor : "unknown";
        remaining_kills = isDefined(progress.remaining_kills) && progress.remaining_kills >= 0
            ? progress.remaining_kills : "unknown";
        rows[rows.size] = unavailable("Next Dance Color: " + next_color, "Native dance-floor instruction for the current step");
        rows[rows.size] = unavailable("Dance Kills Remaining: " + remaining_kills, "Native dance-floor counter for the current step");
    }
    rows = dance_rows(view, rows);
    rows = floating_skull_rows(view, rows);
    rows = brute_cabinet_rows(view, rows);
    return rows;
}

dance_rows(view, rows)
{
    start_reason = "";
    dance_host_reason = "Only the current living host can assist dance kills";
    if (!truth(view.host))
        start_reason = dance_host_reason;
    else if (!isDefined(view.dance_hint))
        start_reason = "Wait for native dance assist readiness data";
    else if (view.dance_hint != "")
        start_reason = view.dance_hint;
    else if (!isDefined(view.dance_running))
        start_reason = "Wait for dance assist status";
    else if (view.dance_running)
        start_reason = "Dance kill assistance is already running";

    // Native tile and callback readiness only applies to starting a worker
    row = action("Start Dance Kill Assist", scripts\apparition\menu\actions::start_dance, undefined, true);
    row.enabled = start_reason == "";
    row.description = row.enabled ? "The host must move to each indicated native tile; only normal eligible enemies are attacked while it matches, and the native quest must advance the stage"
        : start_reason;
    rows[rows.size] = row;

    cancel_reason = "";
    if (!truth(view.host))
        cancel_reason = dance_host_reason;
    else if (!isDefined(view.dance_running) || !isDefined(view.dance_status))
        cancel_reason = "Wait for dance assist status";
    else if (!view.dance_running)
        cancel_reason = "No dance kill assistance is running";
    else if (view.dance_status == "Cancelling")
        cancel_reason = "Dance kill assistance cancellation is already pending";

    // Cancellation remains available when native stage readiness changes
    row = action("Cancel Dance Kill Assist", scripts\apparition\menu\actions::cancel_dance, undefined, true);
    row.enabled = cancel_reason == "";
    row.description = row.enabled ? "Stop the background worker; native quest checks still own stage completion"
        : cancel_reason;
    rows[rows.size] = row;

    dance_status = isDefined(view.dance_status) ? view.dance_status : "Unknown";
    rows[rows.size] = unavailable("Dance Assist Status: " + dance_status,
        "Worker state is separate from native dance counters and quest progress");
    return rows;
}

floating_skull_rows(view, rows)
{
    hit_reason = "";
    if (!truth(view.host))
        hit_reason = "Only the current host can request a floating-skull hit";
    else if (!isDefined(view.floating_probe) || !isDefined(view.floating_probe.reason))
        hit_reason = "Wait for floating-skull readiness data";
    else if (view.floating_probe.reason != "")
        hit_reason = view.floating_probe.reason;
    else if (!isDefined(view.floating_running))
        hit_reason = "Wait for floating-skull worker status";
    else if (view.floating_running)
        hit_reason = "A floating-skull hit is already pending";

    // The callback probes again and submits at most one native damage request
    row = action("Hit Floating Skull", scripts\apparition\menu\actions::hit_floating_skull, undefined, true);
    row.enabled = hit_reason == "";
    row.description = row.enabled ? "Submit one sign-laser-type damage request; native glasses and quest checks remain required, and an unconfirmed submitted hit is not repeated"
        : hit_reason;
    rows[rows.size] = row;

    // Submission state is separate from native quest completion
    input_status = isDefined(view.floating_status) ? view.floating_status : "Unknown";
    rows[rows.size] = unavailable("Floating Skull Input: " + input_status,
        "Read-only submission state; native quest progress controls completion");
    return rows;
}

brute_cabinet_rows(view, rows)
{
    hit_reason = "";
    if (!truth(view.host))
        hit_reason = "Only the current host can hit the cabinet with a Brute";
    else if (!isDefined(view.brute_cabinet_probe) || !isDefined(view.brute_cabinet_probe.reason))
        hit_reason = "Wait for Brute cabinet readiness data";
    else if (view.brute_cabinet_probe.reason != "")
        hit_reason = view.brute_cabinet_probe.reason;
    else if (!isDefined(view.brute_cabinet_running))
        hit_reason = "Wait for Brute cabinet input status";
    else if (view.brute_cabinet_running)
        hit_reason = "A Brute cabinet hit is already pending";

    // The callback refreshes the target and submits one native-context hit
    row = action("Hit Cabinet With Brute", scripts\apparition\menu\actions::hit_brute_cabinet, undefined, true);
    row.enabled = hit_reason == "";
    row.description = row.enabled ? "At a ready native cabinet stage, submit one direct bullet-type hit on the cabinet credited to a real living Brute; the native quest must advance, and an ambiguous submitted hit is not replayed"
        : hit_reason;
    rows[rows.size] = row;

    // Observer results never substitute for native quest progress
    input_status = isDefined(view.brute_cabinet_status) ? view.brute_cabinet_status : "Unknown";
    rows[rows.size] = unavailable("Brute Cabinet Input: " + input_status,
        "Read-only submitted-hit state; native quest progress controls completion");

    route = isDefined(view.brute_cabinet_probe) && isDefined(view.brute_cabinet_probe.route)
        ? view.brute_cabinet_probe.route : "Unknown";
    route_description = "Native cabinet route is unknown";
    if (route == "Initial Unlock")
        route_description = "The native cabinet route is at its initial unlock stage";
    else if (route == "Reactivation")
        route_description = "A native Brute reactivation attempt was observed";
    else if (route == "Unavailable")
        route_description = "No supported native cabinet route is available";
    // Route history explains admission without implying quest completion
    rows[rows.size] = unavailable("Cabinet Route: " + route, route_description);
    return rows;
}

portal_rows(view)
{
    rows = [];
    areas = scripts\apparition\maps\spaceland\portals::areas();
    for (index = 0; index < areas.size; index++)
    {
        area = areas[index];
        side = view.portal_sides[area];
        row = action("Use Side Portal " + (index + 1), scripts\apparition\menu\actions::visit_portal, undefined, true);
        row.area = area;
        row.kind = "toggle";
        row.checked = truth(side.used);
        row.enabled = truth(view.host) && truth(side.ready) && !truth(view.portal_running);
        row.description = side.hint;
        rows[rows.size] = row;
    }
    rows[rows.size] = pap_action(view);
    rows[rows.size] = unavailable("Visit Status: " + view.portal_status, "Progress checkboxes read native portal use");
    return rows;
}

pap_action(view)
{
    row = action("Use Pack-a-Punch Portal", scripts\apparition\menu\actions::enter_pap, undefined, true);
    row.enabled = truth(view.host) && truth(view.portal_ready) && !truth(view.portal_running);
    row.description = view.portal_hint;
    return row;
}

tone_rows(view)
{
    rows = [];
    row = action("Start Tone Matching", scripts\apparition\menu\actions::start_tones, undefined, true);
    row.enabled = truth(view.host) && truth(view.tones_ready) && !truth(view.tones_running);
    row.description = "Wait for a fresh round, then play its native notes; other input may interrupt";
    rows[rows.size] = row;
    row = action("Cancel Tone Matching", scripts\apparition\menu\actions::cancel_tones, undefined, true);
    row.enabled = truth(view.host) && truth(view.tones_running) && view.tone_status != "Cancelling";
    row.description = "Stop further menu notes and keep the native quest running";
    rows[rows.size] = row;
    rows[rows.size] = unavailable("Tone Status: " + view.tone_status, "Completion follows native quest progress");
    return rows;
}

dj_row(view, label, speaker)
{
    row = action(label, scripts\apparition\menu\actions::request_dj, undefined, true);
    if (speaker)
        row.speaker_defense = true;
    reason = speaker ? "Only the current host can control the native speaker"
        : "Only the current host can request the native DJ";
    if (truth(view.host))
    {
        reason = "Wait for native DJ readiness data";
        // A retained speaker page cannot advertise the later generator request
        if (speaker && (!isDefined(view.ufo) || view.ufo.step < 2 || view.ufo.step > 4))
            reason = "Speaker requests require a native speaker-defense stage";
        else if (isDefined(view.dj) && isstruct(view.dj)
            && isDefined(view.dj.reason) && isstring(view.dj.reason)
            && isDefined(view.dj.kind) && isstring(view.dj.kind))
        {
            reason = view.dj.reason;
            expected = speaker ? "defense" : "tone";
            if (reason == "" && view.dj.kind != expected)
                reason = "Wait for the native DJ quest request";
        }
    }
    row.enabled = reason == "";
    row.description = row.enabled ? (speaker ? "Use the native DJ door to request or retry this speaker defense"
        : "Collect tone generators from the selected DJ") : reason;
    return row;
}

speaker_rows(view)
{
    rows = [];
    host = truth(view.host);
    host_hint = "Only the current host can control the native speaker";
    step = isDefined(view.ufo) ? view.ufo.step : -1;
    speaker_stage = step >= 2 && step <= 4;
    place_hint = host ? view.speaker_place_hint : host_hint;
    speaker_hint = host ? view.speaker_hint : host_hint;
    pickup_hint = host ? view.speaker_pickup_hint : host_hint;
    if (host && place_hint == "")
        place_hint = "Place the requested speaker through its native interaction; placement cannot be canceled after commit";
    if (host && speaker_hint == "")
    {
        if (truth(view.speaker_running))
            speaker_hint = "Speaker defense assistance is already active";
        else
            speaker_hint = "Assist the active speaker; the level-owned job continues if this menu closes";
    }
    if (host && pickup_hint == "")
    {
        if (truth(view.speaker_running))
            pickup_hint = "A speaker job is already running";
        else if (!truth(view.speaker_pickup_ready))
            pickup_hint = "The host must be alive, out of last stand and in a supported private session";
        else
            pickup_hint = "Collect the actual recorded speaker; native pickup and a regular wave remain required";
    }

    rows[rows.size] = dj_row(view, "Request/Retry Speaker", true);

    row = action("Place Speaker", scripts\apparition\menu\actions::place_speaker, undefined, true);
    row.enabled = host && truth(view.speaker_place_ready) && !truth(view.speaker_place_running);
    row.description = place_hint;
    rows[rows.size] = row;

    row = action("Assist Active Speaker", scripts\apparition\menu\actions::start_speakers, undefined, true);
    row.enabled = host && truth(view.speaker_ready) && !truth(view.speaker_running);
    row.description = speaker_hint;
    rows[rows.size] = row;

    row = action("Collect Defended Speaker", scripts\apparition\menu\actions::collect_speaker, undefined, true);
    row.enabled = host && speaker_stage && truth(view.speaker_pickup_ready) && !truth(view.speaker_running);
    row.description = pickup_hint;
    rows[rows.size] = row;

    row = action("Cancel Speaker Job", scripts\apparition\menu\actions::cancel_speakers, undefined, true);
    row.enabled = host && truth(view.speaker_running) && view.speaker_status != "Cancelling";
    row.description = host ? "Stop future speaker-job inputs; native defense and quest progression continue" : host_hint;
    rows[rows.size] = row;

    rows[rows.size] = unavailable("Placement Status: " + view.speaker_place_status, "Placement runs on the level and continues if this menu closes");
    rows[rows.size] = unavailable("Speaker Job Status: " + view.speaker_status, "Only native quest progress confirms defense completion");

    timer = "unknown";
    if (isDefined(view.speaker_timer) && view.speaker_timer >= 0)
        timer = view.speaker_timer + " seconds";
    rows[rows.size] = unavailable("Native Defense Timer: " + timer, "Read from the native speaker defense timer");

    health = "unknown";
    if (isDefined(view.speaker_health) && view.speaker_health >= 0)
        health = view.speaker_health + "/10";
    rows[rows.size] = unavailable("Native Speaker Health: " + health, "Read from the active native speaker actor");
    rows[rows.size] = unavailable("Native Wave Required", "The actual speaker is recorded during active defense; no model scan or timer skip is used, and native pickup plus a regular wave remain required");
    return rows;
}

wave_rows(view)
{
    rows = [];
    host = truth(view.host);
    host_hint = "Only the current host can control native wave clearing";
    wave_stage = isDefined(view.ufo) && view.ufo.step == 5;
    hint = host ? view.wave_hint : host_hint;
    if (host && hint == "")
    {
        if (truth(view.wave_running))
            hint = "A native wave clear is already running";
        else if (!truth(view.wave_ready))
            hint = "The host must be alive, out of last stand and in a supported private session";
        else
            hint = "Clear unprotected native blockers to reach the next regular wave";
    }

    row = action("Clear to Next Regular Wave", scripts\apparition\menu\actions::start_wave, undefined, true);
    row.enabled = host && wave_stage && truth(view.wave_ready);
    row.description = hint;
    rows[rows.size] = row;

    row = action("Cancel Wave Clearing", scripts\apparition\menu\actions::cancel_wave, undefined, true);
    row.enabled = host && truth(view.wave_running) && view.wave_status != "Cancelling";
    row.description = host ? "Stop future clear input; native wave progression continues on its own" : host_hint;
    rows[rows.size] = row;

    rows[rows.size] = unavailable("Wave Job Status: " + view.wave_status, "Only native quest advancement confirms completion");

    wave_number = "unknown";
    if (isDefined(view.wave_progress.wave) && view.wave_progress.wave >= 0)
        wave_number = view.wave_progress.wave;
    rows[rows.size] = unavailable("Native Wave Number: " + wave_number, "Read from native wave progress");

    deaths = "unknown";
    if (isDefined(view.wave_progress.kills) && view.wave_progress.kills >= 0
        && isDefined(view.wave_progress.goal) && view.wave_progress.goal >= 0)
        deaths = view.wave_progress.kills + "/" + view.wave_progress.goal;
    rows[rows.size] = unavailable("Native Deaths: " + deaths, "Read from the native current-wave death counter");
    rows[rows.size] = unavailable("Native Wave Required", "A normal event or clown round may run first; protected or non-counting actors remain untouched, and only native quest advancement confirms completion");
    return rows;
}

bomber_rows(view)
{
    rows = [];
    host = truth(view.host);
    // Permission takes priority so a guest is not told to repair the host's health
    hint = "Only the current host can control the bomber worker";
    if (host)
    {
        hint = view.bomber_hint;
        if (hint == "")
        {
            if (truth(view.bomber_running))
                hint = "A bomber worker already owns this native stage";
            else
                hint = truth(view.bomber_ready) ? "Defeat current and newly spawned UFO quest bombers" : "The host must be alive, out of last stand and in a supported private session";
        }
    }
    row = action("Start Defeating UFO Bombers", scripts\apparition\menu\actions::start_bombers, undefined, true);
    row.enabled = host && truth(view.bomber_ready) && !truth(view.bomber_running);
    row.description = hint;
    rows[rows.size] = row;
    row = action("Cancel Bomber Attacks", scripts\apparition\menu\actions::cancel_bombers, undefined, true);
    row.enabled = host && truth(view.bomber_running) && view.bomber_status != "Cancelling";
    row.description = host ? "Stop further attacks; defeated bombers still count" : hint;
    rows[rows.size] = row;
    count = view.bombers.kills < 0 ? "waiting for native counter" : view.bombers.kills + "/" + view.bombers.goal;
    rows[rows.size] = unavailable("Bombers defeated: " + count, "Progress updates when the game records a bomber death");
    rows[rows.size] = unavailable("Bomber Status: " + view.bomber_status, "Completed appears when the game advances to the next quest stage");
    return rows;
}

grey_rows(view)
{
    rows = [];
    host = truth(view.host);
    hint = host ? view.grey_hint : "Only the current host can control the Grey assist";
    if (host && hint == "")
    {
        if (truth(view.grey_running))
            hint = "A Grey assist already owns this fight";
        else
            hint = truth(view.grey_ready) ? "Defeat registered native Greys and strike fresh exposed fuses" : "The host must be alive, out of last stand and in a supported private session";
    }
    row = action("Defeat Greys", scripts\apparition\menu\actions::start_greys, undefined, true);
    row.enabled = host && truth(view.grey_ready) && !truth(view.grey_running);
    row.description = hint;
    rows[rows.size] = row;
    row = action("Cancel Grey Assist", scripts\apparition\menu\actions::cancel_greys, undefined, true);
    row.enabled = host && truth(view.grey_running) && view.grey_status != "Cancelling";
    row.description = host ? "Stop future menu hits while native fight cleanup continues" : hint;
    rows[rows.size] = row;
    rows[rows.size] = unavailable("Grey Assist Status: " + view.grey_status, "Both modes share one worker; only native quest advancement confirms completion");
    rows[rows.size] = unavailable("Spawn Watch: " + view.grey_sequence_status, "Full fight mode requires the early native callback and complete initial spawn-loop return");
    count = view.grey_count < 0 ? "waiting for registration" : view.grey_count;
    rows[rows.size] = unavailable("Native Greys: " + count, "An empty native roster alone does not prove quest completion");
    rows[rows.size] = link("Exposed Fuse Controls", "Grey Fuse Controls", view.target);
    return rows;
}

grey_fuse_rows(view)
{
    rows = [];
    host = truth(view.host);
    hint = "Only the current host can control the Grey assist";
    if (host)
    {
        hint = view.grey_fuse_hint;
        if (hint == "")
        {
            if (truth(view.grey_running))
                hint = "A fuse assist already owns this native stage";
            else
                hint = truth(view.grey_fuse_ready) ? "Wait for a new regeneration window, then strike its exposed fuse once" : "The host must be alive, out of last stand and in a supported private session";
        }
    }
    row = action("Auto Strike Exposed Fuses", scripts\apparition\menu\actions::start_grey_fuses, undefined, true);
    row.enabled = host && truth(view.grey_fuse_ready) && !truth(view.grey_running);
    row.description = hint;
    rows[rows.size] = row;
    row = action("Cancel Grey Assist", scripts\apparition\menu\actions::cancel_greys, undefined, true);
    row.enabled = host && truth(view.grey_running) && view.grey_status != "Cancelling";
    row.description = host ? "Stop further menu hits; native fuse removals remain part of the fight" : hint;
    rows[rows.size] = row;
    rows[rows.size] = unavailable("Fuse Assist Status: " + view.grey_status, "Completed appears only after native quest advancement");
    rows[rows.size] = unavailable("Fuse-only mode", "Handles fresh exposed fuses; the parent page offers full Grey fight assistance");
    return rows;
}

finale_rows(view)
{
    rows = [];
    host = truth(view.host);
    row = action("Collect Dropped Alien Fuses", scripts\apparition\menu\actions::collect_fuses, undefined, true);
    row.enabled = host && truth(view.fuse_pickup_ready) && !truth(view.fuse_pickup_running);
    row.description = host ? view.fuse_pickup_hint : "Only the current host can collect quest fuses";
    rows[rows.size] = row;
    rows[rows.size] = unavailable("Fuse Collection Status: " + view.fuse_pickup_status, "A collection result does not complete the final UFO stage");
    row = unavailable("Alien Fuses Collected", "The dropped pair becomes one shared native inventory item");
    row.kind = "toggle";
    row.checked = view.fuses.held > 0 || truth(view.fuses.inserted);
    rows[rows.size] = row;
    row = action("Insert Alien Fuses", scripts\apparition\menu\actions::insert_fuses, undefined, true);
    row.kind = "toggle";
    row.checked = truth(view.fuses.inserted);
    row.enabled = host && truth(view.insert_fuse_ready) && !truth(view.insert_fuse_running);
    row.description = host ? view.insert_fuse_hint : "Only the current host can insert quest fuses";
    rows[rows.size] = row;
    rows[rows.size] = unavailable("Fuse Insertion Status: " + view.insert_fuse_status, "A committed native insertion finishes before releasing the machine");
    rows[rows.size] = link("Final Power Nodes", "Final Power Nodes", view.target);
    rows[rows.size] = link("Soul Key Controls", "Soul Key Controls", view.target);
    return rows;
}

node_rows(view)
{
    rows = [];
    host = truth(view.host);
    hint = host ? view.node_hint : "Only the current host can control final-node inputs";
    row = action("Activate Final Power Nodes", scripts\apparition\menu\actions::start_nodes, undefined, true);
    row.enabled = host && truth(view.node_ready) && !truth(view.node_running);
    row.description = hint;
    rows[rows.size] = row;
    row = action("Cancel Node Inputs", scripts\apparition\menu\actions::cancel_nodes, undefined, true);
    row.enabled = host && truth(view.node_running) && view.node_status != "Cancelling";
    row.description = host ? "Stop future menu hits; native charging and projectiles continue" : hint;
    rows[rows.size] = row;
    rows[rows.size] = unavailable("Node Status: " + view.node_status, "Only native UFO destruction confirms success; input history is an exclusion guard");
    for (index = 0; index < 5; index++)
    {
        row = unavailable("Power Node " + (index + 1), "Native activation resets before the final projectile fires");
        row.kind = "toggle";
        row.checked = truth(view.node_values[index]);
        rows[rows.size] = row;
    }
    row = unavailable("UFO Destroyed", "The game owns final destruction, quest completion and reward pickup");
    row.kind = "toggle";
    row.checked = truth(view.ufo_destroyed);
    rows[rows.size] = row;
    return rows;
}


soul_key_rows(view)
{
    rows = [];
    row = action("Collect Soul Key", scripts\apparition\menu\actions::collect_soul_key, undefined, true);
    row.enabled = truth(view.host) && truth(view.soul_key_ready) && !truth(view.soul_key_running);
    row.description = truth(view.host) ? view.soul_key_hint : "Only the current host can collect the shared Soul Key";
    rows[rows.size] = row;
    rows[rows.size] = unavailable("Soul Key Status: " + view.soul_key_status, "Collected requires native model cleanup and observed recipient ownership");
    row = unavailable("All Current Players Own Key", "Native persistent ownership may predate this match and does not prove pickup cleanup");
    row.kind = "toggle";
    row.checked = scripts\apparition\maps\spaceland\soul_key::all_owned(view.soul_key_receipt);
    rows[rows.size] = row;
    receipt = view.soul_key_receipt;
    rows[rows.size] = unavailable("Key Owners: " + receipt.owners + "/" + receipt.total, "Current-roster native ownership; disconnected or unreadable recipients remain unconfirmed");
    return rows;
}


basic_rows(view)
{
    rows = [];
    rows[rows.size] = god_row(view, false);
    rows[rows.size] = scripts\apparition\menu\demi_row::build(view);
    foreach (label in ["Noclip", "Bind Noclip To [{+frag}]", "UFO Mode"])
        rows[rows.size] = unavailable(label);
    rows[rows.size] = ammo_row(view, false);
    rows[rows.size] = equipment_row(view, false);
    rows[rows.size] = unavailable("Unlimited Special Weapon");
    rows[rows.size] = score_row(view);
    rows[rows.size] = link("Perk Menu", "Perk Menu", view.target);
    foreach (label in ["Gobblegum Menu", "Movement Speed", "Third Person", "Invisibility", "Clone", "No Target", "Reduced Spread", "Multi-Jump", "Disable HUD", "Visual Effects", "Set Vision", "Zombie Charms", "Custom Crosshairs", "No Explosive Damage", "Character Model Index", "Random Character Model Index", "Shoot While Sprinting", "Unlimited Sprint", "Respawn"])
    {
        // Supported controls keep the original source positions
        switch (label)
        {
            case "Movement Speed":
                row = movement_row(view);
                break;
            case "Set Vision":
                row = scripts\apparition\menu\vision_row::build(view);
                break;
            case "Invisibility":
                row = invisibility_row(view);
                break;
            case "Disable HUD":
                row = hud_visibility_row(view);
                break;
            case "Multi-Jump":
                row = multi_jump_row(view);
                break;
            case "Shoot While Sprinting":
                row = sprint_fire_row(view);
                break;
            case "Custom Crosshairs":
                row = scripts\apparition\menu\crosshair_row::build(view);
                break;
            case "No Explosive Damage":
                row = explosive_row(view);
                break;
            default:
                row = unavailable(label);
                break;
        }
        rows[rows.size] = row;
    }
    rows[rows.size] = revive_row(view, false);
    rows[rows.size] = scripts\apparition\menu\death_row::build(view, false);
    return rows;
}

quick_rows(view)
{
    rows = [];
    // Living Quick Menu rows follow the owner life state in this view
    if (truth(view.owner_alive))
    {
        rows[rows.size] = god_row(view, false);
        foreach (label in ["Noclip", "Bind Noclip To [{+frag}]"])
            rows[rows.size] = unavailable(label);
        rows[rows.size] = ammo_row(view, false);
        rows[rows.size] = equipment_row(view, false);
        rows[rows.size] = score_row(view);
        rows[rows.size] = link("Perk Menu", "Perk Menu", view.target);
        foreach (label in ["No Target", "Reduced Spread", "Unlimited Sprint"])
            rows[rows.size] = unavailable(label);
    }
    rows[rows.size] = unavailable("Respawn");
    if (truth(view.owner_alive))
        rows[rows.size] = revive_row(view, false);
    if (truth(view.host))
    {
        rows[rows.size] = unavailable("Restart Game");
        rows[rows.size] = unavailable("Disconnect");
    }
    return rows;
}

god_row(view, lobby)
{
    players = lobby ? view.players : [view.target];
    target = lobby ? undefined : view.target;
    row = action("God Mode", scripts\apparition\menu\actions::toggle_god, target, lobby);
    row.kind = "toggle";
    row.checked = false;
    permission_denied = lobby && !scripts\apparition\runtime\player_control::can_manage(view.access);

    // Lobby permission stays ahead of roster and hook details
    if (permission_denied)
    {
        row.enabled = false;
        row.description = "Co-Host access is required to change lobby God Mode";
    }

    // Actor admission precedes saved flags in both personal and lobby scopes
    actor_reason = lobby ? actor_snapshot_reason(view) : target_snapshot_reason(view);
    if (actor_reason != "")
    {
        row.enabled = false;
        if (!permission_denied)
            row.description = actor_reason;
        return row;
    }

    // The checkbox records configured flags, not proof that damage is intercepted
    row.checked = scripts\apparition\features\god_mode::all_enabled(players);

    // A valid guest snapshot remains readable without granting change access
    if (permission_denied)
        return row;

    // The aggregate checkbox also determines the next backend toggle direction
    row.description = "Use " + (row.checked ? "disables" : "enables") + " God Mode for this player";

    reason = scripts\apparition\features\god_mode::reason(players, truth(view.god_ready));
    row.enabled = reason == "";
    if (!truth(view.god_ready) && row.checked && row.enabled)
    {
        // A checked row remains usable so its saved flags can be cleared
        row.description = "Disable the saved God Mode setting; damage protection is not confirmed";
        return row;
    }

    if (!row.enabled)
    {
        row.description = reason;
        if (lobby && !truth(view.god_ready) && isDefined(players))
        {
            has_enabled_flag = false;
            foreach (player in players)
            {
                if (isDefined(player.playerGodmode) && player.playerGodmode)
                {
                    has_enabled_flag = true;
                    break;
                }
            }
            if (has_enabled_flag)
                row.description += "; existing flags can be cleared through each player's Basic Scripts";
        }
        return row;
    }

    if (lobby)
        row.description = "Use " + (row.checked ? "disables" : "enables")
            + " God Mode for every current player; later joins keep their own state";
    return row;
}

movement_row(view)
{
    row = action("Movement Speed", scripts\apparition\menu\actions::set_movement, view.target, false);
    row.kind = "slider";
    row.values = scripts\apparition\features\movement::scales();
    // The source default is literal one, independent of the saved active value
    row.initial_index = 2;
    row.active_value = "Unknown";
    reason = target_snapshot_reason(view);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }
    // Rejected actor snapshots cannot expose a stale saved scale
    row.active_value = scripts\apparition\features\movement::configured_scale(view.target);
    // IW7 exposes no movement-scale getter, so this describes configuration
    row.description = "Absolute scale; configured: " + row.active_value + "; 1 applies once, others repeat every 0.5s";
    return row;
}

invisibility_row(view)
{
    row = action("Invisibility", scripts\apparition\menu\actions::toggle_invisibility, view.target, false);
    row.kind = "toggle";
    row.checked = false;
    reason = target_snapshot_reason(view);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }
    // Saved configuration is read only after the selected actor is admitted
    row.checked = scripts\apparition\features\invisibility::configured(view.target);
    row.description = row.checked
        ? "Saved on; Use shows once; native game code can override"
        : "Saved off; Use hides once; native game code can override";
    return row;
}

hud_visibility_row(view)
{
    row = action("Disable HUD", scripts\apparition\menu\actions::toggle_hud_visibility, view.target, false);
    row.kind = "toggle";
    row.checked = false;
    reason = target_snapshot_reason(view);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }
    // Native scripts can overwrite this command after the saved flag changes
    row.checked = scripts\apparition\features\hud_visibility::configured(view.target);
    row.description = row.checked
        ? "Saved on; Use shows native HUD once; game code can override"
        : "Saved off; Use hides native HUD once; game code can override";
    return row;
}

multi_jump_row(view)
{
    row = action("Multi-Jump", scripts\apparition\menu\actions::toggle_multi_jump, view.target, false);
    row.kind = "toggle";
    row.checked = false;
    reason = target_snapshot_reason(view);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }

    // Admission protects both saved intent and the player's input receipt
    row.checked = scripts\apparition\features\multi_jump::configured(view.target);
    // Missing input setup prevents enable but cannot trap a saved setting on
    if (!scripts\apparition\runtime\jump_input::input_ready(view.target))
    {
        row.enabled = row.checked;
        row.description = row.checked
            ? "Saved on; Use disables; jump input setup is unavailable"
            : "Wait for jump input setup";
        return row;
    }
    row.description = (row.checked ? "Saved on; Use disables" : "Saved off; Use enables")
        + "; first airborne release arms, later releases boost +250 Z";
    return row;
}

sprint_fire_row(view)
{
    row = action("Shoot While Sprinting", scripts\apparition\menu\actions::toggle_sprint_fire, view.target, false);
    row.kind = "toggle";
    row.checked = false;
    reason = target_snapshot_reason(view);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }
    // CP tracks a script mirror; its helper also needs an admitted player
    row.checked = scripts\apparition\features\sprint_fire::configured(view.target);
    row.description = (row.checked ? "Configured on; Use removes sprint fire" : "Configured off; Use grants sprint fire")
        + "; Racin' Stripes shares this effect";
    return row;
}

target_snapshot_reason(view)
{
    // Personal controls share actor and selection admission without a life requirement
    return isDefined(view.target_actor_reason) && isstring(view.target_actor_reason)
        ? view.target_actor_reason : "Wait for a valid player roster";
}

score_row(view)
{
    row = action("Modify Score", scripts\apparition\menu\actions::modify_score, view.target, false);
    row.kind = "slider";
    row.values = scripts\apparition\features\score::selections();
    row.enabled = false;
    row.description = "Wait for native currency data";
    snapshot = view.score;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return row;

    reason = snapshot.reason;
    if (reason == "")
        reason = scripts\apparition\features\score::balance_reason(snapshot.balance, snapshot.cap);
    if (reason != "")
    {
        row.description = reason;
        return row;
    }

    // The live balance and slider preview stay separate until dispatch
    row.enabled = true;
    row.description = "Live balance: " + snapshot.balance + "/" + snapshot.cap
        + "; Use applies the preview delta; 0 clears";
    return row;
}

explosive_row(view)
{
    row = action("No Explosive Damage", scripts\apparition\menu\actions::toggle_explosive_protection, view.target, false);
    row.kind = "toggle";
    row.checked = false;
    reason = target_snapshot_reason(view);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }
    // This checkbox reads the original explosive setting only
    row.checked = scripts\apparition\features\explosive_protection::enabled(view.target);
    reason = scripts\apparition\features\explosive_protection::reason(view.target, truth(view.god_ready));
    row.enabled = reason == "";

    if (!truth(view.god_ready) && row.checked)
    {
        // A saved setting stays clearable after the native callback is lost
        row.description = "Disable the saved explosive protection setting; damage protection is not confirmed";
        return row;
    }

    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }

    // The available row names both the native callback and its damage scope
    row.description = "Toggle explosive-only protection through Apparition's native damage callback";
    return row;
}

actor_snapshot_reason(view)
{
    // Actor snapshots configure future settings and do not require a living player
    if (!isDefined(view.players) || !isarray(view.players))
        return "Wait for a valid player roster";
    if (!view.players.size)
        return "No current players are available";
    if (!isDefined(view.actor_reason) || !isstring(view.actor_reason))
        return "Wait for a valid player roster";
    return view.actor_reason;
}

ammo_row(view, lobby)
{
    target = lobby ? undefined : view.target;
    row = action("Unlimited Ammo", scripts\apparition\menu\actions::set_ammo, target, lobby);
    row.kind = "slider";
    row.values = scripts\apparition\features\ammo::modes();
    reason = lobby ? actor_snapshot_reason(view) : target_snapshot_reason(view);
    // No active mode can be inferred from an empty or invalid selection
    row.active_value = "Unavailable";
    if (reason == "")
        row.active_value = lobby ? scripts\apparition\features\ammo::lobby_mode(view.players)
            : scripts\apparition\features\ammo::current_mode(view.target);
    if (lobby && !truth(view.host))
        reason = "Only the current host can change lobby ammo";
    row.enabled = reason == "";
    row.description = reason != "" ? reason : "Use applies the selection; active: " + row.active_value;
    if (lobby && row.enabled)
        row.description += "; current roster only, later joins keep their own mode";
    return row;
}

revive_row(view, lobby)
{
    target = lobby ? undefined : view.target;
    row = action("Revive", scripts\apparition\menu\actions::revive, target, lobby);

    // Lobby role permission stays visible even when native revive data is unavailable
    if (lobby && !scripts\apparition\runtime\player_control::can_manage(view.access))
    {
        row.enabled = false;
        row.description = "Co-Host access is required to revive current players";
        return row;
    }

    snapshot = view.revive;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.hint) || !isstring(snapshot.hint)
        || !isDefined(snapshot.targets) || !isarray(snapshot.targets)
        || (snapshot.reason == "" && !snapshot.targets.size))
    {
        row.enabled = false;
        row.description = "Wait for native revive data";
        return row;
    }

    // A submitted native request is not proof that last stand has ended
    row.enabled = snapshot.reason == "";
    row.description = row.enabled ? snapshot.hint : snapshot.reason;
    return row;
}

equipment_row(view, lobby)
{
    players = lobby ? view.players : [view.target];
    target = lobby ? undefined : view.target;
    row = action("Unlimited Equipment", scripts\apparition\menu\actions::toggle_equipment, target, lobby);
    row.kind = "toggle";
    row.checked = false;
    reason = lobby ? actor_snapshot_reason(view) : target_snapshot_reason(view);
    // Saved settings are readable only for the admitted selection
    if (reason == "")
        row.checked = scripts\apparition\features\equipment::all_enabled(players);
    status = isDefined(view.equipment_status) && isstring(view.equipment_status) && view.equipment_status != ""
        ? view.equipment_status : "Unknown";
    if (lobby && !truth(view.host))
    {
        row.enabled = false;
        row.description = "Only the current host can change lobby equipment refill; snapshot: " + status;
        return row;
    }
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }
    // Actor-only admission keeps future refills configurable while down
    row.description = "Refill supported primary grenades; secondary powers and removed equipment are excluded";
    row.description += "; snapshot: " + status;
    if (lobby)
        row.description += "; current roster only, later joins keep their setting";
    return row;
}

perk_rows(view, lobby)
{
    catalog = scripts\apparition\maps\spaceland\perks::catalog();
    perk_ids = scripts\apparition\maps\spaceland\perks::ids();
    players = lobby ? view.players : [view.target];
    actor_reason = lobby ? actor_snapshot_reason(view) : target_snapshot_reason(view);
    rows = [];
    row = action("All Perks", scripts\apparition\menu\actions::toggle_all_perks, view.target, lobby);
    row.kind = "toggle";
    // Valid actors keep their ownership visible while life or callback checks block actions
    row.checked = actor_reason == "" && scripts\apparition\features\perks::all_owned(players, perk_ids);
    reason = perk_reason(view, lobby, perk_ids);
    row.enabled = reason == "";
    // A partial inventory grants the whole selection instead of inverting each perk
    row.description = reason != "" ? reason : (row.checked
        ? (lobby ? "Use removes all ten perks from every current player; later joins keep their own perks"
            : "Use removes all ten Spaceland machine perks")
        : (lobby ? "Use gives all ten perks to every current player; later joins keep their own perks"
            : "Use gives all ten Spaceland machine perks"));
    rows[rows.size] = row;
    rows[rows.size] = retention_row(view, players, lobby);
    foreach (perk in catalog)
    {
        row = action(perk.label, scripts\apparition\menu\actions::toggle_perk, view.target, lobby);
        row.kind = "toggle";
        row.perk_id = perk.id;
        selected_ids = [perk.id];
        row.checked = actor_reason == "" && scripts\apparition\features\perks::all_owned(players, selected_ids);
        reason = perk_reason(view, lobby, selected_ids);
        row.enabled = reason == "";
        // Each perk uses its own ownership check rather than the All Perks direction
        row.description = reason != "" ? reason : (row.checked
            ? (lobby ? "Use removes this perk from every current player; later joins keep their own perks"
                : "Use removes this perk")
            : (lobby ? "Use gives this perk to every current player; later joins keep their own perks"
                : "Use gives this perk"));
        rows[rows.size] = row;
    }
    return rows;
}

retention_row(view, players, lobby)
{
    row = action("Retain Perks", scripts\apparition\menu\actions::toggle_retention, view.target, lobby);
    row.kind = "toggle";
    // Each admitted player owns one setting record; inventory remains separate
    actor_reason = lobby ? actor_snapshot_reason(view) : target_snapshot_reason(view);
    row.checked = actor_reason == "" && scripts\apparition\features\perk_retention::all_enabled(players);
    reason = retention_reason(view, lobby, row.checked);
    row.enabled = reason == "";
    if (reason != "")
        row.description = reason;
    // Both normal and hook-loss cleanup discard the same saved snapshot
    else if (row.checked)
    {
        row.description = lobby
            ? "Use disables retention for every current player; saved snapshots are discarded; owned perks stay"
            : "Use disables retention; saved snapshots are discarded; owned perks stay";
        if (!truth(view.retention_ready))
            row.description += "; capture callback is inactive";
    }
    else
        row.description = lobby
            ? "Use enables retention for every current player; save at normal downs, restore after spawn; Ghosts N Skulls participants keep prior snapshots; later joins excluded"
            : "Use enables retention; save at normal downs, restore after spawn; Ghosts N Skulls participants keep prior snapshots";
    return row;
}

retention_reason(view, lobby, checked)
{
    if (lobby && !truth(view.host))
        return "Only the current host can change lobby perks";
    reason = lobby ? actor_snapshot_reason(view) : target_snapshot_reason(view);
    if (reason != "")
        return reason;
    if (!truth(view.retention_ready))
    {
        // Keep the off action available for an existing setting after hook loss
        if (checked)
            return "";
        if (lobby)
            return "Enable requires the active last-stand callback; disable existing settings in each player's Perk Menu";
        return "Retain Perks requires the active Apparition last-stand callback";
    }
    return "";
}

perk_reason(view, lobby, perk_ids)
{
    if (lobby && !truth(view.host))
        return "Only the current host can change lobby perks";
    reason = lobby ? actor_snapshot_reason(view) : target_snapshot_reason(view);
    if (reason != "")
        return reason;
    // View capture owns life, temporary-mode and inventory readiness for this scope
    reason = lobby ? view.perk_roster_reason : view.perk_target_reason;
    if (!isDefined(reason) || !isstring(reason))
        return "Wait for native perk readiness";
    if (reason != "")
        return reason;
    // Shared readiness checks only the callback pairs required by this row
    return scripts\apparition\features\perks::callback_reason(view.perk_callbacks, perk_ids);
}

action(label, callback, target, lobby)
{
    row = spawnstruct();
    row.label = label;
    row.kind = "action";
    row.enabled = true;
    row.callback = callback;
    row.target = target;
    row.lobby = lobby;
    return row;
}

link(label, destination, target)
{
    row = action(label, scripts\apparition\menu\actions::open_page, target, false);
    row.kind = "submenu";
    row.destination = destination;
    row.description = "Open " + label;
    return row;
}

unavailable(label, description)
{
    row = spawnstruct();
    row.label = label;
    row.kind = "unavailable";
    row.enabled = false;
    row.description = isDefined(description) ? description : "This BO3 feature has no verified IW7 binding yet";
    return row;
}

for_display(rows)
{
    if (rows.size == 0)
        rows[0] = unavailable("No Options Found", "This page has no available entries");
    return rows;
}

truth(value)
{
    return isDefined(value) && value;
}
