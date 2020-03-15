using Pkg.TOML

#using TOML

using PeaceVote
using PeaceCypher

demespec = DemeSpec("PeaceDeme",:default,:PeaceCypher,:default,:PeaceCypher,:PeaceVote)

function config(demespec)
    config = Dict()

    #metadata = Dict()
    config["name"] = demespec.name
    config["uuid"] = "$(demespec.uuid)"
    config["maintainer"] = demespec.maintainer ### BigInt could be left unchanged
    
    ### I could have a second layer for this!
    
    notary = Dict()
    notary["config"] = "$(demespec.crypto)"
    notary["uuid"] = "$(demespec.cryptodep)"

    cypher = Dict()
    cypher["config"] = "$(demespec.cypherconfig)"
    cypher["uuid"] = "$(demespec.cypherdep)"

    peacefounder = Dict()
    peacefounder["uuid"] = "$(demespec.peacefounder)"


    #config["metadata"] = metadata
    config["notary"] = notary
    config["cypher"] = cypher
    config["peacefounder"] = peacefounder

    return config
end

using Base: UUID

import PeaceVote.DemeSpec
function DemeSpec(dict::Dict)
    name = dict["name"]
    uuid = UUID(dict["uuid"])
    maintainer = dict["maintainer"]
    crypto = Symbol(dict["notary"]["config"])
    cryptodep = UUID(dict["notary"]["uuid"])
    cypherconfig = Symbol(dict["cypher"]["config"])
    cypherdep = UUID(dict["cypher"]["uuid"])
    peacefounder = UUID(dict["peacefounder"]["uuid"])

    DemeSpec(uuid,name,maintainer,crypto,cryptodep,cypherconfig,cypherdep,peacefounder)
end

@show DemeSpec(config(demespec)) == demespec


totoml(demespec) = TOML.print(config(demespec))


#dict = TOML.parse(arrbody)
