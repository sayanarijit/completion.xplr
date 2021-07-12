completion.xplr
===============

The missing tab completion for xplr input buffer.

This plugin is intended to be used as a library for other potential plugins
or custom hacks.


TODO
----

- [x] Path completion
- [x] Command completion
- [ ] Message completion
- [ ] Multisource completion
- [ ] Partial completion


Installation
------------

### Install manually

- Add the following line in `~/.config/xplr/init.lua`

  ```lua
  package.path = os.getenv("HOME") .. '/.config/xplr/plugins/?/src/init.lua'
  ```

- Clone the plugin

  ```bash
  mkdir -p ~/.config/xplr/plugins

  git clone https://github.com/sayanarijit/completion.xplr ~/.config/xplr/plugins/completion
  ```

- Require the module in `~/.config/xplr/init.lua`

  ```lua
  require("completion").setup()

  -- Exposed functions:
  -- - xplr.fn.custom.completion.complete_path
  -- - xplr.fn.custom.completion.complete_command
  ```


Use Case
--------

Switch to completion mode (look at the `tab` key)

  ```lua
  -- Path completion

  xplr.config.modes.builtin.go_to.key_bindings.on_key.p = {
    help = "go to path",
    messages = {
      "PopMode",
      { SwitchModeCustom = "go_to_path" },
      { SetInputBuffer = "" },
    }
  }

  xplr.config.modes.custom.go_to_path = {
    name = "go to path",
    key_bindings = {
      on_key = {
        enter = {
          messages = {
            "FocusPathFromInput",
            "PopMode",
          },
        },
        esc = {
          help = "cancel",
          messages = { "PopMode" },
        },
        tab = {
          help = "complete",
          messages = {
            { CallLuaSilently = "custom.completion.complete_path" },
          },
        },
        ["ctrl-c"] = {
          help = "terminate",
          messages = { "Terminate" },
        },
        backspace = {
          help = "remove last character",
          messages = { "RemoveInputBufferLastCharacter" },
        },
        ["ctrl-u"] = {
          help = "remove line",
          messages = { { SetInputBuffer = "" } },
        },
        ["ctrl-w"] = {
          help = "remove last word",
          messages = { "RemoveInputBufferLastWord" },
        },
      },
      default = {
        messages = {
          "BufferInputFromKey"
        },
      },
    },
  }
  ```
