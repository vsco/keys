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

require "Utils"
require "Constants"
require "json"
local logging = require "Logging.lua"
local JSON = require "json"
local DevelopSettings = require "DevelopSettings"
local LrTasks = import "LrTasks"
local LrHttp = import "LrHttp"
local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"

local LrBinding = import "LrBinding"
local LrFunctionContext = import "LrFunctionContext"
local LrView = import "LrView"
local LrColor = import "LrColor"
local LrMD5 = import "LrMD5"
local LrFileUtils = import "LrFileUtils"
local prefs = import 'LrPrefs'.prefsForPlugin()

Client = {
  done = false,
  uuid = tostring(notUUID()),
  lastValidData = os.time(),
  currentPhotoId = -1,
}

function Client:loop()
  self.lastValidData = os.time()
  local counter = 0
  while (not self.done) do

    self.currentPhoto = LrApplication.activeCatalog():getTargetPhoto()

    local photoData = {}

    -- Pushing photodata is super super costly and slow -- not good need to do some incremental version of this if the feature is needed
    --  For example you could have the data only get queued to be sent when the data has changed from a keys request (but this doesn't
    --  account for non-keys changes) basically it's not a good system for how expensive the query and send is.
--    if (self.currentPhoto) then
--      photoData = self.currentPhoto:getDevelopSettings()
--    end

    local response, headers = LrHttp.post(CLIENT_DATA_ENDPOINT, JSON:encode(photoData), {{field="UUID", value=self.uuid}, {field="Content-Type", value="application/json"}}, "POST", 1)

    if (response == nil) then
      logging:log("error:" .. to_string(headers.error))
    else
      if (headers.status == 403) then
        -- server has told us that our id has expired (init happened) which means we are a dangler.
        logging:log("Old LR thread was killed ".. self.uuid)
        break
      end
      -- logging:log("headers:"..to_string(headers))

      local json = JSON:decode(response)

      -- SPECIAL CASE for authentication information
      if (json and json._AuthUUID and json._AuthToken and json._AuthSerial and json._AuthTimestamp) then

        if (not AUTHENTICATION_IS_ON) then
          json._AuthUUID = nil
          json._AuthToken = nil
          json._AuthTimestamp = nil
          json._AuthSerial = nil
        else
          self.machineUUID = json._AuthUUID
          self.token = json._AuthToken
          self.timestamp = json._AuthTimestamp;
          self.serial = json._AuthSerial;

          logging:log("auth info received.")

          -- kill loop & reset only if auth passes
          self:auth(function()
            self:init()
          end)

          self:sendKillMessageToServer()
          break
        end
      end

      -- SPECIAL CASE for presets
      if (json and self.currentPhoto and json._SetPreset) then
        -- find named preset in hierarchy
        logging:log("setting preset: ".. json._SetPreset)

        local path = string.explode("/", json._SetPreset)
        local folders = LrApplication.developPresetFolders()
        local folderName = nil
        local presetName = json._SetPreset:gsub("%s",""):lower()

        if (#path == 2) then
          folderName = path[1]:gsub("%s",""):lower()
          presetName = path[2]:gsub("%s",""):lower()
        end

        local preset = nil
        logging:log("path: " .. tostring(folderName) .. "/" .. tostring(presetName))

        for _,v in ipairs(folders) do
          local currentFolderName = v:getName():gsub("%s",""):lower()
          --logging:log("folder: ".. currentFolderName)

          if (folderName == nil or currentFolderName == folderName) then
            local presets = v:getDevelopPresets()

            for _,v in ipairs(presets) do
              local currentPresetName = v:getName():gsub("%s",""):lower()
              --logging:log("preset: ".. currentPresetName)

              if (currentPresetName == presetName) then
                preset = v
                break
              end
            end

            if (preset ~= nil) then
              break
            end
          end
        end

        if (preset) then
          logging:log("Preset found -- applying")
          local photos = self.currentPhoto.catalog.targetPhotos
          for i,photo in ipairs(photos) do
            photo.catalog:withWriteAccessDo("VSCO Keys", function()
              photo:applyDevelopPreset(preset)
            end, {asynchronous = true})
          end
        end
      end

      -- apply batched image changes
      if (json and self.currentPhoto) then

        -- strip out edits not in our settings table or of old version
        for k,v in pairs(json) do
          if (not DevelopSettings[k] or (DevelopSettings[k].maxVersion ~= nil and DevelopSettings[k].maxVersion < LrApplication.versionTable().major)) then
            json[k] = nil
            logging:log(k .. " not in settings table or outdated.")
          end
        end

        -- if there's one target photo then there can be more
        local photos = self.currentPhoto.catalog.targetPhotos
        for i,photo in ipairs(photos) do

          local edits = table.shallowcopy(json)

          photoData = photo:getDevelopSettings()

          -- clamp values and find out what our edit text looks like
          local editText = ""
          for k,v in pairs(edits) do

            -- SPECIAL CASE for white balance changes
            -- TODO: move out into data somewhere / somehow
            if (photoData.WhiteBalance ~= "Custom" and (k == "IncrementalTemperature" or k == "IncrementalTint" or k == "Temperature" or k == "Tint")) then
              -- need to update the photo state before we can do the other operation -- complete a full write of the whitebalance change
              --  before applying the changes in the json response
              local wbDict = { WhiteBalance = "Custom" }

              photo.catalog:withWriteAccessDo("VSCO Keys", function()
                local preset = LrApplication.addDevelopPresetForPlugin(_PLUGIN, "WhiteBalance   Custom   Custom", wbDict)
                photo:applyDevelopPreset(preset, _PLUGIN)
              end, {asynchronous = true})

              -- requery the photo data to get the current whitebalance data
              photoData = photo:getDevelopSettings()
            end

            -- SPECIAL CASE for lens correction rotation
            -- TODO: move out into data somewhere / somehow
            if (photoData.CropConstrainToWarp ~= 1 and k == "PerspectiveRotate") then
              -- need to update the photo state before we can do the other operation -- complete a full write of the constrain change
              --  before applying the changes in the json response
              local wbDict = { CropConstrainToWarp = 1 }

              logging:log("Locking constrain to warp.")

              photo.catalog:withWriteAccessDo("VSCO Keys", function()
                local preset = LrApplication.addDevelopPresetForPlugin(_PLUGIN, "Crop Constrain To Warp   Yes   Yes", wbDict)
                photo:applyDevelopPreset(preset, _PLUGIN)
              end, {asynchronous = true})

              -- requery the photo data to get the current constrain data
              photoData = photo:getDevelopSettings()
            end

            -- add incrementally if both values are a number
            if (photoData[k] ~= nil and type(photoData[k]) == "number" and type(v) == "number") then
              edits[k] = photoData[k] + v
            else
              if (photoData[k]) then
                edits[k] = v
              else
                edits[k] = nil
                logging:log("No data in photo for " .. k)
              end
            end

            -- clamp value to valid range
            if (type(edits[k]) == "number") then
              edits[k] = math.min(math.max(edits[k],DevelopSettings[k].min),DevelopSettings[k].max)
            end

            -- guard to only show edits that will actually take
            if (photoData[k]) then
              if (editText == "") then
                local plus = ""

                if (type(v) == "number" and v > 0) then
                  plus = "+"
                end

                editText = DevelopSettings[k].name .. "  " .. plus .. v .. "  " .. edits[k]
              else
                editText = "Multiple Edits"
              end
            else
              logging:log("Edit ignored for " .. k)
            end
          end

          if (table.count(edits) > 0) then
            photo.catalog:withWriteAccessDo("VSCO Keys", function()
              local preset = LrApplication.addDevelopPresetForPlugin(_PLUGIN, editText, edits)
              photo:applyDevelopPreset(preset, _PLUGIN)

              logging:log("Edit Applied " .. to_string(edits))
            end, {asynchronous = true})
          end
        end
      else
        if (json and table.count(json) > 0) then
          LrDialogs.message( "Please select a photo before making edits." )
        end
      end

      -- logging:log("json: \n"..to_string(json))

      self.lastValidData = os.time()
    end

    -- haven't heard from the server in a while -- time to re-initialize
    if (os.time() - self.lastValidData > TIMEOUT_TIME) then
      logging:log("Connection with server timed out. Restarting server.")
      self:init()
      break
    end

    -- logging:log("counter " .. to_string(counter))

    counter = counter + 1

    LrTasks.sleep(CLIENT_UPDATE_TIME)
  end
end

function Client:auth(successCallback)

  -- Kill switch for plugin authentication
  if (not AUTHENTICATION_IS_ON) then
    successCallback()
    return
  end

  local function promptForSerial(errorString) end

  local function clearAuthData()
    self.machineUUID = nil
    self.token = nil
    self.timestamp = nil
    self.serial = nil
  end

  local function success(serial)

    logging:log("storing key: " .. serial)
    prefs.serial = serial

    clearAuthData()

    successCallback()
  end

  local function failure(errorString)
    prefs.serial = nil

    clearAuthData()

    promptForSerial(errorString)
  end

  local function authenticateSerial(serial)

    -- if we don't have a uuid or token yet then we don't attempt networked auth
    if (not self.machineUUID or not self.token) then
      logging:log("no uuid or token yet.")
      success(serial)
      return
    end

    logging:log("authenticating serial: ".. serial)
    LrTasks.startAsyncTask(function()

      local urlParams = {
        { field="uuid", value=self.machineUUID },
        { field="appid", value=AUTHENTICATION_SERVER_APPID },
        { field="ts", value=self.timestamp },
        { field="tkn", value=self.token },
        { field="license", value=(self.serial or serial) },
        { field="ver", value=AUTHENTICATION_SERVER_VERSION },
      }

      local requestParams = ""

      for i,v in ipairs(urlParams) do
        requestParams = requestParams .. urlParams[i].field .. "=" .. urlParams[i].value .. "&"
      end

      logging:log(requestParams)

      local response, headers = LrHttp.post(AUTHENTICATION_SERVER_ENDPOINT, requestParams, {{field="Content-Type", value="application/x-www-form-urlencoded"}})

      if (response ~= nil and headers.status ~= 503) then
        local json = JSON:decode(response)

        if (json.status == 0) then
          logging:log("Invalid key: \n" .. to_string(json))
          failure(json.msg)
        else
          success(serial)
        end
      else
        logging:log("Error connecting to auth server: " .. to_string(headers))
        success(serial)
      end
    end)
  end

  -- returns true if hash matches
  local function validateSerialHash(serial)
--    logging:log("attempting validate: "..serial .. " with " .. SERIAL_KEY_HASH)
    logging:log("attempting serial validation")
    return string.match(serial, SERIAL_KEY_HASH)
  end

  local currentSerial = SERIAL_KEY_DEFAULT

  if (prefs.serial ~= nil) then
    currentSerial = prefs.serial
  end

  local function promptIfSerialInvalid()
    if (validateSerialHash(currentSerial)) then
      authenticateSerial(currentSerial)
    else
      logging:log("validate serial failed: ".. currentSerial)
      failure("Invalid license.")
    end
  end

  promptForSerial = function(errorString)
    logging:log("prompting")
    LrFunctionContext.callWithContext( 'enterserial', function( context )
      local f = LrView.osFactory() --obtain a view factory
      local properties = LrBinding.makePropertyTable( context ) -- make a table
      properties.serial = currentSerial -- initialize setting
      local contents = f:column {
        f:row {
          spacing = f:label_spacing(),
          f:spacer {
            width = 50,
          },
          f:static_text {
            title = errorString,
            text_color = LrColor('red'),
            alignment = 'center',
          },
        },
        f:row {
          spacing = f:label_spacing(),
          bind_to_object = properties, -- default bound table is the one we made
          f:static_text {
            title = "License",
            alignment = 'right',
          },
          f:edit_field {
            fill_horizonal = 1,
            width_in_chars = 20,
            value = LrView.bind( 'serial' ),-- edit field shows settings value
          },
        },
      }

      local result = LrDialogs.presentModalDialog( -- invoke a dialog box
      {
        title = "Enter serial number",
        contents = contents, -- with the UI elements
        actionVerb = "OK", -- label for the action button
      } )
      if result == 'ok' then -- action button was clicked
        currentSerial = properties.serial

        promptIfSerialInvalid()
      end
    end )
  end

  promptIfSerialInvalid()
end

function Client:sendKillMessageToServer()
  logging:log("Requesting server shutdown")
  local response, headers = LrHttp.get(CLIENT_SHUTDOWN_ENDPOINT, nil, 1)
end

function Client:sendInitMessageToServer()
  logging:log("Initializing server with ".. self.uuid)
  local response, headers = LrHttp.get(CLIENT_INIT_ENDPOINT, {{field="UUID", value=self.uuid}}, 1)
end

function Client:init()
  LrTasks.startAsyncTask(function()
    -- check if server is running (shut it down if it is)
    self:sendKillMessageToServer()

    logging:log("Booting server")
    LrTasks.startAsyncTask(function()
      LrTasks.execute("cd " .. _PLUGIN.path .. "/halfway_server; ./lua Server.lua &")
    end, "Boot mac server")
    LrTasks.startAsyncTask(function()
      LrTasks.execute("cd " .. _PLUGIN.path .. "\\halfway_server & lua5.1.exe Server.lua")
    end, "Boot win server")

    LrTasks.sleep(CLIENT_WAIT_FOR_SERVER_TIME)

    self:sendInitMessageToServer()

    self:loop()
  end, "Client Poll")
end

