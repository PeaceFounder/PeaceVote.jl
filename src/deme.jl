# Just a quick fix
using Serialization: serialize, deserialize
using Pkg.Types: Context

using Base: UUID
_uuid(name::AbstractString) = UUID(Base.hash(name))

module SandBox end

uuid(ctx::Context,name::AbstractString) = ctx.env.project.deps[name]
uuid(ctx::Context,name::Symbol) = uuid(ctx,String(name))
uuid(ctx::Context,name::Module) = uuid(ctx,nameof(name))

uuid(name::Union{Module,Symbol,AbstractString}) = uuid(Context(),name)


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

function package(ctx::Context,uuid::UUID)
    @assert uuid in ctx.env.manifest.keys "The package is not imported in $NAMESPACE"
    name = Symbol(ctx.env.manifest[uuid].name)
    return name
end


function importdeps(m::Module,deps::Vector{UUID})
    ctx = Context()
    depnames = [package(ctx,dep) for dep in deps]
    
    for dep in depnames
        Base.eval(m,:(import $dep))
    end
    
end

### importdeps could be also used for the present namespace!!!

function Notary(crypto::Expr,deps::Vector{UUID})
    ### A command like importdeps would be a nice name
    importdeps(SandBox,deps)
    
    expr = quote
        let
            $crypto
        end
    end
    spec = Base.eval(SandBox,expr)
    return Notary(spec...)
end

Notary(metadata::DemeSpec) = Notary(metadata.crypto,metadata.deps)

Notary(crypto::Expr,deps::Vector{Symbol}) = Notary(crypto,UUID[uuid(dep) for dep in deps])



function DemeSpec(name::AbstractString,crypto::Expr,deps::Vector{Symbol},peacefounder::Symbol,notary::Notary)
    ctx = Context()
    deps_uuid = UUID[uuid(ctx,dep) for dep in deps]
    peacefounder_uuid = uuid(ctx,peacefounder)
    demeuuid = _uuid(name)

    maintainer = Signer(demeuuid,notary,"maintainer")
    DemeSpec(demeuuid,name,maintainer.id,crypto,deps_uuid,peacefounder_uuid)
end

### This one does not work. Why?
function DemeSpec(name::AbstractString,crypto::Expr,deps::Vector{Symbol},peacefounder::Symbol)
    notary = Notary(crypto,deps)
    DemeSpec(name,crypto,deps,peacefounder,notary)
end




DemeType(uuid::UUID) = Deme{uuid.value}
DemeType(m::Module) = DemeType(uuid(m))

function Deme(spec::DemeSpec,notary::Notary,port)
    ThisDeme = DemeType(spec.peacefounder)
    if port==nothing
        ledger = nothing
    else
        ledger = Ledger(ThisDeme,port)
    end
    ThisDeme(spec,notary,ledger)
end
Deme(spec::DemeSpec,port) = Deme(spec,Notary(spec),port)

### In this way the working namespace would not need to know anything about DemeType. 

### There still would be no possibility to dispatch accuratelly if namespace is polluted


function info(deme::Deme)
    @show deme
end


### Definitions which must be implemented by PeaceFounder

Ledger(::Type{Deme},port) = error("Ledger is not implemented by peacefounder")
sync!(::Deme) = error("sync! is not implemented by peacefounder")
register(::Deme,certificate::Certificate) = error("register is not implemented by peacefounder")
braid(::Deme,newsigner::AbstractSigner,oldsigner::AbstractSigner) = error("braid is not implemented by peacefounder")
vote(::Deme,option::AbstractOption,signer::AbstractSigner) = error("vote is not implemented by peacefounder")
propose(::Deme,proposal::AbstractProposal,signer::AbstractSigner) = error("propose is not implemented by peacefounder")
braidchain(::Deme) = error("braidchain is not implemented by peacefounder")

import Base.count
count(deme::Deme, proposal::AbstractProposal) = error("count is not implemented by peacefounder")
