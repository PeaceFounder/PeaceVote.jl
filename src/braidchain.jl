### Perhaps it could be an abstract type extended by the peacefounder


### Perhaps I need to look into the Commands pattern. 
### Here the first argument would always be UUID.


#struct PeaceFounderType{T} end
#struct PeaceFounderSingleton{T<:UUID} end

#abstract type AbstractPeaceFounder end


# struct PeaceFounderTrait
#     uuid::Var{UUID}
# end

# One then specifies 

# I need methods 
# register
# braid
# vote
# braidchain

# then there are optional methods to certify
# Perhaps I could have parametric type with Val. 


# struct Ticket <: AbstractRecord
#     uuid ### Id of commiunity issuing the certificate ### One may would not like to trust some communities as much as others. One needs this information to sample statistically for fake and real members.
#     cid ### Id of the certifier
#     id # id is uuid itself
# end

# struct Braid <: AbstractRecord
#     ###
#     uuid #uuid # so one could find the right braid
#     bcid # ballot config id (for example server and mixer)
#     input # a set
#     output # a set with the same length
# end


### Let's look into theese two types


# struct Vote <: AbstractRecord
#     uuid # The uuid of the vote. 
#     id
#     msg 
# end


# struct Proposal <: AbstractProposal
#     uuid ### just so one could find it
#     id ### the person issueing the proposal
#     msg
#     options### just a list of messages
# end

function addvoters!(voters::Set,braid::Braid)
    for i in braid.signatures
        @assert i in voters
    end
    
    for o in braid.document.ballot
        push!(voters,o)
    end
end


function voters!(voters::Set,braid::Braid)
    addvoters!(voters,braid)

    for i in braid.signatures
        pop!(voters,i)
    end

end

function voters!(voters::Set,messages::Vector)
    for msg in messages
        if typeof(msg) <: Ticket
            push!(voters,msg.document.id)
        elseif typeof(msg) <: Braid
            voters!(voters,msg)
        #elseif typeof(msg) == Vote
            #@assert msg.id in voters "Vote with $(msg.uuid) is invalid."
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


proposals(messages::Vector) = filter(msg -> typeof(msg) <: Proposal,messages)
votes(messages::Vector) = filter(msg -> typeof(msg) <: Vote,messages)
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
    vset = Set()
    voters!(vset,messages[1:index])
    return vset
end

### Index is the one by which one can filter the votes of the proposal
#voters(messages,option::AbstractOption) = voters(messages,option.index)

function voters(braidchain)
    vset = Set()
    voters!(vset,braidchain)
    return vset
end

function members(braidchain)
    mset = Set()
    for msg in braidchain
        if typeof(msg) <: Ticket
            push!(mset,msg.document.id)
        end
    end
    return mset
end

function members(braidchain,ca)
    mset = Set()
    for item in braidchain
        if typeof(item) <: ID
            @assert item.references in ca "certificate for $(item.references) is not valid"
            push!(mset,item.id)
        end
    end
    return mset
end

function allvoters(braidchain)
    vset = Set()
    for msg in braidchain
        if typeof(msg) <: ID
            push!(vset,msg.document.id)
        elseif typeof(msg) <: Braid
            addvoters!(vset,msg)
        end
    end

    return vset
end

# function count(uuid::UUID, proposal::Proposal, braidchain)
#     com = community(uuid)
#     return com.count(proposal,braidchain)
# end

# function Ledger(uuid::UUID)
#     com = community(uuid)
#     return com.Ledger()
# end

# function sync!(ledger,uuid::UUID)
#     com = community(uuid)
#     com.sync!(ledger)
# end

# function braidchain(ledger,uuid::UUID)
#     com = community(uuid)
#     return com.braidchain(ledger)
# end

# braidchain(uuid::UUID) = braidchain(Ledger(uuid),uuid)


#export voters!, Braid, Vote, Ticket

