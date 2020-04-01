using PeaceVote.DemeNet: DemeSpec, Deme, Signer, Certificate, Intent, save
# using PeaceCypher


# demespec = DemeSpec("PeaceDeme",:default,:PeaceCypher,:default,:PeaceCypher,:PeaceVote)
# save(demespec)
# DemeSpec(demespec.uuid)==demespec # All fields are equal. Need to implement equality for this test


# # Now some testing 

# deme = Deme(demespec)
# maintainer = Signer(deme,"maintainer")

# notary = deme.notary

# signer = notary.Signer()
# msg = "Hello World"
# signature = notary.Signature(msg,signer)
# notary.verify(msg,signature)


# ### Let's test Certificates and intent
# maintainer = Signer(deme,"maintainer")
# cert = Certificate("hello world",maintainer)
# intent = Intent(cert,notary)
