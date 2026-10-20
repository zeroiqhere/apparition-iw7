// The activation receipt observes only an unchanged native Ghost step-six callback

run()
{
    install_wraps_only_the_exact_native_activation_callback();
    foreign_native_callbacks_remain_untouched();
    a_spent_watch_cannot_be_installed_again();
    a_valid_native_return_is_recorded_once_without_quest_mutation();
    unsupported_context_delegates_without_a_receipt();
    post_callback_registry_changes_do_not_record_a_receipt();
    a_valid_entry_replacement_cannot_inherit_the_original_receipt();
    post_callback_step_changes_do_not_record_a_receipt();
    post_callback_watch_changes_do_not_record_a_receipt();
    a_different_valid_watch_cannot_receive_a_stale_callback_receipt();
    a_valid_watch_replacement_cannot_receive_a_stale_callback_receipt();
    post_callback_original_changes_do_not_record_a_receipt();
    a_context_change_during_native_delegation_blocks_the_receipt();
    stale_step_delegates_without_a_receipt();
    arena_and_card_flags_cannot_infer_activation();
}

state(step, installed)
{
    value = tests\fixtures\ghosts::quest(step);

    if (installed)
        install_watch(value);
    return value;
}

install_watch(value)
{
    watch = spawnstruct();
    watch.observed = false;
    value.apparition_ghost_history = watch;
    scripts\apparition\maps\spaceland\ghost_history::install(value, watch);
    return watch;
}

install_wraps_only_the_exact_native_activation_callback()
{
    value = state(0, false);
    watch = spawnstruct();
    watch.observed = false;
    value.apparition_ghost_history = watch;
    other = value._id_13F4D["ghost"][5];
    entry = value._id_13F4D["ghost"][6];

    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghost_history::install(value, watch), "The unchanged native activation step can install its completion observer");
    tests\support\checks::expect(watch.entry == entry && watch.original == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet, "The watch retains the exact registered entry and native callback");
    tests\support\checks::expect(entry._id_446D == scripts\apparition\maps\spaceland\ghost_history::on_activation && other._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_brute_hit_arcade_cabinet_with_laser, "Only Ghost step six changes its completion field");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\ghost_history::install(value, watch), "An installed callback is not wrapped a second time");
}

foreign_native_callbacks_remain_untouched()
{
    value = state(0, false);
    watch = spawnstruct();
    watch.observed = false;
    value.apparition_ghost_history = watch;
    entry = value._id_13F4D["ghost"][6];
    entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;

    tests\support\checks::expect(!scripts\apparition\maps\spaceland\ghost_history::install(value, watch), "A changed native activation body is rejected");
    tests\support\checks::expect(entry._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet && !isDefined(watch.entry), "A foreign entry keeps its original completion callback");

    value = state(0, false);
    watch = spawnstruct();
    watch.observed = false;
    value.apparition_ghost_history = watch;
    entry = value._id_13F4D["ghost"][6];
    entry.init_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::wait_for_player_activation;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\ghost_history::install(value, watch), "A changed native initializer is rejected");
    tests\support\checks::expect(entry._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet, "A changed initializer cannot redirect callback ownership");

    value = state(0, false);
    watch = spawnstruct();
    watch.observed = false;
    value.apparition_ghost_history = watch;
    entry = value._id_13F4D["ghost"][6];
    entry._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\ghost_history::install(value, watch), "A replaced native completion callback is never overwritten");
    tests\support\checks::expect(entry._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank, "A foreign completion owner remains intact");
}

a_spent_watch_cannot_be_installed_again()
{
    value = state(0, false);
    watch = spawnstruct();
    watch.observed = true;
    value.apparition_ghost_history = watch;
    entry = value._id_13F4D["ghost"][6];

    tests\support\checks::expect(!scripts\apparition\maps\spaceland\ghost_history::install(value, watch), "A watch with an earlier receipt cannot be reused as a fresh observer");
    tests\support\checks::expect(entry._id_446D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::complete_clean_arcade_cabinet, "A spent watch leaves the native completion callback untouched");
}

a_valid_native_return_is_recorded_once_without_quest_mutation()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    owner = callback_owner(value);
    original_result = owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);
    entry = value._id_13F4D["ghost"][6];

    tests\support\checks::expect(original_result == "native callback result" && owner.calls == 1, "The native callback result is returned after one delegation");
    tests\support\checks::expect(owner.session_checks == 2, "Session support is checked before and after native delegation");
    tests\support\checks::expect(owner.receiver == owner && !owner.observed_during_callback, "The original callback keeps its inherited receiver and runs before observation");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghost_history::observed(value), "A supported native step-six callback return becomes an activation receipt");
    tests\support\checks::expect(value._id_13F1B["ghost"] == 6 && entry.init_func == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank && entry._id_DB5D == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::wait_for_player_activation && entry._id_446D == scripts\apparition\maps\spaceland\ghost_history::on_activation, "Observation leaves the native quest index and registered work unchanged");
    tests\support\checks::expect(!isDefined(value.skulls_before_activation) && !isDefined(value.ghostskulls_complete_status), "An activation receipt does not invent coin or arena completion state");
}

unsupported_context_delegates_without_a_receipt()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    owner = callback_owner(value);
    owner.session_allowed = false;
    result = owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(result == "native callback result" && owner.calls == 1, "An unsupported context still delegates native completion exactly once");
    tests\support\checks::expect(owner.session_checks == 1 && !watch.observed && !scripts\apparition\maps\spaceland\ghost_history::observed(value), "An unsupported context cannot create an activation receipt");
}

post_callback_registry_changes_do_not_record_a_receipt()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    owner = callback_owner(value);
    owner.mutation = "registry";
    result = owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(result == "native callback result" && owner.calls == 1, "Registry change cannot prevent the original callback from returning");
    tests\support\checks::expect(!watch.observed && !scripts\apparition\maps\spaceland\ghost_history::observed(value), "A replaced quest entry cannot keep a stale activation receipt");
}

a_valid_entry_replacement_cannot_inherit_the_original_receipt()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    entry_before = watch.entry;
    owner = callback_owner(value);
    owner.mutation = "valid_entry";
    owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(owner.calls == 1 && watch.entry != entry_before && scripts\apparition\maps\spaceland\ghost_history::owns(value), "A valid-shaped entry replacement can retain structural ownership");
    tests\support\checks::expect(!watch.observed, "A different registered entry cannot inherit the old entry's callback receipt");
}

post_callback_step_changes_do_not_record_a_receipt()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    owner = callback_owner(value);
    owner.mutation = "step";
    owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(owner.calls == 1 && value._id_13F1B["ghost"] == 5, "The callback can advance native state without altering its delegate count");
    tests\support\checks::expect(!watch.observed && !scripts\apparition\maps\spaceland\ghost_history::observed(value), "A changed quest step invalidates the post-callback receipt");
}

post_callback_watch_changes_do_not_record_a_receipt()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    owner = callback_owner(value);
    owner.mutation = "watch";
    owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(owner.calls == 1 && value.apparition_ghost_history != watch, "The original callback can replace the map watch");
    tests\support\checks::expect(!watch.observed && !scripts\apparition\maps\spaceland\ghost_history::observed(value), "A replaced watch cannot retain a receipt");
}

a_different_valid_watch_cannot_receive_a_stale_callback_receipt()
{
    value = state(6, true);
    current_watch = value.apparition_ghost_history;
    stale_watch = spawnstruct();
    stale_watch.entry = current_watch.entry;
    stale_watch.original = current_watch.original;
    stale_watch.observed = false;
    owner = callback_owner(value);
    result = owner scripts\apparition\maps\spaceland\ghost_history::route(value, stale_watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(result == "native callback result" && owner.calls == 1, "A callback with a stale captured watch still delegates native behavior");
    tests\support\checks::expect(!current_watch.observed && !stale_watch.observed, "A callback cannot record a receipt on a watch it did not capture");
}

a_valid_watch_replacement_cannot_receive_a_stale_callback_receipt()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    replacement = spawnstruct();
    replacement.entry = watch.entry;
    replacement.original = watch.original;
    replacement.observed = false;
    owner = callback_owner(value);
    owner.mutation = "valid_watch";
    owner.replacement = replacement;
    owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(owner.calls == 1 && value.apparition_ghost_history == replacement, "A native callback can replace the observer with another valid watch");
    tests\support\checks::expect(!watch.observed && !replacement.observed, "A replaced callback watch cannot receive a stale activation receipt");
}

post_callback_original_changes_do_not_record_a_receipt()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    owner = callback_owner(value);
    owner.mutation = "original";
    owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(owner.calls == 1 && watch.original == scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank, "The callback can replace the saved native original");
    tests\support\checks::expect(!watch.observed && !scripts\apparition\maps\spaceland\ghost_history::observed(value), "A changed original callback invalidates the post-callback receipt");
}

a_context_change_during_native_delegation_blocks_the_receipt()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    owner = callback_owner(value);
    owner.mutation = "context";
    result = owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(result == "native callback result" && owner.calls == 1, "A context change cannot prevent the native callback from completing");
    tests\support\checks::expect(owner.session_checks == 2 && !watch.observed, "A fresh post-callback context check blocks the receipt");
}

stale_step_delegates_without_a_receipt()
{
    value = state(5, true);
    watch = value.apparition_ghost_history;
    owner = callback_owner(value);
    result = owner scripts\apparition\maps\spaceland\ghost_history::route(value, watch, ::record_native_return, ::session_check);

    tests\support\checks::expect(result == "native callback result" && owner.calls == 1, "A stale callback still delegates its saved native behavior");
    tests\support\checks::expect(!watch.observed && !scripts\apparition\maps\spaceland\ghost_history::observed(value), "A callback outside native step six cannot be recorded");
}

arena_and_card_flags_cannot_infer_activation()
{
    value = state(6, true);
    watch = value.apparition_ghost_history;
    value.gns_active = 1;
    value.entered_thru_card = 1;
    value.ghostskulls_complete_status = 1;

    tests\support\checks::expect(!watch.observed && !scripts\apparition\maps\spaceland\ghost_history::observed(value), "Arena, card and win flags cannot substitute for this callback receipt");
}

callback_owner(value)
{
    owner = spawnstruct();
    owner.value = value;
    owner.calls = 0;
    owner.mutation = "";
    owner.session_allowed = true;
    owner.session_checks = 0;
    return owner;
}

session_check()
{
    self.session_checks++;
    return self.session_allowed;
}

record_native_return()
{
    self.calls++;
    self.receiver = self;
    self.observed_during_callback = self.value.apparition_ghost_history.observed;

    // Each mutation represents state changing while the saved callback runs
    if (self.mutation == "registry")
        self.value._id_13F4D["ghost"][6] = spawnstruct();
    else if (self.mutation == "valid_entry")
    {
        watch = self.value.apparition_ghost_history;
        replacement = spawnstruct();
        replacement.init_func = watch.entry.init_func;
        replacement._id_DB5D = watch.entry._id_DB5D;
        replacement._id_446D = watch.entry._id_446D;
        // Both references change together, so identity must be checked separately
        watch.entry = replacement;
        self.value._id_13F4D["ghost"][6] = replacement;
    }
    else if (self.mutation == "step")
        self.value._id_13F1B["ghost"] = 5;
    else if (self.mutation == "watch")
        self.value.apparition_ghost_history = spawnstruct();
    else if (self.mutation == "valid_watch")
        self.value.apparition_ghost_history = self.replacement;
    else if (self.mutation == "original")
        self.value.apparition_ghost_history.original = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    else if (self.mutation == "context")
        self.session_allowed = false;

    return "native callback result";
}
