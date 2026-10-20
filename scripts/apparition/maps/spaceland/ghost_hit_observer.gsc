// One observation loop serves the two direct Ghosts damage inputs

wait_for_result(job, poll, deadline)
{
    for (;;)
    {
        // Each feature keeps its own native progress and ownership policy
        result = [[poll]](job, getTime() >= deadline);
        if (result != "")
            return result;
        // Yield before checking the native quest again
        wait 0.05;
    }
}

running(job)
{
    return isDefined(job) && job.state == "Observing";
}

status(job)
{
    return isDefined(job) ? job.state : "Idle";
}
