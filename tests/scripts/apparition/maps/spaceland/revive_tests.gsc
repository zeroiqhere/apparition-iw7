// The map policy selects only a current ordinary Spaceland laststand target

run()
{
    native_map_context_requires_the_registered_ordinary_callback();
    solo_hoff_override_is_not_a_native_wait_listener();
    player_must_be_alive_and_in_an_ordinary_laststand();
    every_temporary_or_nonordinary_state_blocks_admission();
    an_active_revive_requires_its_native_progress_record();
    player_revive_pointer_must_match_one_owned_live_trigger();
    a_new_native_pointer_does_not_inherit_an_older_submission();
    submitted_entity_stays_unconfirmed_without_native_exit();
    probing_never_marks_or_changes_native_state();
}

native_map_context_requires_the_registered_ordinary_callback()
{
    state = tests\fixtures\revive::context();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(state, 0) == "",
        "The registered Spaceland callback admits the ordinary co-op wait path");

    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(undefined, 0) != "",
        "A missing map context cannot authorize a revive");
    state = tests\fixtures\revive::context();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(state, undefined) != "",
        "An unknown solo-mode result cannot authorize a revive");
    state = tests\fixtures\revive::context();
    state.gameended = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(state, 0) != "",
        "An ended game cannot accept a revive request");
    state = tests\fixtures\revive::context();
    state.wait_to_be_revived_func = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(state, 0) != "",
        "A missing native wait callback cannot prove ordinary listener behavior");
    state = tests\fixtures\revive::context();
    state.wait_to_be_revived_func = scripts\cp\maps\cp_zmb\cp_zmb::setup_tutorial_requirements;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(state, 0) != "",
        "A replaced native wait callback blocks the revive path");
}

solo_hoff_override_is_not_a_native_wait_listener()
{
    state = tests\fixtures\revive::context();
    state.the_hoff_revive = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(state, 1) != "",
        "The solo Hoff trigger wait cannot receive the ordinary revive event");

    state = tests\fixtures\revive::context();
    state.only_one_player = 1;
    state.the_hoff_revive = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(state, 0) != "",
        "The one-player Hoff trigger wait cannot receive the ordinary revive event");

    state = tests\fixtures\revive::context();
    state.the_hoff_revive = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\revive::context_reason(state, 1) == "",
        "Solo state without the Hoff override keeps the native callback path");
}

player_must_be_alive_and_in_an_ordinary_laststand()
{
    target = tests\fixtures\revive::player();
    body = tests\fixtures\revive::revive_trigger(target);
    target.reviveent = body;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason == "" && result.entity == body,
        "A live player with one exact native revive trigger is ready");

    result = scripts\apparition\maps\spaceland\revive::probe(undefined, []);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A missing selected player cannot be revived");

    target = tests\fixtures\revive::player();
    target.inlaststand = 0;
    result = scripts\apparition\maps\spaceland\revive::probe(target, []);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A player outside native laststand cannot be selected");

    target = tests\fixtures\revive::player();
    target.inlaststand = "1";
    result = scripts\apparition\maps\spaceland\revive::probe(target, []);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A malformed laststand state cannot authorize a native revive");

    target = tests\fixtures\revive::player();
    target.sessionstate = "spectator";
    result = scripts\apparition\maps\spaceland\revive::probe(target, []);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A spectator cannot be selected for an ordinary revive");

    target = tests\fixtures\revive::player();
    target.health = 0;
    result = scripts\apparition\maps\spaceland\revive::probe(target, []);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A dead actor cannot be treated as a live laststand target");

    target = tests\fixtures\revive::player();
    target.health = "1";
    result = scripts\apparition\maps\spaceland\revive::probe(target, []);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A malformed health value cannot authorize a native revive");

    target = tests\fixtures\revive::player();
    target.sessionstate = undefined;
    result = scripts\apparition\maps\spaceland\revive::probe(target, []);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A missing session state cannot authorize a native revive");
}

every_temporary_or_nonordinary_state_blocks_admission()
{
    fields = ["spectating", "in_afterlife_arcade", "playing_ghosts_n_skulls", "playing_game",
        "linked_to_coaster", "self_revive", "kill_trigger_event_processed"];
    foreach (field in fields)
    {
        target = tests\fixtures\revive::player();
        body = tests\fixtures\revive::revive_trigger(target);
        target.reviveent = body;
        target[field] = 1;
        result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
        tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
            "A native temporary-state or kill-trigger marker blocks ordinary revive admission");
    }
}

an_active_revive_requires_its_native_progress_record()
{
    target = tests\fixtures\revive::player();
    body = tests\fixtures\revive::revive_trigger(target);
    target.reviveent = body;
    target.being_revived = 1;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "An incomplete active-revive record cannot reach native progress-bar cleanup");
    target.reviver = spawnstruct();
    target.revive_progress_bar_id = 1;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason == "" && result.entity == body,
        "A complete native progress record allows a current revive without assuming a player-only rescuer");
    target.revive_progress_bar_id = 2;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason == "",
        "The second native on-world revive progress slot is also supported");
    target.revive_progress_bar_id = 0;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "An invalid native progress slot cannot be used for a revive request");
}

player_revive_pointer_must_match_one_owned_live_trigger()
{
    target = tests\fixtures\revive::player();
    body = tests\fixtures\revive::revive_trigger(target);
    target.reviveent = undefined;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A trigger without the player's current revive pointer is not ready");

    target.reviveent = body;
    result = scripts\apparition\maps\spaceland\revive::probe(target, undefined);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A missing entity roster cannot establish a unique native trigger");

    result = scripts\apparition\maps\spaceland\revive::probe(target, "not an entity array");
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A malformed entity roster cannot establish a unique native trigger");

    other = tests\fixtures\revive::revive_trigger(target);
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body, other]);
    tests\support\checks::expect(result.reason == "" && result.entity == body,
        "The current native pointer is authoritative among older owned revive models");

    other = tests\fixtures\revive::revive_trigger(undefined);
    result = scripts\apparition\maps\spaceland\revive::probe(target, [other]);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A trigger owned by another actor cannot authorize the selected player's revive");

    other = tests\fixtures\revive::revive_trigger(target);
    other.targetname = "decoration";
    result = scripts\apparition\maps\spaceland\revive::probe(target, [other]);
    tests\support\checks::expect(result.reason != "" && !isDefined(result.entity),
        "A non-revive entity cannot stand in for the native revive trigger");
}

submitted_entity_stays_unconfirmed_without_native_exit()
{
    target = tests\fixtures\revive::player();
    body = tests\fixtures\revive::revive_trigger(target);
    target.reviveent = body;
    body.apparition_revive_submitted = 1;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason == "Revive submitted; native laststand exit is unconfirmed"
        && !isDefined(result.entity),
        "A prior submission for this down cannot be retried without native exit confirmation");

    body.apparition_revive_submitted = 0;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason == "" && result.entity == body,
        "A false marker does not reserve a revive entity");
}

a_new_native_pointer_does_not_inherit_an_older_submission()
{
    target = tests\fixtures\revive::player();
    previous = tests\fixtures\revive::revive_trigger(target);
    previous.apparition_revive_submitted = 1;
    current = tests\fixtures\revive::revive_trigger(target);
    target.reviveent = current;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [previous, current]);
    tests\support\checks::expect(result.reason == "" && result.entity == current,
        "A new native down identity is independent of an older submitted model");
    tests\support\checks::expect(previous.apparition_revive_submitted && !isDefined(current.apparition_revive_submitted),
        "Selecting a new native pointer never clears an earlier request or spends the new one");
}

probing_never_marks_or_changes_native_state()
{
    target = tests\fixtures\revive::player();
    body = tests\fixtures\revive::revive_trigger(target);
    target.reviveent = body;
    result = scripts\apparition\maps\spaceland\revive::probe(target, [body]);
    tests\support\checks::expect(result.reason == "" && !isDefined(body.apparition_revive_submitted),
        "Readiness inspection never spends the at-most-once request marker");
    tests\support\checks::expect(target.inlaststand == 1 && target.health == 1 && target.reviveent == body,
        "Readiness inspection leaves native target state unchanged");
}
