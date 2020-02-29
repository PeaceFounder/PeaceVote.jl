# A little bit crazy implementation of Notaries. In future there could be a standart for cryptographic methods which would not require to use eval. That would be achieved in a module level with singleton types. Something like Notary(::Type{ThisCrypto},spec::Symbol) where ThisCrypto is a subtype of Crypto{T} where T is uuid of the package.


import Base.invokelatest
import Base.UUID

struct New{T}
    invoke::T
end

unbox(x) = x
unbox(x::New{T}) where T = x.invoke
unbox(args::Tuple) = Tuple(unbox(i) for i in args)

import Base.getindex
getindex(::Type{New},x::Type) = Union{x,New{x}}

module SandBox end

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

function Notary(deps::Vector{UUID},crypto::Expr)
    importdeps(SandBox,deps)
    
    expr = quote
        let
            $crypto
        end
    end

    spec = Base.eval(SandBox,expr)
    return New(Notary(spec...))
end

Notary(deps::Vector{Symbol},crypto::Expr) = Notary(UUID[uuid(dep) for dep in deps],crypto)

### Now paying the price of eval 

Deme(spec::DemeSpec,notary::New{Notary},port) = New(Deme(spec,notary.invoke,port))

Signer(uuid::UUID,notary::New{Notary},account::AbstractString) = New(invokelatest(notary->Signer(uuid,notary,account),notary.invoke)::Signer)

Signer(deme::New{Deme{T}},account::AbstractString) where T = New(Signer(deme.invoke.spec.uuid,deme.invoke.notary,account))

KeyChain(deme::New{Deme},account::AbstractString) = New(invokelatest(deme->KeyChain(deme,account),deme.invoke)::KeyChain)

KeyChain(deme::New{Deme}) = KeyChain(deme,"")

### The methods now also need to support theese New types

### A manual generation of methods

# ### I could make a macro for this
# for method in [:braid!, :register, :vote, :propose, :braidchain, :count]
#     @eval begin
#         @generated function $method(args...)
#             if findfirst(x->x<:New,args)==nothing
#                 return quote
#                     error("A method error. Please define what to do for $method $args")
#                 end
#             else
#                 return quote
#                     return invokelatest($(esc($method)),unbox(args)...)
#                 end
#             end
#         end
#     end
# end

### Theese methods have the similarity that they all are methods of Notary and derived types.

@generated function braid!(args...)
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for braid!$args")
        end
    else
        return quote
            return invokelatest(braid!,unbox(args)...)
        end
    end
end


@generated function register(args...)
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for register$args")
        end
    else
        return quote
            return invokelatest(register,unbox(args)...)
        end
    end
end


@generated function vote(args...)
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for vote$args")
        end
    else
        return quote
            return invokelatest(vote,unbox(args)...)
        end
    end
end


@generated function propose(args...)
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for propose$args")
        end
    else
        return quote
            return invokelatest(propose,unbox(args)...)
        end
    end
end


@generated function braidchain(args...)
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for braidchain$args")
        end
    else
        return quote
            return invokelatest(braidchain,unbox(args)...)
        end
    end
end

@generated function count(args...)
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for braidchain$args")
        end
    else
        return quote
            return invokelatest(count,unbox(args)...)
        end
    end
end

### This method does not need invokelatest to succeed
@generated function sync!(args...)
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for braidchain$args")
        end
    else
        return quote
            #return invokelatest(sync!,unbox(args)...)
            return sync!(unbox(args)...)
        end
    end
end

@generated function DemeSpec(args...)
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for DemeSpec$args")
        end
    else
        return quote
            return invokelatest(DemeSpec,unbox(args)...)
        end
    end
end
