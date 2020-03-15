var documenterSearchIndex = {"docs":
[{"location":"#The-PeaceFounder's-project-1","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Online voting systems had been active research problem since the discovery of asymmetric cryptography. However, none to my knowledge is trustworthy. It is easy to imagine a software-independent system where anonymity is disregarded by having a public ledger to which one submits their signed votes. But the anonymity is essential to the integrity of elections! Or one imagines a software which is perfect and so preserves anonymity while being secure. However, what if a villain takes over the server and replaces the software with its own?","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"There are many metrics which had been introduced for measuring the trustworthiness of the electronic voting system. I propose to group them into three categories - transparency, security and anonymity. Which are easy to remember through existing technologies:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"security + anonymity: Trust the system X doing Y. Most electronic voting systems fit into this category, for example, the Estonian system. Their Achilles heel is the software dependance.\nsecurity + transparency: Trust the voter X being independent of Y. Such a voting system makes sense when X is representative of Y. However, for ordinary citizens, this is inappropriate as that enables easy coercion, shaming and bribery. \ntransparency + anonymity: Trust X not doing Y. These are all voting systems to which you can authorize with anonymous means. The best example would be a privately generated bitcoin by a PoW which acts as a token for a vote to be transferred to an account A, B and C representing a choice.","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"More specifically, I propose to fix the definitions for anonymity, transparency and security as follows:","category":"page"},{"location":"#Transparency:-1","page":"The PeaceFounder's project","title":"Transparency:","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Open source and open participation\nSoftware independence. If someone hacks in the system and replaces that with his own, he shall not be able to change an election outcome without being detected. (I apply this notion here as that the collected data would not change, so it does not overlap with verifiability.)\nIndividual verifiability. See proof how you voted and that you were counted.\nUniversal verifiability. Fairness and accurateness can be proved from publically available data.","category":"page"},{"location":"#Security:-1","page":"The PeaceFounder's project","title":"Security:","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Legitimacy. All participating members are real and verified. \nAccountabilty. Misbehaving individuals can be isolated. \nTamper resitant. The publically available data can not be tampered with to change the election outcome. (cryptographically secure)\nNo single attackable entity (phone, server, cryptographic protocol, ....) which can significantly change the election outcome. (There is always a possibility of malware. I assume that it is a minority and the detection and prevention of that is the Vendor's responsibility whose reputation would be at stake.)","category":"page"},{"location":"#Anonymity:-1","page":"The PeaceFounder's project","title":"Anonymity:","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Privacy: Noone knows how you voted without your cooperation.\nSecrecy: You can not prove how you voted for another person, even with your cooperation, also known as receipt freeness and secret ballot. I don't use those definitions because the voting system can have a receipt, but it might not be the only one. The voter might have a secret!","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Secrecy can be implemented with software by giving the citizen a choice to vote in a traditional voting ceremony which would override the online voting receipt while not revealing whether he/she did so to the public. In such a case, the system needs a trusted auditor who produces a compensated tally. It seems reasonable to assume that the secret ballot would be much smaller than a public (not open) ballot thus universal verifiability would still hold approximatelly. However, before, that is reasonable to implement one needs to prevent such a simple thing as identity selling which one could achieve with hardware (see the PeaceCard project). ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The focus thus for PeaceVote is voluntarily democracies. It is the democracies of communities where members get engaged by making a significant change in their surroundings and so would want to protect their democracy. The privacy would make decisions less group biased and more thoughtful by individuals themselves for the community. The democracy could also be a great tool to unite audiences of two opposing divisions of the society by giving them the ability to delegate representatives for a discussion.  The system is also useful for anonymous questionnaires where the minority members do not feel safe to be publically known. Or for whistleblowers who do feel that their integrity had been intact. The last part is essential to punish those members who are documented to sell their votes on the field or sell their representative power within the community. ","category":"page"},{"location":"#The-design-of-PeaceVote-1","page":"The PeaceFounder's project","title":"The design of PeaceVote","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The design of PeaceVote voting system as basis uses a thought experiment. Imagine that you go to elections, register with a gatekeeper and enter the ballot cabin with the envelope. Now instead of selecting candidates, you put in a public key which you have generated in secret and put the envelope in that ballot box. The keys public keys collected that way would have a great property: anonymity and legitimacy. Those keys then allow doing anonymous, transparent and secure electronic voting.  ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"But of course, life is not simple, and no one would try to explain to an ordinary person what the public key is and how to securely generate that. Instead, we need to have an electronic voting system to get anonymous keys for electronic voting. Right, that is a tautology. Can we do better?","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Let's consider an electronic ballot server which does have some reason of trust, is secure and anonymous by design. Multiple people would participate and would form a ballot. The server would randomize the ballot and publish that. Since the server is like a black box is there anything else what we can do to increase the trust of the result? In the end, we do not want to lose the ability to vote.","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"We can validate ballot! Every participating member must sign the ballot to confirm that his newly generated key is there. If everyone signs the ballot, we form a braid which connects old input keys with new output keys. In this way, we for sure, know that the system is secure. Whereas the anonymity of new keys is guaranteed by having trust in the system and depends on the ballot protocol used.  However, there is a pressing issue with such a design. What if a participating member refuses to sign the ballot? Shall we consider him a victim or a villain? Since the relation between input and output is lost, we can not give any knowledge on the issue. Such an electronic voting system is simply not accountable and scales badly as we increase the number of participants.","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The idea I am proposing is to do multiple small ballots, which we can retry quickly in case a participant refuses to sign the ballot, and chain them together to braid anonymity. This is the idea of the BraidChain which firstly allows scaling of unaccountable voting systems and secondly offers a natural extension for distributing the trust of anonymity over multiple participating ballot servers. Thus, in the end, we obtain the list of anonymous and legitimate keys which allows us to do secure, anonymous and transparent electronic voting. ","category":"page"},{"location":"#How-to-use-PeaceVote-1","page":"The PeaceFounder's project","title":"How to use PeaceVote","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"There is an infinite variation in which one could make the voting system I described above from cryptographic protocols to a policy how new members are accepted and how votes are counted - quadratically, cumulatively or as in liquid democracy. A nightmare for the programmer to offer all these variations in a single package and a nightmare for the community. This is why PeaceVote is modular, and each community maintains the module which defines how to register, braid and vote. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"One such community is Community.jl which we add as an ordinary package:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"using Pkg\nPkg.add(\"Community.jl\")","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"which good to know we get securely with the help of certified authority certificates and Diffie-Hellman key exchange. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Let's assume that the Community server is running so I could walk through the user perspective. The user does the following thing to start using the community:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"using PeaceVote\nsetnamespace(@__MODULE__)\nimport Community","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The setnamespace method allows the PeaceVote module to see the imported modules in the present namespace. This allows PeaceVote to be as small as possible for the junction work it does while also offering higher-order abstractions, for example, to make module containerized.  Currently, when one imports any community, one trusts that the code will not steal the keys and send them over the network.","category":"page"},{"location":"#Passive-exploration-1","page":"The PeaceFounder's project","title":"Passive exploration","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"First, we can explore community passively. For doing that we need to get UUID of the Community, which in this case happens to be:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"uuid = PeaceVote.uuid(\"Community\")","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Then we can get a handle for the community module with community method which tries to access already loaded module from the namespace:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"com = community(uuid)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"which returns the community module and informs the user whether PeaceVote Community API is supported. Internally community is used to unwrap signed data from other communities; thus UUID felt like a right handle. The com variable now holds the community module (which incidentally happens to be Community), and now one can investigate the community. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The first thing we do is to synchronize the community data with us locally:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"PeaceVote.sync(uuid)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"which will download the ledger locally by the community specified method in the folder PeaceVote.datadir(uuid). ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"When all data is downloaded, we can start to investigate the BraidChain by first loading it:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"braidchain = PeaceVote.braidchain(uuid)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"This loads all data associated with the community, cryptographically verify that it is correct and return a list of messages containing information which let new members inside the community, braids, proposals, and votes in the order which they were registered.   ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The braidchain elements are standardized by PeaceVote to enable uniform postprocessing. For example, we may ask the question of the set of participating member public keys. That we can easily get with PeaceVote.members(braidchain); a current list of anonymous identities PeaceVote.voters(braidchain); a set of all voters PeaceVote.allvoters(braidchain); and significantly a set of all proposals in the system PeaceVote.proposals(braidchain), let's explore those further.","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"A proposal is an item in the ledger which is included in the ledger by policies laid out by the community. (In one case one may want a community where every member is allowed to submit their proposal in another case only community elected representatives are allowed to submit the proposals.) The proposal contains the message of the proposal proposal.msg and options proposal.options which is simply a list of choices. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The set of voters eligible to vote on the proposal is defined as the current list of anonymous identities at the time when the proposal was added to the ledger. Let's assume that we have a proposal::Proposal. To obtain the list of eligible voters, we can use ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"PeaceVote.voters(braidchain, proposal)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"which is also essential for counting the votes as well. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The last part we shall discuss of passive analysis of braidchain is counting. Each community is expected to use its own counting method for the votes. For example, the community may choose ordinary, cumulative, quadratic or preferential voting or even supporting multiple ways indicating that in the voting message. To obtain the tally for the proposal::Proposal one does:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"PeaceVote.count(uuid, proposal, braidchain)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Returning a number for every option provided by the proposal. ","category":"page"},{"location":"#Participation-1","page":"The PeaceFounder's project","title":"Participation","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Let's say that we are interested in taking part in the community. How can we do that? First, we need to generate a private and public key pair:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"member = PeaceVote.Member(uuid)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"This loads a community with community(uuid) method, and from the community load a Signer() method and finally stores the key at PeaceVote.keydir(uuid). If the key is already generated, then it is just loaded from the disk. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The next important step is to register the member.id with the community.  From the community perspective, the most pressing issue is whether they can prove that a new member is a real person. In an ideal world, each of us would have a state-issued ID card where identities would be published in a publically accessible ledger. Then one would just be able to sign the key which then the community would be able to accept from a legitimacy point of view. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Unfortunately, we are not living in such a world. What we can do, however, is having a certifying authority which verifies your identity and signs your key on such a basis. Such a certifying authority can be an algorithm which gives a certificate of your identity derived from your FaceBook, Twitter, GitHub, etc. identities. Or it can be an actual person who verifies you in person or over a conversation online. Or it can be you signing the key by already certified key. In the end, how new members are approved is up to the community itself who specifies Web of Trust. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"PeaceVote models this process as follows. The potential member first creates his identity:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"identification = PeaceVote.ID(\"name\", \"date\", meber.id)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"He/She then send that to a certifying authority who approves signs that and so creates a certificate:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"certificate = PeaceVote.Certificate(identification,authority)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Because the authority could come from a different community and so use a different set of cryptographic protocols the UUID is encoded in the certificate additionally with ID. One can then verify the correctness of the signature with PeaceVote.unwrap(certificate). After the certificate had been obtained, one can register and so become a member of the community:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"PeaceVote.register(uuid,certificate)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"When we are registered, the next important step is to braid for anonymity. To do so, one creates a KeyChain which name implies contains a chain of keys for the community:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"keychain = PeaceVote.KeyChain(uuid)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The keychain contains a keychain.member and keychain.signers and keychain.uuid. The signers are all anonymous identities in chronological order. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The braiding can be executed as follows:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"PeaceVote.braid!(keychain)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"During the execution of this command, the community is loaded from UUID, a new signer is generated and the braiding procedure is executed. If it is successful, the key is not removed from the storage, and a key is added to the list of signers. This procedure can be repeated as often as one wishes until sufficient anonymity is braided. ","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"The last part of participation essentials is voting. To do so one gets picks a proposal from the BraidChain and makes a choice by creating an Option message:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"option = PeaceVote.Option(proposal, 2)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"which means that we have chosen proposal.options[2]. Then the last step is to deliver the vote with the right voting key, which can be done as follows:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"PeaceVote.vote(option,keychain)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Some of the members (or all) would be eligible to make a voting proposition. That they can do simply with a command:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"PeaceVote.propose(\"Found peace for a change?\", [\"yes, \"no\", \"maybe\"], member)","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"which will deliver the proposal to the community (encoded in member.uuid) server(s) and perform the vote. ","category":"page"},{"location":"#How-to-set-it-up?-1","page":"The PeaceFounder's project","title":"How to set it up?","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"To enable the use of PeaceVote, the community needs to support an extensive API. The list of methods and variables which must be a part of the community is as follows:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"# For analysis\nsync\nbraidchain\ncount\n\n# For participation\nSigner \nSignature \nverify ### verifies signature with respect to data\nid ### method for the Signer and for the Signature\nregister\nbraid\nvote\n\n# For intercommunity communication\nG\nSecureSocket\nhash","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"Currently id and verify appears at very much at the same places. In future id will be deprecated in favour of verify which returns id if signature is valid and nothing otherwise.","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"For an example of the community see Community.jl, and for convenience, methods see PeaceFounder.jl package. But mainly it is up to you to build the voting tool you need for the community whereas PeaceVote helps your community to be more accessible, distributed and transparent.","category":"page"},{"location":"#References-1","page":"The PeaceFounder's project","title":"References","text":"","category":"section"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"After I finalized the design and found it trustworthy from my perspective, I tried to research shit of existing systems, the values and general criticisms of electronic voting. For example, I discovered that SynchronicBallot.jl which is the system I developed as part of functional Community.jl turns out is not very novel as it is a mixnet combined with kind of a blind signature scheme and was remarkably used to my surprise for Bitcoin in part of CoinJoin project and derivatives. Perhaps my contribution here was an extra validation step, but I don't know for sure. These are, in my opinion, the most important references I have found so far about electronic voting:","category":"page"},{"location":"#","page":"The PeaceFounder's project","title":"The PeaceFounder's project","text":"https://www.youtube.com/watch?v=LkH2r-sNjQs\nhttps://www.youtube.com/watch?v=abQCqIbBBeM&feature=emb_title\nhttps://en.wikipedia.org/wiki/Software_independence\nhttps://en.bitcoin.it/wiki/CoinJoin\nhttps://arxiv.org/pdf/1707.08619.pdf\nhttps://usvotefoundation-drupal.s3.amazonaws.com/prod/E2EVIVfullreport.pdf\nhttps://www.nap.edu/catalog/25120/securing-the-vote-protecting-american-democracy [section about blockchain]","category":"page"}]
}
