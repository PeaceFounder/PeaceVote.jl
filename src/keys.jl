### This file contains all functions which are necessary for accessing .peacevote/keys folder. In future it would be great to have a password prtotection so one could do easier backups.

abstract type AbstractSigner end

function save(s,fname) 
    mkpath(dirname(fname))
    serialize(fname,s)
end

struct Member <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

"""
Gives a member key of the community. If does not exist it is generated. It is possible to reffine dispatch in the future with respseect to config file or such. Perhaps with respect to device. 
"""
function Member(community::Community,account)
    fname = keydir(community) * account * "/member"

    if !isfile(fname)
        @info "Creating a new member for the community"
        s = community.Signer()
        save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = community.Signature(data,signer)

    return Member(community.uuid,community.id(signer),sign)
end

Member(community) = Member(community,"")

struct Maintainer <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

"""
Gives key of the community. If does not exist it is generated. It is possible to reffine dispatch in the future with respseect to config file or such. Perhaps with respect to device. 
"""
function Maintainer(community::Community,account)
    fname = keydir(community) * account * "/maintainer"

    if !isfile(fname)
        @info "Creating a new maintainer for the community"
        s = community.Signer()
        save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = community.Signature(data,signer)

    return Maintainer(community.uuid,community.id(signer),sign)
end

Maintainer(community) = Maintainer(community,"")


struct Voter <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

function getnewestvoter(community::Community,account)
    dir = keydir(community) * account 
    
    t = 0
    fname = nothing
    for file in readdir(dir)
        if split(file,"-")[1]=="voter" && t<mtime("$dir/$file")
            fname = file
        end
    end

    return fname
end

function Voter(community::Community,account; new=false)

    fname = getnewestvoter(community,account)
    if fname==nothing || new==true
        @info "Creating a new voter for the community"
        
        s = community.Signer()
        id = community.id(s)
        save(s,keydir(community) * account * "/voter-$id")
    end
    
    fname = getnewestvoter(community,account)
    signer = deserialize(keydir(community) * account * "/$fname")
    sign(data) = community.Signature(data,signer)

    return Voter(community.uuid,community.id(signer),sign)
end

Voter(community; new=false) = Voter(community,"",new=new)
