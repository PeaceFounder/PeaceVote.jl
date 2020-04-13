module BraidChains

using DemeNet: ID, AbstractID, Notary, Contract, Certificate, Intent, Consensus
using ..Plugins: AbstractChain, AbstractProposal, AbstractVote, AbstractBraid, load

function attest(chain::Vector{Union{Certificate,Contract}},notary::Notary)
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
    
    return messages
end

attest(chain::AbstractChain) = attest(load(chain.ledger),chain.deme.notary)


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
        if typeof(msg)==Intent{ID} 
            push!(voters,msg.document)
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

end
