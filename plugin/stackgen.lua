vim.api.nvim_create_user_command("StackGenSetToken", function(opts)
  local config = require "stackgen.config"
  config.set_token(opts.args)
  ---@diagnostic disable-next-line: missing-fields
  vim.notify("Stackgen token set successfully.", vim.log.levels.INFO, {
    title = "Stackgen",
  })
end, {
  nargs = 1,
})

vim.api.nvim_create_user_command("StackGenModuleList", function()
  require("stackgen.commands").list_modules()
end, {})

vim.api.nvim_create_user_command("StackGenModuleGet", function(opts)
  local module_id = opts.args
  require("stackgen.commands").get_module(module_id)
end, {
  nargs = 1,
})

vim.api.nvim_create_user_command("StackGenModuleSync", function()
  require("stackgen.commands").sync_module()
end, {})

vim.api.nvim_create_user_command("StackGenModulePublish", function(opts)
  local version = opts.args
  require("stackgen.commands").publish_module(version)
end, {
  nargs = 1,
})
