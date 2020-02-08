### This file contains all functions which are necessary for accessing .peacevote/keys folder. In future it would be great to have a password prtotection so one could do easier backups.

abstract type AbstractSigner end

function save(s,fname) 
    mkpath(dirname(fname))
    serialize(fname,s)
end


struct Signer <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

function Signer(uuid::UUID,community::Module,account)
    fname = keydir(uuid) * account 
    
    if !isfile(fname)
        @info "Creating a new signer for the community"
        s = community.Signer()
        save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = community.Signature(data,signer)

    return Signer(uuid,community.id(signer),sign)
end

Signer(uuid::UUID,account) = Signer(uuid,community(uuid),account)

Member(uuid::UUID,account) = Signer(uuid,account * "/member")
Member(uuid::UUID) = Member(uuid,"")

Voter(uuid::UUID,idx,account) = Signer(uuid,account * "/voters/$idx")
Voter(uuid::UUID,idx) = Voter(uuid,idx,"")

### The KeyChain part. 

struct KeyChain <: AbstractSigner
    uuid::UUID
    account
    member::Signer
    signers::Vector{Signer}
end

function KeyChain(uuid::UUID,account)
    member = Member(uuid,account)

    voterdir = keydir(uuid) * account * "/voters/"
    mkpath(voterdir)

    t = []
    voters = Signer[]
    for file in readdir(voterdir)
        voter = Voter(uuid,file,account)
        push!(t,mtime("$voterdir/$file"))
        push!(voters,voter)
    end

    if length(voters) > 0 
        voters=voters[sortperm(t)]
    end

    return KeyChain(uuid,account,member,voters)
end

KeyChain(uuid::UUID) = KeyChain(uuid,"")

### I could use oldvoter.id as filename
function braid!(kc::KeyChain,braid::Function,community::Module)
    if length(kc.signers)==0 
        oldvoter = kc.member
    else
        oldvoter = kc.signers[end]
    end

    newvoter = Signer(kc.uuid,community,kc.account * "/voters/$(oldvoter.id)")

    braid(newvoter,oldvoter)
    # if fails, delete the newvoter
    push!(kc.signers,newvoter)
end

braid!(kc::KeyChain,braid::Function) = braid!(kc,braid,community(kc.uuid))
braid!(kc::KeyChain) = braid!(kc,community(kc.uuid).braid)


Voter(kc::KeyChain) = kc.signers[end]

function Voter(kc::KeyChain,vset::Set,braidchain)
    for voter in kc.signers 
        if voter.id in vset
            return voter
        end
    end
end

Voter(kc::KeyChain,proposal::Proposal,braidchain) = Voter(kc,voters(braidchain,proposal),braidchain)
Voter(kc::KeyChain,option::Option,braidchain) = Voter(kc,voters(braidchain,option),braidchain)

Voter(kc::KeyChain,proposal::Proposal) = Voter(kc,proposal,community(kc.uuid).braidchain())
Voter(kc::KeyChain,option::Option) = Voter(kc,option,community(kc.uuid).braidchain())

function vote(option::Option,keychain::KeyChain,braidchain)
    com = community(keychain.uuid)
    voter = Voter(keychain,option,braidchain)
    com.vote(option,voter)
end

vote(option::Option,keychain::KeyChain) = vote(option,keychain,community(keychain.uuid).braidchain())

function propose(msg,options,member::Signer)
    com = community(member.uuid)
    com.propose(msg, options, member)
end

function propose(msg,options,keychain::KeyChain)
    com = community(keychain.uuid)
    com.propose(msg, options, keychain.member)
end

function whistle(msg, keychain)
    com = community(keychain.uuid)
    voter = Voter(keychain)
    com.vote(msg, voter)
end
