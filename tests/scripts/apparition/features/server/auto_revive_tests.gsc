// Auto-revive contracts avoid changing native actors or level settings

run()
{
    absent_and_undefined_tokens_are_disabled();
    only_the_current_token_is_owned();
    invalid_requesters_cannot_probe_or_toggle();
}

absent_and_undefined_tokens_are_disabled()
{
    state = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\server\auto_revive::enabled(state),
        "An absent auto-revive token means the setting is disabled");

    state.apparition_auto_revive = undefined;
    tests\support\checks::expect(!scripts\apparition\features\server\auto_revive::enabled(state),
        "An undefined auto-revive token remains disabled");
}

only_the_current_token_is_owned()
{
    state = spawnstruct();
    first = spawnstruct();
    replacement = spawnstruct();
    state.apparition_auto_revive = first;

    tests\support\checks::expect(scripts\apparition\features\server\auto_revive::enabled(state)
        && scripts\apparition\features\server\auto_revive::owns(state, first),
        "The current token is the sole enabled worker identity");
    tests\support\checks::expect(!scripts\apparition\features\server\auto_revive::owns(state, replacement),
        "A different token cannot own the current worker session");

    state.apparition_auto_revive = replacement;
    tests\support\checks::expect(scripts\apparition\features\server\auto_revive::enabled(state)
        && !scripts\apparition\features\server\auto_revive::owns(state, first)
        && scripts\apparition\features\server\auto_revive::owns(state, replacement),
        "Replacing the token makes the previous worker stale");

    state.apparition_auto_revive = undefined;
    tests\support\checks::expect(!scripts\apparition\features\server\auto_revive::enabled(state)
        && !scripts\apparition\features\server\auto_revive::owns(state, replacement),
        "Clearing the current token disables the setting and retires ownership");
}

invalid_requesters_cannot_probe_or_toggle()
{
    probe = scripts\apparition\features\server\auto_revive::probe(undefined);
    tests\support\checks::expect(probe.reason != "",
        "A missing requester is rejected before the world setting is exposed");
    tests\support\checks::expect(!probe.enabled && probe.native_reason == "",
        "A missing requester receives no global setting or native readiness details");
    tests\support\checks::expect(!scripts\apparition\features\server\auto_revive::toggle(undefined),
        "A missing requester cannot start or stop the world worker");

    requester = spawnstruct();
    probe = scripts\apparition\features\server\auto_revive::probe(requester);
    tests\support\checks::expect(probe.reason != "",
        "A nonplayer requester is rejected by shared server admission");
    tests\support\checks::expect(!probe.enabled && probe.native_reason == "",
        "A nonplayer requester receives no global setting or native readiness details");
    tests\support\checks::expect(!scripts\apparition\features\server\auto_revive::toggle(requester),
        "A nonplayer requester cannot change the world worker token");
}
