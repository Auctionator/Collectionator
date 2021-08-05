mkdir -p tmp

cd tmp

../GetRecipesToSpellIDs/get-files.sh
../GetRecipesToSpellIDs/convert-recipes-to-spell-ids.py >../Collectionator/Data/RecipesToSpellIDs.lua

cd ../
