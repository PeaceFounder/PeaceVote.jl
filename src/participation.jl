### All methods which PeaceVote users would use to interact with communities and communitcate.

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
