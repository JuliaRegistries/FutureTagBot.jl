function _versions_toml_filename(ctx::Context)
    package_dir = _package_dir(ctx)
    versions_toml_filename = joinpath(package_dir, "Versions.toml")
    return versions_toml_filename
end

function parse_versions(ctx::Context)
    versions_toml_filename = _versions_toml_filename(ctx)
    versions_parsed_str = TOML.parsefile(versions_toml_filename)
    versions_parsed_vn = Dict{VersionNumber,valtype(versions_parsed_str)}()
    for (k, v) in versions_parsed_str
        versions_parsed_vn[VersionNumber(k)] = v
    end
    return versions_parsed_vn
end

function get_all_versions(ctx::Context)
    parsed_versions = parse_versions(ctx)
    vers = collect(keys(parsed_versions))
    sort!(vers)
    return vers
end

function version_to_target(ctx::Context, version::VersionNumber)
    tree = _version_to_tree(ctx, version)
    return Target(; version, tree)
end

function _version_to_tree(ctx::Context, version::VersionNumber)
    parsed_versions = parse_versions(ctx)
    ver_info = parsed_versions[version]
    tree = strip(ver_info["git-tree-sha1"])
    return tree
end

function version_to_candidate(ctx::Context, version::VersionNumber)
    commit = _version_to_commit(ctx, version)
    return Candidate(; version, commit)
end

function _versions_toml_line_number(ctx::Context, version::VersionNumber)
    versions_toml_filename = _versions_toml_filename(ctx)
    versions_toml_contents = read(versions_toml_filename, String)
    lines = split(versions_toml_contents, '\n')
    line_number = string(only(findall(lines .== "[\"$(string(version))\"]")))
    return line_number
end

function _version_to_commit(ctx::Context, version::VersionNumber)
    package_dir = _package_dir(ctx)
    return cd(package_dir) do
        @info "Running git-blame"
        line_number = _versions_toml_line_number(ctx, version)
        blame_output = strip(read(`git --no-pager blame Versions.toml -L$(line_number),$(line_number)`, String))
        r_blame = r"^(\w*?) "
        loc_blame = only(findall(r_blame, blame_output))
        m_blame = match(r_blame, blame_output)
        registry_commit = strip(m_blame[1])
        @info "Running git-show"
        show_output = strip(read(`git --no-pager show $(registry_commit)`, String))
        r_show = r"New \w*?: \w*:? [\w\.]*? \(#(\d*?)\)"
        loc_show = only(findall(r_show, show_output))
        m_show = match(r_show, show_output)

        general_pr_number = strip(m_show[1])

        gh_repo = with_delay() do
            repo_name = "JuliaRegistries/General"
            @info "Getting repo $(repo_name) from GitHub"
            GitHub.repo(repo_name; auth = ctx.gh_auth)
        end
        gh_pull = with_delay() do
            @info "Getting PR #$(general_pr_number) from GitHub"
            GitHub.pull_request(gh_repo, general_pr_number; auth = ctx.gh_auth)
        end
        prbody = strip(gh_pull.body) * '\n'
        r_prbody = r"- Commit: (\w*?)\s"
        loc_prbody = only(findall(r_prbody, prbody))
        m_prbody = match(r_prbody, prbody)
        commit = strip(m_prbody[1])
    end
end
