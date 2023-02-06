function generate_plan(ctx::Context, version::VersionNumber)
    target = version_to_target(ctx, version)
    candidate = version_to_candidate(ctx, version)
    if !candidate_satisfies_target(ctx, candidate, target)
        msg = ""
        throw(ErrorException(msg))
    end
    plan = Plan(; version, candidate.commit, target.tree)
    return plan
end
