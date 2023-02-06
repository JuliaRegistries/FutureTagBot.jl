function clone_general_registry()
    general = Registry(;
        name = "General",
        uuid = Base.UUID("23338594-aafe-5451-b93e-139f81909106"),
        url = "https://github.com/JuliaRegistries/General.git",
    )
    cloned_general = FutureTagBot.cloned(general)
    return cloned_general
end

function read_already_cloned_package(
    path::AbstractString;
    gh_repo_slug = ENV["GITHUB_REPOSITORY"],
)
    project_filename = abspath(joinpath(path, "Project.toml"))
    project = TOML.parsefile(project_filename)
    name = strip(project["name"])
    uuid_str = strip(project["uuid"])
    uuid = Base.UUID(uuid_str)
    package = FutureTagBot.Package(; name, uuid, url = "", gh_repo_slug)
    cloned_package = ClonedPackage(; package, path)
    return cloned_package
end

function main(;
    path::AbstractString,
    ignore_versions::AbstractVector{VersionNumber} = VersionNumber[],
)
    cloned_registry = clone_general_registry()
    cloned_package = read_already_cloned_package(path)
    ctx = Context(; registry = cloned_registry, package = cloned_package)
    return main_all_versions(ctx, ignore_versions)
end

function main_all_versions(ctx::Context, ignore_versions::AbstractVector{VersionNumber})
    vers = get_all_versions(ctx)
    map_collect_errors(vers) do version
        if version in ignore_versions
            @info "Skipping tag $(version) because it is in the ignorelist"
        else
            if tag_already_exists(ctx::Context, version::VersionNumber)
                @info "Skipping tag $(version) because a tag with that name already exists"
            else
                @info "Attempting to create and push an annotated Git tag for version $(version)"
                tag_single_version(ctx, version)
            end
            if github_release_already_exists(ctx, version)
                @info "Skipping release $(version) because a release already exists for the tag"
            else
                @info "Attempting to create a GitHub Release for version $(version)"
                github_release_single_version(ctx, version)
            end
        end
    end
    return nothing
end

function tag_single_version(ctx::Context, version::VersionNumber)
    plan = generate_plan(ctx, version)
    create_tag(ctx, plan)
    push_tag(ctx, plan)
    return nothing
end

function github_release_single_version(ctx::Context, version::VersionNumber)
    tag_name = _tag_name(version)
    commit_for_existing_tag = get_commit_for_existing_tag(ctx, version)
    @info "" tag_name version commit_for_existing_tag

    gh_repo_slug = ctx.cloned_package.package.gh_repo_slug
    # gh_repo = GitHub.repo(gh_repo_slug; auth = ctx.gh_auth)

    # params = Dict()
    # params["tag_name"] = tag_name
    # params["target_commitish"] = get_commit_for_existing_tag(ctx, version)
    # params["name"] = tag_name
    # params["generate_release_notes"] = true

    # GitHub.create_release(gh_repo; params, auth = ctx.gh_auth)

    cmd = `curl -vvvv --fail-with-body -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $(ENV["GITHUB_TOKEN"])" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$(gh_repo_slug)/releases -d '{"tag_name":"$(tag_name)","target_commitish":"237d0510bed0a276c1a348bc1f65b5d27f47757d","name":"$(tag_name)","generate_release_notes":true}'`
    run(cmd)

    return nothing
end
