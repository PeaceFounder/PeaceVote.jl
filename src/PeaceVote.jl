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
#include("evalnotaries.jl")

### Some methods necessary 

###

export DemeSpec, Notary, Cypher, CypherSuite, Deme, Ledger, save, ID, DemeID
export sync!, register, braid!, vote, propose, braidchain, count
export Signer, KeyChain, Envelope, Certificate, Contract, Consensus, Intent
export proposals
end # module
