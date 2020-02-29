# A typing force to keep @eval out of your code. 

struct New{T}
    invoke::T
end

unbox(x) = x
unbox(x::New{T}) where T = x.invoke
unbox(args::Tuple) = Tuple(unbox(i) for i in args)

import Base.getindex
getindex(::Type{New},x::Type) = Union{x,New{x}}

f(x::Int,y::Int) = 3

@generated function f(args...)
    @show args
    
    if findfirst(x->x<:New,args)==nothing
        return quote
            error("A method error. Please define what to do for f$args")
        end
    else
        return quote
            return f(unbox(args)...)
        end
    end
end
