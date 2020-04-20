module KeyChains

using Pkg.TOML
using DemeNet: Deme, DemeSpec, Signer, ID, DemeID, Profile, keydir, Certificate
using PeaceVote: AbstractVote, AbstractProposal, AbstractChain, load, attest, voters

import PeaceVote: braid!

struct KeyChain 
    deme::Deme ### This is necessary to make braid! function obvious  
    account::AbstractString
    member::Signer
    signers::Vector{Signer}
end

function KeyChain(deme::Deme,account::AbstractString)
    uuid = deme.spec.uuid
    notary = deme.notary

    ### Each app may have it's own subdirectory to preven conflicts. 
    ### The member key could be the same! 
    member = Signer(deme,account * "/member")
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

KeyChain(deme::Deme) = KeyChain(deme,"")

voter(kc::KeyChain) = kc.signers[end]

function voter(kc::KeyChain,vset::Set)
    for v in kc.signers 
        if v.id in vset
            return v
        end
    end
end

Certificate(stuff::Union{AbstractProposal,ID},keychain::KeyChain) = Certificate(stuff,keychain.member)

### In place of this one I need to add Certificate methods for KeyChain
### The chain part could be omitted by storing the pid with the keys.
function Certificate(option::AbstractVote,chain::AbstractChain,keychain::KeyChain)
    loadedledger = load(chain)
    messages = attest(loadedledger,keychain.deme.notary)
    vset = voters(messages[1:option.pid])
    v = voter(keychain,vset)
    return Certificate(option,v)
end

function braid!(chain::AbstractChain,kc::KeyChain)
    config = chain.config

    if length(kc.signers)==0 
        oldvoter = kc.member
    else
        oldvoter = kc.signers[end]
    end

    newvoter = Signer(kc.deme,kc.account * "/voters/$(string(oldvoter.id))")

    braid!(chain,newvoter,oldvoter)
    # if fails, delete the newvoter
    push!(kc.signers,newvoter)
end

end
