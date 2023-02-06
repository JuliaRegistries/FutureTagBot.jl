module FutureTagBot

import GitHub
import TOML

include("types.jl")

include("delay.jl")
include("map.jl")
include("pkgdir.jl")
include("versions.jl")

include("git/clone.jl")
include("git/commit_to_tree.jl")

end # module
