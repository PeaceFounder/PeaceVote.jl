Contract(x,signer::AbstractSigner) = Contract(x,signer.sign("$x"))

Envelope(data,signer::AbstractSigner) = Envelope(signer.uuid,Contract(data,signer))

function Voucher(envelope::Envelope) 
    demespec = DemeSpec(envelope.uuid)
    notary = Notary(demespec)

    contract = envelope.contract
    id = notary.verify("$(contract.document)",contract.signatures) 

    ref = ExtRef(envelope.uuid,id)
    return Voucher(document,ref)
end

function Voucher(contract::Contract,notary::Notary)
    id = notary.verify("$(contract.document)",contract.signatures) 
    ref = LocRef(envelope.uuid,id)
    return Voucher(document,ref)
end    

function Voucher(contract::Contract{T},notary::Notary) where T <: AbstractBraid
    refs = LocRef[]
    for s in contract.signatures
        id = notary.verify("$(contract.document)",s)
        push!(refs,LocRef(id))
    end
    return Voucher(document,refs)
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

function voter(kc::KeyChain,x::Union{Proposal,Vote}) 
    bc = BraidChain(kc.deme).records 
    voter(kc,voters(bc,x),bc)
end    

voter(kc::KeyChain,vset::Set) = voter(kc,vset,braidchain(kc.deme))

function vote(option::AbstractVote,keychain::KeyChain)
    v = voter(keychain,option)
    vote(keychain.deme,option,v)
end

#vote(option::AbstractOption,keychain::New{KeyChain}) = invokelatest(kc->vote(option,kc),keychain.invoke)

propose(msg,options,kc::KeyChain) = propose(kc.deme,msg,options,kc.member)

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
BraidChain(::Deme) = error("braidchain is not implemented by peacefounder")

### Perhaps a different name should be used. Or the proposal could be the first argument to reflect Base.count.
import Base.count
count(deme::Deme, proposal::AbstractProposal) = error("count is not implemented by peacefounder")
