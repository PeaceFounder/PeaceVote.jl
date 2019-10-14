module PeaceVote

abstract type Community end

### Let's write a community specific code first!!!

#repo = "CommunityA"

# type CommunityA
#     publickeys
#     proposals
#     votes
# end

### Repository information

function publickeys()
    publickeys = "$repo/ledger"
    # The porcedure of loading in the files
    # a check that the keys are correctly block signed
    # return list of valid public keys
end

function proposals()
    proposals = "$repo/proposals"
    # load in the proposals which are stored in and take their hash summs for the votes.
    # return list of proposals
end

function votes(hashsum)
    votedir = "$repo/votes/$hashsum/"
    # load the votes checking that each of the votes are signed with a key from a public key ledger and that each vote contains a correct hashsum
    # return list of signed messages and public keys.
end

function count(hashsum)
    list = votes(repo,hashsum)
    options = []
    # for simplicity for a short moment let's assume that person can vote only once.
    # get all options from votes and the count
    # return that
end

### Database tools

function sendanonymously(message,signature)
    # for now let's connect to HTTP server which accepts all messages and stores them in a file
    # Tests also if the server had been signed by maintainer (maintainer becomes like a certyfing authority)
    # also tests if the vote can be found in the database from another anonymous ip address.
end

function getanonymousdatabase()
    # download all available votes at once
    # check their validity - elligibiality un correctness
    # return the list of votes
end

function mirrordatabase()
    # Keeps the database locally
    # Chekcs that no valid votes are removed
    # Resends thoose if that is the case
    # If that fails publishes the invalid ones in the group.
    # Checks that all votes are being merged for the proposal.
    # In the merge also checks integrity of them with respect to proposal, elligibiality of public keys, and that all votes contain the right hashsum.
end

### Sign up or in

function signin(privatekey)
    # Generates a publickey
    # Checks if that can be found in the public key ledger
    # returns true if that is the case.
end

function signup()
    # Asks maintainer over a secure channel for a private key
    # Generates a private key for vote signing
    # Generates the public key for vote signing
    # Signs the vote signinsg public key with maintainers given private key
    # Uses sendanonymously(message,signature)
    # Waits until maintainer gets all public keys and pushes them to the repository (monitors the database until maintailner had sent the signal)
end

### Voting

function vote(hashsum,message,privatekey)
    textmessage = "$hashsum $message"
    signature = encrypt(hash(textmessage),privatekey)
    sendanonymously(message,signature)
    ### Let's consider the system free of storage
    return message, signature
end

### Maintainer tools

function mergevotes(hash,maintainerkey)
    # Filters all votes from the database with a hash
    # makes a file for git repo with votes/$hash 
    # puts all signed valid votes in there
    # adds files to the git
    # pushes the changes to the remote
end

function mergeproposal(proposal,maintainerkey)
    # Maintainer designs the proposal as a .toml file where question and options are being defined
    # pushes that to the repository
end

### This is part of PeaceVote
function initcommunity(template,name,maintainerkey)
    # Creates the folder structure according to template
    # Puts in a public key for the maintainer
end

# A process
function getanonymouskeys(maintainerkey)
    # Waits until 10 members had been collected
    # Generates a private key
    # Geerates a public key and publishes that to the voting database signed with maintainer signature
    # Sends the private key over secret channel to the new memebers.
    # Waits for 10 signed public keys until they appear in the mirror locally
    # Maintainer signs previous block with the private key and puts the signature in the new block of members
    # The block of anonymous keys signed with a key is pushed to the repository
    # Maintainer deletes private key
    # Maintainer let's us know that the action of merge had been taken over anonymous database again signed with his key.
end

function servedatabase(privatekey)
    # Checks if the ip address is in the repo
    # If not errors
    # The server which collects the votes anonymously.
    # Generally it does not need to be a server at all.
end

end # module
