module PeaceVote

#import Base.save
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


struct DemeSpec
    uuid::UUID
    name::AbstractString
    maintainer # ::BigInt
    crypto::Expr
    deps::Vector{UUID} # libraries to initialize Signatures type. 
    peacefounder::UUID # Everything else appart from signature stuff
end

struct Notary
    Signer::Function # allows to create signatures when necessery. id is obtained with verify on random data.
    Signature::Function 
    verify::Function # verify returns id of the signature.
    hash::Function
end

struct Deme{T}
    spec::DemeSpec
    notary::Notary
    ledger ### This one is used by peacefounder to construct configuration
end

include("braidchain.jl")
include("envelopes.jl")
include("keys.jl")
include("deme.jl")


export DemeSpec, Notary,  Deme, Ledger, save
export sync!, register, braid!, vote, propose, braidchain, count
export Signer, KeyChain

end # module
