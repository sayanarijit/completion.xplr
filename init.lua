COMPLETION_BUFFER = ""
COMPLETION_INIT_BUFFER = nil
COMPLETION_OPTIONS = {}
COMPLETION_LAST_INDEX = 1

-- https://stackoverflow.com/a/11130774/5209439
local function scandir(directory)
  local i, t, popen = 0, {}, io.popen

  local pfile
  if directory == nil or directory == "" then
    pfile = popen('ls -a1')
    directory = ""
  else
    pfile = popen('if [ -d "' .. directory .. '" ]; then ls -a1 "' .. directory .. '"; fi')
  end

  for filename in pfile:lines() do
    if filename ~= "." and filename ~= ".." then
      i = i + 1
      t[i] = directory .. filename
    end
  end
  pfile:close()
  return t
end

local function all_commands()
  local i, t, popen = 0, {}, io.popen

  local pfile = popen('compgen -c')
  for cmd in pfile:lines() do
    i = i + 1
    t[i] = cmd
  end
  return t
end

local function filter_by_startswith(str, options)
  local result = {}
  for _, option in ipairs(options) do
    if string.sub(option, 1, string.len(str)) == str then
      table.insert(result, option)
    end
  end
  return result
end

local function next_option()
  COMPLETION_LAST_INDEX = COMPLETION_LAST_INDEX + 1
  local result = COMPLETION_OPTIONS[COMPLETION_LAST_INDEX]
  if result == nil then
    COMPLETION_LAST_INDEX = 0
    return COMPLETION_INIT_BUFFER
  else
    return result
  end
end

local function prev_option()
  COMPLETION_LAST_INDEX = COMPLETION_LAST_INDEX - 1
  local result = COMPLETION_OPTIONS[COMPLETION_LAST_INDEX]
  if result == nil then
    for i, _ in ipairs(COMPLETION_OPTIONS) do
      COMPLETION_LAST_INDEX = i
    end
    return COMPLETION_INIT_BUFFER
  else
    return result
  end
end

local function setup(args)
  local xplr = xplr

  xplr.fn.custom.completion = {}

  -- Path completion
  xplr.fn.custom.completion.complete_path = function(app)
    local buff = app.input_buffer
    local dirname = buff:match("(.*/)")

    COMPLETION_BUFFER = buff
    COMPLETION_INIT_BUFFER = buff
    COMPLETION_OPTIONS = filter_by_startswith(buff, scandir(dirname))
    return {
      { SwitchModeCustom = "completion" },
      { CallLuaSilently = "custom.completion.next_option" }
    }
  end

  -- Command completion
  xplr.fn.custom.completion.complete_command = function(app)
    local buff = app.input_buffer

    COMPLETION_BUFFER = buff
    COMPLETION_INIT_BUFFER = buff
    COMPLETION_OPTIONS = filter_by_startswith(buff, all_commands())
    return {
      { SwitchModeCustom = "completion" },
      { CallLuaSilently = "custom.completion.next_option" }
    }
  end


  xplr.fn.custom.completion.accept = function(_)
    return {
      "PopMode",
      { SetInputBuffer = COMPLETION_BUFFER },
    }
  end

  xplr.fn.custom.completion.cancel = function(_)
    return {
      "PopMode",
      { SetInputBuffer = COMPLETION_INIT_BUFFER },
    }
  end

  xplr.fn.custom.completion.next_option = function(_)
    COMPLETION_BUFFER = next_option()
    return {
      { SetInputBuffer = COMPLETION_BUFFER },
    }
  end

  xplr.fn.custom.completion.prev_option = function(_)
    COMPLETION_BUFFER = prev_option()
    return {
      { SetInputBuffer = COMPLETION_BUFFER },
    }
  end

  xplr.config.modes.custom.completion = {
    name = "completion",
    key_bindings = {
      on_key = {
        ["ctrl-n"] = {
          help = "next option",
          messages = {
            { CallLuaSilently = "custom.completion.next_option" }
          }
        },
        ["ctrl-p"] = {
          help = "prev option",
          messages = {
            { CallLuaSilently = "custom.completion.prev_option" }
          }
        },
        enter = {
          help = "accept",
          messages = {
            -- https://github.com/sayanarijit/xplr/issues/303
            { CallLuaSilently = "custom.completion.accept" },
          },
        },
        backspace = {
          messages = {
            -- https://github.com/sayanarijit/xplr/issues/303
            { CallLuaSilently = "custom.completion.accept" },
            "RemoveInputBufferLastCharacter",
          },
        },
        ["ctrl-u"] = {
          messages = {
            "PopMode",
            { SetInputBuffer = "" },
          },
        },
        ["ctrl-w"] = {
          messages = {
            -- https://github.com/sayanarijit/xplr/issues/303
            { CallLuaSilently = "custom.completion.accept" },
            "RemoveInputBufferLastWord",
          }
        },
        esc = {
          help = "cancel",
          messages = {
            -- https://github.com/sayanarijit/xplr/issues/303
            { CallLuaSilently = "custom.completion.cancel" }
          }
        },
        ["ctrl-c"] = {
          help = "terminate",
          messages = { "Terminate" }
        }
      },
      default = {
        messages = {
          { CallLuaSilently = "custom.completion.accept" },
          "BufferInputFromKey",
        },
      },
    }
  }

  local on_key = xplr.config.modes.custom.completion.key_bindings.on_key

  on_key.tab = on_key["ctrl-n"]
  on_key["back-tab"] = on_key["ctrl-p"]

  on_key.down = on_key["ctrl-n"]
  on_key.up = on_key["ctrl-p"]

  on_key.right = on_key["ctrl-n"]
  on_key.left = on_key["ctrl-p"]
end

return { setup = setup }
