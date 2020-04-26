module BraidChains

using DemeNet: ID, Signer, Deme, Signer
#using PeaceVote.Plugins: AbstractChain

using PeaceVote: AbstractChain


include("Types/Types.jl")
include("Braiders/Braiders.jl")
include("Ledgers/Ledgers.jl") 
include("Analysis/Analysis.jl") ### There should not be any problems with this
include("Recorders/Recorders.jl") 


import .Types: Proposal, Vote
import .Braiders: braid!, BraiderConfig, Braider, Mixer
import .Recorders: RecorderConfig, Recorder, record
import .Ledgers: Ledger, record!, getrecord, readbootrecord, writebootrecord, load
import .Analysis: normalcount, voters, attest, members, proposals ### A counting strategy depends on the proposal, thus normalcount could be replaceed just with count

struct BraidChainConfig{T} # Perhaps BraidChainRemote
    server::ID
    mixerport::T
    syncport::T
    braider::BraiderConfig{T}
    recorder::RecorderConfig{T}
end

struct BraidChain <: AbstractChain
    config::BraidChainConfig # I don't need a parameter for the BraidChain itself
    deme::Deme
    ledger
end

BraidChain(config::BraidChainConfig,deme::Deme) = BraidChain(config,deme,Ledger(deme.spec.uuid))

import PeaceVote: record
record(config::BraidChainConfig,data) = record(config.recorder,data)
record(chain::BraidChain,data) = record(chain.config,data)

Recorder(chain::BraidChain,braider::Braider,signer::Signer) = Recorder(chain.config.recorder,chain.deme,chain.ledger,braider,signer)


struct BraidChainServer
    mixer
    synchronizer
    braider
    recorder
end

function BraidChainServer(chain::BraidChain,server::Signer)
    
    config = chain.config

    mixer = Mixer(config.mixerport,chain.deme,server)
    synchronizer = @async Ledgers.serve(config.syncport,chain.ledger)
    braider = Braider(config.braider,chain.deme,server)
    recorder = Recorder(chain,braider,server)
    
    return BraidChainServer(mixer,synchronizer,braider,recorder)
end

load(chain::BraidChain) = load(chain.ledger)

import PeaceVote: sync!
#sync!(chain::BraidChain,syncport) = Ledgers.sync!(chain.ledger,syncport)
#sync!(chain::BraidChain,config::BraidChainConfig) = sync!(chain,config.syncport)

sync!(chain::BraidChain) = Ledgers.sync!(chain.ledger,chain.config.syncport)

import PeaceVote: count
count(index::Int,chain::BraidChain) = normalcount(index,chain.deme,chain.ledger)

braid!(chain::BraidChain,newvoter::Signer,oldvoter::Signer) = braid!(chain.config.braider,chain.deme,newvoter,oldvoter)


attest(chain::BraidChain) = attest(load(chain.ledger),chain.deme.notary)


end
