// Callback contracts describe native delegation and per-attempt admission

run()
{
    native_registry_has_only_the_two_expected_steps();
    exact_native_callback_installation_preserves_other_owners();
    first_callback_captures_the_new_native_attempt();
    a_completed_brute_phase_can_rearm_a_new_attempt();
    unresolved_brute_phase_invalidates_old_work_without_rearming();
    malformed_existing_registry_cannot_be_admitted();
    missing_or_foreign_registry_after_delegation_stays_unready();
    existing_entries_must_keep_their_identity_across_rearm();
    unsupported_context_still_delegates_and_invalidates_old_work();
    stale_watch_or_callback_still_delegates_without_receipt();
    attempt_replacement_during_delegation_blocks_current_receipt();
    watch_replacement_during_delegation_blocks_current_receipt();
    callback_replacement_during_delegation_blocks_current_receipt();
    context_change_during_delegation_blocks_current_receipt();
    return_value_and_inherited_receiver_are_preserved();
}

native_registry_has_only_the_two_expected_steps()
{
    state = tests\fixtures\reactivation::state();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == 0, "The native initial Brute step is recognized");
    state._id_13F1B["reactivateghost"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == 1, "The native cabinet activation step is recognized");
    state._id_13F1B["reactivateghost"] = 2;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == -1, "An out-of-range native index is rejected");
    state._id_13F1B["reactivateghost"] = 0;
    state._id_13F4D["reactivateghost"][1]._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == -1, "A changed body cannot inherit the native line identity");
    state = tests\fixtures\reactivation::state();
    state._id_13F4D["reactivateghost"][0].init_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == -1, "A changed Brute initializer is rejected");
    state = tests\fixtures\reactivation::state();
    state._id_13F4D["reactivateghost"][0]._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == -1, "A changed Brute completion callback is rejected");
    state = tests\fixtures\reactivation::state();
    state._id_13F4D["reactivateghost"][1].init_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::reactive_ghost_n_skull_cabinet;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == -1, "A changed activation initializer is rejected");
    state = tests\fixtures\reactivation::state();
    state._id_13F4D["reactivateghost"][1]._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == -1, "A changed activation completion callback is rejected");
    state = tests\fixtures\reactivation::state();
    state._id_13F4D["reactivateghost"][2] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == -1, "Extra registered entries reject the exact two-step contract");
    state._id_13F4D["reactivateghost"] = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::step(state) == -1, "A missing native line is not a current attempt");
}

exact_native_callback_installation_preserves_other_owners()
{
    state = tests\fixtures\reactivation::state();
    watch = spawnstruct();
    state.apparition_reactivation_history = watch;
    original = state.ghost_n_skull_reactivate_func;

    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::install(state, watch), "The known global native callback can be wrapped");
    tests\support\checks::expect(watch.original == original && scripts\apparition\maps\spaceland\reactivation_history::owns(state), "The watch retains the exact native callback owner");
    tests\support\checks::expect(state.ghost_n_skull_reactivate_func == scripts\apparition\maps\spaceland\reactivation_history::on_reactivation, "Only the known map callback is replaced");

    state = tests\fixtures\reactivation::state();
    watch = spawnstruct();
    state.apparition_reactivation_history = watch;
    state.ghost_n_skull_reactivate_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\reactivation_history::install(state, watch), "An unknown callback is never overwritten");
    tests\support\checks::expect(state.ghost_n_skull_reactivate_func == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank, "A foreign global owner remains unchanged");
}

first_callback_captures_the_new_native_attempt()
{
    state = tests\fixtures\reactivation::unregistered_state();
    watch = install_watch(state);
    caller = callback_owner(state);
    caller.mutation = "register_entries";
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);
    attempt = watch.attempt;

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "The native reactivation callback runs once and returns its result");
    tests\support\checks::expect(attempt.ready && attempt.first == state._id_13F4D["reactivateghost"][0] && attempt.activation == state._id_13F4D["reactivateghost"][1], "First registration captures the exact newly created entries");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\reactivation_history::current(state)), "A pending native quest thread has no current step yet");
    state._id_13F1B["reactivateghost"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::current(state) == attempt, "The attempt becomes current when the native first step begins");
}

a_completed_brute_phase_can_rearm_a_new_attempt()
{
    state = tests\fixtures\reactivation::state();
    state._id_13F1B["reactivateghost"] = 1;
    watch = install_watch(state);
    old_attempt = spawnstruct();
    old_attempt.ready = true;
    old_attempt.first = state._id_13F4D["reactivateghost"][0];
    old_attempt.activation = state._id_13F4D["reactivateghost"][1];
    watch.attempt = old_attempt;
    caller = callback_owner(state);
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "A settled reactivation still delegates native behavior");
    tests\support\checks::expect(watch.attempt != old_attempt && watch.attempt.ready, "A completed Brute phase admits a fresh captured attempt");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\reactivation_history::current(state) == watch.attempt, "The captured attempt remains current at the native activation step");
}

unresolved_brute_phase_invalidates_old_work_without_rearming()
{
    state = tests\fixtures\reactivation::state();
    watch = install_watch(state);
    old_attempt = spawnstruct();
    old_attempt.ready = true;
    old_attempt.first = state._id_13F4D["reactivateghost"][0];
    old_attempt.activation = state._id_13F4D["reactivateghost"][1];
    watch.attempt = old_attempt;
    caller = callback_owner(state);
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "A repeated native call preserves the original callback");
    tests\support\checks::expect(watch.attempt != old_attempt && !watch.attempt.ready, "An unresolved Brute phase invalidates old jobs without admitting overlap");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\reactivation_history::current(state)), "An unready replacement cannot be used by feature workers");
}

malformed_existing_registry_cannot_be_admitted()
{
    state = tests\fixtures\reactivation::state();
    state._id_13F1B["reactivateghost"] = 2;
    watch = install_watch(state);
    caller = callback_owner(state);
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "A malformed prior index still delegates native behavior");
    tests\support\checks::expect(!watch.attempt.ready, "Unknown existing progress cannot arm a new observer");
}

missing_or_foreign_registry_after_delegation_stays_unready()
{
    foreach (mutation in ["missing", "foreign"]) 
    {
        state = tests\fixtures\reactivation::state();
        state._id_13F1B["reactivateghost"] = 1;
        watch = install_watch(state);
        caller = callback_owner(state);
        caller.mutation = mutation;
        result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

        tests\support\checks::expect(result == "native result" && caller.calls == 1, "A missing or foreign post-call registry cannot suppress native delegation");
        tests\support\checks::expect(!watch.attempt.ready, "Only both exact native entries arm a first attempt");
    }
}

existing_entries_must_keep_their_identity_across_rearm()
{
    state = tests\fixtures\reactivation::state();
    state._id_13F1B["reactivateghost"] = 1;
    watch = install_watch(state);
    caller = callback_owner(state);
    caller.mutation = "replace_valid_entries";
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "A native call still returns through an entry replacement");
    tests\support\checks::expect(!watch.attempt.ready, "A pre-existing registry replacement cannot be attributed to the native rearm");
}

unsupported_context_still_delegates_and_invalidates_old_work()
{
    state = tests\fixtures\reactivation::state();
    state._id_13F1B["reactivateghost"] = 1;
    watch = install_watch(state);
    old_attempt = spawnstruct();
    old_attempt.ready = true;
    old_attempt.first = state._id_13F4D["reactivateghost"][0];
    old_attempt.activation = state._id_13F4D["reactivateghost"][1];
    watch.attempt = old_attempt;
    caller = callback_owner(state);
    caller.session_allowed = false;
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "Unsupported context cannot block the native outer callback");
    tests\support\checks::expect(watch.attempt != old_attempt && !watch.attempt.ready, "Out-of-session invocation still invalidates the old attempt");
    tests\support\checks::expect(caller.session_checks == 2, "Admission and receipt both use a fresh session check");
}

stale_watch_or_callback_still_delegates_without_receipt()
{
    state = tests\fixtures\reactivation::state();
    watch = install_watch(state);
    stale = spawnstruct();
    stale.original = watch.original;
    stale.attempt = spawnstruct();
    stale.attempt.ready = true;
    caller = callback_owner(state);
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, stale, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "A stale wrapper still delegates its fixed native callback");
    tests\support\checks::expect(stale.attempt.ready && !isDefined(watch.attempt), "A stale wrapper cannot change either watch's attempt");

    state.ghost_n_skull_reactivate_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    caller = callback_owner(state);
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);
    tests\support\checks::expect(result == "native result" && caller.calls == 1, "A callback after ownership loss still delegates the native function");
    tests\support\checks::expect(!isDefined(watch.attempt), "A callback after ownership loss cannot publish a new attempt");
}

attempt_replacement_during_delegation_blocks_current_receipt()
{
    state = tests\fixtures\reactivation::state();
    state._id_13F1B["reactivateghost"] = 1;
    watch = install_watch(state);
    caller = callback_owner(state);
    caller.mutation = "replace_attempt";
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "Attempt replacement cannot prevent native behavior");
    tests\support\checks::expect(!isDefined(watch.attempt.ready), "A superseded attempt cannot receive a registration receipt");
}

watch_replacement_during_delegation_blocks_current_receipt()
{
    state = tests\fixtures\reactivation::state();
    state._id_13F1B["reactivateghost"] = 1;
    watch = install_watch(state);
    caller = callback_owner(state);
    caller.mutation = "replace_watch";
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "Watch replacement cannot prevent native behavior");
    tests\support\checks::expect(!watch.attempt.ready && state.apparition_reactivation_history != watch, "A replaced watch cannot receive a registration receipt");
}

callback_replacement_during_delegation_blocks_current_receipt()
{
    state = tests\fixtures\reactivation::state();
    state._id_13F1B["reactivateghost"] = 1;
    watch = install_watch(state);
    caller = callback_owner(state);
    caller.mutation = "replace_callback";
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "A callback replacement cannot prevent native behavior");
    tests\support\checks::expect(!watch.attempt.ready && state.ghost_n_skull_reactivate_func == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank, "A foreign callback owner cannot receive an observer receipt");
}

context_change_during_delegation_blocks_current_receipt()
{
    state = tests\fixtures\reactivation::state();
    state._id_13F1B["reactivateghost"] = 1;
    watch = install_watch(state);
    caller = callback_owner(state);
    caller.mutation = "context";
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "A context change cannot prevent the native callback");
    tests\support\checks::expect(caller.session_checks == 2 && !watch.attempt.ready, "Fresh session validation after delegation blocks admission");
}

return_value_and_inherited_receiver_are_preserved()
{
    state = tests\fixtures\reactivation::state();
    watch = install_watch(state);
    caller = callback_owner(state);
    result = caller scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::native_delegate, ::session_check);

    tests\support\checks::expect(result == "native result" && caller.calls == 1, "The original function return is passed through unchanged");
    tests\support\checks::expect(caller.receiver == caller && caller.session_checks == 2, "The saved callback receives the inherited caller and support is checked twice");
}

install_watch(state)
{
    watch = spawnstruct();
    state.apparition_reactivation_history = watch;
    scripts\apparition\maps\spaceland\reactivation_history::install(state, watch);
    return watch;
}

callback_owner(state)
{
    owner = spawnstruct();
    owner.state = state;
    owner.calls = 0;
    owner.session_allowed = true;
    owner.session_checks = 0;
    owner.mutation = "";
    return owner;
}

session_check()
{
    self.session_checks++;
    return self.session_allowed;
}

native_delegate()
{
    self.calls++;
    self.receiver = self;
    if (self.mutation == "missing")
        self.state._id_13F4D["reactivateghost"] = undefined;
    else if (self.mutation == "foreign")
        self.state._id_13F4D["reactivateghost"][1]._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    else if (self.mutation == "replace_valid_entries")
    {
        self.state._id_13F4D["reactivateghost"] = [tests\fixtures\reactivation::first_entry(), tests\fixtures\reactivation::activation_entry()];
    }
    else if (self.mutation == "replace_attempt")
        self.state.apparition_reactivation_history.attempt = spawnstruct();
    else if (self.mutation == "replace_watch")
        self.state.apparition_reactivation_history = spawnstruct();
    else if (self.mutation == "replace_callback")
        self.state.ghost_n_skull_reactivate_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    else if (self.mutation == "context")
        self.session_allowed = false;
    else if (self.mutation == "register_entries")
    {
        self.state._id_13F4D["reactivateghost"] = [tests\fixtures\reactivation::first_entry(), tests\fixtures\reactivation::activation_entry()];
        // Native thread sets the index after the outer callback returns
    }
    return "native result";
}
