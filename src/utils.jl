struct Ticket
    id # id is uuid itself
end

struct Braid
    uuid # so one could find the right braid
    input # a set
    output # a set with the same length
end

struct Vote
    uuid
    id
end

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

export voters!, Braid, Vote, Ticket

