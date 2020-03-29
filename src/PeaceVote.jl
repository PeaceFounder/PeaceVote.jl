module PeaceVote

using Pkg.Types: Context
using Base: UUID

const CONFIG_DIR = homedir() * "/.peacevote/"

function setconfigdir(dir::String)
    global CONFIG_DIR = dir
end

demefile(uuid::UUID) = CONFIG_DIR * "/demes/$uuid"
keydir(uuid::UUID) = CONFIG_DIR * "/keys/$uuid/"
datadir(uuid::UUID) = CONFIG_DIR * "/data/$uuid/"

include("utils.jl")
include("types.jl")
include("userapi.jl")
include("braidchain.jl")
include("keys.jl")
include("deme.jl")
include("profile.jl")


# Keys would contain
export Signer, KeyChain
# Demes would contain
export DemeSpec, Notary, Cypher, CypherSuite, Deme, Ledger, ID, DemeID
# Profiles would contain
export Profile

# BraidChains would then contain
export sync!, register, braid!, vote, propose, braidchain, count
export Envelope, Certificate, Contract, Consensus, Intent
export proposals

export save, load

end # module
