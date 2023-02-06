function _package_dir(ctx::Context)
    cloned_registry = ctx.cloned_registry
    cloned_package = ctx.cloned_package
    registry_toml_filename = abspath(joinpath(cloned_registry.path, "Registry.toml"))
    registry_toml_parsed = TOML.parsefile(registry_toml_filename)
    packages = registry_toml_parsed["packages"]
    package_info = packages[string(cloned_package.package.uuid)]
    package_relpath = strip(package_info["path"])
    package_dir = abspath(joinpath(cloned_registry.path, package_relpath))
    return package_dir
end
