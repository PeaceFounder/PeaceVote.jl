module LoadModule

# Currently, it is possible for community code to access everything on the system and thus it can easally steal the keys. Ideally it would be cool if the modules could be loaded with some sort of restricted namespace which could access only given folders on the system. But that seems unlikelly to be a focus of julia developers. Instead one could try to start a julia process in the container which does not have a filesystem access at all (except read only access to the community data) and then connect it over a socket and make a wrapper for restriction. Also worth exploring Cassete.jl

### Could be reduced in length
# function loadmodule(m::Symbol)
#     expr = :(import $m)
#     @eval $expr
#     m = @eval $m
#     return m
# end

import Pkg.Types.UUID
import Pkg.Types.Context

function loadmodule(ctx::Context,uuid::UUID)
    name = Symbol(ctx.env.manifest[uuid].name)
    expr = :(import $name) 
    @eval $expr
    #return @eval $name
end

end

import Pkg.Types.UUID
importcommunity(uuid::UUID) = LoadModule.loadmodule(Context(),uuid)


addcommunity(spec::PackageSpec) = addcommunity(spec::PackageSpec,CONFIG_DIR)
addcommunity(name) = addcommunity(PackageSpec(name))
addcommunity(;url=nothing) = addcommunity(PackageSpec(url=url))


### Would be usefull for setting up the system for the developer
function uuid(name::AbstractString)
    ctx = Context()
    return ctx.env.project.deps[name]
end

function adduuid!(spec::PackageSpec)
    name = basename(spec.repo.url)[1:end-3]
    spec.uuid = uuid(name)
end

# The question however how does 

function addcommunity(spec::PackageSpec,CONFIG_DIR)
    mkpath(CONFIG_DIR * "/communities/")
    withenv("JULIA_PKG_DEVDIR" => CONFIG_DIR * "/communities/") do     # Good enough for the prototype
        Pkg.develop(spec)
    end
end
