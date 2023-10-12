-- GuildMan Namespace
local MB_NS = {
  ADDON_NAME = "MountBuddy",
  SHORT_ADDON_NAME = "MB",
  SAVED_VAR_NAME = "MountBuddySavedVariables",
  DEFAULT = {
    TRAINING_TYPE = "speed"
  },
  VARIABLE_VERSION = 1,
  DB = {
    TRAINING_TYPE = "speed"
  },
  HELP_TEXT=[[

    /mountbuddy - Prints this help information.
    /mountbuddy-set speed - Sets addon to train mount speed.
    /mountbuddy-set stamina - Sets addon to train mount stamina.
    /mountbuddy-set carrying - Sets addon to train carrying capacity.
    /mountbuddy-get - Gets current training type.
  ]]
}

MB_NS.CHAT = LibChatMessage(MB_NS.ADDON_NAME, MB_NS.SHORT_ADDON_NAME)

--- Prints the help info
function MB_NS.printHelp()
  MB_NS.CHAT:Print(MB_NS.HELP_TEXT)
end

--set which mount training to do
function MB_NS.setTrainingType(input)
  if input ~= "stamina" and input ~= "speed" and input ~= "carrying" then 
    MB_NS.printHelp()
    return 
  end
  MB_NS.DB.TRAINING_TYPE = input
  MB_NS.printTrainingType()
end

--get the current mount training
function MB_NS.printTrainingType()
  MB_NS.CHAT:Print("Training Type set to: " .. MB_NS.DB.TRAINING_TYPE)
end

-- Skip stable dialog
function MB_NS.skipChat(_, optionCount)
  if optionCount <= 0 then return end

  local _, optionType = GetChatterOption(1)
  if optionType ~= CHATTER_START_STABLE then return end

  SelectChatterOption(1)
end

function MB_NS.getTrainingType()
  if MB_NS.DB.TRAINING_TYPE == "stamina" then return "ZO_StablePanelStaminaTrainRowTrainButton" end
  if MB_NS.DB.TRAINING_TYPE == "speed" then return "ZO_StablePanelSpeedTrainRowTrainButton" end
  if MB_NS.DB.TRAINING_TYPE == "carrying" then return "ZO_StablePanelCarryTrainRowTrainButton" end
end

function MB_NS.trainMount()
    local control = GetControl(MB_NS.getTrainingType())
    ZO_Stable_TrainButtonClicked(control)
    SCENE_MANAGER:ShowBaseScene()
end

--- Startup
function MB_NS.onAddOnLoad(event, addonName)
   -- Return if not the correct addon
   if addonName ~= MB_NS.ADDON_NAME then return end
   MB_NS.CHAT:Print(string.format("%s loaded.", MB_NS.ADDON_NAME))
   MB_NS.DB = ZO_SavedVars:NewAccountWide(MB_NS.SAVED_VAR_NAME, MB_NS.VARIABLE_VERSION, nil,MB_NS.DEFAULT)
   EVENT_MANAGER:UnregisterForEvent(MB_NS.ADDON_NAME, EVENT_ADD_ON_LOADED)
end

SLASH_COMMANDS["/mountbuddy"] = MB_NS.printHelp
SLASH_COMMANDS["/mountbuddy-set"] = MB_NS.setTrainingType
SLASH_COMMANDS["/mountbuddy-get"] = MB_NS.printTrainingType

EVENT_MANAGER:RegisterForEvent(MB_NS.ADDON_NAME, EVENT_STABLE_INTERACT_START, MB_NS.trainMount)
EVENT_MANAGER:RegisterForEvent(MB_NS.ADDON_NAME, EVENT_CHATTER_BEGIN, MB_NS.skipChat)
EVENT_MANAGER:RegisterForEvent(MB_NS.ADDON_NAME, EVENT_ADD_ON_LOADED, MB_NS.onAddOnLoad)