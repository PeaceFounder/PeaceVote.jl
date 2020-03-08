using PeaceVote
using PeaceCypher

demespec = PeaceVote.DemeSpec("PeaceDeme",:default,:PeaceCypher,:default,:PeaceCypher,:PeaceVote)

# Now some testing 

deme = Deme(demespec,nothing)
maintainer = PeaceVote.Signer(deme,"maintainer")

notary = deme.notary

signer = notary.Signer()
msg = "Hello World"
signature = notary.Signature(msg,signer)
notary.verify(msg,signature)
