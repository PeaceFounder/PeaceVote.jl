module PeaceVote

using Base: UUID

const CONFIG_DIR = homedir() * "/.peacevote/"

function setconfigdir(dir::String)
    global CONFIG_DIR = dir
end

demefile(uuid::UUID) = CONFIG_DIR * "/demes/$uuid"
keydir(uuid::UUID) = CONFIG_DIR * "/keys/$uuid/"
datadir(uuid::UUID) = CONFIG_DIR * "/data/$uuid/"

abstract type AbstractSigner end
abstract type AbstractEnvelope end
abstract type AbstractID end
abstract type AbstractOption end
abstract type AbstractProposal end
abstract type AbstractRecord end


include("braidchain.jl")
include("envelopes.jl")
include("deme.jl")
include("keys.jl")


export DemeSpec, Deme, Ledger
export sync!, register, braid!, vote, propose, braidchain, count

export Signer, KeyChain

end # module
