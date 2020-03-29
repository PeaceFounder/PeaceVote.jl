Certificate(x,signer::AbstractSigner) = Certificate(x,Dict(signer.sign("$x")))

Envelope(data,signer::AbstractSigner) = Envelope(signer.uuid,Certificate(data,signer))

verify(cert::Certificate,notary::Notary) = notary.verify("$(cert.document)",notary.Signature(cert.signature)) 

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
    id = notary.verify("$(contract.document)",notary.Signature(contract.signature)) 

    ref = DemeID(envelope.uuid,id)
    return Intent(document,ref)
end

function Intent(contract::Certificate,notary::Notary)
    signature = notary.Signature(contract.signature)
    id = notary.verify("$(contract.document)",signature) 
    return Intent(contract.document,id)
end    

function Consensus(contract::Contract,notary::Notary) 
    doc = "$(contract.document)"
    refs = ID[]
    for s in contract.signatures
        signature = notary.Signature(s)
        id = notary.verify(doc,signature)
        push!(refs,id)
    end
    return Consensus(contract.document,refs)
end

function BraidChain(chain::Vector{Union{Certificate,Contract}},notary::Notary)
    messages = []
    for record in chain
        if typeof(record) <: Certificate
            intent = Intent(record,notary)
            push!(messages,intent)
        elseif typeof(record) <: Contract
            braid = Consensus(record,notary)
            push!(messages,braid)
        else
            error("The type $(typeof(record)) is not valid for braidchain")
        end
    end
    
    return BraidChain(messages)
end


BraidChain(ledger::AbstractLedger,notary::Notary) = BraidChain(load(ledger),notary)
BraidChain(deme::Deme) = BraidChain(deme.ledger,deme.notary)


function addvoters!(voters::Set{ID},input,output)
    for i in input
        @assert i in voters
    end
    
    for o in output
        push!(voters,o)
    end
end


function voters!(voters::Set{ID},input,output)
    addvoters!(voters,input,output)
    
    for i in input
        pop!(voters,i)
    end

end


function voters!(voters::Set{ID},messages::Vector)
    for msg in messages
        if typeof(msg) <: Intent{T} where T<:AbstractID
            push!(voters,msg.document.id)
        elseif typeof(msg) <: Consensus{T} where T<:AbstractBraid
            input = unique(msg.references)
            output = unique(msg.document.ids)
            @assert length(input)==length(output)
            voters!(voters,input,output)
        end
    end
end


# """
#     Returns a parrent braid
# """
# function parrent(id,braids::Vector{Braid}) 
#     for b in braids
#         if id in b.outputs
#             return b
#         end
#     end
# end

# """
#     Returns a child braid
# """
# function child(id,braids::Vector{Braid})
#     for b in braids
#         if id in b.inputs
#             return b
#         end
#     end
# end


proposals(messages::Vector) = findall(msg -> typeof(msg) <: Intent{T} where T<:AbstractProposal,messages)
votes(messages::Vector) = filter(msg -> typeof(msg) <: Intent{T} where T<:AbstractVote,messages)
#tickets(messages::Vector) = filter(msg -> typeof(msg)==Ticket,messages)

#function voters(proposal::Proposal,messages) 
# function voters(messages,proposal::Proposal) 
#     index = findfirst(item -> item==proposal,messages)
#     vset = Set()
#     voters!(vset,messages[1:index])
#     return vset
# end

# function voters(messages,option::AbstractOption)
#     index = findfirst(x -> typeof(x)<:Proposal && x.uuid==option.pid,messages)
#     vset = Set()
#     voters!(vset,messages[1:index])
#     return vset
# end

function voters(messages,index::Integer)
    vset = Set{ID}()
    voters!(vset,messages[1:index])
    return vset
end

### Index is the one by which one can filter the votes of the proposal
#voters(messages,option::AbstractOption) = voters(messages,option.index)

function voters(braidchain)
    vset = Set{ID}()
    voters!(vset,braidchain)
    return vset
end

function members(braidchain)
    mset = Set{ID}()
    for msg in braidchain
        if typeof(msg) <: Intent{T} where T<:AbstractID
            push!(mset,msg.document.id)
        end
    end
    return mset
end

function members(braidchain,ca)
    mset = Set{ID}()
    for msg in braidchain
        if typeof(msg) <: Intent{T} where T<:AbstractID
            @assert msg.reference in ca "certificate with reference=$(msg.reference) is not valid"
            push!(mset,msg.document.id)
        end
    end
    return mset
end

function allvoters(braidchain)
    vset = Set{ID}()
    for msg in braidchain
        if typeof(msg) <: ID
            push!(vset,msg.document.id)
        elseif typeof(msg) <: Braid
            addvoters!(vset,msg)
        end
    end

    return vset
end

