cloned(x::AbstractCloned) = x

function _clone(x::Union{Registry,Package})
    path = mktempdir(; cleanup = true)
    cmd = `git clone $(x.url) $(path)`
    run(cmd)
    return path
end

function cloned(registry::Registry)
    @info "Cloning the $(registry.name) registry"
    path = _clone(registry)
    return ClonedRegistry(; registry, path)
end

function cloned(package::Package)
    @info "Cloning the $(package.name) package"
    path = _clone(package)
    return ClonedPackage(; package, path)
end
