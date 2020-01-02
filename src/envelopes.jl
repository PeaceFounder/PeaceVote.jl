abstract type AbstractEnvelope end

import Base.String
function String(envelope::AbstractEnvelope)
    io = IOBuffer()
    serialize(io,envelope)
    String(take!(io))
end

"""
Verifies that the signature and calculates id of the public key.
"""
function unwrap(envelope::AbstractEnvelope)
    c = Community(envelope.uuid)
    if c.verify(envelope.data,envelope.signature)
        return envelope.data, c.id(envelope.signature)::Integer
    else
        return envelope.data, nothing
    end
end

struct Envelope <: AbstractEnvelope
    uuid::UUID
    data
    signature
end

Envelope(data,signer::AbstractSigner) = Envelope(signer.uuid,data,signer.sign(data))
Envelope(str::AbstractString) = deserilize(IOBuffer(str))

### The Certificates

abstract type AbstractID end

struct ID <: AbstractID
    name
    date # of birth
    id # The id of the public key. One uses the hash function from the Community.
end

# Certificate could also be made as Envelope{ID}. 
struct Certificate <: AbstractEnvelope
    uuid::UUID
    data::AbstractID
    signature#::AbstractSignature
end

Certificate(id::AbstractID,signer::AbstractSigner) = Certificate(signer.uuid,id,signer.sign(id))
Certificate(str::AbstractString) = deserilize(IOBuffer(str))

export Certificate, Envelope, unwrap
