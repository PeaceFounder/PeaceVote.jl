using DemeNet: Notary, Cypher, DemeSpec, Deme, Signer, Certificate, datadir, save, DemeID, ID

using PeaceVote.BraidChains.Types: Proposal, Vote
using PeaceVote.BraidChains.Ledgers: Ledger, load
using PeaceVote.BraidChains.Braiders: BraiderConfig, Braider, Mixer, braid!
using PeaceVote.BraidChains.Analysis: members, proposals, attest, voters
using PeaceVote.BraidChains.Recorders: RecorderConfig, Recorder, record

using PeaceCypher

for dir in [homedir() * "/.demenet/"]
    isdir(dir) && rm(dir,recursive=true)
end

### Configuration ###

demespec = DemeSpec("PeaceDeme",:default,:PeaceCypher,:default,:PeaceCypher,:PeaceFounder)
save(demespec) ### Necessary to connect with Mixer
uuid = demespec.uuid
deme = Deme(demespec)

maintainer = Signer(deme,"maintainer")

# Somewhere far far away
mixer = Signer(deme,"mixer")
mixerserver = Mixer(2001,deme,mixer)

server = Signer(deme,"server")

MIXER_ID = mixer.id
SERVER_ID = server.id

braiderconfig = BraiderConfig(2000,2001,UInt8(3),UInt8(64),SERVER_ID,DemeID(uuid,MIXER_ID))
recorderconfig = RecorderConfig([maintainer.id,],server.id,2002,2003,2004)

braider = Braider(braiderconfig,deme,server)

ledger = Ledger(uuid)
recorder = Recorder(recorderconfig,deme,ledger,braider,server)

### Testing the server ###

for i in 1:3
    account = "account$i"
    member = Signer(deme,account * "/member")
    cert = Certificate(member.id,maintainer)
    @show record(recorderconfig,cert)
end

pmember = Signer(deme,"account2" * "/member")
proposal = Proposal("Found peace for a change?",["yes","no","maybe"])
cert = Certificate(proposal,pmember)

record(recorderconfig,cert);

@sync for i in 1:3
    @async begin
        account = "account$i"
        member = Signer(deme,account * "/member")
        voter = Signer(deme,account * "/voters/$(string(member.id))")
        braid!(braiderconfig,deme,voter,member)
    end
end

### Now I can work on reading in parsing the ledger to a BraidChain

sleep(1)

loadedledger = load(ledger)
messages = attest(loadedledger,deme.notary)
index = proposals(messages)[1]
proposal = messages[index]

for i in 1:3
    account = "account$i"

    member = Signer(deme,account * "/member")
    voter = Signer(deme,account * "/voters/$(string(member.id))")

    option = Vote(index,rand(1:length(proposal.document.options)))
    cert = Certificate(option,voter)

    record(recorderconfig,cert)
end

