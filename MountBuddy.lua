-- GuildMan Namespace
MOUNTBUDDY_NS = {
  ADDON_NAME = "MountBuddy",
  SHORT_ADDON_NAME = "MB",
  SAVED_VAR_NAME = "MountBuddySavedVariables",
  SLASH_CMD = { { "/mountbuddy", "/mb" }, "print help info" },
  SLASH_SUBCMDS = {
    { { "help", "h" },     'func', "print help info" },
    { { "priority", "p" }, 'func', "set priority" }
  },
  DEFAULT = {},
  VARIABLE_VERSION = 1,
  DB = {
    PRIORITY = "STABLE_TRAIN_SPEED"
  }
};

MOUNTBUDDY_NS.LOGGER = LibDebugLogger(MOUNTBUDDY_NS.ADDON_NAME)
MOUNTBUDDY_NS.CHAT = LibChatMessage(MOUNTBUDDY_NS.ADDON_NAME, MOUNTBUDDY_NS.SHORT_ADDON_NAME)
MOUNTBUDDY_NS.LIB_SLASH_CMDR = LibSlashCommander
MOUNTBUDDY_NS.LTF = LibTableFunctions

-- Functions

--- Prints the help info
function MOUNTBUDDY_NS.printHelp()
  local strHelp = string.format("Help:\nType: %s or %s <command>\n<command> can be:\n", MOUNTBUDDY_NS.SLASH_CMD[1][1],
    MOUNTBUDDY_NS.SLASH_CMD[1][2])
  for _, sub_cmd in ipairs(MOUNTBUDDY_NS.SLASH_SUBCMDS) do
    local strSubCmd = string.format("%s (%s) - %s \n", sub_cmd[1][1], sub_cmd[1][2], sub_cmd[3])
    strHelp = strHelp .. strSubCmd
  end
  MOUNTBUDDY_NS.CHAT:Print(strHelp)
end

--set which mount training to do
function MOUNTBUDDY_NS.setPriority(input)
  if input == "stamina" then
    MOUNTBUDDY_NS.DB.PRIORITY = STABLE_TRAIN_SPEED
  elseif input == "speed" then
    MOUNTBUDDY_NS.DB.PRIORITY = STABLE_TRAIN_STAMINA
  elseif input == "carrying" then
    MOUNTBUDDY_NS.DB.PRIORITY = STABLE_TRAIN_CARRYING_CAPACITY
  else
    MOUNTBUDDY_NS.CHAT:Print("Valid Options are: stamina, speed, carrying")
    return
  end
  MOUNTBUDDY_NS.CHAT:Print(string.format("Priority set to %s", input))
end

--get the current mount training
function MOUNTBUDDY_NS.getPriority()
  MOUNTBUDDY_NS.CHAT:Print(MOUNTBUDDY_NS.DB.PRIORITY)
end

-- Create a callback function for the EVENT_PLAYER_ACTIVATED event
function MOUNTBUDDY_NS.OnPlayerActivated(eventCode)
  if CanStableMasterTrainMount() then
    TrainMount(MOUNTBUDDY_NS.DB.PRIORITY)
  end
end

--- register commands with slash commander addon
function MOUNTBUDDY_NS.RegisterSlashCommands()
  -- Assign functions
  MOUNTBUDDY_NS.SLASH_SUBCMDS[1][2] = MOUNTBUDDY_NS.printHelp
  MOUNTBUDDY_NS.SLASH_SUBCMDS[2][2] = MOUNTBUDDY_NS.setPriority
  MOUNTBUDDY_NS.SLASH_SUBCMDS[3][2] = MOUNTBUDDY_NS.getPriority

  -- Register Slash Command
  local command = MOUNTBUDDY_NS.LIB_SLASH_CMDR:Register()
  command:AddAlias(MOUNTBUDDY_NS.SLASH_CMD[1][1])
  command:AddAlias(MOUNTBUDDY_NS.SLASH_CMD[1][2])
  command:SetCallback(MOUNTBUDDY_NS.printHelp)
  command:SetDescription(MOUNTBUDDY_NS.SLASH_CMD[2])

  -- Register Slash Subcommands
  for _, sub_cmd in ipairs(MOUNTBUDDY_NS.SLASH_SUBCMDS) do
    local subcommand = command:RegisterSubCommand()
    subcommand:AddAlias(sub_cmd[1][1])
    subcommand:AddAlias(sub_cmd[1][2])
    subcommand:SetCallback(sub_cmd[2])
    subcommand:SetDescription(sub_cmd[3])
  end
end

--- Startup
function MOUNTBUDDY_NS.OnAddOnLoaded(event, addonName)
  if addonName ~= MOUNTBUDDY_NS.ADDON_NAME then return end

  local initialMsg = string.format("Loaded Addon: %s", MOUNTBUDDY_NS.ADDON_NAME)
  MOUNTBUDDY_NS.LOGGER:Info(initialMsg)
  MOUNTBUDDY_NS.CHAT:Print(initialMsg)
  MOUNTBUDDY_NS.RegisterSlashCommands()
  MOUNTBUDDY_NS.DB = ZO_SavedVars:NewAccountWide(MOUNTBUDDY_NS.SAVED_VAR_NAME, MOUNTBUDDY_NS.VARIABLE_VERSION, nil,
    MOUNTBUDDY_NS.DEFAULT)
  EVENT_MANAGER:UnregisterForEvent(MOUNTBUDDY_NS.ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(MOUNTBUDDY_NS.ADDON_NAME, EVENT_ADD_ON_LOADED, MOUNTBUDDY_NS.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(MOUNTBUDDY_NS.ADDON_NAME, EVENT_PLAYER_ACTIVATED, MOUNTBUDDY_NS.OnPlayerActivated)