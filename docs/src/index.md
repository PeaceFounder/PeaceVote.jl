# PeaceVote.jl a mobile, transparent and anonymous electronic voting solution

It is interesting to observe that the design of PeaceVote voting system does not depend on trustworthy authority. That allows anyone to gather people and make a vote. And even that anyone can be an anonymous person from the group whose responsibility is to initiate voting on proposals and maintain knowledge on how people can vote. It is finally a time where we move away from toothless platforms like "change.org", "manabals.lv" and move towards organized activism, political parties, corporations and symbiosis. Noone shall have the power to tell us on what to vote!

But why would one want to vote when we are powerless? This probably is the question you ask yourself now. Here is the thing. Collectively we are very powerful. Together we can disobey, we can strike, we can boycott, and in doing so, we regain our security in knowing that we are not the only ones. We can collectively fund projects which benefits us working class and our recognition. We can decide together on how to invest for a fulfilling retirement. The profit is not the answer; the wellbeing is. There is a great demand for democracy.

But why then no-one else had entered this market before? Present technology indeed allows making bailouts, but it requires us to have trust in the authority. Everyone expects their solution to be more trustworthy and so we get fragmentation of power. In the end, we face such obscurity in our personal lives to maintain such a variety of technologies, and so we lose our interest. We do not vote; we do not participate in making a change. 

PeaceVote can be different. Firstly, there would be no fragmentation of authority when we consider them all as one. There would be no fragmentation when the cryptographic protocol does not leave a room for better security when it already satisfies all requirements for an honest bailout. There would be no room for fragmentation when the user application would be open-sourced and developed by an open community with the best open-source technology, namely Rust and Julia.

Let's now turn to the main point - how would the implementation of PeaceVote on mobile works. Firstly one needs to establish a community where either all members can physically come together or members can form a secret communication between other members. It is remarkably simple to do that online. And here is the strategy.

First one establishes an online community, for example, a Facebook,  or a Telegram group. The community has it's maintainer could be publically known or anonymous person from the group. He has the power to merge new members to the group, and responsibility to collect valid anonymous signatures. Physically that can be done with bailout box. Remarkably a valid anonymous key can also be delivered online.

In the online situation, the maintainer decides on a public database he wants to use where everyone without authorization can host messages and then see them. Usually, one would want that to be as decentralized as possible to avoid DDOS attacks. 

Then the maintainer generates a private key and then messages that privately for the new members at the same time. A more massive pile of new members means greater anonymity. Also, maintainer publishes the public key for everyone to see and be able to convince themselves that only eligible anonymous public keys are merged. In case of private key leaks, there would be members who would see that their public key is not in the merged list and could protest. The procedure then, is repeated. And the final step is for the users to generate their private keys and deliver signed public keys with the private key maintainer gave anonymously with Tor or another anonymizer. 

So at this point, the anonymous public-key ledger is established. The voting can begin by people signing arbitrary messages and designing arbitrary vote-counting and vote collecting protocols. Usually, however, one would want some order. This is where the community designs and votes on how the maintainer should act in certain situations; what is the procedure to change the maintainer and so on. Thus the maintainer, in the end, is just a servant for the community. That makes PeaceVote design very powerful to fight the tyranny of greed and fear!

## Specs of mobile application

Let's describe the application from the user's perspective for clarity. Firstly, the user applies as a member of the community, for example, a Telegram group who uses PeaceVote for decision making, which is specified in the group metadata. There he can make conversations, discuss stuff publically and also establish a secret communication channel between the members. 

To start voting, the user installs the PeaceVote app from a trusted source. When the user starts the app, he is asked to connect it to Telegram, which he does. After that, the app scans for metadata of the groups to see if they use a PeaceVote for decision making. In the metadata, the app finds where the associated git repository for voting is hosted, where further information could be found and downloads that locally, where it is scanned and checked for integrity.

After that, the application asks for a new set, and it's associated private key from the maintainer. When enough number of people had been in the list to ensure anonymity, the private key is delivered through the secure channel, for example, Telegram. At that point, the application generates the anonymous private key and signs it with the set's private key and delivers that in the same fashion as a vote. Then when maintainer had collected all public keys, he merges them in the repository. The app checks that the key is in the newly merged set and if not proceeds with revealing the identity and the signed public key in the group chat. At that point, the merge would need to be reverted, and the procedure would be repeated.

At this point, the user is capable to vote on the proposals which are happening at that moment within the community. In the application, he/she sees them as in email client with some descriptive information, with voting options and deadline. It could also contain information on the current result for the vote. That would be specified in the particular proposal.

When the user decides on the vote, he oppens the proposal in the app. There he finds the action to vote and puts down his choice. The choice would initiate a signing process with the private key associated with the community. Then the vote would be delivered in a way as specified in `communication.jl`. The app would then follow that the valid votes including his own remain in the public database until the bailout ends and the maintainer merges valid ballots in the git. After that, the votes are downloaded from the repo and counted as specified in `counting.jl` and the result shown next to the proposal.

## The structure of the git repository

The repository has the following tree structure:
```
/ledger
	set1
	set2
	...
/proposals
	proposal1
	proposal2
	...
/votes
	proposal1
	proposal2
	...
/src
	ComunityA.jl
	integrity.jl
	communication.jl
	counting.jl
Manifest.toml
Project.toml
 ```
Let's now break down what each piece does:

      - `/ledger` contains the eligible anonymous public keys which are separated in sets. Sets are the contain list of public keys which were collected by a maintainer with the single private key. The private key is also used to sign the previous block to make the database untampered.
      - `/proposals` contain the information about bailouts which had happened and the bailouts which are happening. Essentially it is like a common mailbox.
      - `/votes` contain results of the bailouts. Each bailout contains a list of signatures made by one of the keys from the anonymous public ledger collected from predefined source and merged by the maintainer. The purpose of it is to be more like a trophy as each device would count the votes from the anonymous communication source themselves.
      - `/src` contains the code which defines how the community is being built. Specifically:
      
            - `integrity.jl` contains code which is necessary to verify that anonymous public key ledger is not tampered. 
            - `communication.jl` establishes a protocol with which to send the vote to bailout box anonymously (like a Tor). And also it establishes the public channel for downloading the votes.
            - `counting.jl` contains the protocol on how votes are counted. Contains logic about expiring public keys, what to do when the user had voted twice, perhaps a second choice protocol, etc. Also, it defines the majority. 

 

