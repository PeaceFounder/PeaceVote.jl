module Plugins

using Base: UUID
using ..DemeNet: Signer, Certificate, Deme, Profile, AbstractID, AbstractPlugin

################## The API of PeaceFounder #################

abstract type AbstractChain <: AbstractPlugin end 
abstract type AbstractVote end
abstract type AbstractProposal end
abstract type AbstractBraid end

##### LEDGER #######
#Ledger(::Type{Deme},deme::UUID) = error("Ledger must be implemented by the peacefounder")
#Ledger(::Type{Deme},port) = error("Ledger is not implemented by peacefounder")
record!(ledger::AbstractChain,fname::AbstractString,data) = error("Must be implemented by ledger type $(typeof(ledger))")
records(ledger::AbstractChain) = error("Must be implemented by ledger type $(typeof(ledger))")
#loadrecord(record) = error("Must be implemented by $(typeof(record))")
load(ledger::AbstractChain) = error("Must be implemented by $(typeof(ledger))")

####### DEME ########

sync!(deme::AbstractChain) = error("sync! is not implemented by peacefounder")
register(deme::AbstractChain,certificate::Certificate{T}) where T <: AbstractID = error("register is not implemented by peacefounder")
register(deme::AbstractChain,profile::Profile,tooken::Integer) = error("register by a tooken is not implemented by a peacefounder")
braid!(deme::AbstractChain,newsigner::Signer,oldsigner::Signer) = error("braid is not implemented by peacefounder")
vote(deme::AbstractChain,option::AbstractVote,signer::Signer) = error("vote is not implemented by peacefounder")
propose(deme::AbstractChain,proposal::AbstractProposal,signer::Signer) = error("propose is not implemented by peacefounder")

########### BRAIDCHAIN ###############

### Perhaps a different name should be used. Or the proposal could be the first argument to reflect Base.count.
import Base.count
count(index::Int, proposal::AbstractProposal,deme::AbstractChain) = error("count is not implemented by peacefounder")

end
