### Methods for Community

### I already can load existing module with Community.

#using Pkg
# import Pkg: develop
# import Pkg.Types.UUID
# import Pkg.Types.PackageSpec
# import Pkg.Types.Context

# struct Community # {T}
#     uuid::UUID
#     #package::Module
#     daemon::Task
#     config #::T 
# end

### I would just add Member method which initiates from a folder

### This would be useful for unwraping of the envelope or certificate.
### I could pass eval 


# I could avoid of loading a spec with the community as that is something external.
# function Community(uuid::UUID,CONFIG_DIR; daemon=false)
#     # first one checks what uuid
#     #ctx = Context()
#     #@assert uuid in ctx.env.manifest.keys

#     #package = LoadModule.loadmodule(ctx,uuid)

#     if daemon
#         d = package.daemon()
#     else
#         d = @async nothing
#     end
    
#     Community(uuid,package,d,CONFIG_DIR)
# end

# Community(uuid::UUID; daemon=false) = Community(uuid,CONFIG_DIR,daemon=daemon)

# uuid(c::Community) = c.uuid
# keydir(c::Community) = c.config * "/keys/$(uuid(c))/"

# import Base.getproperty

# function Base.getproperty(c::Community,s::Symbol)
    
#     package = getfield(c,:package)

#     if s==:G
#         package.G
#     elseif s==:Signer
#         package.Signer
#     elseif s==:Signature
#         package.Signature
#     elseif s==:id
#         package.id
#     elseif s==:unwrap
#         package.unwrap
#     elseif s==:SecureSocket
#         package.SecureSocket
#     else
#         getfield(c,s)
#     end
# end

