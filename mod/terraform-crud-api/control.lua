resources = {
  players = {
    read = function()
      result = {}
      for k,v in pairs(game.players) do
        table.insert(result, {
          name = v.name,
          position = v.position,
        })
      end
      return result
    end,
  },
  entity = require('resources.entity'),
  hello = require('resources.hello'),
}

-- In addition to json serialization, this code also replaces empty objects with empty arrays
-- due to the fact that lua cannot differentiate.
-- This means we cannot have empty objects, however it is easier to add an unused key
-- to an object to avoid empty objects than to add an unused element to every array.

-- Factorio 2.0: game.table_to_json was removed, implement manual JSON serialization
local function escape_string(str)
  return string.gsub(str, '["\\]', {
    ['"'] = '\\"',
    ['\\'] = '\\\\',
  })
end

local function serialize_value(value)
  if value == nil then
    return 'null'
  elseif type(value) == 'string' then
    return '"' .. escape_string(value) .. '"'
  elseif type(value) == 'number' then
    return tostring(value)
  elseif type(value) == 'boolean' then
    return value and 'true' or 'false'
  elseif type(value) == 'table' then
    -- Check if it's an array (all numeric keys starting from 1)
    local is_array = true
    local max_index = 0
    for k, v in pairs(value) do
      if type(k) ~= 'number' or k < 1 or k ~= math.floor(k) then
        is_array = false
        break
      end
      if k > max_index then
        max_index = k
      end
    end
    
    if is_array and max_index > 0 then
      -- Serialize as array
      local parts = {}
      for i = 1, max_index do
        table.insert(parts, serialize_value(value[i]))
      end
      return '[' .. table.concat(parts, ',') .. ']'
    else
      -- Serialize as object
      local parts = {}
      for k, v in pairs(value) do
        local key_str = type(k) == 'string' and ('"' .. escape_string(k) .. '"') or tostring(k)
        table.insert(parts, key_str .. ':' .. serialize_value(v))
      end
      local result = '{' .. table.concat(parts, ',') .. '}'
      -- Replace empty objects with empty arrays (Lua quirk workaround)
      return (string.gsub(result, '{}', '[]'))
    end
  else
    return 'null'
  end
end

function serialize(value)
  return serialize_value(value)
end

-- Factorio 2.0: game.json_to_table was removed, implement manual JSON deserialization
local function skip_whitespace(str, pos)
  while pos <= #str and string.match(string.sub(str, pos, pos), '%s') do
    pos = pos + 1
  end
  return pos
end

local function parse_value(str, pos)
  pos = skip_whitespace(str, pos)
  local char = string.sub(str, pos, pos)
  
  if char == 'n' then
    -- null
    if string.sub(str, pos, pos + 3) == 'null' then
      return nil, pos + 4
    end
    error('Invalid JSON: expected null')
  elseif char == 't' then
    -- true
    if string.sub(str, pos, pos + 3) == 'true' then
      return true, pos + 4
    end
    error('Invalid JSON: expected true')
  elseif char == 'f' then
    -- false
    if string.sub(str, pos, pos + 4) == 'false' then
      return false, pos + 5
    end
    error('Invalid JSON: expected false')
  elseif char == '"' then
    -- string
    pos = pos + 1
    local result = ''
    while pos <= #str do
      local c = string.sub(str, pos, pos)
      if c == '\\' then
        pos = pos + 1
        local next_c = string.sub(str, pos, pos)
        if next_c == '"' then
          result = result .. '"'
        elseif next_c == '\\' then
          result = result .. '\\'
        elseif next_c == 'n' then
          result = result .. '\n'
        elseif next_c == 'r' then
          result = result .. '\r'
        elseif next_c == 't' then
          result = result .. '\t'
        else
          result = result .. next_c
        end
        pos = pos + 1
      elseif c == '"' then
        return result, pos + 1
      else
        result = result .. c
        pos = pos + 1
      end
    end
    error('Invalid JSON: unterminated string')
  elseif char == '[' then
    -- array
    pos = pos + 1
    local result = {}
    local index = 1
    pos = skip_whitespace(str, pos)
    if string.sub(str, pos, pos) == ']' then
      return result, pos + 1
    end
    while pos <= #str do
      local value
      value, pos = parse_value(str, pos)
      result[index] = value
      index = index + 1
      pos = skip_whitespace(str, pos)
      local next_char = string.sub(str, pos, pos)
      if next_char == ']' then
        return result, pos + 1
      elseif next_char == ',' then
        pos = pos + 1
        pos = skip_whitespace(str, pos)
      else
        error('Invalid JSON: expected , or ]')
      end
    end
    error('Invalid JSON: unterminated array')
  elseif char == '{' then
    -- object
    pos = pos + 1
    local result = {}
    pos = skip_whitespace(str, pos)
    if string.sub(str, pos, pos) == '}' then
      return result, pos + 1
    end
    while pos <= #str do
      -- parse key
      pos = skip_whitespace(str, pos)
      if string.sub(str, pos, pos) ~= '"' then
        error('Invalid JSON: expected string key')
      end
      local key
      key, pos = parse_value(str, pos)
      pos = skip_whitespace(str, pos)
      if string.sub(str, pos, pos) ~= ':' then
        error('Invalid JSON: expected :')
      end
      pos = pos + 1
      -- parse value
      local value
      value, pos = parse_value(str, pos)
      result[key] = value
      pos = skip_whitespace(str, pos)
      local next_char = string.sub(str, pos, pos)
      if next_char == '}' then
        return result, pos + 1
      elseif next_char == ',' then
        pos = pos + 1
        pos = skip_whitespace(str, pos)
      else
        error('Invalid JSON: expected , or }')
      end
    end
    error('Invalid JSON: unterminated object')
  elseif string.match(char, '%d') or char == '-' then
    -- number
    local start = pos
    if char == '-' then
      pos = pos + 1
    end
    while pos <= #str and string.match(string.sub(str, pos, pos), '%d') do
      pos = pos + 1
    end
    if string.sub(str, pos, pos) == '.' then
      pos = pos + 1
      while pos <= #str and string.match(string.sub(str, pos, pos), '%d') do
        pos = pos + 1
      end
    end
    local num_str = string.sub(str, start, pos - 1)
    return tonumber(num_str), pos
  else
    error('Invalid JSON: unexpected character ' .. char)
  end
end

local function deserialize(str)
  local pos = 1
  local value, new_pos = parse_value(str, pos)
  pos = skip_whitespace(str, new_pos)
  if pos <= #str then
    error('Invalid JSON: extra characters after value')
  end
  return value
end

exports = {
  ping = function() return 'pong' end,

  read = function(resource_type, query)
    return resources[resource_type].read(query)
  end,

  create = function(resource_type, create_config)
    return resources[resource_type].create(create_config)
  end,

  update = function(resource_type, resource_id, update_config)
    return resources[resource_type].update(resource_id, update_config)
  end,

  delete = function(resource_type, resource_id)
    return resources[resource_type].delete(resource_id)
  end,
}

local function handle_rpc(request_string)
  local deserialize_succeeded, deserialize_result = xpcall(
    deserialize,
    debug.traceback,
    request_string)
  if not deserialize_succeeded then
    return {
      error = {
        code = 400,
        message = 'Failed to deserialize request_string',
        data = deserialize_result
      }
    }
  end
  local request = deserialize_result
  local method = exports[request.method]
  if method == nil then
    return {
      error = {
        code = 404,
        message = string.format('No method named "%s"', request.method),
      }
    }
  end
  local method_succeeded, result = xpcall(method, debug.traceback, table.unpack(request.params))
  if method_succeeded then
    return {
      result = result,
      -- _preserve_table is a throwaway key to prevent
      -- crazy lua empty object == empty array shenanigans
      -- in the event that result == nil/null
      _preserve_table = true
    }
  else
    return {
      error = {
        code = 500,
        message = string.format('Error during "%s"', request.method),
        data = result
      }
    }
  end
end

local function call_and_serialize_result(request_string)
  return serialize(handle_rpc(request_string))
end

local function call_and_handle_unhandled_errors(request_string)
  local suceeded, response = xpcall(
    call_and_serialize_result,
    debug.traceback,
    request_string)
  if suceeded then
    return response
  else
    return serialize({
      error = {
        code = 500,
        message = 'Unhandled error',
        data = response
      }
    })
  end
end

local function call(request_string)
  print(string.format('terraform-crud-api REQUEST: %s', request_string))
  local response = call_and_handle_unhandled_errors(request_string)
  print(string.format('terraform-crud-api RESPONSE: %s', response))
  return response
end

remote.add_interface('terraform-crud-api', {call = call})

local function ensure_resource_db()
  local g = rawget(_G, 'global')
  if not g then
    _G.global = {}
    g = _G.global
  end
  if not g.resource_db then
    g.resource_db = {}
  end
end

script.on_init(function()
  ensure_resource_db()
end)

script.on_load(function()
  ensure_resource_db()
end)
