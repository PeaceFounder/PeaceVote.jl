module Recorders

using Sockets
using DemeNet: Certificate, Intent, Contract, Consensus, Envelope, Notary, Deme, Signer, ID, DemeID, AbstractID, datadir, verify, serialize, deserialize
using PeaceVote: AbstractVote, AbstractChain, AbstractProposal

import PeaceVote: record
using ..Analysis: voters!, members, addvoters!
using ..Braiders: Braider
using ..Types: Proposal, Vote, Braid
using ..Ledgers: Ledger, load

include("../debug.jl")

struct Registrator{T}
    server
    daemon
    messages::Channel{Certificate{T}}
end

function Registrator{T}(port,verify::Function,validate::Function) where T<:Any
    server = listen(port)
    messages = Channel{Certificate{T}}()
    
    daemon = @async while true
        socket = accept(server)
        @async begin
            envelope = deserialize(socket,Certificate{T})
            signerid = verify(envelope)
            #memberid, signerid = unwrap(envelope)

            if validate(signerid)
                put!(messages,envelope)
            end
        end
    end
    
    Registrator(server,daemon,messages)
end


struct RecorderConfig{T}
    membersca::Union{Vector{Union{DemeID,ID}},Vector{ID}} ### One needs to explicitly add the certifier server id here. That's because 
    serverid::ID
    registratorport::T ### The port to which the certificate of membership is delivered
    votingport::T
    proposalport::T
end

struct Recorder # RecorderConfig
    registrator::Registrator{ID}
    voterecorder::Registrator{Vote}
    proposalreceiver::Registrator{Proposal}
    braider::Braider
    members::Set{ID}
    daemon
end

const listmembers = members

extverify(x::Certificate{T},notary::Notary) where T <: AbstractID = verify(x,notary)
extverify(x::Envelope{Certificate{T}},notary::Notary) where T <: AbstractID = verify(x)

### Recorder or BraidChainRecorder
function Recorder(config::RecorderConfig,deme::Deme,ledger::Ledger,braider::Braider,signer::Signer) 
    notary = deme.notary
    
    @show messages = load(ledger) ### Maybe a different name must be used here

    members = listmembers(messages,config.membersca)
    voters!(braider.voters,messages) ### I could update the braider here

    allvoters = Set{ID}()
    voters!(allvoters,messages)

    registrator = Registrator{ID}(config.registratorport,x->extverify(x,notary),x -> x in config.membersca)
    voterecorder = Registrator{Vote}(config.votingport,x->verify(x,notary),x -> x in allvoters)
    proposalreceiver = Registrator{Proposal}(config.proposalport,x->verify(x,notary),x -> x in members)

    daemon = @async @sync begin
        @async while true
            cert = take!(registrator.messages)

            id = cert.document

            push!(members,id)
            push!(braider.voters,id)
            push!(allvoters,id)

            serialize(ledger,cert)
        end

        @async while true
            braid = take!(braider)
            consbraid = Consensus(braid,notary)
            
            ### We have different types here. I could move everything to references in future.
            input = unique(consbraid.references)
            output = unique(consbraid.document.ids)
            @assert length(input)==length(output)

            voters!(braider.voters,input,output)
            addvoters!(allvoters,input,output)

            serialize(ledger,braid)
        end

        @async while true
            vote = take!(voterecorder.messages)
            serialize(ledger,vote)
        end

        @async while true
            proposal = take!(proposalreceiver.messages)
            serialize(ledger,proposal)
        end
    end

    Recorder(registrator,voterecorder,proposalreceiver,braider,members,daemon)
end


function record(config::RecorderConfig,cert::Certificate{ID})
    socket = connect(config.registratorport)
    serialize(socket,cert)
    close(socket)
end

function record(config::RecorderConfig,cert::Certificate{T}) where T <: AbstractVote
    socket = connect(config.votingport)
    serialize(socket,cert)
    close(socket)
end

function record(config::RecorderConfig,cert::Certificate{T}) where T <: AbstractProposal
    socket = connect(config.proposalport)
    serialize(socket,cert)
    close(socket)
end

export BraidChain, RecorderConfig, Recorder, record

end
