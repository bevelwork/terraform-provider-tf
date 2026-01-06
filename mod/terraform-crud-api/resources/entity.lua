local resource_db = require('resource_db')

local function table_invert(t)
  local s={}
  for k,v in pairs(t) do
    s[v]=k
  end
  return s
end

local direction_to_string = table_invert(defines.direction)

local function get_direction(direction_name)
  local direction = defines.direction[direction_name]
  if direction == nil then
    error(string.format('Expected valid direction but got "%s"', direction_name))
  end
  return direction
end

local function set_entity_contents(e, contents)
  -- Try to set contents in burner inventory (for burner entities like mining drills)
  if e.burner ~= nil and e.burner.inventory ~= nil then
    local inventory = e.burner.inventory
    -- Clear existing contents
    inventory.clear()
    -- Insert new contents
    for _, content in pairs(contents) do
      if content.kind ~= nil and content.qty ~= nil and content.qty > 0 then
        inventory.insert({name = content.kind, count = content.qty})
      end
    end
    return
  end
  
  -- Try to set contents in main inventory (for entities with inventories)
  if e.get_inventory ~= nil then
    local main_inventory = e.get_inventory(defines.inventory.chest)
    if main_inventory ~= nil then
      -- Clear existing contents
      main_inventory.clear()
      -- Insert new contents
      for _, content in pairs(contents) do
        if content.kind ~= nil and content.qty ~= nil and content.qty > 0 then
          main_inventory.insert({name = content.kind, count = content.qty})
        end
      end
      return
    end
  end
  
  -- If no inventory found, warn but don't error
  if #contents > 0 then
    game.print(string.format('Warning: Entity "%s" does not have an inventory to set contents', e.name))
  end
end

local function get_entity_contents(e)
  local contents = {}
  
  -- Try to get contents from burner inventory (for burner entities like mining drills)
  if e.burner ~= nil and e.burner.inventory ~= nil then
    local inventory = e.burner.inventory
    local inventory_contents = inventory.get_contents()
    if inventory_contents ~= nil then
      for item_name, count in pairs(inventory_contents) do
        -- Ensure item_name is a string and count is a number
        if type(item_name) == "string" and type(count) == "number" then
          table.insert(contents, {
            kind = tostring(item_name),
            qty = tonumber(count)
          })
        end
      end
    end
  end
  
  -- Try to get contents from main inventory (for entities with inventories)
  if e.get_inventory ~= nil then
    local main_inventory = e.get_inventory(defines.inventory.chest)
    if main_inventory ~= nil then
      local inventory_contents = main_inventory.get_contents()
      if inventory_contents ~= nil then
        for item_name, count in pairs(inventory_contents) do
          -- Ensure item_name is a string and count is a number
          if type(item_name) == "string" and type(count) == "number" then
            table.insert(contents, {
              kind = tostring(item_name),
              qty = tonumber(count)
            })
          end
        end
      end
    end
  end
  
  -- Always return an array (even if empty) to ensure proper JSON serialization
  return contents
end

local function entity_to_resource(e)
  return {
    unit_number = e.unit_number,
    surface = e.surface.name,
    name = e.name,
    position = e.position,
    direction = direction_to_string[e.direction],
    force = e.force.name,
    contents = get_entity_contents(e)
  }
end

local function position_matches(pos1, pos2, tolerance)
  tolerance = tolerance or 0.1
  return math.abs(pos1.x - pos2.x) < tolerance and math.abs(pos1.y - pos2.y) < tolerance
end

return {
  read = function(query)
    local unit_number = query.unit_number
    local entity = resource_db.get('entity', unit_number)
    if entity == nil then
      -- Entity not in resource_db - we can't find it by unit_number alone
      -- This can happen if resource_db was cleared or entity was created before mod update
      -- The list function will discover it when searching by position
      return nil
    end
    if not entity.valid then
      resource_db.put('entity', unit_number, nil)
      return nil
    end
    return entity_to_resource(entity)
  end,

  list = function(query)
    query = query or {}
    local results = {}
    local seen_unit_numbers = {}
    
    -- First, search resource_db
    local type_query = global.resource_db['entity']
    if type_query ~= nil then
      for unit_number_str, entity in pairs(type_query) do
        if entity ~= nil and entity.valid then
          local resource = entity_to_resource(entity)
          local matches = true
          
          -- Match by surface
          if query.surface ~= nil and resource.surface ~= query.surface then
            matches = false
          end
          
          -- Match by name
          if query.name ~= nil and resource.name ~= query.name then
            matches = false
          end
          
          -- Match by position (with tolerance)
          if query.position ~= nil then
            if not position_matches(resource.position, query.position, query.position_tolerance) then
              matches = false
            end
          end
          
          -- Match by force
          if query.force ~= nil and resource.force ~= query.force then
            matches = false
          end
          
          -- Match by direction
          if query.direction ~= nil and resource.direction ~= query.direction then
            matches = false
          end
          
          if matches then
            table.insert(results, resource)
            seen_unit_numbers[entity.unit_number] = true
          end
        else
          -- Clean up invalid entities
          if entity ~= nil and not entity.valid then
            resource_db.put('entity', tonumber(unit_number_str), nil)
          end
        end
      end
    end
    
    -- Also search the game world if position and surface are specified
    if query.position ~= nil and query.surface ~= nil then
      local surface = game.surfaces[query.surface]
      if surface ~= nil then
        local tolerance = query.position_tolerance or 0.1
        local area = {
          {query.position.x - tolerance, query.position.y - tolerance},
          {query.position.x + tolerance, query.position.y + tolerance}
        }
        local world_entities = surface.find_entities_filtered({area = area})
        
        for _, entity in pairs(world_entities) do
          if entity.valid and not seen_unit_numbers[entity.unit_number] then
            local resource = entity_to_resource(entity)
            local matches = true
            
            -- Match by name
            if query.name ~= nil and resource.name ~= query.name then
              matches = false
            end
            
            -- Match by force
            if query.force ~= nil and resource.force ~= query.force then
              matches = false
            end
            
            -- Match by direction
            if query.direction ~= nil and resource.direction ~= query.direction then
              matches = false
            end
            
            if matches then
              -- Add to resource_db if not already there
              resource_db.put('entity', entity.unit_number, entity)
              table.insert(results, resource)
            end
          end
        end
      end
    end
    
    return results
  end,

  create = function(config)
    local surface = game.surfaces[config.surface]
    if surface == nil then
      error(string.format('Could not find surface with id "%s"', config.surface))
    end
    
    -- Check for existing entities at this position
    -- Use a small bounding box to find entities at the exact position
    local position = config.position
    local tolerance = 0.1
    local area = {
      {position.x - tolerance, position.y - tolerance},
      {position.x + tolerance, position.y + tolerance}
    }
    local existing_entities = surface.find_entities_filtered({area = area})
    
    -- Helper function to check if an entity should be auto-cleared (crash-site entities, trees, etc.)
    local function should_auto_clear_entity(entity)
      local name = entity.name
      -- Crash-site entities
      if string.sub(name, 1, 11) == "crash-site-" then
        return true
      end
      -- Trees (tree-01, tree-02, tree-03, tree-04, dry-tree, dead-grey-trunk, etc.)
      if string.sub(name, 1, 5) == "tree-" then
        return true
      end
      if name == "dry-tree" or name == "dead-grey-trunk" then
        return true
      end
      return false
    end
    
    -- First, check if there's a matching entity we can reuse
    local matching_entity = nil
    local conflicting_entities = {}
    local auto_clear_entities = {}
    for _, existing_entity in pairs(existing_entities) do
      if existing_entity.valid then
        -- Check if this entity matches what we're trying to create
        if existing_entity.name == config.name then
          -- It matches! Reuse it instead of clobbering
          matching_entity = existing_entity
          -- Make sure it's in resource_db
          resource_db.put('entity', existing_entity.unit_number, existing_entity)
        elseif should_auto_clear_entity(existing_entity) then
          -- Entity that should be auto-cleared (crash-site, trees, etc.)
          table.insert(auto_clear_entities, existing_entity)
        else
          -- Different entity type - this is a conflict
          table.insert(conflicting_entities, existing_entity)
        end
      end
    end
    
    -- If we found a matching entity, reuse it (but still need to update direction/force/contents if needed)
    if matching_entity ~= nil then
      -- Update direction if needed
      if config.direction ~= nil then
        matching_entity.direction = get_direction(config.direction)
      end
      -- Update force if needed
      if config.force ~= nil then
        matching_entity.force = config.force
      end
      -- Update contents if provided
      if config.contents ~= nil then
        set_entity_contents(matching_entity, config.contents)
      end
      return entity_to_resource(matching_entity)
    end
    
    -- Auto-clear entities that should be removed (crash-site, trees, etc.)
    for _, clear_entity in pairs(auto_clear_entities) do
      if clear_entity.valid then
        -- Remove from resource_db if it's tracked
        local unit_number = clear_entity.unit_number
        if resource_db.get('entity', unit_number) ~= nil then
          resource_db.put('entity', unit_number, nil)
        end
        -- Destroy the entity
        clear_entity.destroy()
      end
    end
    
    -- If there are conflicting entities (different type), return an error instead of clobbering
    if #conflicting_entities > 0 then
      local conflict_msg_parts = {}
      for _, conflicting_entity in pairs(conflicting_entities) do
        local entity_name = conflicting_entity.name
        local pos = conflicting_entity.position
        -- Replace newlines and other problematic characters for JSON
        entity_name = string.gsub(entity_name, '\n', ' ')
        entity_name = string.gsub(entity_name, '\r', ' ')
        table.insert(conflict_msg_parts, string.format('please remove %s from (%.1f, %.1f)', entity_name, pos.x, pos.y))
      end
      local conflict_msg = table.concat(conflict_msg_parts, ', ')
      -- Ensure error message doesn't contain newlines that break JSON
      conflict_msg = string.gsub(conflict_msg, '\n', ' ')
      conflict_msg = string.gsub(conflict_msg, '\r', ' ')
      error(string.format('Object collision: %s', conflict_msg))
    end
    
    local entity_creation_params = {
      name = config.name,
      position = config.position,
      direction = get_direction(config.direction),
      force = config.force,
      target = nil,
      source = nil,
      fast_replace = false,
      player = nil,
      spill = true,
      raise_built = true,
      create_build_effect_smoke = false,
      spawn_decorations = true,
      move_stuck_players = true,
      item = nil,
    }
    if config.entity_specific_parameters ~= nil then
      for k,v in pairs(config.entity_specific_parameters) do
        entity_creation_params[k] = v
      end
    end
    local e = surface.create_entity(entity_creation_params)
    if e == nil then
      error(string.format('Failed to create "%s"', config.name))
    end
    
    -- Set contents if provided
    if config.contents ~= nil and #config.contents > 0 then
      set_entity_contents(e, config.contents)
    end
    
    resource_db.put('entity', e.unit_number, e)
    return entity_to_resource(e)
  end,

  update = function(resource_id, update_config)
    local unit_number = tonumber(resource_id)
    local entity = resource_db.get('entity', unit_number)
    if entity == nil then
      return nil
    end
    if not entity.valid then
      resource_db.put('entity', unit_number, nil)
      return nil
    end
    if update_config.direction ~= nil then
      entity.direction = get_direction(update_config.direction)
    end
    if update_config.force ~= nil then
      entity.force = update_config.force
    end
    if update_config.contents ~= nil then
      set_entity_contents(entity, update_config.contents)
    end

    return entity_to_resource(entity)
  end,

  delete = function(resource_id)
    local unit_number = tonumber(resource_id)
    local entity = resource_db.get('entity', unit_number)
    if entity == nil then
      return {
        resource_exists = false
      }
    end
    if not entity.valid then
      resource_db.put('entity', unit_number, nil)
      return {
        resource_exists = false
      }
    end
    local destroyed = entity.destroy()
    if destroyed then
      resource_db.put('entity', unit_number, nil)
    end
    return {
      resource_exists = not destroyed
    }
  end,
}