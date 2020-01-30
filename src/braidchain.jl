struct Ticket
    uuid ### Id of commiunity issuing the certificate ### One may would not like to trust some communities as much as others. One needs this information to sample statistically for fake and real members.
    cid ### Id of the certifier
    id # id is uuid itself
end

struct Braid
    ###
    uuid #uuid # so one could find the right braid
    bcid # ballot config id (for example server and mixer)
    input # a set
    output # a set with the same length
end

struct Vote
    uuid # The uuid of the vote. 
    id
    msg 
end


abstract type AbstractOption end

abstract type AbstractProposal end



struct Proposal <: AbstractProposal
    uuid ### just so one could find it
    id ### the person issueing the ceritificate
    msg
    options### just a list of messages
end

struct Option <: AbstractOption
    pid ### the id of the proposal
    vote ### just a number or perhaps other choice
end

Option(p::Proposal,choice) =  Option(p.uuid,choice)

function voters!(voters::Set,braid::Braid)
    for i in braid.input
        @assert i in voters
    end
    
    for i in braid.input
        pop!(voters,i)
    end

    for o in braid.output
        push!(voters,o)
    end
end

function voters!(voters::Set,messages::Vector)
    for msg in messages
        if typeof(msg) == Ticket
            push!(voters,msg.id)
        elseif typeof(msg) == Braid
            voters!(voters,msg)
        elseif typeof(msg) == Vote
            @assert msg.id in voters "Vote with $(msg.uuid) is invalid."
        end
    end
end

"""
    Returns a parrent braid
"""
function parrent(id,braids::Vector{Braid}) 
    for b in braids
        if id in b.outputs
            return b
        end
    end
end

"""
    Returns a child braid
"""
function child(id,braids::Vector{Braid})
    for b in braids
        if id in b.inputs
            return b
        end
    end
end

#export voters!, Braid, Vote, Ticket

