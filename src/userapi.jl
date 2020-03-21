Certificate(x,signer::AbstractSigner) = Certificate(x,signer.sign("$x"))


Envelope(data,signer::AbstractSigner) = Envelope(signer.uuid,Certificate(data,signer))

verify(cert::Certificate,notary::Notary) = notary.verify("$(cert.document)",cert.signature) 

function verify(envelope::Envelope)
    demespec = DemeSpec(envelope.uuid)
    notary = Notary(demespec)
    id = verify(envelope.contract,notary)
    return DemeID(envelope.uuid,id)
end


function Intent(envelope::Envelope) 
    demespec = DemeSpec(envelope.uuid)
    notary = Notary(demespec)

    contract = envelope.contract
    id = notary.verify("$(contract.document)",contract.signature) 

    ref = DemeID(envelope.uuid,id)
    return Intent(document,ref)
end

function Intent(contract::Certificate,notary::Notary)
    id = notary.verify("$(contract.document)",contract.signature) 
    return Intent(contract.document,id)
end    

function Consensus(contract::Contract,notary::Notary) 
    refs = ID[]
    for s in contract.signature
        id = notary.verify("$(contract.document)",s)
        push!(refs,id)
    end
    return Consensus(document,refs)
end



#propose(msg,options,kc::KeyChain) = propose(kc.deme, proposal, kc.member)
#propose(proposal::AbstractProposal,kc::KeyChain) = propose(kc.deme, proposal, kc.member)

#propose(proposal::AbstractProposal,kc::New{KeyChain}) = invokelatest(kc->propose(proposal,kc),kc.invoke)

#whistle(msg,keychain) = vote(msg,keychain)


### I could use oldvoter.id as filename
function braid!(kc::KeyChain)
    if length(kc.signers)==0 
        oldvoter = kc.member
    else
        oldvoter = kc.signers[end]
    end

    newvoter = Signer(kc.deme,kc.account * "/voters/$(string(oldvoter.id))")

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

function voter(kc::KeyChain,x::AbstractVote) 
    bc = BraidChain(kc.deme).records 
    vset = voters(bc[1:x.pid])
    voter(kc,vset,bc)
end    

voter(kc::KeyChain,vset::Set) = voter(kc,vset,braidchain(kc.deme))

function vote(option::AbstractVote,keychain::KeyChain)
    v = voter(keychain,option)
    vote(keychain.deme,option,v)
end

#vote(option::AbstractOption,keychain::New{KeyChain}) = invokelatest(kc->vote(option,kc),keychain.invoke)



##### API

record!(ledger::AbstractLedger,fname::AbstractString,data) = error("Must be implemented by ledger type $(typeof(ledger))")
records(ledger::AbstractLedger) = error("Must be implemented by ledger type $(typeof(ledger))")
loadrecord(record) = error("Must be implemented by $(typeof(record))")

Ledger(::Type{Deme},deme::UUID) = error("Ledger must be implemented by the peacefounder")


Ledger(::Type{Deme},port) = error("Ledger is not implemented by peacefounder")
sync!(::Deme) = error("sync! is not implemented by peacefounder")
register(::Deme,certificate::Contract{T}) where T <: AbstractID = error("register is not implemented by peacefounder")
braid!(::Deme,newsigner::AbstractSigner,oldsigner::AbstractSigner) = error("braid is not implemented by peacefounder")
vote(::Deme,option::AbstractVote,signer::AbstractSigner) = error("vote is not implemented by peacefounder")
propose(::Deme,proposal::AbstractProposal,signer::AbstractSigner) = error("propose is not implemented by peacefounder")
propose(proposal::AbstractProposal,kc::KeyChain) = propose(kc.deme,proposal,kc.member)

BraidChain(::Deme) = error("braidchain is not implemented by peacefounder")

### Perhaps a different name should be used. Or the proposal could be the first argument to reflect Base.count.
import Base.count
count(index::Int, proposal::AbstractProposal,deme::Deme) = error("count is not implemented by peacefounder")
