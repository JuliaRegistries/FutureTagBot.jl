_tag_name(version::VersionNumber) = "v$(version)"
_tag_name(plan::Plan) = _tag_name(plan.version)

function tag_already_exists(ctx::Context, version::VersionNumber)
    cloned_package = ctx.cloned_package
    tag_name = _tag_name(version)
    str = cd(cloned_package.path) do
        cmd = `git rev-list -1 $(tag_name)`
        strip(read(cmd, String))
    end
    return !isempty(str)
end

function get_commit_for_existing_tag(ctx::Context, version::VersionNumber)
    cloned_package = ctx.cloned_package
    tag_name = _tag_name(version)
    commit = cd(cloned_package.path) do
        cmd = `git rev-parse $(tag_name)`
        strip(read(cmd, String))
    end
    return commit
end

function create_tag(ctx::Context, plan::Plan)
    cloned_package = ctx.cloned_package
    tag_name = _tag_name(plan)
    verify_plan(ctx, plan)
    cd(cloned_package.path) do
        cmd = `git tag -a $(tag_name) $(plan.commit) -m "$(tag_name)"`
        @info "Creating tag $(tag_name)"
        run(cmd)
    end
    return nothing
end

function push_tag(ctx::Context, plan::Plan)
    cloned_package = ctx.cloned_package
    tag_name = _tag_name(plan)
    cd(cloned_package.path) do
        cmd = `git push origin $(tag_name)`
        @info "Pushing tag $(tag_name)"
        run(cmd)
    end
    return nothing
end
