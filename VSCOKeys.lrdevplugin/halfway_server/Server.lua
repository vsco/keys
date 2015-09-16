require "file"
package.path = "../?.lua;" .. package.path
require "Constants"
require "Utils"
local Http = require "Http"
require "copas"
local DevelopSettings = require "DevelopSettings"
local logger = logging.file("test.log")

logger:setLevel (logging.DEBUG)

logger:debug("Server starting")

local status, err = pcall(
function()
  server = socket.bind(BROADCAST_IP, PORT)

  local isDone = false
  local currentUUID = ""
  local lastPoll = os.time()

  local currentPhotoStatus = {}
  local clientUpdates = {}
  local hasUpdates = false

  local dataHandlingTable = {
    {
      condition = function(data) return data.path:find("/Init/") end,
      action = function(data,skt)
        currentUUID = data.uuid

        logger:debug("Server Init Requested with ".. currentUUID)

        return Http.createResponse(data)
      end
    },
    {
      condition = function(data) return data.path:find("/Shutdown/") end,
      action = function(data,skt)
        isDone = true

        logger:debug("Server was shutdown because of a request.")
        return Http.createResponse(data)
      end
    },
    {
      condition = function(data) return data.path:find("/VSCOKeys/") end,
      action = function(data,skt)
        -- if client loop has expired, send it a shutdown notification
        if (currentUUID ~= "" and data.uuid ~= currentUUID) then
          data.code = 403
          data.reason = "Forbidden"
          logger:debug(data.uuid .. " terminated because not == current " .. currentUUID)
        else
          currentPhotoStatus = data.json

          -- check for pending changes to image then send those off to plugin
          if (hasUpdates) then
            -- clear out zeroed updates
            for k,v in pairs(clientUpdates) do
              if v == 0 then
                clientUpdates[k] = nil
              end
            end

            data.json = clientUpdates
          else
            data.json = nil
          end

          hasUpdates = false

          lastPoll = os.time()
        end

        return Http.createResponse(data)
      end
    },
    {
      condition = function(data) return data.path:find("/Update/") end,
      action = function(data,skt)

        logger:debug(to_string(data.json))

        -- add delta to batched client updates
        if (data.json) then
          if not hasUpdates then
            clientUpdates = {}
          end

          for k,v in pairs(data.json) do
            local vAsNum = tonumber(v)
            if (vAsNum ~= nil) then
              if (clientUpdates[k] == nil) then
                clientUpdates[k] = vAsNum
              else
                clientUpdates[k] = clientUpdates[k] + vAsNum
              end
            else
              clientUpdates[k] = v
            end

          end

          logger:debug(to_string(clientUpdates))
        end

        hasUpdates = true

        -- clear out data for response
        data.json = nil

        return Http.createResponse(data)
      end
    },
    {
      condition = function(data) return data.path:find("/PhotoData/") end,
      action = function(data,skt)
        data.json = currentPhotoStatus

        logger:debug("Photo data Requested.")
        return Http.createResponse(data)
      end
    },
    {
      condition = function(data) return data.path:find("/Settings/") end,
      action = function(data,skt)
        data.json = DevelopSettings

        logger:debug("Develop settings Requested.")
        return Http.createResponse(data)
      end
    },
  }

  local function handler(skt)
    skt = copas.wrap(skt)
    local stopStream = false
    local data = {}
    local lines = {}
    while true do
      local dataLine = skt:receive("*l")

      if (dataLine == nil) then
        -- data = Http.parseHttpHeaders(lines)
        break
      end

      table.insert(lines, dataLine)

      -- print(tostring(dataLine))

      if (dataLine == "") then
        data = Http.parseHttpHeaders(lines)

        if (data.contentLength ~= nil and data.contentLength > 0) then
          data.content = skt:receive(data.contentLength)
          data = Http.parseHttpContent(data)
        end
        break
      end
    end

    -- print("Request: \n" .. to_string(data.path))

    for k,o in ipairs(dataHandlingTable) do
      if (o.condition(data)) then
        local response = nil

        local status, err = pcall(
        function()
          response = o.action(data,skt)
          end
        )

        if not status then
          logger:fatal("Runtime parse error in action table: " .. to_string(err))
        end

        -- print("Response: \n" .. response)
        skt:send(response)

        break
      end
    end
  end

  copas.addserver(server, handler)

  while (isDone == false) do
    -- check for ping
    local delta = os.time() - lastPoll
    -- print(delta)
    if (delta > TIMEOUT_TIME) then
      logger:fatal("No response from LR plugin. Exiting.")
      break
    end

    copas.step(SERVER_UPDATE_TIME)
  end

end
)

if not status then
  logger:fatal("Runtime parse error in lua: " .. to_string(err))
end
