// One native death target policy is shared by wave, dance and one-shot requests

run()
{
    targets_require_countable_native_roster_and_death_callbacks();
    protection_presence_and_unknown_fields_exclude_targets();
    native_brutes_remain_outside_the_wave_target_set();
    native_clowns_share_the_proven_player_attributed_death_path();
    pinned_generic_and_clown_registrations_are_accepted();
    malformed_actor_and_state_containers_are_rejected_before_fields();
    malformed_callback_tables_and_native_fields_cannot_be_eligible();
}

targets_require_countable_native_roster_and_death_callbacks()
{
    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "An initialized tracked axis zombie with the native death callback is eligible");
    state.spawned_enemies = [];
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "A stale copied roster entry cannot receive damage");
    state.spawned_enemies = [enemy];
    state.agent_funcs[enemy.agent_type]["gametype_on_killed"] = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "A foreign death callback cannot prove normal wave counting");
    state.agent_funcs[enemy.agent_type]["gametype_on_killed"] = scripts\cp\agents\gametype_zombie::onzombiekilled;
    state.agent_funcs[enemy.agent_type]["on_killed"] = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "A foreign per-type death handler cannot bypass the required native bookkeeping path");
    state.agent_funcs[enemy.agent_type]["on_killed"] = scripts\mp\agents\zombie\zombie_agent::onzombiekilled;
    enemy.team = "allies";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "An allied actor is never a wave-clear target");
    enemy.team = "axis";
    enemy.agent_type = "c6";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "An unproven actor death path cannot inherit wave clearing");
    enemy.agent_type = "generic_zombie";
    enemy.health = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "Dead actors cannot receive another packet");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, undefined), "A deleted actor is excluded");
}

protection_presence_and_unknown_fields_exclude_targets()
{
    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    enemy.is_reserved = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "Reserved quest actors cannot contribute normal wave deaths");
    enemy.is_reserved = 0;
    enemy.died_poorly = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "Respawn-marked actors are left to native bookkeeping");
    enemy.died_poorly = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "Uninitialized death-count eligibility cannot be guessed");
    enemy.died_poorly = 0;
    enemy.dont_scriptkill = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "Native script-kill protection depends on field presence even when its value is zero");
    enemy.dont_scriptkill = undefined;
    enemy.maxhealth = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "A native max-health damage packet requires initialized positive health bounds");
}

native_brutes_remain_outside_the_wave_target_set()
{
    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    enemy.agent_type = "zombie_brute";
    state.agent_funcs[enemy.agent_type] = [];
    state.agent_funcs[enemy.agent_type]["gametype_on_killed"] = scripts\cp\agents\gametype_zombie::onzombiekilled;
    state.agent_funcs[enemy.agent_type]["on_killed"] = scripts\mp\agents\zombie\zombie_agent::onzombiekilled;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "A Brute cannot join the wave target set even with an ordinary death callback and no reserved flag");
    enemy.dont_scriptkill = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "Reserved Brutes remain outside the ordinary quota target set");
}

native_clowns_share_the_proven_player_attributed_death_path()
{
    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    enemy.agent_type = "zombie_clown";
    enemy.is_suicide_bomber = 1;
    state.agent_funcs[enemy.agent_type] = [];
    state.agent_funcs[enemy.agent_type]["gametype_on_killed"] = scripts\cp\agents\gametype_zombie::onzombiekilled;
    state.agent_funcs[enemy.agent_type]["on_killed"] = scripts\mp\agents\zombie\zombie_agent::onzombiekilled;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "A countable native clown follows the shared proven zombie death handler");
    state.agent_funcs[enemy.agent_type]["on_killed"] = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "A changed clown handler cannot rely on the native player-kill branch");
}

pinned_generic_and_clown_registrations_are_accepted()
{
    state = tests\fixtures\spaceland::wave();
    // The token catalog supplies the callable path for both decompiled registrations
    foreach (type in ["generic_zombie", "zombie_clown"])
    {
        state.agent_funcs[type] = [];
        state.agent_funcs[type]["gametype_on_killed"] = scripts\cp\agents\gametype_zombie::onzombiekilled;
        state.agent_funcs[type]["on_killed"] = scripts\mp\agents\zombie\zombie_agent::onzombiekilled;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_targets::death_path(state, type),
            "The official native token module is admitted for generic and clown callbacks");
    }
}

malformed_actor_and_state_containers_are_rejected_before_fields()
{
    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    foreach (invalid in [7, "invalid", [], spawnstruct()])
    {
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, invalid),
            "A malformed actor cannot supply fields to the shared native target selector");
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(invalid, enemy),
            "A malformed state cannot supply the shared current native roster");
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::death_path(invalid, "generic_zombie"),
            "A malformed state cannot supply native killed callbacks");
    }
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::death_path(state, undefined),
        "An undefined actor type cannot index native callback data");
}

malformed_callback_tables_and_native_fields_cannot_be_eligible()
{
    foreach (invalid in [7, "invalid", [], spawnstruct()])
    {
        state = tests\fixtures\spaceland::wave();
        enemy = tests\fixtures\spaceland::wave_enemy(state);
        state.agent_funcs["generic_zombie"] = invalid;
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy),
            "Incomplete or malformed type callbacks reject before pointer comparison");
    }
    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    enemy.health = "500";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy),
        "Text health cannot be treated as native numeric health");
    enemy.health = 500;
    enemy.origin = "1 2 3";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy),
        "Text origins cannot be used as native damage points");
    enemy.origin = (1, 2, 3);
    enemy.died_poorly = "0";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy),
        "An unknown death-bookkeeping flag cannot authorize a request");
    enemy.died_poorly = 0;
    state.spawned_enemies = "invalid";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy),
        "A malformed native roster cannot be passed to membership lookup");
}
