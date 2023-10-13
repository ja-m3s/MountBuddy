local MountBuddy = {
  ADDON_NAME = "MountBuddy",
  SAVED_VAR_NAME = "MountBuddySavedVariables",
  SAVED_VAR_DEFAULTS = { TRAINING_ORDER = { "speed", "stamina", "carrying" } },
  SAVED_VARIABLES = {},
  SAVED_VAR_VERSION = 1,
  HELP_TEXT = [[

    /mountbuddy - Prints this help information.
    /mountbuddy-set - Prints the training order options
    /mountbuddy-set <number> - Set the order
    /mountbuddy-get - Gets current training type.
  ]],
  TRAINING_LOOKUP = {
    ["1"] = { "speed", "stamina", "carrying" },
    ["2"] = { "speed", "carrying", "stamina" },
    ["3"] = { "stamina", "speed", "carrying" },
    ["4"] = { "stamina", "carrying", "speed" },
    ["5"] = { "carrying", "speed", "stamina" },
    ["6"] = { "carrying", "stamina", "speed" }
  },
  BUTTON_NAMES = {
    ["speed"] = "ZO_StablePanelSpeedTrainRowTrainButton",
    ["stamina"] = "ZO_StablePanelStaminaTrainRowTrainButton",
    ["carrying"] = "ZO_StablePanelCarryTrainRowTrainButton"
  }
}

--prints the help info
function MountBuddy:printHelp()
  d(self.HELP_TEXT)
end

--set which mount training to do
function MountBuddy:setTrainingOrder(input)
  if not self.TRAINING_LOOKUP[input] then
    local trainOptions = "Training Order options are:\n %s"
    local trainTypes = ""
    for key, order in pairs(self.TRAINING_LOOKUP) do
      trainTypes = trainTypes .. key .. ". " .. table.concat(order, ',') .. "\n"
    end
    d(string.format(trainOptions, trainTypes))
    return
  end
  self.SAVED_VARIABLES.TRAINING_ORDER = self.TRAINING_LOOKUP[input]
  MountBuddy:printTrainingOrder()
end

--print the current mount training
function MountBuddy:printTrainingOrder()
  local strOrder = table.concat(self.SAVED_VARIABLES.TRAINING_ORDER, ',')
  d(string.format("Training Order set to: %s", strOrder))
end

--skip stable dialog
function MountBuddy:skipChat(_, optionCount)
  if optionCount <= 0 then return end

  local _, optionType = GetChatterOption(1)
  if optionType ~= CHATTER_START_STABLE then return end

  SelectChatterOption(1)
end

function MountBuddy:trainMount()
  for _, trainType in ipairs(self.SAVED_VARIABLES.TRAINING_ORDER) do
    local control = GetControl(self.BUTTON_NAMES[trainType])
    ZO_Stable_TrainButtonClicked(control)
  end
  SCENE_MANAGER:ShowBaseScene()
end

--startup
function MountBuddy:onAddonLoad(event, addonName)
  --exit if not the correct addon
  if addonName ~= self.ADDON_NAME then return end
  d(string.format("%s loaded.", self.ADDON_NAME))
  self.SAVED_VARIABLES = ZO_SavedVars:NewCharacterIdSettings(self.SAVED_VAR_NAME, self.SAVED_VAR_VERSION, nil, self.SAVED_VAR_DEFAULTS)
  EVENT_MANAGER:UnregisterForEvent(self.ADDON_NAME, EVENT_ADD_ON_LOADED)
end

function MountBuddy:registerEvent(eventName, callback)
  EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, eventName, callback)
end

--setup slash commands
SLASH_COMMANDS["/mountbuddy"] = function() MountBuddy:printHelp() end
SLASH_COMMANDS["/mountbuddy-set"] = function(input) MountBuddy:setTrainingOrder(input) end
SLASH_COMMANDS["/mountbuddy-get"] = function() MountBuddy:printTrainingOrder() end

--register events
MountBuddy:registerEvent(EVENT_STABLE_INTERACT_START, function() MountBuddy:trainMount() end)
MountBuddy:registerEvent(EVENT_CHATTER_BEGIN, function(_, optionCount) MountBuddy:skipChat(_, optionCount) end)
MountBuddy:registerEvent(EVENT_ADD_ON_LOADED, function(event, addonName) MountBuddy:onAddonLoad(event, addonName) end)