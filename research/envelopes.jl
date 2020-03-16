# import Base.String
# function String(envelope::AbstractEnvelope)
#     io = IOBuffer()
#     serialize(io,envelope)
#     String(take!(io))
# end



### I could create a Voucher and then take out valuable info
# """
# Verifies that the signature and calculates id of the public key.
# """
# function unwrap(envelope::Envelope,notary::Notary)
#     id = notary.verify("$(envelope.data)",envelope.signature)
#     return envelope.data, (envelope.uuid,id)
# end


# struct Envelope <: AbstractEnvelope
#     uuid::UUID
#     data
#     signature
# end


#Envelope(str::AbstractString) = deserilize(IOBuffer(str))

### The Certificates


# struct ID <: AbstractID
#     name
#     date # of birth
#     id # The id of the public key. One uses the hash function from the Community.
# end

# Certificate could also be made as Envelope{ID}. 
# struct Certificate <: AbstractEnvelope
#     uuid::UUID ### Now it is the deme
#     data::AbstractID
#     signature#::AbstractSignature
# end


#Certificate(id::AbstractID,signer::AbstractSigner) = Certificate(signer.uuid,id,signer.sign("$id"))
#Certificate(str::AbstractString) = deserilize(IOBuffer(str)) # We could do a little better here


# function register(uuid::UUID,certificate::Certificate)
#     com = community(uuid)
#     com.register(certificate)
# end


#export Certificate, Envelope, unwrap
