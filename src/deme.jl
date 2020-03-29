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

### Makes a ticket string which can be used by the register method
function ticket(deme::DemeSpec,port,tooken::Int)
    config = Dict("demespec"=>Dict(deme),"port"=>Dict(port),"tooken"=>tooken)
    io = IOBuffer()
    TOML.print(io, config)
    return String(take!(io))
end

### To use this function one is supposed to know
### How to create a identity

function register(invite::Dict,profile::Profile; account="")

    demespec = DemeSpec(invite["demespec"])
    save(demespec)

    deme = Deme(demespec)
    if haskey(invite,"port")
        sync!(deme,invite["port"]) 
    end

    tooken = invite["tooken"]
    keychain = KeyChain(deme,account)
    id = keychain.member.id
    register(deme,profile,id,tooken)
end

register(invite::AbstractString,profile::Profile; kwargs...) = register(TOML.parse(invite),profile; kwargs...)

#tooken = dict["tooken"]
#register(deme,id,tooken)

### Definitions which must be implemented by PeaceFounder
