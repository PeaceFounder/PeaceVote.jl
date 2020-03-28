abstract type AbstractSigner end
abstract type AbstractID end
abstract type AbstractVote end
abstract type AbstractProposal end
abstract type AbstractBraid end
abstract type AbstractRecord end
abstract type AbstractPort end
abstract type AbstractLedger end

struct ID <: AbstractID
    id::Union{BigInt,Nothing}
end

function Base.string(id::ID; length=nothing, kwargs...) 
    str = string(id.id; kwargs...)
    if length!=nothing
        len = Base.length(str)
        @assert len<=length
        pre = "0"^(length-len)        
    else
        pre = ""
    end
    return "$pre$str"
end

ID(str::AbstractString; kwargs...) = ID(parse(BigInt,str; kwargs...))

import Base.Vector

Vector{UInt8}(id::ID; kwargs...) = Vector{UInt8}(string(id; kwargs...))

ID(bytes::Vector{UInt8}; kwargs...) = ID(String(copy(bytes)); kwargs...)


Base.:(==)(a::ID,b::ID) = a.id==b.id
Base.hash(a::ID,h::UInt) = hash(a.id,hash(:ID,h))
Base.in(a::ID,b::ID) = a==b

#Base.iterate(id::ID) = (id, nothing)

struct DemeID <: AbstractID
    uuid::UUID
    id::ID
end

DemeID(uuid::UUID,id::BigInt) = DemeID(uuid,ID(id))

Base.:(==)(a::DemeID,b::DemeID) = a.uuid==b.uuid && a.id==b.id
Base.hash(a::DemeID,h::UInt) = hash(a.id,hash(a.uuid,hash(:DemeID, h)))

# Do I need a base hash also here? 

Base.in(a::DemeID,b::DemeID) = a==b


#Base.iterate(id::DemeID) = (id, nothing)

struct DemeSpec
    uuid::UUID
    name::AbstractString
    maintainer::ID  # ::BigInt
    crypto::Symbol
    cryptodep::UUID
    #crypto::Union{Symbol,Expr} 
    #deps::Union{UUID,Vector{UUID}} # libraries to initialize Signatures type. In case when crypto is a symbol the libraries are imported into the working namespace (Notary and Cypher).
    cypherconfig::Symbol
    cypherdep::UUID
    peacefounder::UUID # Everything else appart from signature stuff
end

struct CypherSuite{T} end

CypherSuite(uuid::UUID) = CypherSuite{uuid.value}
CypherSuite(m::Module) = CypherSuite(uuid(m))

struct Notary
    Signer::Function # allows to create signatures when necessery. id is obtained with verify on random data.
    Signature::Function 
    verify::Function # verify returns id of the signature.
    hash::Function
end

Notary(cyphersuite::UUID,crypto::Symbol) = Notary(CypherSuite(cyphersuite),crypto)::Notary
Notary(metadata::DemeSpec) = Notary(metadata.cryptodep,metadata.crypto)

struct Cypher
    G # a group for DiffieHellman key exchange
    rng::Function
    secureio::Function 
end

Cypher(cyphersuite::UUID,crypto::Symbol) = Cypher(CypherSuite(cyphersuite),crypto)::Cypher
Cypher(metadata::DemeSpec) = Cypher(metadata.cypherdep,metadata.cypherconfig)


struct Deme{T}
    spec::DemeSpec
    notary::Notary
    cypher::Cypher
    ledger ### This one is used by peacefounder to construct configuration
end

### Could have multiple signatures as one wishes
struct Signer <: AbstractSigner
    uuid::UUID
    id::ID
    sign::Function
end

struct KeyChain <: AbstractSigner
    deme::Deme ### This is necessary to make braid! function obvious  
    account
    member::Signer
    signers::Vector{Signer}
end


struct Contract{T}
    document::T
    signatures::Vector{Dict{String,Any}}
end

### In ususal computer science 
### certified authorithy is called also a certificate.
### However the therm voucher, verifier, issuer (tust anchor) would be more appropriate in such setting. 
### On the other hand one might look on it as a certificate from the chain of trust. 
### Anyway there should be a difference in the terminolgy.
struct Certificate{T}
    document::T
    signature::Dict
end


### This is the type which requires a dynamic dyspatch
struct Envelope{T}
    uuid::UUID
    contract::Certificate{T} # Perhaps Union{Contract{T},Certificate{T}}
end


struct Intent{T}
    document::T
    reference::Union{ID,DemeID}
end

### This one is associated to the contract
# Gives permission to do something, like add a new key to the braidchain synchronically. 
# Common consent
struct Consensus{T}
    document::T
    references::Vector{ID}
end

### 
#const ID = Intent{T} where T <: AbstractID 
const Braid = Consensus{T} where T <: AbstractBraid
const Proposal = Intent{T} where T <: AbstractProposal
const Vote = Intent{T} where T <: AbstractVote


