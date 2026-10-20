// Pickup discovery accepts one exact native model and excludes decorative or ambiguous matches

run()
{
    one_exact_asset_and_origin_is_required();
    duplicate_and_incomplete_candidates_are_rejected();
    multiple_native_sites_still_require_one_unambiguous_model();
}

one_exact_asset_and_origin_is_required()
{
    pickup = tests\fixtures\models::model("pickup_asset", (10, 20, 30));
    decorative = tests\fixtures\models::model("pickup_asset", (11, 20, 30));
    unrelated = tests\fixtures\models::model("other_asset", pickup.origin);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pickup_models::select([decorative, unrelated, pickup], "pickup_asset", [pickup.origin]) == pickup, "Only the requested asset at its exact source position owns the pickup action");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\pickup_models::select([decorative, unrelated], "pickup_asset", [pickup.origin])), "A nearby decorative model or another asset is not a pickup target");
}

duplicate_and_incomplete_candidates_are_rejected()
{
    pickup = tests\fixtures\models::model("pickup_asset", (10, 20, 30));
    twin = tests\fixtures\models::model("pickup_asset", pickup.origin);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\pickup_models::select([pickup, twin], "pickup_asset", [pickup.origin])), "Two exact matches are ambiguous and receive no event");
    incomplete = tests\fixtures\models::model("pickup_asset", pickup.origin);
    incomplete.origin = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pickup_models::select([undefined, spawnstruct(), incomplete, pickup], "pickup_asset", [pickup.origin]) == pickup, "Missing entities and model fields are skipped before native reads");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\pickup_models::select([], "pickup_asset", [pickup.origin])), "An empty world scan has no pickup target");
}

multiple_native_sites_still_require_one_unambiguous_model()
{
    first = tests\fixtures\models::model("pickup_asset", (10, 20, 30));
    second = tests\fixtures\models::model("pickup_asset", (40, 50, 60));
    sites = [first.origin, second.origin];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pickup_models::select([second], "pickup_asset", sites) == second, "One matching native model may occupy any registered site");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\pickup_models::select([first, second], "pickup_asset", sites)), "Matches across two native sites are ambiguous");
    twin = tests\fixtures\models::model("pickup_asset", first.origin);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\pickup_models::select([first, twin, second], "pickup_asset", sites)), "Duplicate models at one site cannot be hidden by a unique match at another");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pickup_models::select([first], "pickup_asset", [first.origin, first.origin]) == first, "Repeated source positions do not count the same model twice");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\pickup_models::select([first], "pickup_asset", [])), "An empty native site list selects no model");
}
