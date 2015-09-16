package.path = "../?.lua;" .. package.path
require "Constants"
require "Utils"
local Http = require "Http"
require "copas"
local JSON = require "json"
--
-- function sleep(sec)
--     socket.select(nil, nil, sec)
-- end

function sendTweaks(tweaks)
  local data = {json = tweaks}

  client = socket.connect(LOCALHOST_IP, PORT)

  data.method = "POST"
  data.path = "/Update/"
  data.version = "HTTP/1.1"

  data = Http.createRequest(data)

  client:send(data)
  client:close()
end

function getPhotoData()
  local data = {}

  client = socket.connect(LOCALHOST_IP, PORT)

  data.method = "GET"
  data.path = "/PhotoData/"
  data.version = "HTTP/1.1"

  data = Http.createRequest(data)

  client:send(data)

  while true do
    local dataLine = client:receive("*l")

    if (dataLine == nil) then
      break
    end

    print(dataLine)
  end

  client:close()
end

function getSettings()
  local data = {}

  client = socket.connect(LOCALHOST_IP, PORT)

  data.method = "GET"
  data.path = "/Settings/"
  data.version = "HTTP/1.1"

  data = Http.createRequest(data)

  client:send(data)

  while true do
    local dataLine = client:receive("*l")

    if (dataLine == nil) then
      break
    end

    print(dataLine)
  end

  client:close()
end

local cmdList = {}

cmdList["inv"] = function ()
  sendTweaks({ inv = 0.2 })
end

cmdList["exp+"] = function ()
  sendTweaks({ Exposure2012 = 0.2 })
end

cmdList["exp++"] = function ()
  sendTweaks({ Exposure2012 = 2.0 })
end

cmdList["exp-"] = function ()
  sendTweaks({ Exposure2012 = -0.2 })
end

cmdList["exp--"] = function ()
  sendTweaks({ Exposure2012 = -2.0 })
end

cmdList["exp+-"] = function ()
  sendTweaks({ Exposure2012 = 0.2 })
  sendTweaks({ Exposure2012 = -0.2 })
end

cmdList["p"] = function ()
  getPhotoData()
end

cmdList["s"] = function ()
  getSettings()
end

cmdList["exit"] = function ()
end

function printCmds()
  local cmds = ""
  for k,v in pairsByKeys(cmdList) do
    cmds = cmds .. k .. " "
  end

  print(cmds)
end

cmdList[""] = printCmds
cmdList["?"] = printCmds
cmdList["cmd"] = printCmds

local cmd = ""
while cmd ~= "exit" do
  print("enter command:")
  cmd = io.stdin:read'*l'

  if (cmd:find("/",1,true)) then
    local tweak = {}
    local key = cmd:sub(2, cmd:find(" ")-1)
    local value = cmd:sub(cmd:find(" ")+1)
    tweak[key] = value
    sendTweaks(tweak)
  end

  for k,v in pairs(cmdList) do
    if (k == cmd) then
      v()
    end
  end

end

