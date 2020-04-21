using DemeNet: DemeSpec, Deme, Signer, Certificate, save, DemeID, ID
using PeaceVote: KeyChain, members, proposals, attest, voters, BraiderConfig, RecorderConfig, BraidChainConfig, BraidChainServer, Vote, Proposal, BraidChain, load, record, braid!, sync!
using PeaceCypher

### Some clenup first ###
for dir in [homedir() * "/.demenet/"]
    isdir(dir) && rm(dir,recursive=true)
end

### Setting up Deme with PeaceVote ###

demespec = DemeSpec("PeaceDeme",:default,:PeaceCypher,:default,:PeaceCypher,:PeaceCypher)
save(demespec) ### Necessary to connect with Mixer
uuid = demespec.uuid
deme = Deme(demespec)

maintainer = Signer(deme,"maintainer")
server = Signer(deme,"server")

MIXER_ID = server.id
SERVER_ID = server.id
MAINTAINER_ID = maintainer.id

MIXER_PORT = 3001 # Self mixing
BRAIDER_PORT = 3000
REGISTRATOR_PORT = 3002
VOTING_PORT = 3003
PROPOSAL_PORT = 3004
SYNC_PORT = 3005

braiderconfig = BraiderConfig(BRAIDER_PORT,MIXER_PORT,UInt8(3),UInt8(64),SERVER_ID,DemeID(uuid,MIXER_ID))
recorderconfig = RecorderConfig([MAINTAINER_ID,SERVER_ID],server.id,REGISTRATOR_PORT,VOTING_PORT,PROPOSAL_PORT)
braidchainconfig = BraidChainConfig(SERVER_ID,MIXER_PORT,SYNC_PORT,braiderconfig,recorderconfig)

braidchain = BraidChain(braidchainconfig,deme)
system = BraidChainServer(braidchain,server)

### Testing the server ###

maintainer = Signer(deme,"maintainer")

for i in 1:3
    account = "account$i"
    keychain = KeyChain(deme,account)
    cert = Certificate(keychain.member.id,maintainer)
    @show record(braidchain,cert)
end

# Now let's test braiding 

@sync for i in 1:3
    @async begin
        account = "account$i"
        keychain = KeyChain(deme,account)
        braid!(braidchain,keychain)
    end
end

# Proposing

keychain = KeyChain(deme,"account2")
proposal = Proposal("Found peace for a change?",["yes","no","maybe"])
cert = Certificate(proposal,keychain.member)
record(braidchain,cert) 

sleep(1)

loadedledger = load(braidchain)
messages = attest(loadedledger,braidchain.deme.notary)
index = proposals(messages)[1]
proposal = messages[index]

# Now we can vote

for i in 1:3
    account = "account$i"
    keychain = KeyChain(deme,account)
    
    option = Vote(index,rand(1:length(proposal.document.options)))
    cert = Certificate(option,braidchain,keychain)
    record(braidchain,cert)
end

# Now let's count 
sleep(1)

@show tally = count(index,braidchain)

# Let's test synchronization

demesync = Deme(demespec)
bcsync = BraidChain(braidchainconfig,demesync)
sync!(bcsync,braidchainconfig)
@show tally = count(index,bcsync)
