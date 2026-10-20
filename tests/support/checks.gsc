// Explicit checks remain executable when a compiler strips builtin assertions

reset()
{
    level.apparition_test_checks = 0;
    level.apparition_test_failures = 0;
}

expect(condition, message)
{
    level.apparition_test_checks++;
    if (condition)
        return;
    level.apparition_test_failures++;
    printLn("Apparition test FAIL: " + message);
}

summary()
{
    if (level.apparition_test_failures > 0)
    {
        printLn("Apparition tests FAILED: " + level.apparition_test_failures + " / " + level.apparition_test_checks + " checks");
        return false;
    }
    printLn("Apparition tests PASSED: " + level.apparition_test_checks + " checks");
    return true;
}
