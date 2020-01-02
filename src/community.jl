### Methods for Community

### I already can load existing module with Community.

#using Pkg
import Pkg: develop
import Pkg.Types.UUID
import Pkg.Types.PackageSpec
import Pkg.Types.Context

struct Community # {T}
    uuid::UUID
    package::Module
    daemon::Task
    config #::T 
end

### I would just add Member method which initiates from a folder

### Here I also can extend the setup with community initiated from a remote

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
    return @eval $name
end

end

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

addcommunity(spec::PackageSpec) = addcommunity(spec::PackageSpec,CONFIG_DIR)
addcommunity(name) = addcommunity(PackageSpec(name))
addcommunity(;url=nothing) = addcommunity(PackageSpec(url=url))

# I could avoid of loading a spec with the community as that is something external.
function Community(uuid::UUID,CONFIG_DIR; daemon=false)
    # first one checks what uuid
    ctx = Context()
    @assert uuid in ctx.env.manifest.keys

    package = LoadModule.loadmodule(ctx,uuid)

    if daemon
        d = package.daemon()
    else
        d = @async nothing
    end
    
    Community(uuid,package,d,CONFIG_DIR)
end

Community(uuid::UUID; daemon=false) = Community(uuid,CONFIG_DIR,daemon=daemon)

uuid(c::Community) = c.uuid
keydir(c::Community) = c.config * "/keys/$(uuid(c))/"

import Base.getproperty

function Base.getproperty(c::Community,s::Symbol)
    
    package = getfield(c,:package)

    if s==:hash
        package.hash
    elseif s==:G
        package.G
    elseif s==:Signer
        package.Signer
    elseif s==:Signature
        package.Signature
    elseif s==:pubkey
        package.pubkey
    elseif s==:id
        package.id
    elseif s==:verify
        package.verify
    else
        getfield(c,s)
    end
end

