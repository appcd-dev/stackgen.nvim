local M = {}
local api = require "stackgen.api"
local modules = require "stackgen.modules"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function open_module_files_in_telescope(module_dir)
  local opts = {
    prompt_title = "Stackgen Module Files",
    cwd = module_dir,
    hidden = true,
    no_ignore = true,
  }

  require("telescope.builtin").find_files(opts)
end

---@param id string
function M.get_module(id)
  --     local token = args[1]
  --     if not token or token == "" then
  --       vim.notify("StackGen: Please provide a token.", vim.log.levels.ERROR)
  --       return
  --     end
  --     config.set_token(token)
  --     ---@diagnostic disable-next-line: missing-fields
  --     vim.notify("Stackgen token set successfully.", vim.log.levels.INFO, {
  --       title = "Stackgen",
  --     })
  -- if not id or id == "" then
  --   error("Module ID is required")
  --   return
  -- end

  ---@param content stackgen_module
  api.get_module(id, function(content)
    local ok, result = pcall(modules.save_module_to_file, content)
    if not ok then
      error("Failed to save module: " .. result)
      return
    end

    local _
    ok, _ = pcall(modules.save_module_metadata, content, result)
    if not ok then
      error("Failed to set module metadata: " .. error)
      return
    end

    open_module_files_in_telescope(result)
  end)
end

---@param modules_list stackgen_module[]
local function open_module_names_in_telescope(modules_list)
  local opts = {
    prompt_title = "Stackgen Modules",
    previewer = false,
    results_title = "Available Modules",
  }

  pickers
    .new(opts, {
      prompt_title = "Stackgen Modules",
      finder = finders.new_table {
        results = modules_list,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
          }
        end,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()

          local ok, err = pcall(M.get_module, selection.value.id)
          if not ok then
            vim.notify("Failed to get module: " .. err, vim.log.levels.ERROR, {
              title = "Stackgen Module",
            })
            return
          end
        end)
        return true
      end,
    })
    :find()
end

function M.list_modules()
  ---@param modules_list stackgen_module[]
  api.list_modules(function(modules_list)
    if not modules_list or #modules_list == 0 then
      vim.notify("No modules found.", vim.log.levels.INFO, {
        title = "Stackgen Modules",
      })
      return
    end

    open_module_names_in_telescope(modules_list)
  end)
end

function M.sync_module()
  local module_metadata = modules.get_module_metadata()

  -- convert module files for API call
  local module_content = {}
  for _, file in ipairs(vim.fn.globpath(module_metadata.directory .. "*", "*", false, true)) do
    local file_name = vim.fn.fnamemodify(file, ":t")
    -- skip the config file
    if file_name ~= ".stackgen.config.json" then
      local file_content = vim.fn.readfile(file)
      module_content[file_name] = table.concat(file_content, "\n")
    end
  end

  local module_id = module_metadata.id
  local module_name = module_metadata.name
  api.sync_module(module_id, module_content, function(_)
    ---@diagnostic disable-next-line: missing-fields
    vim.notify("Module " .. module_name .. " synced successfully", vim.log.levels.INFO, {
      title = "Stackgen Module",
    })
  end)
end

---@param version string public version of the module
function M.publish_module(version)
  local module_metadata = modules.get_module_metadata()
  local module_id = module_metadata.id
  local module_name = module_metadata.name

  api.publish_module(module_id, version, function(_)
    ---@diagnostic disable-next-line: missing-fields
    vim.notify(
      "Version " .. version .. " for Module " .. module_name .. " published successfully",
      vim.log.levels.INFO,
      {
        title = "Stackgen Module",
      }
    )
  end)
end

function M.show_config()
  local config = require "stackgen.config"
  ---@diagnostic disable-next-line: missing-fields
  vim.notify("Stackgen Config: " .. vim.inspect(config.options), vim.log.levels.INFO, {
    title = "Stackgen Config",
  })
end

return M
