// Modify Score applies one bounded delta to the native CP currency balance

selections()
{
    return ["1000000", "100000", "10000", "1000", "100", "10", "0",
        "-10", "-100", "-1000", "-10000", "-100000", "-1000000"];
}

valid_selection(selection)
{
    if (!isDefined(selection) || !isstring(selection))
        return false;

    foreach (supported in selections())
    {
        if (selection == supported)
            return true;
    }

    return false;
}

balance_reason(balance, cap)
{
    if (!isDefined(balance) || !isnumber(balance)
        || !isDefined(cap) || !isnumber(cap))
        return "Wait for native currency data";

    // Range checks reject non-finite values before integer conversion
    if (!(balance >= 0 && balance <= cap && cap > 0 && cap <= 2147483647))
        return "Wait for native currency data";

    if (int(balance) != balance || int(cap) != cap)
        return "Wait for native currency data";

    return "";
}

next_balance(balance, cap, selection)
{
    // The caller validates the menu choice and native values before arithmetic
    // Normalize whole-valued native floats so large balances keep exact integer deltas
    balance = int(balance);
    cap = int(cap);

    if (selection == "0")
        return 0;

    delta = int(selection);
    if (delta > 0)
    {
        room = cap - balance;
        if (delta >= room)
            return cap;

        // Addition is safe because the remaining room exceeds the delta
        return balance + delta;
    }

    magnitude = delta * -1;
    if (magnitude >= balance)
        return 0;

    // Subtraction is safe because the balance exceeds the magnitude
    return balance - magnitude;
}

probe(player)
{
    result = spawnstruct();
    result.reason = "";

    if (!isDefined(player))
    {
        result.reason = "No current players are available";
        return result;
    }

    // Actor and session admission precede both native currency reads
    reason = scripts\apparition\runtime\context::actor_reason([player]);
    if (reason != "")
    {
        result.reason = reason;
        return result;
    }
    if (!scripts\apparition\runtime\context::supported())
    {
        result.reason = "Wait for native currency data";
        return result;
    }

    balance = player scripts\cp\cp_persistence::get_player_currency();
    cap = player scripts\cp\cp_persistence::get_player_max_currency();
    reason = balance_reason(balance, cap);
    if (reason != "")
    {
        result.reason = reason;
        return result;
    }

    // Only a validated live read is exposed to the menu
    result.balance = balance;
    result.cap = cap;
    return result;
}

modify(player, selection)
{
    // Reject an unsupported choice before probing or reaching the native setter
    if (!valid_selection(selection))
        return false;

    result = probe(player);
    if (result.reason != "")
        return false;

    target_balance = next_balance(result.balance, result.cap, selection);
    if (target_balance == result.balance)
        return true;

    // Native persistence owns the currency field and its EoG balance stat
    player scripts\cp\cp_persistence::set_player_currency(target_balance);
    return true;
}
