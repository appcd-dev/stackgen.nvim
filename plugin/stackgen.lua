local config = require "stackgen.config"
local cmds = require "stackgen.commands"

---@class MySubCommand
---@field impl fun(args: string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments

---@type table<string, MySubCommand>
local subcommand_tbl = {
  module_get = {
    impl = function(args, _)
      local id = args[1]
      if not id or id == "" then
        vim.notify("StackGen: Please provide a module ID.", vim.log.levels.ERROR)
        return
      end
      cmds.get_module(id)
    end,
  },
  module_list = {
    impl = cmds.list_modules,
  },
  module_sync = {
    impl = cmds.sync_module,
  },
  module_publish = {
    impl = function(args, _)
      local version_name = args[1]
      if not version_name or version_name == "" then
        vim.notify("StackGen: Please provide a version name.", vim.log.levels.ERROR)
        return
      end
      cmds.publish_module(version_name)
    end,
  },
  show_config = {
    impl = cmds.show_config,
  },
  set_token = {
    impl = function(args, _)
      local token = args[1]
      if not token or token == "" then
        vim.notify("StackGen: Please provide a token.", vim.log.levels.ERROR)
        return
      end
      config.set_token(token)
      ---@diagnostic disable-next-line: missing-fields
      vim.notify("Stackgen token set successfully.", vim.log.levels.INFO, {
        title = "Stackgen",
      })
    end,
  },
}

---@param opts table :h lua-guide-commands-create
local function my_cmd(opts)
  local fargs = opts.fargs
  local subcommand_key = fargs[1]
  -- Get the subcommand's arguments, if any
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local subcommand = subcommand_tbl[subcommand_key]
  if not subcommand then
    vim.notify("StackGen: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
    return
  end
  -- Invoke the subcommand
  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command("StackGen", my_cmd, {
  nargs = "+",
  complete = function(arg_lead, cmdline, _)
    -- Get the subcommand.
    local subcmd_key, subcmd_arg_lead = cmdline:match "^['<,'>]*StackGen[!]*%s(%S+)%s(.*)$"
    if subcmd_key and subcmd_arg_lead and subcommand_tbl[subcmd_key] and subcommand_tbl[subcmd_key].complete then
      -- The subcommand has completions. Return them.
      return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
    end
    -- Check if cmdline is a subcommand
    if cmdline:match "^['<,'>]*StackGen[!]*%s+%w*$" then
      -- Filter subcommands that match
      local subcommand_keys = vim.tbl_keys(subcommand_tbl)
      return vim
        .iter(subcommand_keys)
        :filter(function(key)
          return key:find(arg_lead) ~= nil
        end)
        :totable()
    end
  end,
  bang = true, -- If you want to support ! modifiers
})
