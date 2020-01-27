### This file contains all functions which are necessary for accessing .peacevote/keys folder. In future it would be great to have a password prtotection so one could do easier backups.


abstract type AbstractSigner end

function save(s,fname) 
    mkpath(dirname(fname))
    serialize(fname,s)
end

# In the end one should be able to also start the server through PeaceVote. 
struct Server <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

"""
Gives a member key of the community. If does not exist it is generated. It is possible to reffine dispatch in the future with respseect to config file or such. Perhaps with respect to device. 
"""
function Server(uuid::UUID,community::Module,account)
    fname = keydir(uuid) * account * "/server"
    
    if !isfile(fname)
        @info "Creating a new server for the community"
        s = community.Signer()
        save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = community.Signature(data,signer)

    return Server(uuid,community.id(signer),sign)
end

Server(uuid::UUID,account) = Server(uuid,community(uuid),account)
Server(uuid::UUID) = Server(uuid,"")


struct Member <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

"""
Gives a member key of the community. If does not exist it is generated. It is possible to reffine dispatch in the future with respseect to config file or such. Perhaps with respect to device. 
"""
function Member(uuid::UUID,community::Module,account)
    fname = keydir(uuid) * account * "/member"

    if !isfile(fname)
        @info "Creating a new member for the community"
        s = community.Signer()
        save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = community.Signature(data,signer)

    return Member(uuid,community.id(signer),sign)
end

Member(uuid::UUID,account) = Member(uuid,community(uuid),account)
Member(uuid::UUID) = Member(uuid,"")

struct Maintainer <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

"""
Gives key of the community. If does not exist it is generated. It is possible to reffine dispatch in the future with respseect to config file or such. Perhaps with respect to device. 
"""
function Maintainer(uuid::UUID,community::Module,account)
    fname = keydir(uuid) * account * "/maintainer"

    if !isfile(fname)
        @info "Creating a new maintainer for the community"
        s = community.Signer()
        save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = community.Signature(data,signer)

    return Maintainer(uuid,community.id(signer),sign)
end

Maintainer(uuid::UUID,account) = Maintainer(uuid,community(uuid),account)
Maintainer(uuid::UUID) = Maintainer(uuid,"")


struct Voter <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

function getnewestvoter(uuid::UUID,account)
    dir = keydir(uuid) * account 
    
    t = 0
    fname = nothing
    for file in readdir(dir)
        if split(file,"-")[1]=="voter" && t<mtime("$dir/$file")
            fname = file
        end
    end

    return fname
end

function Voter(uuid::UUID,community::Module,account; new=false)

    fname = getnewestvoter(uuid,account)
    if fname==nothing || new==true
        @info "Creating a new voter for the community"
        
        s = community.Signer()
        id = community.id(s)
        save(s,keydir(uuid) * account * "/voter-$id")
    end
    
    fname = getnewestvoter(uuid,account)
    signer = deserialize(keydir(uuid) * account * "/$fname")
    sign(data) = community.Signature(data,signer)

    return Voter(uuid,community.id(signer),sign)
end

Voter(uuid::UUID,account;new=false) = Voter(uuid,community(uuid),account,new=new)
Voter(uuid::UUID; new=false) = Voter(uuid,"",new=new)
