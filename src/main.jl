function clone_general_registry()
    general = Registry(;
        name = "General",
        uuid = Base.UUID("23338594-aafe-5451-b93e-139f81909106"),
        url = "https://github.com/JuliaRegistries/General.git",
    )
    cloned_general = FutureTagBot.cloned(general)
    return cloned_general
end

function read_already_cloned_package(path::AbstractString; gh_repo_slug = ENV["GITHUB_REPOSITORY"])
    project_filename = abspath(joinpath(path, "Project.toml"))
    project = TOML.parsefile(project_filename)
    name = strip(project["name"])
    uuid_str = strip(project["uuid"])
    uuid = Base.UUID(uuid_str)
    package = FutureTagBot.Package(;
        name,
        uuid,
        url = "",
    )
    cloned_package = ClonedPackage(;
        package,
        path,
    )
    return cloned_package
end

function main(; path::AbstractString, ignore_versions::AbstractVector{VersionNumber} = VersionNumber[])
    cloned_registry = clone_general_registry()
    cloned_package = read_already_cloned_package(path)
    ctx = Context(;
        registry = cloned_registry,
        package = cloned_package,
    )
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
                main_single_version(ctx, version)
            end
            if github_release_already_exists(ctx::Context, plan::Plan)
                @info "Skipping release $(version) because a release already exists for the tag"
            else 
            end
        end
    end
    return nothing
end

function main_single_version(ctx::Context, version::VersionNumber)
    plan = generate_plan(ctx, version)
    create_tag(ctx, plan)
    push_tag(ctx, plan)
    return nothing
end
