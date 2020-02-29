### This file contains all functions which are necessary for accessing .peacevote/keys folder. In future it would be great to have a password prtotection so one could do easier backups.

using Serialization: serialize, deserialize

function _save(s,fname) 
    mkpath(dirname(fname))
    serialize(fname,s)
end


struct Signer <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

function Signer(uuid::UUID,notary::Notary,account::AbstractString)
    fname = keydir(uuid) * account 
    
    if !isfile(fname)
        @info "Creating a new signer for the community"
        s = notary.Signer()
        _save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = notary.Signature(data,signer)

    test = "A test message."
    signature = sign(test)
    id = notary.verify(test,signature)

    @assert id!=nothing

    return Signer(uuid,id,sign)
end

Signer(deme::Deme,account::AbstractString) = Signer(deme.spec.uuid,deme.notary,account)

# sign(data::AbstractString,signer::Signer) = signer.sign(data)

### The KeyChain part. 

struct KeyChain <: AbstractSigner
    deme::Deme ### This is necessary to make braid! function obvious  
    account
    member::Signer
    signers::Vector{Signer}
end

function KeyChain(deme::Deme,account::AbstractString)
    uuid = deme.spec.uuid
    notary = deme.notary

    member = Signer(uuid,notary,account * "/member")
    voterdir = keydir(uuid) * account * "/voters/"
    mkpath(voterdir)

    t = []
    voters = Signer[]
    for file in readdir(voterdir)
        voter = Signer(uuid,notary,account * "/voters/$file")
        push!(t,mtime("$voterdir/$file"))
        push!(voters,voter)
    end

    if length(voters) > 0 
        voters=voters[sortperm(t)]
    end

    return KeyChain(deme,account,member,voters)
end

### I could actually define a constructor for New so it would construct the type.


#KeyChain(deme::Deme,account::AbstractString) = KeyChain(deme.spec.uuid,deme.notary,account)
KeyChain(deme::Deme) = KeyChain(deme,"")

### I could use oldvoter.id as filename
function braid!(kc::KeyChain)
    if length(kc.signers)==0 
        oldvoter = kc.member
    else
        oldvoter = kc.signers[end]
    end

    newvoter = Signer(kc.deme,kc.account * "/voters/$(oldvoter.id)")

    braid!(kc.deme,newvoter,oldvoter)
    # if fails, delete the newvoter
    push!(kc.signers,newvoter)
end

#braid!(kc::New{KeyChain}) = invokelatest(kc->braid!(kc),kc.invoke)

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

#vote(option::AbstractOption,keychain::New{KeyChain}) = invokelatest(kc->vote(option,kc),keychain.invoke)

function propose(msg,options,member::Signer)
    com = community(member.uuid)
    com.propose(msg, options, member)
end

propose(proposal::AbstractProposal,kc::KeyChain) = propose(kc.deme, proposal, kc.member)

#propose(proposal::AbstractProposal,kc::New{KeyChain}) = invokelatest(kc->propose(proposal,kc),kc.invoke)

#whistle(msg,keychain) = vote(msg,keychain)
