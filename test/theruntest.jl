using PeaceVote

setnamespace(@__MODULE__)

import Pkg
Pkg.add(Pkg.PackageSpec(url = "https://github.com/PeaceFounder/PeaceFounder.jl"))
Pkg.develop(Pkg.PackageSpec(url = "https://github.com/PeaceFounder/Community.jl"))
Pkg.resolve()

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

server = PeaceVote.Server(uuid)
signature = server.sign("hello world")
community(uuid).verify(signature)

# Start a community server. 
import PeaceFounder

maintainer = PeaceVote.Maintainer(uuid)
server = PeaceVote.Server(uuid)

ballotconfig = Community.BallotConfig(2000,2001,3,server.id,server.id)
braidchainconfig = PeaceFounder.BraidChainConfig(maintainer.id,maintainer.id,2002,2003,ballotconfig)
systemconfig = Community.SystemConfig(2001,braidchainconfig)

community(uuid).save(systemconfig) # Only necessary for testing.

task = @async Community.serve(server)

### The participatory element

# In one way or another members obtain a valid certificates for the community
certificates = []
for i in 1:9
    account = "account$i"
    member = PeaceVote.Member(uuid,account)
    identification = PeaceVote.ID("$i","today",member.id)
    cert = PeaceVote.Certificate(identification,maintainer)
    push!(certificates,cert)
end

# Each member then participates. 
@sync for (cert,i) in zip(certificates,1:9)
    @async begin
        account = "account$i"
        member = PeaceVote.Member(uuid,account)
        voter = PeaceVote.Voter(uuid,account)
        
        commod = community(uuid)
        commod.register(cert)
        commod.braid(voter,member)
        commod.vote("Count me in!",voter)
    end
end

### Methods for analyzing the braidchain. 

commod = community(uuid)
members = commod.loadmembers()
messages = commod.loaddata()
