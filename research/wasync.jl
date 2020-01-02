import Base.sync_varname
import Base.@async

macro _async(expr)
    thunk = esc(:(()->($expr)))
    var = esc(sync_varname)
    quote
        local task = Task($thunk)
        if $(Expr(:isdefined, var))
            push!($var, task)
        end
        schedule(task)
        task
    end
end

macro async(expr)
    quote
        @_async try
            $expr
        catch err
            @warn "error within async" exception=err
        end
    end
end
