# Just a quick fix
using Pkg.TOML
using Base: UUID

_uuid(name::AbstractString) = UUID(Base.hash(name))

function add(spec::DemeSpec)
    error("Not implemented")
end

import Base.Dict
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


### importdeps could be also used for the present namespace!!!

#verify(data::AbstractString,signature,notary::Notary) = notary.verify(data,signature)
#verify(data::AbstractString,signature,notary::New{Notary}) = invokelatest(notary->verify(data,signature,notary),notary.invoke)

#hash(data::AbstractString,notary::Notary) = notary.hash(data)
#hash(data::AbstractString,notary::New{Notary}) = invokelatest(notary->hash(data,notary),notary.invoke)

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

#DemeSpec(name::AbstractString,crypto::Expr,deps::Vector{Symbol},peacefounder::Symbol,notary::New{Notary}) = invokelatest(notary -> DemeSpec(name,crypto,deps,peacefounder,notary),notary.invoke)::DemeSpec

### This one does not work. Why?
#DemeSpec(name::AbstractString,crypto::Union{Symbol,Expr},deps::Vector{Symbol},cypherconfig::Symbol,cypherdep::Symbol,peacefounder::Symbol) = DemeSpec(name,crypto,deps,cypherconfig,cypherdep,peacefounder,Notary(deps,crypto))

DemeType(uuid::UUID) = Deme{uuid.value}
DemeType(m::Module) = DemeType(uuid(m))

function Deme(spec::DemeSpec,notary::Notary,cypher::Cypher,ledger)
    ThisDeme = DemeType(spec.peacefounder)
    ThisDeme(spec,notary,cypher,ledger)
end

function Deme(spec::DemeSpec;ledger=true)
    notary = Notary(spec)
    cypher = Cypher(spec)
    ThisDeme = DemeType(spec.peacefounder)

    if ledger==true
        ledger_ = Ledger(ThisDeme,spec.uuid)
    else
        ledger_ = nothing
    end
    ThisDeme(spec,notary,cypher,ledger_)
end

Deme(uuid::UUID) = Deme(DemeSpec(uuid))

### In this way the working namespace would not need to know anything about DemeType. 

### There still would be no possibility to dispatch accuratelly if namespace is polluted

function info(deme::Deme)
    @show deme
end


### Definitions which must be implemented by PeaceFounder
