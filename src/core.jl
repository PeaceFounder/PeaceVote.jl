function clone(link)
    Pkg.clone(link)
end

### Loading the community in the PeaceVote system

module LoadModule

### Could be reduced in length
function loadmodule(m::Symbol)
    @show expr = :(import $m)
    @eval $expr
    m = @eval $m
    return m
end

end

### The community determines how one should sign the data. One could only pass signer and etc.
# function find_uuid_in_project(name)
#     get(Pkg.Types.EnvCache().project["deps"], name, nothing)
# end

struct Community{T}
    m::Module
    daemon::Task
    config::T # AbstractString, SmartCard, ... # That is actually a place where one could store other stuff for the community. 
    memeber::Function
    voter::Function
    maintainer::Function
end

function iskey(c::Community{T},key::Symbol) where T<:AbstractString
    mname = fullname(c.m)[1] # That gives the Symbol name of the Module
    CONFIG_DIR = c.config
    fname = "$CONFIG_DIR/keys/$mname/$key"
    isfile(fname)
end

function storekey(c::Community{T},key::Symbol,signer) where T<:AbstractString
    mname = fullname(c.m)[1] # That gives the Symbol name of the Module
    CONFIG_DIR = c.config
    fname = "$CONFIG_DIR/keys/$mname/$key"
    if isfile(fname)
        error("Key $fname already exists.")
    else
        keyfile = open(fname,"w")
        serialize(keyfile,signer)
    end
end

function getsign(m::Module,CONFIG_DIR::AbstractString,key::Symbol)
    hash = m.hash ### Function which works on any date
    mname = fullname(m)[1] # That gives the Symbol name of the Module
    
    # If key is a votekey then one gets the newest one.
    fname = "$CONFIG_DIR/keys/$mname/$key"
    if isfile(fname)
        keyfile = open(fname)
        signer = deserialize(keyfile)
        sign(x) = DSASignature(hash(x),signer)
    else
        sign(x) = error("$key not found for $mname.")
    end
    
    return sign
end

### If one has a smartcard then one could do
# Community(m::Symbol,sm::SmartCard) = ...

function Community(m::Symbol,CONFIG_DIR::AbstractString) 
    ### One could check also what methods are implemented to give user representation of what features are supported!
    m_ = LoadModule.loadmodule(m)
    ### One could also load the keys
    memeber(x) = getsign(m_,CONFIG_DIR,:memeber)(x)
    voter(x) = getsign(m_,CONFIG_DIR,:voter)(x)
    maintainer(x) = getsign(m_,CONFIG_DIR,:maintainer)(x)

    daemon = m_.daemon()
    return Community(m_,daemon,CONFIG_DIR,memeber,voter,maintainer)
end

### The registration procedure with in the community

abstract type AbstractID end

struct ID <: AbstractID
    name
    date # of birth
    pubkeyid # The id of the public key. One uses the hash function from the Community.
end

function pubkeyid(signer::AbstractSigner,c::Community)
    hash = c.m.hash
    pubkey = signer.pubkey
    pubkeyid = hash(pubkey)
    return pubkeyid
end

struct Certificate
    id::AbstractID
    signature::AbstractSignature
end

pubkeyid(c::Certificate) = c.id.pubkeyid

function Certificate(id::AbstractID,signature::AbstractString)
    io = IOBuffer(signature)
    s = deserialize(io)
    Certificate(id,s)
end

import Base.String
function String(id::Union{ID,DSASignature})
    io = IOBuffer()
    serialize(io,id)
    String(take!(io))
end

function certify(id::AbstractID,c::Community)
    @info id
    str = String(id)
    return String(c.member(str))
end

function certify(idstr::AbstractString,c::Community)
    io = IOBuffer(idstr)
    id = deserialize(io)
    certify(id,c)
end

### All theese methods currently assume that community also specifies where are the server for simplicity.

function register(community::Community{T},certificate::Certificate) where T<:AbstractString
    CONFIG_DIR = community.config
    if iskey(community,:member)
        mname = fullname(community.m)[1] 
        fname = "$CONFIG_DIR/keys/$mname/member"
        keyfile = open(fname)
        signer = deserialize(keyfile)

        @assert pubkeyid(certificate) == pubkeyid(signer,community)
    else
        error("The idkey had not been found.")
    end
    
    res = community.m.register(certificate)
    
    if res==true
        @info "Registration of the key had been succesfull"
    else
        error("Unsucessfull registration. $res")
    end
end

### Now I need to make an interface for registrating voters key

# using PeaceVote.Traits

function braidkey(community::Community,sign::Function)
    G = community.m.G
    signer = Signer(G)
    pid = pubkeyid(signer,community)
    res = community.m.braidkey(pid,sign) ### Depending on the signature pubkeyid server would say which gates to take.
    if res==true
        storekey(community,:voter,signer)
    else
        error("Unsuccesfull braiding. $res")
    end
end

function braidkey(community::Community)
    if iskey(community,:voter) ### voter key is only added if 
        braidkey(community,community.voter)
    elseif iskey(community,:member)
        braidkey(community,community.member)
    else
        error("No keys found for the community.")
    end
end

### Now the last thing is just a function for vote

function vote(msg,community::Community)
    signature = community.voter(msg)
    community.m.vote(msg,signature)
end
