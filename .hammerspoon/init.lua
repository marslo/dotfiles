local MACIME  = "/opt/homebrew/bin/macime"
local ENGLISH = "com.apple.keylayout.US"
local CHINESE = "com.sogou.inputmethod.sogou.pinyin"

-- per-app input source rules (by bundle ID)
--   "chinese"  : always switch to Chinese
--   "english"  : always switch to English
--   "cursor"   : AI chatbox → Chinese, everything else → English
--   nil        : no interference
local APP_RULES = {
  ["com.tencent.xinWeChat"] = "chinese",
  ["com.apple.finder"]      = "english",
  ["com.todesktop.230313mzl4w4u92"] = "cursor",
}

-- ─── utilities ───────────────────────────────────────────────────────

local function logFocused()
  local app = hs.application.frontmostApplication()
  if not app then print("no frontmost app"); return end
  print("app: " .. app:name() .. "  bundle: " .. (app:bundleID() or "nil"))
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

hs.hotkey.bind({"ctrl"}, "f1", logFocused)

local function switchTo(source)
  local current = hs.execute(MACIME .. " get"):gsub("%s+$", "")
  if current ~= source then
    hs.execute(MACIME .. " set " .. source)
  end
end

local function getFocusedDescription(app)
  local el = hs.axuielement.applicationElement(app):attributeValue("AXFocusedUIElement")
  if not el then return nil end
  return el:attributeValue("AXRoleDescription")
end

-- ─── Cursor input source sync ────────────────────────────────────────

local observer
local cursorActive = false
local dialogOpen   = false

local function cursorSync()
  if not cursorActive then return end
  local a = hs.application.frontmostApplication()
  if not a or a:bundleID() ~= "com.todesktop.230313mzl4w4u92" then return end
  local desc = getFocusedDescription(a)

  if dialogOpen then
    if desc == "editor" or desc == "text entry area" then
      dialogOpen = false
    else
      return
    end
  end

  if desc == "text entry area" then
    switchTo(CHINESE)
  else
    switchTo(ENGLISH)
  end
end

-- AX observer: instant response for most focus changes within Cursor
local function startObserver()
  local app = hs.application.get("Cursor")
  if not app then return end
  if observer then observer:stop(); observer = nil end

  local axApp = hs.axuielement.applicationElement(app)
  observer = hs.axuielement.observer.new(app:pid())
  observer:addWatcher(axApp, "AXFocusedUIElementChanged")
  observer:addWatcher(axApp, "AXFocusedWindowChanged")
  observer:addWatcher(axApp, "AXWindowCreated")
  observer:callback(cursorSync)
  observer:start()
end

-- eventtap: switch to English BEFORE native dialogs open (they lock input method after)
local cursorKeys = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
  if not cursorActive then return false end
  local flags = e:getFlags()
  local code  = e:getKeyCode()
  if flags.cmd and code == hs.keycodes.map["o"]                        -- Cmd+O
  or flags.cmd and flags.shift and code == hs.keycodes.map["g"]        -- Shift+Cmd+G
  or flags.cmd and flags.shift and code == hs.keycodes.map["s"]        -- Shift+Cmd+S (save as)
  then
    dialogOpen = true
    switchTo(ENGLISH)
  end
  return false
end)

-- ─── application watcher ─────────────────────────────────────────────

hs.application.watcher.new(function(name, event, app)
  if event == hs.application.watcher.activated then
    local bid = app and app:bundleID()
    local rule = bid and APP_RULES[bid]

    if rule == "cursor" then
      cursorActive = true
      startObserver()
      cursorKeys:start()
      cursorSync()
    else
      cursorActive = false
      cursorKeys:stop()
      if rule == "chinese" then
        switchTo(CHINESE)
      elseif rule == "english" then
        switchTo(ENGLISH)
      end
    end
  end

  if name == "Cursor" then
    if event == hs.application.watcher.launched then
      startObserver()
    elseif event == hs.application.watcher.terminated then
      cursorActive = false
      cursorPoll:stop()
      cursorKeys:stop()
      if observer then observer:stop(); observer = nil end
    end
  end
end):start()

-- handle already-running Cursor
local front = hs.application.frontmostApplication()
if front and front:bundleID() == "com.todesktop.230313mzl4w4u92" then
  cursorActive = true
  startObserver()
  cursorKeys:start()
  cursorSync()
else
  startObserver()
end
