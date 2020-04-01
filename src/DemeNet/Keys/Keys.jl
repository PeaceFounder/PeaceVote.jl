module Keys
### This file contains all functions which are necessary for accessing .peacevote/keys folder. In future it would be great to have a password prtotection so one could do easier backups.

using Pkg.TOML
using Base: UUID
using ..Types: ID, DemeID, keydir
using ..Plugins: Notary

struct Signer
    uuid::UUID
    id::ID
    sign::Function
end

function _save(s,fname) 
    mkpath(dirname(fname))
    dict = Dict(s)
    open(fname, "w") do io
        TOML.print(io, dict)
    end
end

function Signer(uuid::UUID,notary::Notary,account::AbstractString)
    fname = keydir(uuid) * account 
    
    if !isfile(fname)
        @info "Creating a new signer for the community"
        s = notary.Signer()
        _save(s,fname)
    end

    dict = TOML.parsefile(fname)
    signer = notary.Signer(dict)
    sign(data) = notary.Signature(data,signer)

    test = "A test message."
    signature = sign(test)
    id = notary.verify(test,signature)

    @assert id!=nothing

    return Signer(uuid,id,sign)
end

#Signer(uuid::UUID,account::AbstractString) = Signer(uuid,Notary(DemeSpec(uuid)),account)

### Perhaps I actually do not need this method !!!
#Signer(deme::Deme,account::AbstractString) = Signer(deme.spec.uuid,deme.notary,account)


### In ususal computer science 
### certified authorithy is called also a certificate.
### However the therm voucher, verifier, issuer (tust anchor) would be more appropriate in such setting. 
### On the other hand one might look on it as a certificate from the chain of trust. 
### Anyway there should be a difference in the terminolgy.
struct Certificate{T}
    document::T
    signature::Dict
end


Certificate(x,signer::Signer) = Certificate(x,Dict(signer.sign("$x")))

### This is the type which requires a dynamic dyspatch
struct Envelope{T}
    uuid::UUID
    contract::Certificate{T} # Perhaps Union{Contract{T},Certificate{T}}
end

Envelope(data,signer::Signer) = Envelope(signer.uuid,Certificate(data,signer))

verify(cert::Certificate,notary::Notary) = notary.verify("$(cert.document)",notary.Signature(cert.signature)) 

function verify(envelope::Envelope)
    demespec = DemeSpec(envelope.uuid)
    notary = Notary(demespec)
    id = verify(envelope.contract,notary)
    return DemeID(envelope.uuid,id)
end

struct Intent{T}
    document::T
    reference::Union{ID,DemeID}
end

function Intent(envelope::Envelope) 
    demespec = DemeSpec(envelope.uuid)
    notary = Notary(demespec)

    contract = envelope.contract
    id = notary.verify("$(contract.document)",notary.Signature(contract.signature)) 

    ref = DemeID(envelope.uuid,id)
    return Intent(document,ref)
end

function Intent(contract::Certificate,notary::Notary)
    signature = notary.Signature(contract.signature)
    id = notary.verify("$(contract.document)",signature) 
    return Intent(contract.document,id)
end    

struct Contract{T}
    document::T
    signatures::Vector{Dict{String,Any}}
end

### This one is associated to the contract
# Gives permission to do something, like add a new key to the braidchain synchronically. 
# Common consent
struct Consensus{T}
    document::T
    references::Vector{ID} ### The contract is allowed to be made only between equals. That is necessary to resolve disputes as the Deme who made the contract shall be held responsable for it.
end

function Consensus(contract::Contract,notary::Notary) 
    doc = "$(contract.document)"
    refs = ID[]
    for s in contract.signatures
        signature = notary.Signature(s)
        id = notary.verify(doc,signature)
        push!(refs,id)
    end
    return Consensus(contract.document,refs)
end

end
