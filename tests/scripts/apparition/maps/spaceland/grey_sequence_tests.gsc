// The native spawn routine must return before complete-fight input can begin

run()
{
    only_the_unchanged_early_native_body_can_be_wrapped();
    late_or_changed_native_callbacks_are_left_untouched();
    spawn_return_cannot_resurrect_a_finished_fight();
    restoration_preserves_later_hook_ownership();
}

state()
{
    state = tests\fixtures\spaceland::greys();
    state._id_13F1B["ufo"] = 9;
    state.apparition_grey_sequence = scripts\apparition\maps\spaceland\grey_sequence::create();
    return state;
}

only_the_unchanged_early_native_body_can_be_wrapped()
{
    state = state();
    watch = state.apparition_grey_sequence;
    entry = state._id_13F4D["ufo"][10];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_sequence::install(state, watch), "The unchanged native body can be wrapped before its stage starts");
    tests\support\checks::expect(entry._id_DB5D == scripts\apparition\maps\spaceland\grey_sequence::fight && watch.original == scripts\cp\maps\cp_zmb\cp_zmb_dj::alien_grey_fight, "Only the body slot changes and its original function is retained for restoration");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_sequence::owned(state, watch) && watch.state == "Installed", "The installed watch owns its exact live entry");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_sequence::install(state, watch), "An installed callback cannot wrap itself again");
}

late_or_changed_native_callbacks_are_left_untouched()
{
    state = state();
    state._id_13F1B["ufo"] = 10;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_sequence::install(state, state.apparition_grey_sequence), "An already published Grey stage cannot establish early hook ownership");
    state = state();
    entry = state._id_13F4D["ufo"][10];
    entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_sequence::install(state, state.apparition_grey_sequence) && entry._id_DB5D == scripts\cp\maps\cp_zmb\cp_zmb_dj::blank, "A foreign body callback is never overwritten or chained");
    state = state();
    state._id_13F4D["ufo"][10]._id_446D = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_sequence::install(state, state.apparition_grey_sequence), "Native completion behavior must retain its registered identity");
}

spawn_return_cannot_resurrect_a_finished_fight()
{
    watch = scripts\apparition\maps\spaceland\grey_sequence::create();
    watch.state = "Spawning";
    scripts\apparition\maps\spaceland\grey_sequence::spawn_returned(watch);
    tests\support\checks::expect(watch.state == "Ready", "Full native spawn-loop return establishes readiness");
    watch.state = "Ended";
    scripts\apparition\maps\spaceland\grey_sequence::spawn_returned(watch);
    tests\support\checks::expect(watch.state == "Ended", "An early native completion event cannot be reversed by a later spawn-loop return");
}

restoration_preserves_later_hook_ownership()
{
    state = state();
    watch = state.apparition_grey_sequence;
    scripts\apparition\maps\spaceland\grey_sequence::install(state, watch);
    watch.state = "Ended";
    scripts\apparition\maps\spaceland\grey_sequence::restore(state, watch);
    tests\support\checks::expect(watch.entry._id_DB5D == watch.original && !scripts\apparition\maps\spaceland\grey_sequence::owned(state, watch), "The original body is restored only after native completion");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_sequence::tracked(state, watch), "A restored ended watch can still observe native quest cleanup");
    state = state();
    watch = state.apparition_grey_sequence;
    scripts\apparition\maps\spaceland\grey_sequence::install(state, watch);
    watch.entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    scripts\apparition\maps\spaceland\grey_sequence::restore(state, watch);
    tests\support\checks::expect(watch.entry._id_DB5D == scripts\cp\maps\cp_zmb\cp_zmb_dj::blank && !scripts\apparition\maps\spaceland\grey_sequence::tracked(state, watch), "A later callback owner is preserved and cannot authorize menu damage");
}
