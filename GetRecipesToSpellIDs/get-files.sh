#!/bin/sh
BUILD="$(curl -X GET "https://api.wow.tools/databases/item/versions" -H "accept: text/plain" | jq -r '.[0]')"

wget "https://wow.tools/dbc/api/export/?name=itemxitemeffect&build=$BUILD" -O itemxitemeffect.csv
wget "https://wow.tools/dbc/api/export/?name=itemeffect&build=$BUILD" -O itemeffect.csv
wget "https://wow.tools/dbc/api/export/?name=item&build=$BUILD" -O item.csv
