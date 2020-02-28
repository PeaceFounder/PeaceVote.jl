module SandBox 

import Nettle
import CryptoGroups
import CryptoSignatures


# Let's just use val
#struct Notary{T} end

### This is the place where 
const genpar = Dict{DataType,Expr}() ### Perhaps I need to make a dictionary of type

@generated function compile(notary)
    return genpar[notary]
end

end

crypto = quote
G = CryptoGroups.Scep256k1Group()
hash(x::AbstractString) = parse(BigInt,Nettle.hexdigest("sha256",x),base=16)

Signer() = CryptoSignatures.Signer(G)
Signature(x::AbstractString,signer) = CryptoSignatures.DSASignature(hash(x),signer)
verify(data,signature) = CryptoSignatures.verify(signature,G) && hash(data)==signature.hash ? hash("$(signature.pubkey)") : nothing

(Signer,Signature,verify,hash)
end

