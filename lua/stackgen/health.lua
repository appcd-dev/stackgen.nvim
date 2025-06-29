local M = {}

local config = require "stackgen.config"

local module_service_health_path = "/tf-module/v1/health"

M.check = function()
  vim.health.start "Checking if StackGen API is reachable"

  local health_endpoint = config.options.url .. module_service_health_path
  local cmd =
    { "curl", "-s", "-w", "\n%{http_code}", "-H", "Authorization: Bearer " .. config.get_token(), health_endpoint }

  local result = vim.system(cmd):wait()

  local output = result.stdout
  if not output then
    vim.health.error "StackGen is not reachable, try setting the correct URL in your config or set PAT using :StackGen set_token cmd"
    return
  end

  local http_code = output:match "\n(%d+)$"
  local body = output:gsub("\n%d+$", "")

  if tonumber(http_code) == 200 then
    local ok, decoded = pcall(vim.json.decode, body)
    if ok and decoded.status == "up" then
      vim.health.ok "StackGen is healthy"
    else
      vim.health.error "StackGen is not reachable, try setting the correct URL in your config or set PAT using :StackGen set_token cmd"
    end
  else
    vim.health.error("StackGen is not reachable, HTTP " .. (http_code or "unknown"))
  end
end

M.check()

return M
