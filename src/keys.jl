### This file contains all functions which are necessary for accessing .peacevote/keys folder. In future it would be great to have a password prtotection so one could do easier backups.


abstract type AbstractSigner end

function save(s,fname) 
    mkpath(dirname(fname))
    serialize(fname,s)
end


struct Signer <: AbstractSigner
    uuid::UUID
    id
    sign::Function
end

function Signer(uuid::UUID,community::Module,account)
    fname = keydir(uuid) * account 
    
    if !isfile(fname)
        @info "Creating a new signer for the community"
        s = community.Signer()
        save(s,fname)
    end
    
    signer = deserialize(fname)
    sign(data) = community.Signature(data,signer)

    return Signer(uuid,community.id(signer),sign)
end

Signer(uuid::UUID,account) = Signer(uuid,community(uuid),account)

#Server(uuid::UUID) = Signer(uuid,"server")
#Maintainer(uuid::UUID) = Signer(uuid,"maintainer")

Member(uuid::UUID,account) = Signer(uuid,account * "/member")
Member(uuid::UUID) = Member(uuid,"")


### The KeyChain part. 

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
