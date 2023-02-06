### `AbstractVersioned`s

abstract type AbstractVersioned end

struct VersionMismatch <: Exception
    msg::String
end

function check_versions(A::AbstractVersioned, B::AbstractVersioned)
    verA = A.version::VersionNumber
    verB = B.version::VersionNumber
    if verA != verB
        msg = "Version $(verA) is not equal to version $(verB)"
        throw(VersionMismatch(msg))
    end
    return nothing
end

Base.@kwdef struct Target <: AbstractVersioned
    version::VersionNumber
    tree::String
end

Base.@kwdef struct Candidate <: AbstractVersioned
    version::VersionNumber
    commit::String
end

Base.@kwdef struct Plan <: AbstractVersioned
    version::VersionNumber
    commit::String
    tree::String
end

### Registries and packages

abstract type AbstractCloned end

Base.@kwdef struct Registry
    name::String
    uuid::Base.UUID
    url::String
end

Base.@kwdef struct ClonedRegistry <: AbstractCloned
    registry::Registry
    path::String
end

Base.@kwdef struct Package
    name::String
    uuid::Base.UUID
    url::String
    gh_repo_slug::String
end

Base.@kwdef struct ClonedPackage <: AbstractCloned
    package::Package
    path::String
end

const Registrylike = Union{Registry,ClonedRegistry}
const Packagelike = Union{Package,ClonedPackage}

### `Context`

struct NoAuth end

struct Context
    gh_auth::Union{GitHub.Authorization,NoAuth}
    cloned_registry::ClonedRegistry
    cloned_package::ClonedPackage
end

function _get_github_auth_auto()
    github_token = strip(get(ENV, "GITHUB_TOKEN", ""))
    if isempty(github_token)
        @warn "GITHUB_TOKEN was not provided. Features requiring GitHub authentication will not be available."
        return NoAuth()
    end
    return with_delay() do
        @info "Authenticating to GitHub"
        GitHub.authenticate(github_token)
    end
end

function Context(;
    gh_auth::Union{GitHub.Authorization,NoAuth,Nothing} = nothing,
    registry::Registrylike,
    package::Packagelike,
)
    if gh_auth === nothing
        true_gh_auth = _get_github_auth_auto()
    else
        true_gh_auth = gh_auth
    end
    cloned_registry = cloned(registry)
    cloned_package = cloned(package)
    ctx = Context(true_gh_auth, cloned_registry, cloned_package)
    return ctx
end
