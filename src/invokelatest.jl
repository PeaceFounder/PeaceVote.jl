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

# It is important to 
# @generated function Signer(args...)
#     if findfirst(x->x<:New,args)==nothing
#         return quote
#             error("A method error. Please define what to do for Signer$args")
#         end
#     else
#         return quote
#             return invokelatest(Signer,unbox(args)...)
#         end
#     end
# end

# @generated function KeyChain(args...)
#     if findfirst(x->x<:New,args)==nothing
#         return quote
#             error("A method error. Please define what to do for KeyChain$args")
#         end
#     else
#         return quote
#             return invokelatest(KeyChain,unbox(args)...)
#         end
#     end
# end

