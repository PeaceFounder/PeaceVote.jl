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
    crypto::Union{Symbol,Expr} 
    deps::Union{UUID,Vector{UUID}} # libraries to initialize Signatures type. In case when crypto is a symbol the libraries are imported into the working namespace (Notary and Cypher).
    peacefounder::UUID # Everything else appart from signature stuff
end

struct Notary
    Signer::Function # allows to create signatures when necessery. id is obtained with verify on random data.
    Signature::Function 
    verify::Function # verify returns id of the signature.
    hash::Function
end

struct Cypher
    G # a group for DiffieHellman key exchange
    rng::Function
    secureio::Function 
end

struct CypherSuite{T} end

uuid(ctx::Context,name::AbstractString) = ctx.env.project.deps[name]
uuid(ctx::Context,name::Symbol) = uuid(ctx,String(name))
uuid(ctx::Context,name::Module) = uuid(ctx,nameof(name))
uuid(name::Union{Module,Symbol,AbstractString}) = uuid(Context(),name)

CypherSuite(uuid::UUID) = CypherSuite{uuid.value}
CypherSuite(m::Module) = CypherSuite(uuid(m))

Notary(cyphersuite::UUID,crypto::Symbol) = Notary(CypherSuite(cyphersuite),crypto)::Notary
Notary(metadata::DemeSpec) = Notary(metadata.deps,metadata.crypto)

Cypher(cyphersuite::UUID,crypto::Symbol) = Cypher(CypherSuite(cyphersuite),crypto)::Cypher


struct Deme{T}
    spec::DemeSpec
    notary::Notary
    ledger ### This one is used by peacefounder to construct configuration
end

include("braidchain.jl")
include("envelopes.jl")
include("keys.jl")
include("deme.jl")
include("evalnotaries.jl")

export New, unbox, getindex
export DemeSpec, Notary, Cypher, CypherSuite, Deme, Ledger, save
export sync!, register, braid!, vote, propose, braidchain, count
export Signer, KeyChain

end # module
