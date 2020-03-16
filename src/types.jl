abstract type AbstractSigner end
abstract type AbstractID end
abstract type AbstractVote end
abstract type AbstractProposal end
abstract type AbstractBraid end
abstract type AbstractRecord end
abstract type AbstractPort end
abstract type AbstractLedger end


struct DemeSpec
    uuid::UUID
    name::AbstractString
    maintainer # ::BigInt
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
    id
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
    signatures
end

### This is the type which requires a dynamic dyspatch
struct Envelope{T}
    uuid::UUID
    contract::Contract{T}
end


struct LocRef
    id::BigInt
end

struct ExtRef
    uuid::UUID
    id::BigInt
end

struct Voucher{T}
    document::T
    references::Union{LocRef,ExtRef,Vector{LocRef}}
end

### 
const ID = Voucher{T} where T <: AbstractID 
const Braid = Voucher{T} where T <: AbstractBraid
const Proposal = Voucher{T} where T <: AbstractProposal
const Vote = Voucher{T} where T <: AbstractVote


