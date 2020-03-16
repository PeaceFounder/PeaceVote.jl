### This file contains all functions which are necessary for accessing .peacevote/keys folder. In future it would be great to have a password prtotection so one could do easier backups.

using Pkg.TOML

function _save(s,fname) 
    mkpath(dirname(fname))
    dict = Dict(s)
    open(fname, "w") do io
        TOML.print(io, dict)
    end
end

function Signer(uuid::UUID,notary::Notary,account::AbstractString)
    fname = keydir(uuid) * account 
    
    if !isfile(fname)
        @info "Creating a new signer for the community"
        s = notary.Signer()
        _save(s,fname)
    end

    dict = TOML.parsefile(fname)
    signer = notary.Signer(dict)
    sign(data) = notary.Signature(data,signer)

    test = "A test message."
    signature = sign(test)
    id = notary.verify(test,signature)

    @assert id!=nothing

    return Signer(uuid,id,sign)
end

Signer(uuid::UUID,account::AbstractString) = Signer(uuid,Notary(DemeSpec(uuid)),account)
Signer(deme::Deme,account::AbstractString) = Signer(deme.spec.uuid,deme.notary,account)

# sign(data::AbstractString,signer::Signer) = signer.sign(data)

### The KeyChain part. 

function KeyChain(deme::Deme,account::AbstractString)
    uuid = deme.spec.uuid
    notary = deme.notary

    member = Signer(uuid,notary,account * "/member")
    voterdir = keydir(uuid) * account * "/voters/"
    mkpath(voterdir)

    t = []
    voters = Signer[]
    for file in readdir(voterdir)
        voter = Signer(uuid,notary,account * "/voters/$file")
        push!(t,mtime("$voterdir/$file"))
        push!(voters,voter)
    end

    if length(voters) > 0 
        voters=voters[sortperm(t)]
    end

    return KeyChain(deme,account,member,voters)
end

### I could actually define a constructor for New so it would construct the type.

#KeyChain(deme::Deme,account::AbstractString) = KeyChain(deme.spec.uuid,deme.notary,account)
KeyChain(deme::Deme) = KeyChain(deme,"")

    #com = community(member.uuid)
    #com.propose(msg, options, member)


