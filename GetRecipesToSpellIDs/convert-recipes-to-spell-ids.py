#!/usr/bin/python3
import csv

recipes_only = {}

with open('item.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        if row['ClassID'] == '9':
            itemID = int(row['ID'])
            recipes_only[itemID] = []

with open('itemxitemeffect.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        itemid = int(row['ItemID'])
        if itemid in recipes_only:
            recipes_only[itemid].append(int(row['ItemEffectID']))

effects_to_spell = {}
with open('itemeffect.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        effects_to_spell[int(row['ID'])] = int(row['SpellID'])


def print_recipe(itemID, spellID):
    print("  [" + str(itemID) + "] = " + str(spellID) + ",")

sorted_recipes = list(recipes_only)
sorted_recipes.sort()
print("COLLECTIONATOR_RECIPES_TO_IDS = {")
for key in sorted_recipes:
    itemeffects = recipes_only[key]

    if len(itemeffects) == 2:
        if effects_to_spell[itemeffects[1]] == 483:
            print_recipe(key, effects_to_spell[itemeffects[0]])
        elif effects_to_spell[itemeffects[0]] == 483:
            print_recipe(key, effects_to_spell[itemeffects[1]])
print("}")
