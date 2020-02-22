using PeaceVote

name = "PeaceDeme"
maintainer = BigInt(100)

crypto = quote
G = CryptoGroups.Scep256k1Group()
hash(x::AbstractString) = parse(BigInt,Nettle.hexdigest("sha256",x),base=16)

Signer() = CryptoSignatures.Signer(G)
Signature(x::AbstractString,signer) = CryptoSignatures.DSASignature(hash(x),signer)
verify(data,signature) = CryptoSignatures.verify(signature,G) && hash(data)==signature.hash ? hash("$(signature.pubkey)") : nothing

(Signer,Signature,verify)
end

deps = Symbol[:Nettle,:CryptoGroups,:CryptoSignatures]

demespec = PeaceVote.DemeSpec(name,maintainer,crypto,deps,:PeaceVote)

notary = PeaceVote.Notary(demespec)

signer = notary.Signer()
msg = "Hello World"
signature = notary.Signature(msg,signer)
notary.verify(msg,signature)

### Now a higher order abstractions

deme = PeaceVote.Deme(demespec,nothing)
signer = Signer(deme,"server")
