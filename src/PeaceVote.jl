module PeaceVote

### This is where one would use 
include("DemeNet/DemeNet.jl")

include("Plugins/Plugins.jl")
include("BraidChains/BraidChains.jl")
include("KeyChains/KeyChains.jl")

import .KeyChains: KeyChain
import .Plugins: sync!, load, count
import .KeyChains: register, braid!, vote, propose

export ID, DemeID, DemeSpec, Deme, KeyChain, sync!, load, count, register, braid!, vote, propose

end # module
