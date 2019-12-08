using PeaceVote

# 1. Load a community from a remote git address
# 2. Load trusted certification authorities. (not yet implemented in Community and Peacevote)
# 3. Generate member keypair and store that with the name of community hash of public key. (ToDo)
# 4. Create ID of the member. 
# 5. Convert ID to a string and send that to the certifying authority of choice.
# 6. Certifying authority signs the ID and sends back a signature in a string form.
# 7. The potential member constructs the certificate and sends that to the community with register method.
# 8. The member braids the key.
# 9. N other members are created with the same procedure
# 10. The memeber votes with his message. 
