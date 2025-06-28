local M = {}

local modules_dir = vim.fn.stdpath "data" .. "/stackgen" .. "/modules"
vim.fn.mkdir(modules_dir, "p")

---@param module stackgen_module
---@return string path to the saved module directory
function M.save_module_to_file(module)
  if not module or not module.id or not module.name then
    error "Invalid module provided for saving"
  end

  if not module.files or type(module.files) ~= "table" then
    error "Module files must be a table"
  end

  local module_dir = modules_dir .. "/" .. module.name .. "-" .. module.id
  vim.fn.mkdir(module_dir, "p")

  -- clean up existing files
  for _, file in ipairs(vim.fn.readdir(module_dir)) do
    os.remove(module_dir .. "/" .. file)
  end

  -- write each file in the module
  for file_name, content in pairs(module.files) do
    local file_path = module_dir .. "/" .. file_name
    local f = assert(io.open(file_path, "w"))
    f:write(content)
    f:close()
  end

  return module_dir
end

local module_metadata_file_name = ".stackgen.config.json"

---@class stackgen_metadata
---@field module stackgen_module_metadata

---@class stackgen_module_metadata
---@field id string
---@field name string
---@field directory string

function M.save_module_metadata(module, local_module_dir)
  if not module or not local_module_dir then
    error "Invalid module or local module directory provided for saving metadata"
  end

  local metadata = {
    module = {
      id = module.id,
      name = module.name,
      directory = local_module_dir,
    },
  }

  local metadata_file_path = local_module_dir .. "/" .. module_metadata_file_name
  local f = assert(io.open(metadata_file_path, "w"))
  f:write(vim.fn.json_encode(metadata))
  f:close()

  return metadata
end

---@return stackgen_module_metadata
function M.get_module_metadata()
  local file_path = vim.api.nvim_buf_get_name(0)
  if not file_path or file_path == "" then
    error "No file path found. Please open a Stackgen module file."
  end

  local dir = vim.fn.fnamemodify(file_path, ":p:h")
  local metadata_file_path = dir .. "/" .. module_metadata_file_name

  local stat, err = vim.loop.fs_stat(metadata_file_path)
  if not stat then
    error("Metadata file not found, not a StackGen module: " .. err)
  end

  local f = assert(io.open(metadata_file_path, "r"))
  local content = f:read "*a"
  f:close()

  local metadata = vim.fn.json_decode(content)
  if not metadata or not metadata.module then
    error "Invalid module metadata file"
  end

  return {
    id = metadata.module.id,
    name = metadata.module.name,
    directory = dir,
  }
end

return M
