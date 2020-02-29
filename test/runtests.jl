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

#notary = PeaceVote.Notary(crypto,deps)
demespec = PeaceVote.DemeSpec(name,crypto,deps,:PeaceVote)


# Now some testing 

deme = Deme(demespec,nothing)
maintainer = PeaceVote.Signer(deme,"maintainer")

notary = deme.invoke.notary

signer = notary.Signer()
msg = "Hello World"
signature = notary.Signature(msg,signer)
notary.verify(msg,signature)

