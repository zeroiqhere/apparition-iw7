// Receipt checks use level events without dispatching any generator input

run()
{
    a_callback_acknowledgment_releases_the_waiting_worker();
    a_callback_that_returned_before_waiting_cannot_be_lost();
    an_unrelated_acknowledgment_cannot_complete_an_unreturned_callback();
}

a_callback_acknowledgment_releases_the_waiting_worker()
{
    receipt = new_receipt(false);
    level childthread await_receipt_for_test(receipt);

    // The helper enters the real waiter before the test sends its acknowledgment
    deadline = getTime() + 1000;
    while (!receipt.entered && getTime() < deadline)
        wait 0.01;
    tests\support\checks::expect(receipt.entered && !receipt.finished,
        "The serial worker waits until its callback returns");

    receipt.returned = true;
    level notify("apparition_power_returned");
    deadline = getTime() + 1000;
    while (!receipt.finished && getTime() < deadline)
        wait 0.01;
    tests\support\checks::expect(receipt.finished,
        "A level acknowledgment releases the returned callback receipt");
    level notify("test_stop_power_receipt_waiter");
}

a_callback_that_returned_before_waiting_cannot_be_lost()
{
    receipt = new_receipt(true);
    // An event delivered before a listener starts cannot be the completion source
    level notify("apparition_power_returned");
    level childthread await_receipt_for_test(receipt);

    deadline = getTime() + 1000;
    while (!receipt.finished && getTime() < deadline)
        wait 0.01;
    tests\support\checks::expect(receipt.finished,
        "A stored return releases the waiter even when its event has already passed");
    // A failing regression is bounded so later suites can still report results
    level notify("test_stop_power_receipt_waiter");
}

an_unrelated_acknowledgment_cannot_complete_an_unreturned_callback()
{
    receipt = new_receipt(false);
    level childthread await_receipt_for_test(receipt);
    deadline = getTime() + 1000;
    while (!receipt.entered && getTime() < deadline)
        wait 0.01;
    tests\support\checks::expect(receipt.entered,
        "The unreturned callback waiter starts before the unrelated event");

    level notify("apparition_power_returned");
    wait 0.05;
    tests\support\checks::expect(!receipt.finished,
        "Another level acknowledgment cannot replace this callback's return flag");

    // The actual receipt can still release the same waiter after a spurious wake
    receipt.returned = true;
    level notify("apparition_power_returned");
    deadline = getTime() + 1000;
    while (!receipt.finished && getTime() < deadline)
        wait 0.01;
    tests\support\checks::expect(receipt.finished,
        "The waiter remains usable after an unrelated acknowledgment");
    level notify("test_stop_power_receipt_waiter");
}

new_receipt(returned)
{
    receipt = spawnstruct();
    receipt.returned = returned;
    receipt.entered = false;
    receipt.finished = false;
    return receipt;
}

await_receipt_for_test(receipt)
{
    self endon("test_stop_power_receipt_waiter");
    receipt.entered = true;
    scripts\apparition\maps\spaceland\power_worker::await_return(receipt);
    receipt.finished = true;
}
