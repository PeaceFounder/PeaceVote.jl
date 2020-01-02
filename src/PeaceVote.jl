module PeaceVote

import Serialization: serialize, deserialize
import Pkg

const CONFIG_DIR = homedir() * "/.peacevote/"

function __init__()
    mkpath(CONFIG_DIR)
end

include("community.jl")
include("keys.jl")
include("envelopes.jl")
#include("participation.jl")
include("utils.jl")

export Community, Member, Maintainer, Voter

end # module
