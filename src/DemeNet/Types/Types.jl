module Types

using Base: UUID

using Pkg.Types: Context
uuid(ctx::Context,name::AbstractString) = ctx.env.project.deps[name]
uuid(ctx::Context,name::Symbol) = uuid(ctx,String(name))
uuid(ctx::Context,name::Module) = uuid(ctx,nameof(name))
uuid(name::Union{Module,Symbol,AbstractString}) = uuid(Context(),name)

const CONFIG_DIR = homedir() * "/.demenet/"

function setconfigdir(dir::String)
    global CONFIG_DIR = dir
end

demefile(uuid::UUID) = CONFIG_DIR * "/demes/$uuid"
keydir(uuid::UUID) = CONFIG_DIR * "/keys/$uuid/"
datadir(uuid::UUID) = CONFIG_DIR * "/data/$uuid/"
#datadir(uuid::UUID,app::AbstractString) = CONFIG_DIR * "/apps/$app/$uuid/"

abstract type AbstractID end

struct ID
    id::Union{BigInt,Nothing}
end

function Base.string(id::ID; length=nothing, kwargs...) 
    str = string(id.id; kwargs...)
    if length!=nothing
        len = Base.length(str)
        @assert len<=length
        pre = "0"^(length-len)        
    else
        pre = ""
    end
    return "$pre$str"
end

ID(str::AbstractString; kwargs...) = ID(parse(BigInt,str; kwargs...))

import Base.Vector

Vector{UInt8}(id::ID; kwargs...) = Vector{UInt8}(string(id; kwargs...))
ID(bytes::Vector{UInt8}; kwargs...) = ID(String(copy(bytes)); kwargs...)

Base.:(==)(a::ID,b::ID) = a.id==b.id
Base.hash(a::ID,h::UInt) = hash(a.id,hash(:ID,h))
Base.in(a::ID,b::ID) = a==b

struct DemeID 
    uuid::UUID
    id::ID
end

DemeID(uuid::UUID,id::BigInt) = DemeID(uuid,ID(id))

Base.:(==)(a::DemeID,b::DemeID) = a.uuid==b.uuid && a.id==b.id
Base.hash(a::DemeID,h::UInt) = hash(a.id,hash(a.uuid,hash(:DemeID, h)))

# Do I need a base hash also here? 

Base.in(a::DemeID,b::DemeID) = a==b

### The Notary and Cypher could actually be defined with package where the implementation sits in. I could introduce AbstractNotary, AbstractCypher and just add a constructor CypherSuite{UUID}(AbstractNotary) to give me the right definition.


### Could have multiple signatures as one wishes

end
