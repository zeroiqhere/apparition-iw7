// Rejected requests never reach native revival or create native actor effects

run()
{
    missing_and_empty_selections_cannot_request_revives();
    nonplayer_selections_preserve_custom_request_and_native_state();
    lobby_requests_reject_missing_or_nonplayer_owners_without_reserving_revive();
}

missing_and_empty_selections_cannot_request_revives()
{
    probe = scripts\apparition\features\revive::probe(undefined);
    tests\support\checks::expect(probe.reason == "No current players are available" && !probe.targets.size,
        "An unavailable actor selection exposes no revive target");
    probe = scripts\apparition\features\revive::probe([]);
    tests\support\checks::expect(probe.reason == "No current players are available" && !probe.targets.size,
        "An empty actor selection cannot advertise a native revive");
    tests\support\checks::expect(!scripts\apparition\features\revive::request(undefined),
        "An unavailable selection cannot submit a native revive request");
    tests\support\checks::expect(!scripts\apparition\features\revive::request([]),
        "An empty selection cannot report a successful request");
}

nonplayer_selections_preserve_custom_request_and_native_state()
{
    actor = spawnstruct();
    actor.inlaststand = 1;
    actor.health = 1;
    actor.reviveent = spawnstruct();
    probe = scripts\apparition\features\revive::probe([actor]);
    tests\support\checks::expect(probe.reason == "Wait for a valid player roster" && !probe.targets.size,
        "Native actor admission precedes map and entity inspection");
    tests\support\checks::expect(!scripts\apparition\features\revive::request([actor]),
        "A nonplayer cannot reach the native revive helper");
    tests\support\checks::expect(actor.inlaststand == 1 && actor.health == 1
        && !isDefined(actor.reviveent.apparition_revive_submitted),
        "Rejected requests preserve native life fields and do not reserve an input");
}

lobby_requests_reject_missing_or_nonplayer_owners_without_reserving_revive()
{
    actor = spawnstruct();
    actor.inlaststand = 1;
    actor.health = 1;
    actor.reviveent = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\revive::request_lobby(undefined),
        "A missing requester cannot submit lobby revives");
    tests\support\checks::expect(!scripts\apparition\features\revive::request_lobby(actor),
        "A fixture requester cannot submit lobby revives");
    tests\support\checks::expect(actor.inlaststand == 1 && actor.health == 1
        && !isDefined(actor.reviveent.apparition_revive_submitted),
        "Rejected lobby admission preserves native state and creates no revive reservation");
}
