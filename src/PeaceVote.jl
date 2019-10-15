module PeaceVote

abstract type Community end
abstract type CommunityServer end
abstract type Proposal end
abstract type GroupCommunication end ### A field of Community
abstract type KeyManager end

# KeyManager.user is username in the chat
# KeyManager.chatkey is authetification necessary to send messages as user
# KeyManager.gitkey is necessary credidentials to update the github repository
# KeyManager.votekey is the anonymous private key which is used for voting
# KeyManager.servers contain list of private keys used to host the votecollecting server.

### Community information

"""
The porcedure of loading in the files a check that the keys are correctly block signed return list of valid public keys.
"""
publickeys(c::Community) = error("Must be implemented by Community")

"""
Load in the proposals which are stored in and take their hash summs for the votes. Return list of proposals.
"""
proposals(c::Community) = error("Must be implemented by Community")

"""
Load the votes checking that each of the votes are signed with a key from a public key ledger and that each vote contains a correct hashsum. Return list of signed messages and public keys.
"""
votes(c::Community,hashsum) = error("Must be implemented by Community")
votes(c::Community,proposal::Proposal) = votes(c,proposal.hash)

"""
Gets all options and returns the result for the count.
"""
countvotes(c::Community,hashsum) = error("Must be implemented by a Community")
countvotes(c::Community,proposal::Proposal) = countvotes(c,proposal.hash)

"""
Gets all options and returns the result for the count as source taking the server database.
"""
countvotes(cs::CommunityServer,hashsum) = error("Must be implemented by a Community")
countvotes(cs::CommunityServer,proposal::Proposal) = countvotes(cs,proposal.hash)

"""
Download all available votes at once check their validity - elligibiality un correctness return the list of votes.
"""
clone(cs::CommunityServer) = error("Must be implemented by a Community")

"""
A process which incrementally keeps local database in sync with Community server. Additionally it checks that no calid votes are removed and resends thoose if that is the case. If that fails publishes the invalid ones in the group. Checks that all votes are being merged for the proposal. In the merge also checks integrity of them with respect to proposal, elligibiality of public keys, and that all votes contain the right hashsum.
"""
mirror(cs::CommunityServer,c::Community) = error("Must be implemented by a Community")


### Maintainter tools

"""
Downloads existing community as a template, changes name and removes data. 
"""
initcommunity(template,name,maintainerid) = error("Not yet implemented by PeaceVote")
initcommunity(template,name,key::KeyManager) = initcommunity(template,name,key.user)

"""
Adds ip address with public key to the repository.
"""
addserver!(c::Community,ip,serverpublickey) = error("Must be implemented by a Community")
addserver!(c::Community,ip,key::KeyManager) = addserver!(c::Community,ip,publickey(key.server[ip]))

"""
Adds proposal to the repository. Maintainer designs the proposal as a .toml file where question and options are being defined.
"""
addproposal!(c::Community,proposal::Proposal) = error("Must be implemented by a Community")


"""
Filters all votes from the database with a hash. Makes a file for git repo with votes/$hash. puts all signed valid votes in there. Adds files to the git. pushes the changes to the remote.
"""
mergevotes!(c::Community,cs::CommunityServer,hash) = error("Must be implemented by a Community")
mergevotes!(c::Community,cs::CommunityServer,proposal::Proposal) = mergevotes!(c,cs,proposal.hash)

"""
Uploads local changes to the remote so everyone could see them. Informs about that over chat or over CommunityServer.
"""
pushchanges(c::Community,gitkey) = error("Must be implemented by a Community")
pushchanges(c::Community,key::KeyManager) = pushchanges(c,key.gitkey)

### Maintainer processes

"""
Waits until 10 members had been collected; Generates a private key; Geerates a public key and publishes that to the voting database signed with maintainer signature; Sends the private key over secret channel to the new memebers; Waits for 10 signed public keys until they appear in the mirror locally; Maintainer signs previous block with the private key and puts the signature in the new block of members; The block of anonymous keys signed with a key is pushed to the repository; Maintainer deletes private key; Maintainer let's us know that the action of merge had been taken over anonymous database again signed with his key.
"""
getanonymouskeys!(c::Community,username,chatkey) = error("Must be implemented by a Community")
getanonymouskeys!(c::Community,key::KeyManager) = getanonymouskeys!(c::Community,key.user,key.chatkey)

"""
Checks if the ip address is in the repo. If not errors. The server which collects the votes anonymously. Generally it does not need to be a server at all.
"""
servedatabase(cs::CommunityServer,serverprivatekey) = error("Must be implemented by a Community")
servedatabase(cs::CommunityServer,key::KeyManager) = servedatabase(cs,key.servers[cs.ip])

### Voting

"""
For now let's connect to HTTP server which accepts all messages and stores them in a file. Tests also if the server had been signed by maintainer (maintainer becomes like a certyfing authority) also tests if the vote can be found in the database from another anonymous ip address.
"""
sendanonymously(cs::CommunityServer,message,signature) = error("Must be implemented by a Community")

"""
Checks if the privatekey can be found in the ledger as a valid publickey. 
"""
checkvotekey(c::Community,votekey) = error("Must be implemented by a Community")
checkvotekey(c::Community,key::KeyManager) = checkvotekey(c,key.votekey)

"""
Asks maintainer over a secure channel for a private key. Generates a private key for vote signing. Generates the public key for vote signing. Signs the vote signinsg public key with maintainers given private key. Uses sendanonymously(message,signature) Waits until maintainer gets all public keys and pushes them to the repository (monitors the database until maintailner had sent the signal)
"""
getvotekey(c::Community,userid,chatkey) = error("Must be implemented by a Community")
getvotekey(c::Community,key::KeyManager) = getvotekey(c,key.user,key.chatkey)

"""
Creates a signature of the message with votingkey and sends that anonymously to the CommunityServer. 
"""
vote(c::CommunityServer,hashsum,message,votekey) = error("Must be implemented by a Community")
vote(c::CommunityServer,hashsum,message,key::KeyManager) = vote(c,hashsum,message,key.votekey)

export publickeys, proposals, votes, countvotes, clone, mirror
export initcommunity, addserver!, addproposal!, mergevotes!, pushchanges
export getanonymouskeys!, servedatabase
export checkvotekey, getvotekey, sendanonymously, vote

end # module
