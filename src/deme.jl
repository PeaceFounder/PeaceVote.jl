# Just a quick fix
using Serialization: serialize, deserialize
using Base: UUID

_uuid(name::AbstractString) = UUID(Base.hash(name))

function add(spec::DemeSpec)
    error("Not implemented")
end

#import Base.save
function save(fname::AbstractString,deme::DemeSpec)
    mkpath(dirname(fname))
    serialize(fname,deme)
end

save(deme::DemeSpec) = save(demefile(deme.uuid),deme)

function DemeSpec(uuid::UUID)
    specfile = demefile(uuid)
    @assert isfile(specfile) "No deme spec found for $uuid"
    deserialize(specfile)
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

function Deme(spec::DemeSpec,notary::Notary,cypher::Cypher,port)
    ThisDeme = DemeType(spec.peacefounder)
    if port==nothing
        ledger = nothing
    else
        ledger = Ledger(ThisDeme,port)
    end
    ThisDeme(spec,notary,cypher,ledger)
end

Deme(spec::DemeSpec,port) = Deme(spec,Notary(spec),Cypher(spec),port)
Deme(uuid::UUID,port) = Deme(DemeSpec(uuid),port)

### In this way the working namespace would not need to know anything about DemeType. 

### There still would be no possibility to dispatch accuratelly if namespace is polluted


function info(deme::Deme)
    @show deme
end


### Definitions which must be implemented by PeaceFounder

Ledger(::Type{Deme},port) = error("Ledger is not implemented by peacefounder")
sync!(::Deme) = error("sync! is not implemented by peacefounder")
register(::Deme,certificate::Certificate) = error("register is not implemented by peacefounder")
braid!(::Deme,newsigner::AbstractSigner,oldsigner::AbstractSigner) = error("braid is not implemented by peacefounder")
vote(::Deme,option::AbstractOption,signer::AbstractSigner) = error("vote is not implemented by peacefounder")
propose(::Deme,proposal::AbstractProposal,signer::AbstractSigner) = error("propose is not implemented by peacefounder")
braidchain(::Deme) = error("braidchain is not implemented by peacefounder")

### Perhaps a different name should be used. Or the proposal could be the first argument to reflect Base.count.
import Base.count
count(deme::Deme, proposal::AbstractProposal) = error("count is not implemented by peacefounder")
