module Demes

import Base.Dict
using Base: UUID
using Pkg.TOML
using Pkg.Types: Context
using ..Types: ID, uuid, demefile
import ..Keys: Signer
import ..Plugins: Notary, Cypher

struct DemeSpec
    uuid::UUID
    name::AbstractString
    maintainer::ID  # ::BigInt
    crypto::Symbol
    cryptodep::UUID
    cypherconfig::Symbol
    cypherdep::UUID
    peacefounder::UUID # Everything else appart from signature stuff
end

function Dict(demespec::DemeSpec)
    config = Dict()

    #metadata = Dict()
    config["name"] = demespec.name
    config["uuid"] = "$(demespec.uuid)"
    config["maintainer"] = string(demespec.maintainer.id,base=16)
    
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

function DemeSpec(dict::Dict)
    name = dict["name"]
    uuid = UUID(dict["uuid"])
    maintainer = ID(parse(BigInt,dict["maintainer"],base=16)) ### May need to change this one 
    crypto = Symbol(dict["notary"]["config"])
    cryptodep = UUID(dict["notary"]["uuid"])
    cypherconfig = Symbol(dict["cypher"]["config"])
    cypherdep = UUID(dict["cypher"]["uuid"])
    peacefounder = UUID(dict["peacefounder"]["uuid"])

    DemeSpec(uuid,name,maintainer,crypto,cryptodep,cypherconfig,cypherdep,peacefounder)
end

_uuid(name::AbstractString) = UUID(Base.hash(name))

function add(spec::DemeSpec)
    error("Not implemented")
end

#import Base.save
function save(fname::AbstractString,deme::DemeSpec)
    mkpath(dirname(fname))
    dict = Dict(deme)
    open(fname, "w") do io
        TOML.print(io, dict)
    end
end

save(deme::DemeSpec) = save(demefile(deme.uuid),deme)

function DemeSpec(uuid::UUID)
    specfile = demefile(uuid)
    @assert isfile(specfile) "No deme spec found for $uuid"
    dict = TOML.parsefile(specfile)
    DemeSpec(dict)
end

function DemeSpec(name::AbstractString,crypto::Symbol,cryptodep::Symbol,cypherconfig::Symbol,cypherdep::Symbol,peacefounder::Symbol)#,notary::Notary)
    ctx = Context()
    #deps_uuid = UUID[uuid(ctx,dep) for dep in deps]
    cryptodep_uuid = uuid(ctx,cryptodep)
    cypherdep_uuid = uuid(ctx,cypherdep) 
    peacefounder_uuid = uuid(ctx,peacefounder)
    demeuuid = _uuid(name)

    notary = Notary(cryptodep_uuid,crypto)
    maintainer = Signer(demeuuid,notary,"maintainer")
    DemeSpec(demeuuid,name,maintainer.id,crypto,cryptodep_uuid,cypherconfig,cypherdep_uuid,peacefounder_uuid)
end

Notary(metadata::DemeSpec) = Notary(metadata.cryptodep,metadata.crypto)
Cypher(metadata::DemeSpec) = Cypher(metadata.cypherdep,metadata.cypherconfig)

struct Deme
    spec::DemeSpec
    notary::Notary
    cypher::Cypher
    #ledger ### This one is used by peacefounder to construct configuration
end

Signer(deme::Deme,account::AbstractString) = Signer(deme.spec.uuid,deme.notary,account)
# I could use the [] brackets for defining a proper type!!!

#DemeType(uuid::UUID) = 
#DemeType(m::Module) = DemeType(uuid(m))

function Deme(spec::DemeSpec,notary::Notary,cypher::Cypher,ledger)
    ThisDeme = DemeType(spec.peacefounder)
    ThisDeme(spec,notary,cypher,ledger)
end

function Deme(spec::DemeSpec) #;ledger=true)
    notary = Notary(spec)
    cypher = Cypher(spec)
    # ThisDeme = Deme{spec.peacefounder.value}

    # if ledger==true
    #     ledger_ = Ledger(ThisDeme,spec.uuid)
    # else
    #     ledger_ = nothing
    # end
    # ThisDeme(spec,notary,cypher,ledger_)
    return Deme(spec,notary,cypher)
end

Deme(uuid::UUID) = Deme(DemeSpec(uuid))

function info(deme::Deme)
    @show deme
end

end
