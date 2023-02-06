function github_release_exists(ctx::Context, plan::Plan)
    tag_name = _tag_name(plan)
    gh_repo_slug = ctx.cloned_package.package.gh_repo_slug
    gh_response = GitHub.gh_get_json(GitHub.DEFAULT_API, "/repos/$(gh_repo_slug)/releases/tags/$(tag_name)"; auth, handle_error = false)
    return get(gh_response, "tag_name", nothing) == tag_name
end
