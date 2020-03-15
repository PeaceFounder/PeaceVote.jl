using PeaceVote
using PeaceCypher


demespec = PeaceVote.DemeSpec("PeaceDeme",:default,:PeaceCypher,:default,:PeaceCypher,:PeaceVote)
save(demespec)
DemeSpec(demespec.uuid)==demespec # All fields are equal. Need to implement equality for this test


# Now some testing 

deme = Deme(demespec,ledger=false)
maintainer = PeaceVote.Signer(deme,"maintainer")

notary = deme.notary

signer = notary.Signer()
msg = "Hello World"
signature = notary.Signature(msg,signer)
notary.verify(msg,signature)
