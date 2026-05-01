local MACIME  = "/opt/homebrew/bin/macime"
local ENGLISH = "com.apple.keylayout.US"

local function logFocused()
  local app = hs.application.get("Cursor")
  if not app then print("Cursor not running"); return end
  local focused = hs.axuielement.applicationElement(app):attributeValue("AXFocusedUIElement")
  if not focused then print("no focused element"); return end
  print("=== focused element ===")
  print("role:        " .. (focused:attributeValue("AXRole")            or "nil"))
  print("subrole:     " .. (focused:attributeValue("AXSubrole")         or "nil"))
  print("description: " .. (focused:attributeValue("AXRoleDescription") or "nil"))
  print("title:       " .. (focused:attributeValue("AXTitle")           or "nil"))
  print("identifier:  " .. (focused:attributeValue("AXIdentifier")      or "nil"))
  print("label:       " .. (focused:attributeValue("AXLabel")           or "nil"))
  print("=======================")
end

-- ctrl + F1: log focused element
hs.hotkey.bind({"ctrl"}, "f1", logFocused)

-- brew tap riodelphino/tap && brew install macime
local function switchToEnglish()
  hs.execute(MACIME .. " set " .. ENGLISH)
end

local function getFocusedDescription(app)
  local el = hs.axuielement.applicationElement(app):attributeValue("AXFocusedUIElement")
  if not el then return nil end
  return el:attributeValue("AXRoleDescription")
end

-- watch focus changes within Cursor
local observer

local function startObserver()
  local app = hs.application.get("Cursor")
  if not app then return end

  local axApp = hs.axuielement.applicationElement(app)
  observer = hs.axuielement.observer.new(app:pid())
  observer:addWatcher(axApp, "AXFocusedUIElementChanged")
  observer:callback(function()
    local a = hs.application.get("Cursor")
    if not a then return end
    local desc = getFocusedDescription(a)
    if desc == "editor" then
      switchToEnglish()
    end
  end)
  observer:start()
end

-- start observer when Cursor launches or is activated
hs.application.watcher.new(function(name, event, _)
  if name ~= "Cursor" then return end
  if event == hs.application.watcher.launched
  or event == hs.application.watcher.activated then
    startObserver()
  end
  if event == hs.application.watcher.terminated then
    if observer then observer:stop(); observer = nil end
  end
end):start()

-- handle already-running Cursor
startObserver()
