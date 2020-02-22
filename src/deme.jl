# MetaData (theese things could be part of the braidchain forming a MetaChain). Every member should be aple to propose a new chain. The members who propose malicios metedata would be identifiable.
# - Specifies the name of the deme
# - Specifies uuid with which the deme is suposed to be run
# - Specifies ID of the maintainer
# - Specifies the signature algorithm (Signer,Signature,id,verify). If not specified it assumes the default

# The hash of this file would be ussed to look for a entrance points who would know it and it would define deme::UUID.

# Just a quick fix
using Serialization: serialize, deserialize
using Pkg.Types: UUID, Context

import Pkg
_uuid(name::AbstractString) = Pkg.METADATA_compatible_uuid(name)
using Base: UUID

module SandBox end

uuid(ctx::Context,name::AbstractString) = ctx.env.project.deps[name]
uuid(ctx::Context,name::Symbol) = uuid(ctx,String(name))
uuid(ctx::Context,name::Module) = uuid(ctx,nameof(name))

uuid(name::Union{Module,Symbol,AbstractString}) = uuid(Context(),name)


struct DemeSpec
    uuid::UUID
    name::AbstractString
    maintainer # ::BigInt
    crypto::Expr
    deps::Vector{UUID} # libraries to initialize Signatures type. 
    peacefounder::UUID # Everything else appart from signature stuff
end

function DemeSpec(name::AbstractString,maintainer,crypto::Expr,deps::Vector{Symbol},peacefounder::Symbol)
    ctx = Context()
    deps_uuid = UUID[uuid(dep) for dep in deps]
    peacefounder_uuid = uuid(peacefounder)
    DemeSpec(_uuid(name),name,maintainer,crypto,deps_uuid,peacefounder_uuid)
end



function add(spec::DemeSpec)
    error("Not implemented")
end


function save(fname::AbstractString,deme::DemeSpec)
    mkpath(dirname(fname))
    serialize(fname,deme)
end

save(deme::DemeSpec) = save(demefile(deme.uuid),deme)


struct Notary
    Signer::Function # allows to create signatures when necessery. id is obtained with verify on random data.
    Signature::Function 
    verify::Function # verify returns id of the signature.
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

function Notary(crypto::Expr,deps)
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

#Notary(crypto::AbstractString) = Meta.parse(crypto) ### need to implement

### The constructor could be done by the PeaceFounder itself.
struct Deme{T}
    spec::DemeSpec
    notary::Notary
    ledger ### This one is used by peacefounder to construct configuration
end

DemeType(uuid::UUID) = Deme{uuid.value}
DemeType(m::Module) = DemeType(uuid(m))

function Deme(spec::DemeSpec,port)
    notary = Notary(spec)
    ThisDeme = DemeType(spec.peacefounder)
    if port==nothing
        ledger = nothing
    else
        ledger = Ledger(ThisDeme,port)
    end
    ThisDeme(spec,notary,ledger)
end

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
