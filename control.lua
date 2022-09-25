json = require "json"


local function Dump(event)
    local recipes = {}
    local recipes_group = {}
    local i = 1
    game.print("this is generated by mod data-dump")
    for  _, v in pairs(game.recipe_prototypes) do
        local r = {}
        r["name"] = v.name
        r["ingredients"] = v.ingredients
        r["products"] = v.products
        r["energy"] = v.energy
        r["category"] = v.category
        recipes[i] = r
        -- game.print(v.category)
        recipes_group[v.name] = v.category
        i = i + 1
    end

    local raw = {}
    for k, v in pairs(game.item_prototypes) do --raw dummpy solid resources
        if (v.subgroup.name == "raw-resource") then
            -- raw[v.name] = v.minable["mining_time"]
            
            recipes_group["raw-" .. k] = "basic-solid"
        end
    end
    for k, v in pairs(game.entity_prototypes) do --raw dummpy fluid resources
        if (v.type == "resource") then
            game.print(k)
            game.print(v.minable["mining_time"])
            raw[k] = v.minable["mining_time"]
            recipes_group["raw-" .. k] = v.resource_category
        end
        -- if (v.subgroup.name == "raw-resource") then
        --     -- game.print(v.resource_category)
        --     recipes_group["raw-" .. k] = v.resource_category
        -- end
    end
    recipes_group["raw-water"] = "basic-water" --raw dummpy water
    game.write_file("data-dump/raw.json", game.table_to_json(raw))
    game.print("raw.json written")
    game.write_file("data-dump/recipe-group.json", game.table_to_json(recipes_group))
    game.print("recipes-group.json written")
    game.write_file("data-dump/recipes.json", game.table_to_json(recipes))
    game.print("recipes.json written")

    machines = {}
    belts = {}
    -- game.print("print test")
    for k, v in pairs(game.entity_prototypes) do
        
        if (v.type == "assembling-machine") then
            local m = {}
            m["crafting_speed"] = v.crafting_speed
            m["crafting_categories"] = {}
            for name,_ in pairs(v.crafting_categories) do 
                table.insert(m["crafting_categories"], name)
            end
            machines[k] = m
        end
        if (v.type == "mining-drill") then
            local m = {}
            m["crafting_speed"] = v.mining_speed

            local cat = ""
            for k_, _ in pairs(v.resource_categories) do
                cat = k_
                break
            end
            if (v.resource_categories["basic-solid"]) then
                m["crafting_categories"] = {cat}
            else
                m["crafting_categories"] = {cat}   
            end
            
            machines[k] = m
        end
        if (v.fluid) then --offshore pump
            local m = {}
            m["crafting_speed"] = v.pumping_speed
            m["crafting_categories"] = {"basic-water"}
            machines[k] = m
        end
        if (v.type == "transport-belt") then
            belts[k] = v.belt_speed
        end
        
    end
    game.write_file("data-dump/belts.json", json.encode(belts))
    game.write_file("data-dump/machines.json", json.encode(machines))
    game.print("machines.json written")
    game.print("belts.json written")
    return recipes, machines, belts
end

local function MatchMachineGroup(machines)
    local res = {} --map recipe type to machines
    for name, machine in pairs(machines) do
        for _, group in ipairs(machine["crafting_categories"]) do
            if (res[group] == nil) then
                res[group] = {}
            end
            table.insert(res[group], name)
            
        end
    end
    
    game.write_file("data-dump/machine-group.json", json.encode(res))
    return res
end



script.on_init(function (event)
    local recipes, machines, belts = Dump(event)
    MatchMachineGroup(machines)
end)


script.on_event("dump-data", function (event)
    local recipes, machines, belts = Dump(event)
    MatchMachineGroup(machines)
end)