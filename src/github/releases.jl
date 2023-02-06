function github_release_already_exists(ctx::Context, version::VersionNumber)
    tag_name = _tag_name(version)
    gh_repo_slug = ctx.cloned_package.package.gh_repo_slug
    gh_response = GitHub.gh_get_json(GitHub.DEFAULT_API, "/repos/$(gh_repo_slug)/releases/tags/$(tag_name)"; auth = ctx.gh_auth, handle_error = false)
    return get(gh_response, "tag_name", nothing) == tag_name
end
