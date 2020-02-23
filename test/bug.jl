using PeaceVote

name = "PeaceDeme"

crypto = quote
G = CryptoGroups.Scep256k1Group()
hash(x::AbstractString) = parse(BigInt,Nettle.hexdigest("sha256",x),base=16)

Signer() = CryptoSignatures.Signer(G)
Signature(x::AbstractString,signer) = CryptoSignatures.DSASignature(hash(x),signer)
verify(data,signature) = CryptoSignatures.verify(signature,G) && hash(data)==signature.hash ? hash("$(signature.pubkey)") : nothing

(Signer,Signature,verify,hash)
end

deps = Symbol[:Nettle,:CryptoGroups,:CryptoSignatures]


### So this thing works:

notary = PeaceVote.Notary(crypto,deps)
demespec = PeaceVote.DemeSpec(name,crypto,deps,:PeaceVote,notary)

### Now let's wrap it in the function

function demespecf(name,crypto,deps,peacefounder)

    notary = PeaceVote.Notary(crypto,deps)
    demespec = PeaceVote.DemeSpec(name,crypto,deps,:PeaceVote,notary)
    
    return demespec
end

demespecnew = demespecf("Name",crypto,deps,:PeaceVote)
