// Install this opt-in entry point only for an isolated Spaceland test session

init()
{
    if (!getDvarInt("apparition_run_tests") && !getDvarInt("apparition_test_probe"))
        return;
    if (getDvar("mapname") != "cp_zmb")
    {
        printLn("Apparition tests refused: Spaceland is required for native imports");
        return;
    }
    if (getDvarInt("apparition_test_probe"))
    {
        tests\support\checks::reset();
        tests\support\checks::expect(false, "Intentional failure probe");
        if (level.apparition_test_failures == 1 && level.apparition_test_checks == 1)
            printLn("Apparition probe observed the expected failure");
        else
            printLn("Apparition probe FAILED: the failure check was not evaluated");
        return;
    }
    tests\runner::run();
}
