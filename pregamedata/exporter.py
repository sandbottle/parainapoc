import csv, json

f = open('items.csv')
csv_reader = csv.reader(f)

result = {}

for line in csv_reader:
    if (line[0] != ''):
        #"stone": {
        #    "description": "Basic food",
        #    "type": "material",
        #    "trade_value": 5,
        #    "skin": 1,
        #    "craftable": false
        #},

        craftable = line[5].replace(' ', '').lower() == 'yes'

        if (craftable):
            raw_recipe = line[6]
            raw_recipe = raw_recipe.replace(', ', ',')
            raw_recipe = raw_recipe.replace(': ', ':')
            raw_recipe = raw_recipe.split(',')

            recipe = []
            for item in raw_recipe:
                now_recipe = item.split(':')
                if (len(now_recipe) >= 2):
                    recipe.append({
                        "name": now_recipe[0],
                        "number": int(now_recipe[1])
                    })
                else: 
                    craftable = False

            result[line[0].lower()] = {
                "description": line[1],
                "type": line[2].lower(),
                "trade_value": int(line[3]),
                "craftable": craftable,
                "recipe": recipe,
                "skin": 1
            }
        else:
            result[line[0].lower()] = {
                "description": line[1],
                "type": line[2].lower(),
                "trade_value": int(line[3]),
                "craftable": craftable,
                "skin": 1
            }


print(json.dumps(result, indent= 4))