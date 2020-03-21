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


### Let's test Certificates and intent
maintainer = Signer(deme,"maintainer")
cert = Certificate("hello world",maintainer)
intent = Intent(cert,notary)
