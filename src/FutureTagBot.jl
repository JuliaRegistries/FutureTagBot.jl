module FutureTagBot

import GitHub
import TOML

include("types.jl")

include("main.jl")

include("delay.jl")
include("map.jl")
include("pkgdir.jl")
include("plan.jl")
include("versions.jl")

include("git/clone.jl")
include("git/commit_to_tree.jl")
include("git/tags.jl")

include("github/releases.jl")

end # module
