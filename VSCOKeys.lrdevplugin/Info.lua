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

return {

  LrSdkVersion = 4.0,
  LrSdkMinimumVersion = 3.0, -- minimum SDK version required by this plug-in

  LrToolkitIdentifier = 'com.VSCO.vscokeys',

  LrPluginName = LOC "$$$/VSCO/PluginName=VSCO Keys",

  LrInitPlugin = "Init.lua",
  LrForceInitPlugin = true,
  LrShutdownPlugin = "Shutdown.lua",
  -- LrEnablePlugin = "Init.lua",
  -- LrDisablePlugin = "Shutdown.lua",
  -- LrShutdownApp = "Terminate.lua",

  -- Add the menu item to the File menu.

  LrExportMenuItems = {
    title = "Activate Keys LR3",
    file = "ActivateKeys.lua",
  },

  VERSION = { major=1, minor=0, revision=7, build=0, },

}


