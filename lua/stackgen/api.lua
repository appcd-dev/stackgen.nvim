local M = {}

local config = require "stackgen.config"

local Job = require "plenary.job"

---@class stackgen_module
---@field id string
---@field name string
---@field resourceType string
---@field cloudProvider string
---@field files table<string, string>

local function handle_response(output)
  local status_code = tonumber(output[#output])
  if status_code == nil then
    vim.notify("API request failed: no status code received", vim.log.levels.ERROR)
    return nil
  end

  table.remove(output, #output)
  local body = table.concat(output, "\n")

  if status_code >= 400 then
    vim.notify("API request failed: status code " .. status_code .. "\n" .. body, vim.log.levels.ERROR)
    return nil
  end

  local success, data = pcall(vim.json.decode, body)
  if not success then
    vim.notify("Failed to parse JSON response: " .. data, vim.log.levels.ERROR)
    return nil
  end

  return data
end

local list_modules_path = "/tf-module/v1/modules"

function M.list_modules(callback)
  local list_modules_endpoint = config.options.url .. list_modules_path

  ---@diagnostic disable-next-line: missing-fields
  Job:new({
    command = "curl",
    args = {
      "-s",
      "-w",
      "\n%{http_code}",
      "-H",
      "Authorization" .. ": Bearer " .. config.get_token(),
      list_modules_endpoint,
    },
    on_exit = function(job, _)
      vim.schedule(function()
        local body = handle_response(job:result())
        if not body then
          return
        end

        callback(body)
      end)
    end,
  }):start()
end

local get_module_path = "/tf-module/v1/modules/%s"

function M.get_module(id, callback)
  local get_module_endpoint = string.format(config.options.url .. get_module_path, id)

  ---@diagnostic disable-next-line: missing-fields
  Job:new({
    command = "curl",
    args = {
      "-s",
      "-w",
      "\n%{http_code}",
      "-H",
      "Authorization" .. ": Bearer " .. config.get_token(),
      get_module_endpoint,
    },
    on_exit = function(job, _)
      vim.schedule(function()
        local body = handle_response(job:result())
        if not body then
          return
        end

        callback(body)
      end)
    end,
  }):start()
end

local sync_module_path = "/tf-module/v1/modules/%s/files"

--- Syncs a module with the given ID and content
--- @param id string ID of the module to sync
--- @param content table<string, string> content to sync with the module
function M.sync_module(id, content, callback)
  local sync_module_endpoint = string.format(config.options.url .. sync_module_path, id)

  local payload = {
    files = content,
  }
  local payload_json = vim.fn.json_encode(payload)

  ---@diagnostic disable-next-line: missing-fields
  Job:new({
    command = "curl",
    args = {
      "-X",
      "PUT",
      "-s",
      "-w",
      "\n%{http_code}",
      "-H",
      "Authorization" .. ": Bearer " .. config.get_token(),
      "--data-raw",
      payload_json,
      sync_module_endpoint,
    },
    on_exit = function(job, _)
      vim.schedule(function()
        local body = handle_response(job:result())
        if not body then
          return
        end

        callback(body)
      end)
    end,
  }):start()
end

local publish_module_path = "/tf-module/v1/modules/%s/publish"

function M.publish_module(id, version, callback)
  local publish_module_endpoint = string.format(config.options.url .. publish_module_path, id)

  local payload = {
    version = version,
  }
  local payload_json = vim.fn.json_encode(payload)

  Job:new({
    command = "curl",
    args = {
      "-X",
      "POST",
      "-s",
      "-w",
      "\n%{http_code}",
      "-H",
      "Authorization" .. ": Bearer " .. config.get_token(),
      "--data-raw",
      payload_json,
      publish_module_endpoint,
    },
    on_exit = function(job, _)
      vim.schedule(function()
        local body = handle_response(job:result())
        if not body then
          return
        end

        callback(body)
      end)
    end,
  }):start()
end

local module_service_health_path = "/tf-module/v1/health"

function M.check_module_service_health(callback)
  local health_endpoint = config.options.url .. module_service_health_path

  ---@diagnostic disable-next-line: missing-fields
  Job:new({
    command = "curl",
    args = {
      "-s",
      "-w",
      "\n%{http_code}",
      "-H",
      "Authorization" .. ": Bearer " .. config.get_token(),
      health_endpoint,
    },
    on_exit = function(job, _)
      vim.schedule(function()
        local body = handle_response(job:result())
        if not body then
          return
        end

        callback(body)
      end)
    end,
  }):start()
end

return M
