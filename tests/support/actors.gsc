// Shared opt-in fixtures read native actors without changing the live roster

first_player()
{
    deadline = getTime() + 10000;
    while (getTime() < deadline)
    {
        if (isDefined(level.players) && isarray(level.players))
        {
            foreach (player in level.players)
            {
                if (isDefined(player) && isPlayer(player))
                    return player;
            }
        }
        wait 0.05;
    }
    return undefined;
}
