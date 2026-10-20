// Newsbar contracts inspect text and ownership without creating HUD elements

run()
{
    source_messages_keep_order_and_clean_the_host_name();
    missing_or_empty_host_names_have_no_messages();
    only_the_current_record_owns_the_newsbar_worker();
    invalid_requesters_receive_no_configuration_or_messages();
}

source_messages_keep_order_and_clean_the_host_name()
{
    messages = scripts\apparition\features\server\newsbar::messages("^AHost^9Name");
    expected = [
        "Welcome To ^1Apparition ^7Developed By ^2CF4_99",
        "Your Host Today Is ^6HostName",
        "Once verified, use saved opening controls for ^1Apparition",
        "YouTube.Com/^3CF4_99",
        "Discord.gg/^6apparitionbo3",
        "^5Enjoy Your Stay!"
    ];

    tests\support\checks::expect(isDefined(messages) && isarray(messages)
        && messages.size == expected.size,
        "The Newsbar exposes six source-ordered messages for a readable host name");
    if (!isDefined(messages) || !isarray(messages) || messages.size != expected.size)
        return;
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(messages[index] == expected[index],
            "Newsbar copy and color tokens retain their source order");
    tests\support\checks::expect(!isSubStr(messages[2], "+speed_throw")
        && !isSubStr(messages[2], "+melee"),
        "The opening message does not advertise an unverified shared control chord");
}

missing_or_empty_host_names_have_no_messages()
{
    messages = scripts\apparition\features\server\newsbar::messages(undefined);
    tests\support\checks::expect(isDefined(messages) && isarray(messages) && messages.size == 0,
        "A missing host name does not produce a partial message sequence");
    messages = scripts\apparition\features\server\newsbar::messages(17);
    tests\support\checks::expect(isDefined(messages) && isarray(messages) && messages.size == 0,
        "A nonstring host name does not produce a partial message sequence");
    messages = scripts\apparition\features\server\newsbar::messages("");
    tests\support\checks::expect(isDefined(messages) && isarray(messages) && messages.size == 0,
        "An empty host name does not produce a partial message sequence");
    messages = scripts\apparition\features\server\newsbar::messages("^A^9j=");
    tests\support\checks::expect(isDefined(messages) && isarray(messages) && messages.size == 0,
        "A host name containing only cleaned formatting tokens does not produce messages");
}

only_the_current_record_owns_the_newsbar_worker()
{
    state = spawnstruct();
    current = spawnstruct();
    replacement = spawnstruct();

    tests\support\checks::expect(!scripts\apparition\features\server\newsbar::owns(undefined, current)
        && !scripts\apparition\features\server\newsbar::owns(state, undefined),
        "Missing state or record cannot claim Newsbar ownership");
    state.apparition_newsbar = current;
    tests\support\checks::expect(scripts\apparition\features\server\newsbar::owns(state, current)
        && !scripts\apparition\features\server\newsbar::owns(state, replacement),
        "Only the current token owns the Newsbar worker");

    state.apparition_newsbar = replacement;
    tests\support\checks::expect(!scripts\apparition\features\server\newsbar::owns(state, current)
        && scripts\apparition\features\server\newsbar::owns(state, replacement),
        "Replacing the Newsbar token retires the previous worker identity");
    state.apparition_newsbar = undefined;
    tests\support\checks::expect(!scripts\apparition\features\server\newsbar::owns(state, replacement),
        "Clearing the Newsbar token retires its current worker identity");
}

invalid_requesters_receive_no_configuration_or_messages()
{
    probe = scripts\apparition\features\server\newsbar::probe(undefined);
    tests\support\checks::expect(isDefined(probe.reason) && isstring(probe.reason)
        && probe.reason != "" && probe.configured == 0
        && isDefined(probe.messages) && isarray(probe.messages) && probe.messages.size == 0,
        "A missing requester receives a denied empty Newsbar snapshot");
    tests\support\checks::expect(!scripts\apparition\features\server\newsbar::toggle(undefined),
        "A missing requester cannot start or stop the Newsbar worker");

    requester = spawnstruct();
    probe = scripts\apparition\features\server\newsbar::probe(requester);
    tests\support\checks::expect(isDefined(probe.reason) && probe.reason != ""
        && probe.configured == 0 && probe.messages.size == 0,
        "A nonplayer requester receives no configured state or host messages");
    tests\support\checks::expect(!scripts\apparition\features\server\newsbar::toggle(requester),
        "A nonplayer requester cannot mutate Newsbar ownership");
}
