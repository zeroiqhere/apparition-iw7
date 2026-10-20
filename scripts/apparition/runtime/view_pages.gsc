// Page snapshots are read only when their controls are being rebuilt

capture(page, owner, target, view)
{
    if (!isDefined(page) || !isstring(page))
        return;

    // Host controls read their native state only on this page
    if (page == "Host Menu")
    {
        view.origin_display = scripts\apparition\features\show_origin::probe(owner);
        view.fov = scripts\apparition\features\fov::probe(owner);
        view.server_cheats = scripts\apparition\features\server_cheats::probe(owner);
    }

    // Doheart defaults are captured on entry; this provider only reads them
    if (page == "Doheart Options")
        view.doheart = scripts\apparition\features\server\doheart::probe(owner);

    // Only the Quick root selects different controls from the owner's life state
    if (page == "Quick Menu")
        view.owner_alive = scripts\apparition\menu\life::is_alive(owner);

    // Personal pages share one admitted actor and current dispatch reason
    if (page == "Basic Scripts" || (page == "Quick Menu" && view.owner_alive)
        || page == "Perk Menu" || page == "Fun Scripts"
        || page == "Sounds & Jingles" || page == "Perk Jingles & Quotes"
        || page == "Weaponry" || page == "Weapon Options")
    {
        view.target_actor_reason = scripts\apparition\runtime\context::actor_reason([target]);
        if (view.target_actor_reason == "")
            view.target_actor_reason = scripts\apparition\runtime\player_control::reason(owner, target);
    }
    // Only Options reads inventory; the root needs no native weapon probe
    if (page == "Weapon Options" && view.target_actor_reason == "")
        view.weapon_current = scripts\apparition\features\weapons::probe(owner, target);

    // Roster pages need one complete actor snapshot before names or feature state
    if (page == "Players" || page == "Options" || page == "Verification"
        || page == "All Players Verification" || page == "All Players"
        || page == "All Players Perks")
        view.actor_reason = scripts\apparition\runtime\context::actor_reason(view.players);
    if (page == "Basic Scripts" || page == "All Players"
        || (page == "Quick Menu" && view.owner_alive))
        view.god_ready = scripts\apparition\runtime\damage::active();

    // Perk inventory and callback checks stay on the two pages that use them
    if (page == "Perk Menu" || page == "All Players Perks")
    {
        view.perk_callbacks = level.coop_perk_callbacks;
        view.retention_ready = scripts\apparition\runtime\perk_retention::active();
    }
    // Personal immediate perk readiness is sampled only for its own page
    if (page == "Perk Menu")
    {
        // A rejected selection keeps its known actor reason without probing target state
        if (view.target_actor_reason != "")
            view.perk_target_reason = view.target_actor_reason;
        else
            view.perk_target_reason = scripts\apparition\features\perks::roster_reason([target]);
    }
    if (page == "All Players Perks")
    {
        view.perk_roster_reason = scripts\apparition\features\perks::roster_reason(view.players);
    }
    // Names and access labels use one admitted roster snapshot on player pages
    if (page == "Players" || page == "Options"
        || page == "Verification" || page == "All Players Verification")
    {
        view.player_access = [];
        if (view.actor_reason == "")
        {
            foreach (player in view.players)
            {
                entry = spawnstruct();
                entry.player = player;
                entry.access = scripts\apparition\runtime\access::current(player);
                view.player_access[view.player_access.size] = entry;
            }
        }
    }
    // Native feature snapshots are needed only on pages with their controls
    if (page == "Basic Scripts"
        || (page == "Quick Menu" && view.owner_alive))
    {
        view.equipment_status = "Unavailable";
        // Rejected targets cannot enter probes that read saved player settings
        if (view.target_actor_reason == "")
        {
            equipment = scripts\apparition\features\equipment::probe(target);
            view.equipment_status = equipment.state;
            view.revive = scripts\apparition\features\revive::probe([target]);
            view.score = scripts\apparition\features\score::probe(target);
            if (page == "Basic Scripts")
            {
                view.demi_feedback_reason = scripts\apparition\features\demi_god::feedback_reason(target);
                view.down = scripts\apparition\features\down::probe([target]);
                view.vision = scripts\apparition\features\vision::probe(owner, target);
            }
        }
        else
        {
            // Shared blocked data preserves the actor reason without claiming native values
            snapshot = scripts\apparition\runtime\view::unavailable_target(view.target_actor_reason);
            view.score = snapshot;
            view.revive = snapshot;
            if (page == "Basic Scripts")
            {
                view.down = snapshot;
                view.demi_feedback_reason = view.target_actor_reason;
                view.vision = snapshot;
            }
        }
    }
    else if (page == "All Players")
    {
        if (scripts\apparition\runtime\player_control::can_manage(view.access))
        {
            view.lobby_teleport = scripts\apparition\features\lobby_teleport::probe(owner);
            selection = scripts\apparition\runtime\player_control::without_host(owner);
            if (selection.reason == "")
            {
                view.down = scripts\apparition\features\down::probe(selection.targets);
                view.revive = scripts\apparition\features\revive::probe(selection.targets);
            }
            else
            {
                snapshot = scripts\apparition\runtime\view::unavailable_target(selection.reason);
                view.down = snapshot;
                view.revive = snapshot;
            }
        }
        view.equipment_status = "Unknown";
        if (view.actor_reason == "")
        {
            equipment_probes = [];
            foreach (player in view.players)
                equipment_probes[equipment_probes.size] = scripts\apparition\features\equipment::probe(player);
            view.equipment_status = scripts\apparition\features\equipment::summary(equipment_probes);
        }
    }
    if (page == "Zombie Options")
    {
        view.zombie_visibility = scripts\apparition\maps\spaceland\zombie_visibility::probe(owner);
        view.zombie_health = scripts\apparition\maps\spaceland\zombie_health::probe(owner);
        view.zombie_kill = scripts\apparition\maps\spaceland\zombie_kill::probe(owner);
        view.zombie_movement = scripts\apparition\maps\spaceland\zombie_movement::probe(owner);
    }
    // Fun controls read selected-player state only after shared target admission
    if (page == "Fun Scripts" && view.target_actor_reason == "")
    {
        view.insta_kill = scripts\apparition\features\insta_kill::probe(owner, target);
        view.earthquake = scripts\apparition\features\earthquake::probe(owner, target);
        view.health_bar = scripts\apparition\features\health_bar::probe(owner, target);
        view.frog_jump = scripts\apparition\features\frog_jump::probe(owner, target);
    }
    // Alias checks are needed only on the two sound pages, after actor admission
    if ((page == "Sounds & Jingles"
        || page == "Perk Jingles & Quotes") && view.target_actor_reason == "")
        view.perk_sounds = scripts\apparition\features\perk_sounds::probe(owner, target);
    // Names and the current host are resolved only on the message control pages
    if (page == "Message Menu"
        || page == "Miscellaneous Messages"
        || page == "Advertisements Messages")
        view.messages = scripts\apparition\features\messages::probe(owner, page);
    // Trace and native loot admission are evaluated only on their control page
    if (page == "Power-Up Menu")
        view.powerups = scripts\apparition\features\powerups::probe(owner);
    // Travel checks are limited to their page and carry no cached destinations
    if (page == "Teleport Menu")
    {
        view.teleport = scripts\apparition\features\teleport::probe(owner, target);
        view.official_spawns = scripts\apparition\maps\spaceland\spawn_points::inspect(level);
    }
    if (page == "Entity Teleports")
    {
        view.teleport = scripts\apparition\features\teleport::probe_movement(owner, target);
        view.entity_teleports = scripts\apparition\maps\spaceland\entity_teleports::probe();
    }
    // Per-player Use queries are limited to the collective-hold inspection page
    if (page == "Cabinet Activation")
        view.cabinet_activation = scripts\apparition\maps\spaceland\cabinet_activation::probe();
    // Per-game results are queried only while their read-only page is visible
    if (page == "Arcade Results")
        view.arcade_results = scripts\apparition\maps\spaceland\arcade_history::inspect(level);
    // Native scriptable lookup is limited to the balloon target page
    if (page == "Spawn Balloons" && view.host)
        view.balloons = scripts\apparition\maps\spaceland\balloons::probe(owner);
    // Native collection data is needed only where its two controls are shown
    if (page == "Spaceland Scripts"
        || page == "UFO Quest Steps")
    {
        if (view.host)
            view.dj_parts = scripts\apparition\maps\spaceland\dj_parts::probe(owner);
        else
            view.dj_parts = scripts\apparition\maps\spaceland\dj_parts::inspect(level);
    }
    // Shared quest data also drives side portals and the speaker/wave subpages
    if (page == "UFO Quest Steps" || page == "Portal Controls"
        || page == "Speaker Defense Controls" || page == "Native Wave Controls")
    {
        view.ufo = scripts\apparition\maps\spaceland\quest::progress(level);
    }
    if (page == "Portal Controls" || page == "UFO Quest Steps")
    {
        view.portal_running = scripts\apparition\maps\spaceland\portal_travel::running(level.apparition_portal_job);
        actor_hint = scripts\apparition\maps\spaceland\portal_travel::actor_reason(owner);
        view.portal_hint = scripts\apparition\maps\spaceland\portals::entry_reason(level);
        view.portal_ready = view.portal_hint == "" && actor_hint == ""
            && scripts\apparition\maps\spaceland\portal_travel::path_ready(true);
        if (view.portal_hint == "")
        {
            if (view.portal_running)
                view.portal_hint = "A side-portal visit is already running";
            else if (actor_hint != "")
                view.portal_hint = actor_hint;
            else
                view.portal_hint = view.portal_ready ? "Transport the host through the native Pack-a-Punch route" : "The native Pack-a-Punch route is not ready";
        }
        // The quest page uses only entry readiness; side data belongs to Portal Controls
        if (page == "Portal Controls")
        {
            view.portal_status = scripts\apparition\maps\spaceland\portal_travel::status(level);
            // Actor and side-route checks are shared across all four controls in this snapshot
            side_path_ready = actor_hint == "" && view.ufo.step == 1
                && scripts\apparition\maps\spaceland\portal_travel::path_ready(false);
            view.portal_sides = [];
            foreach (area in scripts\apparition\maps\spaceland\portals::areas())
            {
                side = spawnstruct();
                side.used = scripts\apparition\maps\spaceland\portals::side_used(level, area);
                side.hint = scripts\apparition\maps\spaceland\portals::side_reason(level, area);
                side.ready = side.hint == "" && actor_hint == "" && side_path_ready;
                if (side.hint == "")
                {
                    if (view.portal_running)
                        side.hint = "A side-portal visit is already running";
                    else if (actor_hint != "")
                        side.hint = actor_hint;
                    else
                        side.hint = side_path_ready ? "Charge and visit this side portal; the host returns to the central exit" : "The native side-portal route is not ready";
                }
                view.portal_sides[area] = side;
            }
        }
    }
    if (page == "UFO Quest Steps" || page == "Speaker Defense Controls")
    {
        view.dj = scripts\apparition\maps\spaceland\dj::probe_owner(owner);
    }
    if (page == "UFO Quest Steps")
    {
        view.generators_ready = scripts\apparition\maps\spaceland\generators::available(level);
        view.generators_hint = scripts\apparition\maps\spaceland\generators::hint(level);
    }
    // Native power data is sampled only for the host on its control page
    if (page == "Spaceland Scripts" && view.host)
        view.power = scripts\apparition\maps\spaceland\power::probe(owner);
    // Global server settings are sampled only while their source page is open
    if (page == "Server Modifications")
    {
        view.server_timescale = scripts\apparition\features\server\timescale::probe(owner);
        view.auto_revive = scripts\apparition\features\server\auto_revive::probe(owner);
        view.newsbar = scripts\apparition\features\server\newsbar::probe(owner);
        view.server_movements = [];
        foreach (control in scripts\apparition\features\server\movement::catalog())
            view.server_movements[control.id] = scripts\apparition\features\server\movement::probe(owner, control.id);
        view.server_end_reason = scripts\apparition\features\server\end_game::reason(owner);
    }
    // Timer readiness belongs to its child page, not the parent server list
    if (page == "Lobby Timer Options")
        view.lobby_timer = scripts\apparition\features\server\lobby_timer::probe(owner);
    if (page == "Ghosts N Skulls")
    {
        view.ghost_progress = scripts\apparition\maps\spaceland\ghosts::progress(level);
        // Skull model search and line-of-sight tracing are needed only here
        view.ghost_probe = scripts\apparition\maps\spaceland\ghosts::probe(owner);
        // Dance tile probes and worker state are only needed on this page
        view.dance_hint = scripts\apparition\maps\spaceland\dance::actor_reason(owner);
        view.dance_running = scripts\apparition\maps\spaceland\dance::running(level.apparition_dance_job);
        view.dance_status = scripts\apparition\maps\spaceland\dance::status(level);
        // Floating-skull model scan and input state are needed only here
        view.floating_probe = scripts\apparition\maps\spaceland\floating_skull::probe(owner);
        view.floating_running = scripts\apparition\maps\spaceland\ghost_hit_observer::running(level.apparition_floating_skull_job);
        view.floating_status = scripts\apparition\maps\spaceland\ghost_hit_observer::status(level.apparition_floating_skull_job);
        // Read cabinet input state through the shared observer helpers
        view.brute_cabinet_probe = scripts\apparition\maps\spaceland\brute_cabinet::probe(owner);
        view.brute_cabinet_running = scripts\apparition\maps\spaceland\ghost_hit_observer::running(level.apparition_brute_cabinet_job);
        view.brute_cabinet_status = scripts\apparition\maps\spaceland\ghost_hit_observer::status(level.apparition_brute_cabinet_job);
    }
    // Actor placement checks and native speaker probes run only on their control page
    if (page == "Speaker Defense Controls")
    {
        placement = level.apparition_speaker_placement;
        view.speaker_place_running = isDefined(placement) && isDefined(placement.state) && placement.state == "Placing";
        view.speaker_place_status = isDefined(placement) && isDefined(placement.state) ? placement.state : "Idle";
        view.speaker_place_hint = scripts\apparition\maps\spaceland\speaker_placement::reason(level);
        view.speaker_place_ready = false;
        if (view.speaker_place_hint == "")
        {
            speaker_spot = scripts\apparition\maps\spaceland\speaker_placement::spot(level);
            view.speaker_place_hint = scripts\apparition\maps\spaceland\speaker_placement::actor_reason(owner, speaker_spot);
            view.speaker_place_ready = view.speaker_place_hint == "" && !view.speaker_place_running;
        }

        speaker_job = level.apparition_speaker_job;
        view.speaker_running = scripts\apparition\maps\spaceland\speakers::running(speaker_job);
        view.speaker_status = isDefined(speaker_job) && isDefined(speaker_job.state) ? speaker_job.state : "Idle";
        view.speaker_hint = scripts\apparition\maps\spaceland\speakers::assist_reason(level);
        view.speaker_ready = view.speaker_hint == ""
            && scripts\apparition\runtime\context::living_host(owner) && !view.speaker_running;
        if (view.speaker_hint == "" && view.speaker_running)
            view.speaker_hint = "Speaker defense assistance is already active";
        else if (view.speaker_hint == "" && !view.speaker_ready)
            view.speaker_hint = "The host must be alive, out of last stand and in a supported private session";

        view.speaker_pickup_hint = scripts\apparition\maps\spaceland\speakers::pickup_reason(level, level.apparition_speaker_capture);
        view.speaker_pickup_ready = view.speaker_pickup_hint == ""
            && scripts\apparition\runtime\context::living_host(owner) && !view.speaker_running;

        view.speaker_timer = getOmnvar("zm_speaker_defense_timer");
        view.speaker_health = -1;
        if (isDefined(level.current_speaker) && isDefined(level.current_speaker.hit_point_left))
            view.speaker_health = level.current_speaker.hit_point_left;
    }
    if (page == "Native Wave Controls")
    {
        view.wave_hint = scripts\apparition\maps\spaceland\wave::reason(level);
        view.wave_running = scripts\apparition\maps\spaceland\wave::running(level.apparition_wave_job);
        view.wave_status = scripts\apparition\maps\spaceland\wave::status(level);
        view.wave_progress = scripts\apparition\maps\spaceland\wave::progress(level);
        view.wave_ready = view.wave_hint == ""
            && scripts\apparition\runtime\context::living_host(owner) && !view.wave_running;
    }
    if (page == "UFO Tone Controls")
    {
        view.tones_ready = scripts\apparition\maps\spaceland\tones::available(level);
        view.tones_running = scripts\apparition\maps\spaceland\tones::running(level.apparition_tone_job);
        view.tone_status = scripts\apparition\maps\spaceland\tones::status(level);
    }
    if (page == "UFO Bomber Controls")
    {
        view.bombers = scripts\apparition\maps\spaceland\bombers::progress(level);
        view.bomber_hint = scripts\apparition\maps\spaceland\bombers::reason(level);
        view.bomber_ready = view.bomber_hint == "" && scripts\apparition\runtime\context::living_host(owner);
        view.bomber_running = scripts\apparition\maps\spaceland\bombers::running(level.apparition_bomber_job);
        view.bomber_status = scripts\apparition\maps\spaceland\bombers::status(level);
    }
    if (page == "Grey Fight Controls" || page == "Grey Fuse Controls")
    {
        view.grey_running = scripts\apparition\maps\spaceland\greys::running(level.apparition_grey_job);
        view.grey_status = scripts\apparition\maps\spaceland\greys::status(level);
    }
    if (page == "Grey Fight Controls")
    {
        view.grey_hint = scripts\apparition\maps\spaceland\greys::reason(level, true);
        view.grey_ready = view.grey_hint == "" && scripts\apparition\runtime\context::living_host(owner);
        view.grey_sequence_status = isDefined(level.apparition_grey_sequence) ? level.apparition_grey_sequence.state : "Unavailable";
        view.grey_count = isDefined(level.spawned_grey) ? level.spawned_grey.size : -1;
    }
    if (page == "Grey Fuse Controls")
    {
        view.grey_fuse_hint = scripts\apparition\maps\spaceland\greys::reason(level, false);
        view.grey_fuse_ready = view.grey_fuse_hint == "" && scripts\apparition\runtime\context::living_host(owner);
    }
    if (page == "UFO Finale Controls")
    {
        view.fuses = scripts\apparition\maps\spaceland\fuses::progress(level);
        view.fuse_pickup_hint = scripts\apparition\maps\spaceland\fuses::reason(level);
        view.fuse_pickup_running = scripts\apparition\maps\spaceland\fuses::running(level.apparition_fuse_pickup_job);
        view.fuse_pickup_status = isDefined(level.apparition_fuse_pickup_job) ? level.apparition_fuse_pickup_job.state : "Idle";
        view.fuse_pickup_ready = false;
        if (view.fuse_pickup_hint == "")
        {
            if (view.fuse_pickup_running)
                view.fuse_pickup_hint = "Fuse collection is already being observed";
            else if (!scripts\apparition\runtime\context::living_host(owner))
                view.fuse_pickup_hint = "The host must be alive, out of last stand and in a supported private session";
            else
            {
                // Scan live models only for a ready host on the collection phase
                view.fuse_pickup_ready = isDefined(scripts\apparition\maps\spaceland\fuses::native_pickup());
                view.fuse_pickup_hint = view.fuse_pickup_ready ? "Collect the dropped pair through its native pickup listener" : "The dropped fuse pickup is not available";
            }
        }
        view.insert_fuse_hint = scripts\apparition\maps\spaceland\pap_insert::reason(level);
        view.insert_fuse_running = scripts\apparition\maps\spaceland\pap_insert::running(level.apparition_pap_insert_job);
        view.insert_fuse_status = isDefined(level.apparition_pap_insert_job) ? level.apparition_pap_insert_job.state : "Idle";
        view.insert_fuse_ready = false;
        if (view.insert_fuse_hint == "")
        {
            if (view.insert_fuse_running)
                view.insert_fuse_hint = "Native fuse insertion is finishing its machine cleanup";
            else
            {
                pap = scripts\apparition\maps\spaceland\fuses::spot(level, "pap_upgrade");
                view.insert_fuse_hint = scripts\apparition\maps\spaceland\pap_insert::actor_reason(owner, pap);
                if (view.insert_fuse_hint == "")
                {
                    view.insert_fuse_ready = isDefined(getEnt("pap_machine", "targetname"));
                    view.insert_fuse_hint = view.insert_fuse_ready ? "Insert collected fuses through the native Pack-a-Punch transaction" : "The native Pack-a-Punch machine is not available";
                }
            }
        }
    }
    if (page == "Final Power Nodes")
    {
        watch = level.apparition_node_history;
        view.node_values = [];
        nodes = scripts\apparition\maps\spaceland\nodes::registry(level);
        for (index = 0; index < 5; index++)
            view.node_values[index] = isDefined(nodes) && scripts\apparition\maps\spaceland\nodes::activated(nodes[index]);
        view.ufo_destroyed = isDefined(level.flag) && isDefined(level.flag["ufo_destroyed"]) && level.flag["ufo_destroyed"];
        view.node_running = scripts\apparition\maps\spaceland\nodes::running(level.apparition_node_job);
        view.node_status = isDefined(level.apparition_node_job) ? level.apparition_node_job.state : "Idle";
        if (view.node_status == "Active" && isDefined(watch) && watch.cycle_spent)
            view.node_status = "Observing native UFO destruction";
        view.node_hint = scripts\apparition\maps\spaceland\nodes::reason(level, watch);
        view.node_ready = false;
        if (view.node_hint == "")
        {
            if (view.node_running)
                view.node_hint = "A final-node worker already owns the menu input reservation";
            else
            {
                view.node_hint = scripts\apparition\maps\spaceland\nodes::actor_reason(owner);
                if (view.node_hint == "")
                    view.node_hint = scripts\apparition\maps\spaceland\nodes::live_reason(watch);
                view.node_ready = view.node_hint == "";
                if (view.node_ready)
                    view.node_hint = "Submit one native hit per uncharged node using the host's equipped wonder weapon";
            }
        }
    }
    // Keep the shaped empty ownership receipt when live data is unavailable
    if (page == "Soul Key Controls")
    {
        view.soul_key_running = scripts\apparition\maps\spaceland\soul_key::running(level.apparition_soul_key_job);
        view.soul_key_status = isDefined(level.apparition_soul_key_job) ? level.apparition_soul_key_job.state : "Idle";
        view.soul_key_hint = scripts\apparition\maps\spaceland\soul_key::reason(level);
        view.soul_key_receipt = scripts\apparition\maps\spaceland\soul_key::snapshot([]);
        view.soul_key_ready = false;
        if (scripts\apparition\maps\spaceland\soul_key::context_reason(level) == "")
            view.soul_key_receipt = scripts\apparition\maps\spaceland\soul_key::snapshot(view.players);
        if (view.soul_key_hint == "")
        {
            if (view.soul_key_running)
                view.soul_key_hint = "Soul Key collection is already being observed";
            else if (!scripts\apparition\runtime\context::living_host(owner))
                view.soul_key_hint = "The host must be alive, out of last stand and in a supported private session";
            else if (!scripts\apparition\maps\spaceland\soul_key::ownership_known(view.soul_key_receipt))
                view.soul_key_hint = "Wait for native ownership data for the current lobby";
            else
            {
                view.soul_key_ready = isDefined(scripts\apparition\maps\spaceland\soul_key::native_pickup());
                view.soul_key_hint = view.soul_key_ready ? "Native pickup grants Soul Key ownership and achievement progress to the lobby" : "The native dropped Soul Key is not available";
            }
        }
    }
}
