// Access policy contracts use pure role resolution and safe early guards

run()
{
    catalog_matches_apparition_order();
    assignable_levels_exclude_reserved_roles();
    bot_precedes_host_and_saved_roles();
    invalid_saved_roles_resolve_to_none();
    rank_and_menu_threshold_match_apparition();
    missing_player_cannot_open_menu();
    invalid_grants_stop_before_actor_or_session_calls();
    fun_policy_rejects_invalid_actors_without_changing_saved_state();
    fun_grant_policy_rejects_invalid_actors_without_changing_saved_state();
}

catalog_matches_apparition_order()
{
    expected = ["Bot", "None", "Verified", "VIP", "Admin", "Co-Host", "Host", "Developer"];
    actual = scripts\apparition\runtime\access::catalog();

    tests\support\checks::expect(actual.size == expected.size,
        "The access catalog keeps the eight source roles");
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(actual[index] == expected[index],
            "The access catalog preserves source order");
}

assignable_levels_exclude_reserved_roles()
{
    expected = ["None", "Verified", "VIP", "Admin", "Co-Host"];
    actual = scripts\apparition\runtime\access::assignable();

    tests\support\checks::expect(actual.size == expected.size,
        "Only the five nonreserved guest roles are assignable");
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(actual[index] == expected[index],
            "Assignable roles preserve Apparition order");
}

bot_precedes_host_and_saved_roles()
{
    tests\support\checks::expect(scripts\apparition\runtime\access::resolve(false, true, "VIP") == "Bot",
        "Native bots resolve to Bot before saved access");
    tests\support\checks::expect(scripts\apparition\runtime\access::resolve(true, true, "VIP") == "Bot",
        "Bot resolution takes precedence over host resolution");
    tests\support\checks::expect(scripts\apparition\runtime\access::resolve(true, false, "VIP") == "Host",
        "The current native host resolves to Host");
    tests\support\checks::expect(scripts\apparition\runtime\access::resolve(false, false, "VIP") == "VIP",
        "A recognized saved guest role resolves as configured");
}

invalid_saved_roles_resolve_to_none()
{
    tests\support\checks::expect(scripts\apparition\runtime\access::resolve(false, false, undefined) == "None",
        "A missing saved grant resolves to None");

    tests\support\checks::expect(scripts\apparition\runtime\access::resolve(false, false, false) == "None",
        "A numeric false alias is not a saved role string");
    foreach (saved in ["unknown", "Bot", "Host", "Developer", "verified", 2])
        tests\support\checks::expect(scripts\apparition\runtime\access::resolve(false, false, saved) == "None",
            "Unknown and reserved saved values resolve to None");
}

rank_and_menu_threshold_match_apparition()
{
    roles = scripts\apparition\runtime\access::catalog();
    for (index = 0; index < roles.size; index++)
        tests\support\checks::expect(scripts\apparition\runtime\access::rank(roles[index]) == index,
            "Ranks follow access catalog order");

    tests\support\checks::expect(scripts\apparition\runtime\access::rank("unrecognized") == 1,
        "Unknown roles use the None rank");
    tests\support\checks::expect(scripts\apparition\runtime\access::rank(undefined) == 1,
        "Missing roles use the None rank");
    tests\support\checks::expect(!scripts\apparition\runtime\access::has_menu("Bot")
        && !scripts\apparition\runtime\access::has_menu("None"),
        "Bot and None do not open the menu");
    tests\support\checks::expect(scripts\apparition\runtime\access::has_menu("Verified")
        && scripts\apparition\runtime\access::has_menu("Host")
        && scripts\apparition\runtime\access::has_menu("Developer"),
        "Verified and higher roles open the menu");
    tests\support\checks::expect(!scripts\apparition\runtime\access::has_menu("unrecognized"),
        "Unknown roles do not open the menu");
}

missing_player_cannot_open_menu()
{
    tests\support\checks::expect(scripts\apparition\runtime\access::current(undefined) == "None",
        "A missing player resolves to None before native player calls");
    tests\support\checks::expect(!scripts\apparition\runtime\access::can_open(undefined),
        "A missing player cannot open the menu");
}

invalid_grants_stop_before_actor_or_session_calls()
{
    owner = spawnstruct();
    target = spawnstruct();
    saved_grant = spawnstruct();
    saved_grant.access = "Verified";
    target.apparition_access = saved_grant;

    tests\support\checks::expect(!scripts\apparition\runtime\access::grant(owner, target, undefined),
        "An undefined grant stops before native actor checks");
    foreach (invalid in [0, "Host", "Developer", "unknown", "verified"])
        tests\support\checks::expect(!scripts\apparition\runtime\access::grant(owner, target, invalid),
            "Invalid grants stop before native actor checks");

    tests\support\checks::expect(target.apparition_access == saved_grant && saved_grant.access == "Verified",
        "Rejected grants preserve the target's existing value");
}

fun_policy_rejects_invalid_actors_without_changing_saved_state()
{
    owner = spawnstruct();
    target = spawnstruct();
    saved_grant = spawnstruct();
    saved_grant.access = "VIP";
    owner.apparition_access = saved_grant;
    health_record = spawnstruct();
    frog_record = spawnstruct();
    target.apparition_health_bar = health_record;
    target.apparition_frog_jump = frog_record;

    tests\support\checks::expect(scripts\apparition\runtime\access::fun_reason(owner, target) != "",
        "Fun policy rejects fixture structs that are not admitted actors");
    tests\support\checks::expect(owner.apparition_access == saved_grant
        && saved_grant.access == "VIP",
        "Fun policy rejection preserves the owner's captured verification grant");
    tests\support\checks::expect(target.apparition_health_bar == health_record
        && target.apparition_frog_jump == frog_record,
        "Fun policy rejection preserves target feature configuration");
    tests\support\checks::expect(scripts\apparition\runtime\access::fun_reason(undefined, target) != "",
        "Fun policy rejects a missing owner before reading target feature state");
}

fun_grant_policy_rejects_invalid_actors_without_changing_saved_state()
{
    owner = spawnstruct();
    target = spawnstruct();
    captured_grant = spawnstruct();
    captured_grant.access = "VIP";
    owner.apparition_access = captured_grant;
    health_record = spawnstruct();
    target.apparition_health_bar = health_record;

    tests\support\checks::expect(scripts\apparition\runtime\access::fun_grant_reason(
        owner, target, captured_grant) != "",
        "Fun worker grant policy rejects fixture structs that are not admitted actors");
    tests\support\checks::expect(owner.apparition_access == captured_grant
        && captured_grant.access == "VIP",
        "Rejected worker admission preserves the owner's captured grant");
    tests\support\checks::expect(target.apparition_health_bar == health_record,
        "Rejected worker admission preserves target feature configuration");
}
