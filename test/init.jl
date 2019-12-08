using PeaceVote

### We assume that all modules are using the PeaceVote so there should be no problems.

### One should clone in a active environment.
### I could add LOAD_PATH 
### I could address the isssue of stroage after the release of the prototype.
### That similarly must be specified at the init.jl

const CONFIG_DIR = homedir() * "/.peacevote/"

### Latter on I would also could use Pkg
function __init__()
    mkpath(CONFIG_DIR)
    mkpath(CONFIG_DIR * "/keys")
    mkpath(CONFIG_DIR * "/communities")
end

