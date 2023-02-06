# git --no-pager show 29aa1b4bd266e60e45cc79b1e5ff06e475a40cd6 --pretty=format:'%T'

function _commit_to_tree(ctx::Context, commit::String)
    cloned_package = ctx.cloned_package
    return cd(cloned_package.path) do
        cmd = `git --no-pager show $(commit) --pretty=format:'%T'`
        output = strip(read(cmd, String))
        lines = split(output, '\n')
        return strip(lines[1])
    end
end

function candidate_satisfies_target(ctx::Context, candidate::Candidate, target::Target)
    check_versions(candidate, target)
    candidate_tree = _commit_to_tree(ctx, candidate.commit)
    if candidate_tree == target.tree
        msg = "Candidate DOES satisfy the target"
        @info msg candidate.commit candidate_tree target.tree
        return true
    end
    msg = "Candidate does NOT satisfy the target"
    @warn msg candidate.commit candidate_tree target.tree
    return false
end
