module Types

using DemeNet: Certificate, Contract, Intent, Consensus, AbstractID, ID, DemeID, Deme
using PeaceVote: AbstractVote, AbstractProposal, AbstractBraid
using Base: UUID

import Base.Dict

struct Vote <: AbstractVote
    pid::Int ### One gets it from a BraidChain loking into a sealed proposal
    vote::Int ### Number or a message
end

struct Proposal <: AbstractProposal
    msg::AbstractString
    options::Vector{T} where T<:AbstractString
end

import Base.==
==(a::Proposal,b::Proposal) = a.msg==b.msg && a.options==b.options

struct Braid <: AbstractBraid
    index::Union{Nothing,Int} ### latest index of the ledger
    hash::Union{Nothing,BigInt} ### hash of the ledger up to the latest index
    ids::Vector{ID} ### the new ids for the public keys
end

function Dict(p::Proposal)
    dict = Dict()
    dict["msg"] = p.msg
    dict["options"] = p.options
    return dict
end

function Proposal(dict::Dict)
    msg = dict["msg"]
    options = dict["options"]
    return Proposal(msg,options)
end

function Dict(v::Vote)
    dict = Dict()
    dict["pid"] = v.pid
    dict["vote"] = v.vote
    return dict
end

function Vote(dict::Dict)
    pid = dict["pid"]
    vote = dict["vote"]
    return Vote(pid,vote)
end

function Dict(braid::Braid)
    dict = Dict()
    dict["ids"] = [string(i.id,base=16) for i in braid.ids]
    return dict
end

function Braid(dict::Dict)
    ids = ID[ID(parse(BigInt,i,base=16)) for i in dict["ids"]] ### Any until I fix SynchronicBallot
    return Braid(nothing,nothing,ids)
end

end
