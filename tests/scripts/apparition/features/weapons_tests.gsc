// Weapon policy tests never remove or grant a native weapon

run()
{
    source_exclusions_preserve_none_base_melee_and_knife_names();
    primary_melee_and_alternate_names_keep_the_original_narrow_filter();
    malformed_weapon_state_is_rejected_before_string_operations();
    weapon_access_starts_at_the_original_vip_tier();
    native_temporary_inventory_markers_block_removal();
    only_the_matching_ephemeral_weapon_is_owned_by_native_downgrade();
    invalid_actors_cannot_probe_native_weapon_state();
    last_stand_bookkeeping_requires_the_native_string_and_array_shapes();
}

source_exclusions_preserve_none_base_melee_and_knife_names()
{
    foreach (weapon in ["none", "", "base_melee", "iw7_knife_zm", "special_knife_alt"])
        tests\support\checks::expect(scripts\apparition\features\weapons::weapon_reason(weapon, "base_melee") != "",
            "The source preserves none, base melee and every name containing the knife suffix");
    tests\support\checks::expect(scripts\apparition\features\weapons::weapon_reason("iw7_g18_zmr", "base_melee") == "",
        "An ordinary held pistol passes the source removal filter");
}

primary_melee_and_alternate_names_keep_the_original_narrow_filter()
{
    foreach (weapon in ["iw7_katana_zm", "iw7_axe_zm", "alt_iw7_rifle_zm", "iw7_rifle_zm+scope"])
        tests\support\checks::expect(scripts\apparition\features\weapons::weapon_reason(weapon, "base_melee") == "",
            "The source does not broadly preserve primary melee, alternate names or attachments");
}

malformed_weapon_state_is_rejected_before_string_operations()
{
    tests\support\checks::expect(scripts\apparition\features\weapons::weapon_reason(undefined, "base_melee") != "",
        "An absent native held weapon cannot reach a string operation");
    tests\support\checks::expect(scripts\apparition\features\weapons::weapon_reason("iw7_rifle_zm", undefined) != "",
        "Missing native base melee identity cannot authorize removal");
    foreach (value in [7, [], spawnstruct(), (1, 2, 3), ::run])
    {
        tests\support\checks::expect(scripts\apparition\features\weapons::weapon_reason(value, "base_melee") != "",
            "Malformed current weapon state cannot reach native removal");
        tests\support\checks::expect(scripts\apparition\features\weapons::weapon_reason("iw7_rifle_zm", value) != "",
            "Malformed base melee state cannot weaken the source exclusion");
    }
}

weapon_access_starts_at_the_original_vip_tier()
{
    foreach (access in ["Bot", "None", "Verified", "unknown"])
        tests\support\checks::expect(scripts\apparition\features\weapons::role_reason(access) != "",
            "Roles below the source Weaponry tier cannot use its action");
    foreach (access in ["VIP", "Admin", "Co-Host", "Host", "Developer"])
        tests\support\checks::expect(scripts\apparition\features\weapons::role_reason(access) == "",
            "The source VIP tier and later tiers admit weapon controls");
}

native_temporary_inventory_markers_block_removal()
{
    player = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\weapons::temporary_reason(player, undefined) == "",
        "Absent temporary state does not invent an active native owner");
    player.playing_game = 1;
    tests\support\checks::expect(scripts\apparition\features\weapons::temporary_reason(player, undefined) != "",
        "The existing map inventory guard also protects weapon removal");
    player.playing_game = undefined;
    tests\support\checks::expect(scripts\apparition\features\weapons::temporary_reason(player, 1) != "",
        "Global Ghosts N Skulls ownership blocks removal before a player marker appears");
    foreach (field in ["isusingsupercard", "mpsuperpreviousweapon", "last_weapon", "wor_phase_shift"])
    {
        player[field] = (field == "mpsuperpreviousweapon" || field == "last_weapon") ? "iw7_pistol_zm" : 1;
        tests\support\checks::expect(scripts\apparition\features\weapons::temporary_reason(player, 0) != "",
            "Native temporary weapon ownership and transition markers block removal");
        player[field] = undefined;
    }
    player.isusingsupercard = 0;
    player.wor_phase_shift = 0;
    tests\support\checks::expect(scripts\apparition\features\weapons::temporary_reason(player, 0) == "",
        "Cleared native boolean markers allow the normal removal path");
}

invalid_actors_cannot_probe_native_weapon_state()
{
    snapshot = scripts\apparition\features\weapons::probe(undefined, undefined);
    tests\support\checks::expect(snapshot.reason != "" && !isDefined(snapshot.weapon),
        "A missing actor is rejected before native weapon and phase methods");
    owner = spawnstruct();
    target = spawnstruct();
    target.last_stand_pistol = "unchanged";
    snapshot = scripts\apparition\features\weapons::probe(owner, target);
    tests\support\checks::expect(snapshot.reason != "" && !isDefined(snapshot.weapon),
        "Fixture actors cannot expose native weapon state");
    tests\support\checks::expect(!scripts\apparition\features\weapons::take_current(owner, target)
        && target.last_stand_pistol == "unchanged",
        "Rejected removal cannot mutate Last Stand bookkeeping");
}


last_stand_bookkeeping_requires_the_native_string_and_array_shapes()
{
    player = spawnstruct();
    player.last_stand_pistol = "iw7_g18_zmr";
    player.default_starting_pistol = "iw7_g18_zmr";
    player.weapon_build_models = [];
    player.weaponkitinitialized = 1;
    tests\support\checks::expect(scripts\apparition\features\weapons::bookkeeping_reason(player, ["iw7_g18_zmr"]) == "",
        "Initialized native pistol state and a weapon-build map permit the stock updater");
    player.weaponkitinitialized = undefined;
    tests\support\checks::expect(scripts\apparition\features\weapons::bookkeeping_reason(player, []) != "",
        "Native weapon-build setup must finish before invoking its fallback map");
    player.weaponkitinitialized = 1;
    player.last_stand_pistol = undefined;
    tests\support\checks::expect(scripts\apparition\features\weapons::bookkeeping_reason(player, []) != "",
        "A missing tracked pistol cannot reach native getweaponbasename");
    player.last_stand_pistol = "iw7_g18_zmr";
    foreach (value in ["", "none", 7, [], spawnstruct()])
    {
        player.default_starting_pistol = value;
        tests\support\checks::expect(scripts\apparition\features\weapons::bookkeeping_reason(player, []) != "",
            "Invalid default pistol state cannot reach the stock fallback lookup");
    }
    player.default_starting_pistol = "iw7_g18_zmr";
    player.weapon_build_models = 7;
    tests\support\checks::expect(scripts\apparition\features\weapons::bookkeeping_reason(player, []) != "",
        "A malformed build map cannot reach indexed native fallback access");
    player.weapon_build_models = [];
    foreach (value in [7, "pistol", spawnstruct()])
        tests\support\checks::expect(scripts\apparition\features\weapons::bookkeeping_reason(player, value) != "",
            "The stock last-stand weapon catalog must have its native array shape");
}


only_the_matching_ephemeral_weapon_is_owned_by_native_downgrade()
{
    tests\support\checks::expect(scripts\apparition\features\weapons::ephemeral_reason("iw7_rifle_zm", undefined) == ""
        && scripts\apparition\features\weapons::ephemeral_reason("iw7_rifle_zm", "iw7_pistol_zm") == "",
        "No ephemeral owner or an owner of another basename leaves this current weapon available");
    tests\support\checks::expect(scripts\apparition\features\weapons::ephemeral_reason("iw7_rifle_zm", "iw7_rifle_zm") != "",
        "The matching ephemeral gun stays with its native downgrade worker");
    foreach (value in [7, "", [], spawnstruct()])
        tests\support\checks::expect(scripts\apparition\features\weapons::ephemeral_reason("iw7_rifle_zm", value) != "",
            "Malformed native ephemeral ownership cannot authorize current removal");
}
