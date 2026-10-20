// Native-free checks cover persistent guide ownership without allocating HUDs

run()
{
    allocation_reuse_requires_current_shape_life_and_owned_roles();
    release_clears_only_the_instruction_pool_and_is_repeatable();
}

allocation_reuse_requires_current_shape_life_and_owned_roles()
{
    layout = scripts\apparition\menu\layout::defaults();
    plan = scripts\apparition\menu\instructions::plan(layout, "Guide", false, undefined, false, false);
    pool = spawnstruct();
    pool.shape = plan.shape;
    pool.alive = true;
    pool.elements = [];
    pool.elements["string"] = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\instruction_hud::matches(pool, plan, true),
        "A guide with enabled background cannot reuse a pool missing its rectangles");
    pool.elements["background"] = spawnstruct();
    pool.elements["outline"] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\menu\instruction_hud::matches(pool, plan, true),
        "Complete ownership permits position and message updates in the existing pool");
    tests\support\checks::expect(!scripts\apparition\menu\instruction_hud::matches(pool, plan, false),
        "A life change requires a fresh instruction allocation");
    layout.disable_instructions_background = true;
    plain = scripts\apparition\menu\instructions::plan(layout, "Guide", false, undefined, false, false);
    tests\support\checks::expect(!scripts\apparition\menu\instruction_hud::matches(pool, plain, true),
        "Background preference changes cannot retain the old shape");
    pool.shape = plain.shape;
    pool.elements = [];
    pool.elements["string"] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\menu\instruction_hud::matches(pool, plain, true),
        "A background-free guide owns only its text element");
    pool.elements["string"] = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\instruction_hud::matches(pool, plain, true)
        && !scripts\apparition\menu\instruction_hud::matches(undefined, plain, true),
        "Missing text or a released pool cannot pass the allocation gate");
}

release_clears_only_the_instruction_pool_and_is_repeatable()
{
    owner = spawnstruct();
    owner.apparition_hud = spawnstruct();
    main_hud = owner.apparition_hud;
    owner.apparition_instructions = spawnstruct();
    owner.apparition_instructions.elements = [];
    scripts\apparition\menu\instruction_hud::release(owner);
    scripts\apparition\menu\instruction_hud::release(owner);
    tests\support\checks::expect(!isDefined(owner.apparition_instructions) && owner.apparition_hud == main_hud,
        "Repeated guide cleanup leaves the independent main HUD owner unchanged");
}
