local M = {}

local config_path = vim.fn.stdpath "data" .. "/stackgen/config.json"

---@class StackgenConfig
---@field url string The base URL for the Stackgen API
M.options = {
  url = "https://cloud.stackgen.com",
}

M._token = nil

function M.setup(opts)
  opts = opts or {}
  if opts.url then
    opts.url = opts.url:gsub("/$", "") -- Ensure no trailing slash
  end
  M.options = vim.tbl_deep_extend("force", M.options, opts)
  M.load_token()
end

function M.set_token(token)
  M._token = token
  M.save_token()
end

function M.get_token()
  if not M._token then
    return "token"
  end

  return M._token
end

function M.save_token()
  vim.fn.mkdir(vim.fn.stdpath "data" .. "/stackgen", "p")
  local data = { token = M._token }
  local f = assert(io.open(config_path, "w"))
  f:write(vim.fn.json_encode(data))
  f:close()
end

function M.load_token()
  local f = io.open(config_path, "r")
  if f then
    local content = f:read "*a"
    local ok, decoded = pcall(vim.fn.json_decode, content)
    if ok and decoded and decoded.token then
      M._token = decoded.token
    end
    f:close()
  end
end

return M
