### This file contains all functions which are necessary for accessing .peacevote/keys folder. In future it would be great to have a password prtotection so one could do easier backups.

using Serialization: serialize, deserialize

function save(s,fname) 
    mkpath(dirname(fname))
    serialize(fname,s)
end


struct Signer <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

function Signer(deme::Deme,account)
    fname = keydir(deme.spec.uuid) * account 
    
    if !isfile(fname)
        @info "Creating a new signer for the community"
        
        s = deme.notary.Signer()
        save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = deme.notary.Signature(data,signer)

    test = "A test message."
    signature = sign(test)
    id = deme.notary.verify(test,signature)

    @assert id!=nothing

    return Signer(deme.spec.uuid,id,sign)
end

### The KeyChain part. 

struct KeyChain <: AbstractSigner
    deme::Deme ### This is necessary to make braid! function obvious  
    account
    member::Signer
    signers::Vector{Signer}
end

function KeyChain(deme::Deme,account)
    member = Signer(deme,account * "/member")

    voterdir = keydir(deme.spec.uuid) * account * "/voters/"
    mkpath(voterdir)

    t = []
    voters = Signer[]
    for file in readdir(voterdir)
        voter = Signer(deme,account * "/voters/$file")
        push!(t,mtime("$voterdir/$file"))
        push!(voters,voter)
    end

    if length(voters) > 0 
        voters=voters[sortperm(t)]
    end

    return KeyChain(uuid,account,member,voters)
end

KeyChain(deme::Deme) = KeyChain(deme,"")

### I could use oldvoter.id as filename
function braid!(kc::KeyChain)
    if length(kc.signers)==0 
        oldvoter = kc.member
    else
        oldvoter = kc.signers[end]
    end

    newvoter = Signer(kc.deme,kc.account * "/voters/$(oldvoter.id)")

    braid(kc.deme,newvoter,oldvoter)
    # if fails, delete the newvoter
    push!(kc.signers,newvoter)
end

voter(kc::KeyChain) = kc.signers[end]

function voter(kc::KeyChain,vset::Set,bc)
    for v in kc.signers 
        if v.id in vset
            return v
        end
    end
end

function voter(kc::KeyChain,x::Union{Proposal,Option}) 
    bc = braidchain(kc.deme)
    voter(kc,voters(bc,x),bc)
end    

voter(kc::KeyChain,vset::Set) = voter(kc,vset,braidchain(kc.deme))

function vote(option::AbstractOption,keychain::KeyChain)
    v = voter(keychain,option)
    vote(keychain.deme,option,v)
end


function propose(msg,options,member::Signer)
    com = community(member.uuid)
    com.propose(msg, options, member)
end

propose(proposal::AbstractProposal,kc::KeyChain) = propose(kc.deme, proposal, kc.member)

#whistle(msg,keychain) = vote(msg,keychain)
