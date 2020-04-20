module PeaceVote

using Base: UUID
using DemeNet: Signer, Certificate, Deme, Profile, AbstractID, AbstractPlugin

################## The API of PeaceFounder #################

abstract type AbstractChain <: AbstractPlugin end 
abstract type AbstractVote end
abstract type AbstractProposal end
abstract type AbstractBraid end

##### LEDGER #######
record!(ledger::AbstractChain,fname::AbstractString,data) = error("Must be implemented by ledger type $(typeof(ledger))")
records(ledger::AbstractChain) = error("Must be implemented by ledger type $(typeof(ledger))")
load(ledger::AbstractChain) = error("Must be implemented by $(typeof(ledger))")

####### DEME ########

sync!(deme::AbstractChain) = error("sync! is not implemented by peacefounder")
braid!(deme::AbstractChain,newsigner::Signer,oldsigner::Signer) = error("braid is not implemented by peacefounder")
function record end

########### BRAIDCHAIN ###############

function attest end
function voters end

import Base.count
count(index::Int, proposal::AbstractProposal,deme::AbstractChain) = error("count is not implemented by peacefounder")

include("BraidChains/BraidChains.jl")
include("KeyChains/KeyChains.jl")

import .KeyChains: KeyChain
import .BraidChains: members, proposals, attest, voters, BraiderConfig, RecorderConfig, BraidChainConfig, BraidChainServer, Vote, Proposal, BraidChain, load, record, braid!, sync!

#export ID, DemeID, DemeSpec, Deme, KeyChain, sync!, load, count, braid!

end # module
