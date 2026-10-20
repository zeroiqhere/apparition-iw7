// Rejected-target views keep the real reason without sampling native gameplay data

run()
{
    unavailable_targets_keep_their_reason_on_score_revive_and_down_rows();
}

unavailable_targets_keep_their_reason_on_score_revive_and_down_rows()
{
    foreach (reason in ["The player is no longer in the current roster", "Co-Host access is required to change another player",
        "Only the current host can open the host's player controls"])
    {
        view = spawnstruct();
        view.target = spawnstruct();
        snapshot = scripts\apparition\runtime\view::unavailable_target(reason);
        view.score = snapshot;
        view.revive = snapshot;
        view.down = snapshot;
        rows = [scripts\apparition\menu\model::score_row(view),
            scripts\apparition\menu\model::revive_row(view, false),
            scripts\apparition\menu\death_row::build(view, false)];
        foreach (row in rows)
            tests\support\checks::expect(!row.enabled && row.description == reason,
                "A blocked personal probe reports target admission instead of waiting for unrelated native data");
        tests\support\checks::expect(snapshot.targets.size == 0 && snapshot.reason == reason
            && !isDefined(snapshot.balance) && !isDefined(snapshot.cap),
            "An unavailable target snapshot cannot fabricate native balances or action targets");
    }
}
