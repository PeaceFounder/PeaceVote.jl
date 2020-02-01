using PeaceVote
using PeaceVote: Vote, Option

setnamespace(@__MODULE__)

# import Pkg
# Pkg.add(Pkg.PackageSpec(url = "https://github.com/PeaceFounder/PeaceFounder.jl"))
# Pkg.develop(Pkg.PackageSpec(url = "https://github.com/PeaceFounder/Community.jl"))
# Pkg.resolve()

import Community

#import Pkg.Types.UUID
#mycom = UUID("3fc59347-698f-470f-bc28-6120569cf229")
uuid = PeaceVote.uuid("Community")

# Cleanup from the previous tests
dirs = [PeaceVote.keydir(uuid), PeaceVote.datadir(uuid), PeaceVote.communitydir(uuid)]
for dir in dirs
    isdir(dir) && rm(dir,recursive=true)
end

# Some basics

server = PeaceVote.Signer(uuid,"server")
signature = server.sign("hello world")
community(uuid).verify(signature)

# Start a community server. 
import PeaceFounder

maintainer = PeaceVote.Signer(uuid,"maintainer")
server = PeaceVote.Signer(uuid,"server")

ballotconfig = Community.BallotConfig(2000,2001,3,server.id,(uuid,server.id)) # self referencing
braidchainconfig = PeaceFounder.BraidChainConfig([(uuid,maintainer.id)],maintainer.id,2002,2003,2004,ballotconfig)
systemconfig = Community.SystemConfig(2001,braidchainconfig)

community(uuid).save(systemconfig) # Only necessary for testing.

task = @async Community.serve(server)

### The participatory element

# In one way or another members obtain a valid certificates for the community
certificates = []
for i in 1:3
    account = "account$i"
    member = PeaceVote.Member(uuid,account)
    identification = PeaceVote.ID("$i","today",member.id)
    cert = PeaceVote.Certificate(identification,maintainer)
    push!(certificates,cert)
end

# Each member then participates. 
@sync for (cert,i) in zip(certificates,1:3)
    @async begin
        account = "account$i"
        member = PeaceVote.Member(uuid,account)
        keychain = PeaceVote.KeyChain(uuid,account)
        #voter = PeaceVote.Voter(uuid,account)
        
        commod = community(uuid)
        commod.register(cert)
    end
end


@sync for i in 1:3
    @async begin
        account = "account$i"
        keychain = PeaceVote.KeyChain(uuid,account)
        PeaceVote.braid!(keychain)
    end
end

# Someone puts a proposal
pmember = PeaceVote.Member(uuid,"account2")
commod = community(uuid)
commod.propose("Found peace for a change?",["yes","no","maybe"],pmember);


@sync for i in 1:3
    @async begin
        account = "account$i"
        keychain = PeaceVote.KeyChain(uuid,account)
        PeaceVote.braid!(keychain)
    end
end

pmember = PeaceVote.Member(uuid,"account1")
commod = community(uuid)
commod.propose("Democracy for everyone?",["yes","no"],pmember);

sleep(1)

messages = commod.braidchain()
proposals = PeaceVote.proposals(messages)

@sync for i in 1:3
    @async begin
        account = "account$i"
        keychain = PeaceVote.KeyChain(uuid,account)
        
        voter = PeaceVote.Voter(keychain,proposals[1],messages)
        option = PeaceVote.Option(proposals[1],rand(1:3))
        commod.vote(option,voter)

        voter = PeaceVote.Voter(keychain,proposals[2],messages)
        option = PeaceVote.Option(proposals[2],rand(1:2))
        commod.vote(option,voter)
    end
end


### Methods for analyzing the braidchain. 

sleep(1)

commod = community(uuid)
members = commod.members()
braidchain = commod.braidchain()

for proposal in PeaceVote.proposals(braidchain)
    tally = commod.count(proposal,braidchain)
    @show proposal,tally
end
