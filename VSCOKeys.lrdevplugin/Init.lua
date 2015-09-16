--[[----------------------------------------------------------------------------

VSCO Keys for Adobe Lightroom
Copyright (C) 2015 Visual Supply Company
Licensed under GNU GPLv2 (or any later version).

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

------------------------------------------------------------------------------]]

require "Client"
local logging = require "Logging"
local LrTasks = import "LrTasks"
local LrFileUtils = import "LrFileUtils"

if (LOCK_VSCOS_KEYS_INIT) then
  return
end

LOCK_VSCOS_KEYS_INIT = true
logging:log("init happened.")

Client:auth( function()

  Client:init()

  -- Load up registered applications
  if (LrFileUtils.exists(_PLUGIN.path .. "/apps")) then
    logging:log("booting apps:")
    LrTasks.startAsyncTask( function ()
      local result = LrTasks.execute("cd " .. _PLUGIN.path .. "; bash -c 'for file in apps/*.app; do open $file; done;'")

	  if (result) then
		logging:log("boot mac apps error: " .. tostring(result))
	  end
    end, "Start external apps")

    LrTasks.startAsyncTask( function ()
      local result = LrTasks.execute("cd " .. _PLUGIN.path .. "\\apps & for %f in (*.*) do %f")

	  if (result) then
		logging:log("boot win apps error: " .. tostring(result))
	  end
    end, "Start external apps")
  end
end)
