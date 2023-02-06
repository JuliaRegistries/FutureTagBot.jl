### Setup

# General registry
general = Registry(;
    name = "General",
    uuid = Base.UUID("23338594-aafe-5451-b93e-139f81909106"),
    url = "https://github.com/JuliaRegistries/General.git",
)
@test general isa Registry
cloned_general = FutureTagBot.cloned(general)
@test cloned_general isa FutureTagBot.AbstractCloned
@test cloned_general isa ClonedRegistry

# Example.jl
example = FutureTagBot.Package(;
    name = "Example",
    uuid = Base.UUID("7876af07-990d-54b4-ab0e-23690620f79a"),
    url = "https://github.com/JuliaLang/Example.jl.git",
)
@test example isa Package
cloned_example = FutureTagBot.cloned(example)
@test cloned_example isa FutureTagBot.AbstractCloned
@test cloned_example isa ClonedPackage

ctx = Context(; registry = cloned_general, package = cloned_example)
@test ctx isa Context
