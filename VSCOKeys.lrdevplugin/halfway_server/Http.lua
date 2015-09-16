package.path = "../?.lua;" .. package.path
local JSON = require "json"
local Http = {}

function Http.parseHttpHeaders(lines)
  local data = {}
  local stringLoc = 1

  local reqLine = lines[1]

  data.method = reqLine:sub(stringLoc,reqLine:find(" ", stringLoc) - 1)
  stringLoc = stringLoc + #data.method + 1

  data.path = reqLine:sub(stringLoc,reqLine:find(" ", stringLoc) - 1)
  stringLoc = stringLoc + #data.path + 1

  data.version = reqLine:sub(stringLoc)

  for i,v in ipairs(lines) do
    if (v:find("UUID")) then
      data.uuid = v:sub(#"UUID: ")
    end
    if (v:find("Content-Type: ",1,true)) then
      data.contentType = v:sub(#"Content-Type: "+1)
    end
    if (v:find("Content-Length: ",1,true)) then
      data.contentLength = tonumber(v:sub(#"Content-Length: "+1))
    end
  end
  --
  -- data.content = {}
  -- for i = dataStartLine, #lines do
  --   table.insert(data.content, lines[i])
  -- end
  --
  -- data.content = table.concat(data.content, "\n")
  --
  -- if (data.contentType == "application/json") then
  --   data.json = JSON:decode(data.content)
  -- end

  return data
end

function Http.parseHttpContent(data)
  if (data.contentType == "application/json") then
    data.json = JSON:decode(data.content)
  end

  return data
end

local function prepareContent(response, data)

  if (data.json ~= nil) then
    data.contentType = "application/json"
    data.content = JSON:encode(data.json)
    data.contentLength = #data.content
  else
    return response .. "\n"
  end

  if (data.contentLength ~= nil and
    data.contentLength > 0 and
    data.contentType ~= nil and
    data.content ~= nil) then
    response = response .. "Content-Type: " .. data.contentType .. "\n"
    response = response .. "Content-Length: " .. data.contentLength .. "\n"
    response = response .. "\n" .. data.content .. "\n"
  end

  return response
end

function Http.createResponse(data)
  if (data.code == nil or data.reason == nil) then
    data.code = 200
    data.reason = "OK"
  end

	-- This os.date format string crashes in windows -- doesn't seem to affect http response / request fortitude. 
  -- data.date = os.date("%A, %d-%b-%y %T GMT", os.time())
  local response = data.version .. " " .. data.code .. " " .. data.reason .. "\n"
  -- response = response .. "Date: " ..data.date .. "\n"

  response = prepareContent(response, data)

  return response
end

function Http.continue()
  data = {}
  data.code = 100
  data.reason = "Continue"
  data.version = "Http/1.1"

  return Http.createResponse(data)
end

function Http.badRequest()
  data = {}
  data.code = 200
  data.reason = "OK"
  data.version = "Http/1.1"

  return Http.createResponse(data)
end

function Http.createRequest(data)
  local response = data.method .. " " .. data.path .. " " .. data.version .. "\n"

  response = prepareContent(response, data)

  return response
end

return Http