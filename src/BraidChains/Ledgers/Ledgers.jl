module Ledgers

using Base: UUID
using DemeNet: datadir

import Synchronizers
using Synchronizers: Record

import PeaceVote: load

const SyncLedger = Synchronizers.Ledger

abstract type AbstractLedger end

record!(ledger::AbstractLedger,fname::String,bytes::Vector{UInt8}) = error("Not impl")
records(ledger::AbstractLedger) = error("Not impl")

struct Ledger <: AbstractLedger
    dir::AbstractString
    ledger::SyncLedger
end

function Ledger(dir::AbstractString)
    ledger = SyncLedger(dir)
    return Ledger(dir,ledger)
end

Ledger(uuid::UUID) = Ledger(datadir(uuid) * "/ledger/")

record!(ledger::Ledger,fname::String,data::Vector{UInt8}) = push!(ledger.ledger, Record(fname,data))

### A dirty hack
function record!(ledger::Ledger,fname::String,data::Vector{UInt8},pid::Int)
    ledger.ledger.records[pid] = Record(fname,data)
end

function binary(x)
    io = IOBuffer()
    serialize(io,x)
    return take!(io)
end


records(ledger::Ledger) = ledger.ledger.records # One can pass that 

import Base: dirname, basename
dirname(record::Record) = dirname(record.fname)
basename(record::Record) = basename(record.fname)


serve(port,ledger::Ledger) = Synchronizers.serve(port,ledger.ledger)


sync!(ledger::Ledger,syncport) = Synchronizers.sync(Synchronizers.Synchronizer(syncport,ledger.ledger))


import DemeNet: serialize, deserialize

using Pkg.TOML
using Base: UUID
using ..Types: Vote, Proposal, Braid
using DemeNet: Notary, DemeSpec, Deme, datadir, Signer, Certificate, Contract, Intent, Consensus, Envelope, ID, DemeID, AbstractID


deserialize(record::Record,type::Type) = deserialize(IOBuffer(record.data),type)

function load(ledger::AbstractLedger)
    chain = Union{Certificate,Contract}[]

    for record in records(ledger)
        if dirname(record)=="members"

            id = deserialize(IOBuffer(record.data),Certificate{ID})
            push!(chain,id)

        elseif dirname(record)=="braids"

            braid = deserialize(IOBuffer(record.data),Contract{Braid})
            push!(chain,braid)

        elseif dirname(record)=="votes"

            vote = deserialize(IOBuffer(record.data),Certificate{Vote})
            push!(chain,vote)

        elseif dirname(record)=="proposals"

            proposal = deserialize(IOBuffer(record.data),Certificate{Proposal})
            push!(chain,proposal)

        end
    end
    return chain
end

function getrecord(ledger::AbstractLedger,fname::AbstractString)
    for record in records(ledger)
        if record.fname == fname
            return record
        end
    end
end


serialize(ledger::AbstractLedger,data,fname::AbstractString) = record!(ledger,fname,binary(data))


serialize(ledger::AbstractLedger,id::Certificate{ID}) = record!(ledger,"members/$(id.document.id)",binary(id))

function serialize(ledger::AbstractLedger,vote::Certificate{Vote}) 
    pid = vote.document.pid
    uuid = hash(vote.signature)
    record!(ledger,"votes/$pid-$uuid",binary(vote)) ### We may also use length of the ledger 
end

function serialize(ledger::AbstractLedger,proposal::Certificate{Proposal})
    msg = proposal.document.msg
    propid = hash(msg)
    uuid = hash(proposal.signature)
    record!(ledger,"proposals/$propid-$uuid",binary(proposal))
end

function serialize(ledger::AbstractLedger,braid::Contract{Braid})
    uuid = hash(braid.signatures)
    record!(ledger,"braids/$uuid",binary(braid))
end


function writebootrecord(deme::Deme,config)
    fname = "config/" * string(0,base=16,pad=8)
    bytes = binary(config)
    path = datadir(deme.spec.uuid) * "/ledger/" * fname 
    mkpath(dirname(path))
    write(path, bytes)
end

function readbootrecord(ledger::Ledger,type::Type)
    rec = ledger.ledger.records[1]
    deserialize(rec,type)
end

export Ledger, record!, dirname, basename, serve

end
