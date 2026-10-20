// Soul Key input uses the native pickup while ownership and model cleanup prove the observed result

run()
{
    collection_requires_native_destruction_completion_and_reward_callback();
    existing_ownership_does_not_replace_this_match_pickup_evidence();
    every_observed_recipient_requires_known_native_ownership();
    only_deleted_pickup_and_owned_recipients_confirm_collection();
    submitted_input_remains_spent_after_timeout_or_owner_loss();
}

state()
{
    state = tests\fixtures\spaceland::quest(11);
    state.flag["ufo_quest_finished"] = 1;
    state.flag["ufo_destroyed"] = 1;
    state._id_13F4D["ufo"][11]._id_446D = scripts\cp\maps\cp_zmb\cp_zmb_dj::complete_ufo_projectile_attack;
    return state;
}

receipt(total, known, owners)
{
    receipt = spawnstruct();
    receipt.total = total;
    receipt.known = known;
    receipt.owners = owners;
    return receipt;
}

collection_requires_native_destruction_completion_and_reward_callback()
{
    state = state();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) == "", "The completed native UFO sequence permits its dropped reward pickup");
    state.flag["ufo_quest_finished"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) != "", "Destruction before native quest completion cannot enable reward input");
    state.flag["ufo_quest_finished"] = 1;
    state.flag["ufo_destroyed"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) != "", "An inconsistent completion flag cannot replace native UFO destruction");
    state = state();
    state._id_13F4D["ufo"][11]._id_446D = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) != "", "The callback that creates the reward must retain its native identity");
    state = state();
    state._id_13F1B["ufo"] = 10;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) != "", "Stale reward flags in an earlier stage cannot admit input");
}

existing_ownership_does_not_replace_this_match_pickup_evidence()
{
    state = state();
    receipt = receipt(2, 2, 2);
    pickup = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::all_owned(receipt), "Native persistent ownership can predate this match");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::outcome(state, pickup, receipt, true, false) == "", "Existing ownership alone cannot claim that a surviving reward was collected");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) == "", "Previously owned keys do not block a newly dropped native pickup");
}

every_observed_recipient_requires_known_native_ownership()
{
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\soul_key::all_owned(receipt(0, 0, 0)), "An empty recipient snapshot cannot confirm an award");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\soul_key::all_owned(receipt(2, 1, 1)), "A disconnected or unreadable recipient leaves ownership unconfirmed");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\soul_key::all_owned(receipt(2, 2, 1)), "Every snapshotted recipient must own both native key fields");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::all_owned(receipt(2, 2, 2)), "All known native ownership fields confirm the snapshot result");
}

only_deleted_pickup_and_owned_recipients_confirm_collection()
{
    state = state();
    receipt = receipt(2, 2, 1);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::outcome(state, undefined, receipt, true, false) == "", "Model deletion without native ownership remains under observation");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::outcome(state, undefined, receipt, true, true) == "Pending", "An incomplete receipt at the deadline is unconfirmed");
    receipt.owners = 2;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::outcome(state, undefined, receipt, false, true) == "Collected", "A teammate's complete native pickup is recognized before timeout or permission checks");
    receipt.known = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::outcome(state, undefined, receipt, false, false) == "Unavailable", "Owner loss cannot make an unreadable receipt successful");
}

submitted_input_remains_spent_after_timeout_or_owner_loss()
{
    state = state();
    job = spawnstruct();
    job.state = "Pending";
    job.submitted = true;
    state.apparition_soul_key_job = job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) != "", "A submitted pickup is not repeated after timeout");
    job.state = "Unavailable";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) != "", "Losing the actor does not clear submitted-input history");
    job.submitted = false;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\soul_key::reason(state) == "", "A request rejected before input remains retryable");
}
