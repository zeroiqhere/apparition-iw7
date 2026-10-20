// One player-lifetime observer records the bound GoStand command state

input_ready(player)
{
    if (!isDefined(player))
        return false;
    if (!isDefined(player.apparition_jump_input) || !isstruct(player.apparition_jump_input))
        return false;

    receipt = player.apparition_jump_input;
    return isDefined(receipt.held) && isDefined(receipt.bound) && receipt.bound;
}

observe_input()
{
    if (scripts\apparition\runtime\context::actor_reason([self]) != ""
        || !scripts\apparition\runtime\context::supported())
        return;
    if (isDefined(self.apparition_jump_input))
        return;

    self endon("disconnect");
    level endon("game_ended");
    receipt = spawnstruct();
    receipt.held = false;
    receipt.bound = false;
    receipt.captures_ready = 0;
    self.apparition_jump_input = receipt;

    // Both receivers enter their event waits before commands can notify them
    self childthread capture_input(receipt, "apparition_multi_jump_pressed", true);
    self childthread capture_input(receipt, "apparition_multi_jump_released", false);
    while (receipt.captures_ready < 2)
        wait 0.01;
    receipt.captures_ready = undefined;

    // Engine command mapping follows the selected player's configured binding
    self notifyonplayercommand("apparition_multi_jump_pressed", "+gostand");
    self notifyonplayercommand("apparition_multi_jump_released", "-gostand");
    receipt.bound = true;

    // Keep this observer available across feature toggles for the player lifetime
    level waittill("game_ended");
}

capture_input(receipt, event, held)
{
    // Child captures end with their observer on disconnect or game shutdown
    receipt.captures_ready++;
    for (;;)
    {
        self waittill(event);
        receipt.held = held;
    }
}
