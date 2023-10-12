-- GuildMan Namespace
local MB_NS = {
  ADDON_NAME = "MountBuddy",
  SHORT_ADDON_NAME = "MB",
  SAVED_VAR_NAME = "MountBuddySavedVariables",
  DEFAULT = {},
  VARIABLE_VERSION = 1,
  DB = {
    PRIORITY = "speed"
  },
  CARRY_BUTTON="ZO_StablePanelCarryTrainRowTrainButton",
  SPEED_BUTTON="ZO_StablePanelSpeedTrainRowTrainButton",
  STAMINA_BUTTON="ZO_StablePanelStaminaTrainRowTrainButton",
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
function MB_NS.setPriority(input)
  if input ~= "stamina" and input ~= "speed" and input ~= "carrying" then 
    MB_NS.printHelp()
    return 
  end
  MB_NS.DB.PRIORITY = input
  MB_NS.printPriority()
end

--get the current mount training
function MB_NS.printPriority()
  MB_NS.CHAT:Print("Training Type set to: " .. MB_NS.DB.PRIORITY)
end

-- Skip stable dialog
function MB_NS.skipChat(_, optionCount)
  if optionCount <= 0 then return end

  local _, optionType = GetChatterOption(1)
  if optionType ~= CHATTER_START_STABLE then return end

  SelectChatterOption(1)
end

function MB_NS.getPriority()
  if MB_NS.DB.PRIORITY == "stamina" then return MB_NS.STAMINA_BUTTON end
  if MB_NS.DB.PRIORITY == "speed" then return MB_NS.SPEED_BUTTON end
  if MB_NS.DB.PRIORITY == "carrying" then return MB_NS.CARRY_BUTTON end
end

function MB_NS.trainMount()
    local control = GetControl(MB_NS.getPriority())
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
SLASH_COMMANDS["/mountbuddy-set"] = MB_NS.setPriority
SLASH_COMMANDS["/mountbuddy-get"] = MB_NS.printPriority

EVENT_MANAGER:RegisterForEvent(MB_NS.ADDON_NAME, EVENT_STABLE_INTERACT_START, MB_NS.trainMount)
EVENT_MANAGER:RegisterForEvent(MB_NS.ADDON_NAME, EVENT_CHATTER_BEGIN, MB_NS.skipChat)
EVENT_MANAGER:RegisterForEvent(MB_NS.ADDON_NAME, EVENT_ADD_ON_LOADED, MB_NS.onAddOnLoad)