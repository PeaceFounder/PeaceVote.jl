module DemeNet

include("Types/Types.jl")
include("Plugins/Plugins.jl")
include("Keys/Keys.jl")
include("Demes/Demes.jl")
include("Profiles/Profiles.jl")

import .Plugins: AbstractPlugin, Plugin, Notary, Cypher, CypherSuite
import .Keys: Signer, Certificate, Contract, Consensus, Intent, Envelope, verify
import .Types: ID, DemeID, AbstractID, datadir, keydir # keydir should be deprecated in the future
import .Demes: DemeSpec, Deme, save #, Signer
import .Profiles: Profile

end
