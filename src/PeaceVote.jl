module PeaceVote

include("Plugins/Plugins.jl")
include("BraidChains/BraidChains.jl")
include("KeyChains/KeyChains.jl")

import .KeyChains: KeyChain
import .Plugins: sync!, load, count
import .KeyChains: braid!

export ID, DemeID, DemeSpec, Deme, KeyChain, sync!, load, count, braid!

end # module
