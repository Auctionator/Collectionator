User guide
==========

1. Install the latest version of Auctionator and Collectionator from your addon
   manager.

2. Go to the "Collecting" tab

3. Click the "Scan" button

Updating the recipes data
=========================
Run `./GetRecipesToSpellIDs/do-all.sh` in a `bash` shell with `jq` installed to
update the recipes data

To manually add recipes edit the file
`./Collectionator/Data/RecipesToSpellIDs.lua`. Each entry is of the form
`[recipeID] = spellID`
