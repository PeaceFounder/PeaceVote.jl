module PeaceVote

import Serialization: serialize, deserialize

#import Pkg
using Pkg.Types: UUID, Context

#import Pkg.Types.Context
#import Pkg.Types.UUID


const CONFIG_DIR = homedir() * "/.peacevote/"
keydir(uuid::UUID) = CONFIG_DIR * "/keys/$uuid/"
datadir(uuid::UUID) = CONFIG_DIR * "/data/$uuid/"
communitydir(uuid::UUID) = CONFIG_DIR * "/communities/$uuid/"

NAMESPACE = PeaceVote

function setnamespace(m::Module)
    global NAMESPACE = m
end

function setconfigdir(dir::String)
    global CONFIG_DIR = dir
end

# function __init__()
#     mkpath(CONFIG_DIR)
# end

function communityinfo(m::Module)
    properties = propertynames(m)
    api = [:G, :hash, :Signer, :Signature, :id, :unwrap, :register, :braid, :vote, :braidchain]
    #@info "Verifying API of the community module"
    for method in api
        method in properties || @warn "$method is not part of $m."
    end
end

function community(name::Symbol; info=true) ### I could write a test for this one.
    community = Base.eval(NAMESPACE,name)
    info && communityinfo(community)
    return community
end

function community(uuid::UUID; info=true)
    ctx = Context()
    @assert uuid in ctx.env.manifest.keys "The community module is not imported in $NAMESPACE"
    name = Symbol(ctx.env.manifest[uuid].name)
    return community(name, info)
end

function uuid(name::AbstractString)
    ctx = Context()
    return ctx.env.project.deps[name]
end

include("keys.jl")
include("envelopes.jl")
include("braidchain.jl")

export community, setnamespace

end # module
