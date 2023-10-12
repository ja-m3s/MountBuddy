local MB_NS = {
  ADDON_NAME = "MountBuddy",
  SAVED_VAR_NAME = "MountBuddySavedVariables",
  DEFAULT = { TRAINING_TYPE = "speed" },
  VARIABLE_VERSION = 1,
  DB = {},
  HELP_TEXT = [[
   
    /mountbuddy - Prints this help information.
    /mountbuddy-set speed - Sets addon to train mount speed.
    /mountbuddy-set stamina - Sets addon to train mount stamina.
    /mountbuddy-set carrying - Sets addon to train carrying capacity.
    /mountbuddy-get - Gets current training type.
  ]],
  BUTTON_NAMES = {
    ["stamina"] = "ZO_StablePanelStaminaTrainRowTrainButton",
    ["speed"] = "ZO_StablePanelSpeedTrainRowTrainButton",
    ["carrying"] = "ZO_StablePanelCarryTrainRowTrainButton"
  }
}

--prints the help info
function MB_NS.printHelp()
  d(MB_NS.HELP_TEXT)
end

--set which mount training to do
function MB_NS.setTrainingType(input)
  if not MB_NS.BUTTON_NAMES[input] then
    MB_NS.printHelp()
    return
  end
  MB_NS.DB.TRAINING_TYPE = input
  MB_NS.printTrainingType()
end

--print the current mount training
function MB_NS.printTrainingType()
  d(string.format("Training Type set to: %s", MB_NS.DB.TRAINING_TYPE))
end

--get the current mount training
function MB_NS.getTrainingType()
  return MB_NS.BUTTON_NAMES[MB_NS.DB.TRAINING_TYPE]
end

--skip stable dialog
function MB_NS.skipChat(_, optionCount)
  if optionCount <= 0 then return end

  local _, optionType = GetChatterOption(1)
  if optionType ~= CHATTER_START_STABLE then return end

  SelectChatterOption(1)
end

function MB_NS.trainMount()
  local control = GetControl(MB_NS.getTrainingType())
  ZO_Stable_TrainButtonClicked(control)
  SCENE_MANAGER:ShowBaseScene()
end

--startup
function MB_NS.onAddonLoad(event, addonName)
  --exit if not the correct addon
  if addonName ~= MB_NS.ADDON_NAME then return end
  d(string.format("%s loaded.", MB_NS.ADDON_NAME))
  MB_NS.DB = ZO_SavedVars:NewCharacterIdSettings(MB_NS.SAVED_VAR_NAME, MB_NS.VARIABLE_VERSION, nil, MB_NS.DEFAULT)
  EVENT_MANAGER:UnregisterForEvent(MB_NS.ADDON_NAME, EVENT_ADD_ON_LOADED)
end

function MB_NS.registerEvent(eventName, callback)
  EVENT_MANAGER:RegisterForEvent(MB_NS.ADDON_NAME, eventName, callback)
end

--setup slash commands
SLASH_COMMANDS["/mountbuddy"] = MB_NS.printHelp
SLASH_COMMANDS["/mountbuddy-set"] = MB_NS.setTrainingType
SLASH_COMMANDS["/mountbuddy-get"] = MB_NS.printTrainingType

--register events
MB_NS.registerEvent(EVENT_STABLE_INTERACT_START, MB_NS.trainMount)
MB_NS.registerEvent(EVENT_CHATTER_BEGIN, MB_NS.skipChat)
MB_NS.registerEvent(EVENT_ADD_ON_LOADED, MB_NS.onAddonLoad)
