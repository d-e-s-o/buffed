-- Copyright (C) 2021-2025 Daniel Mueller <deso@posteo.net>
-- SPDX-License-Identifier: GPL-3.0-or-later

local M = {}

-- Retrieve the number of the currently selected buffer.
local function SelectedBuffer()
  local cursor = vim.api.nvim_win_get_cursor(0)
  -- NB: It's important to use a synchronous (blocking) API here to make
  --     sure we have the necessary side effect in the next line.
  vim.api.nvim_feedkeys('^', 'x', true)
  local buf = vim.fn.expand('<cword>')
  -- Restore the previous cursor position.
  vim.api.nvim_win_set_cursor(0, cursor)
  return buf
end

function M.BuffedOpenBuffer()
  local b = SelectedBuffer()
  -- Switch back to the alternate buffer first, so that after the
  -- subsequent switch it is available as alternate, which makes for a
  -- more intuitive user experience.
  -- Note that this buffer could conceivably not exist, so catch any
  -- errors here.
  xpcall(function() vim.api.nvim_command('silent buffer!#') end, function(err) end)
  vim.api.nvim_command('silent buffer! ' .. b)
end

function M.BuffedDeleteBuffer()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)

  local b = SelectedBuffer()
  vim.api.nvim_command('silent bwipeout! ' .. b)

  -- Delete the currently selected line, now that the buffer has been
  -- wiped out already.
  local line = cursor[1] - 1
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, line, line + 1, false, {})
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

-- Assemble a string roughly resembling the output of `:ls`.
local function ListBuffers()
  -- Get the current list of buffers.
  local buf_list = vim.fn.getbufinfo()
  local bufs = {}

  for _, buf in ipairs(buf_list) do
    local flags = "  "

    -- Check if the buffer is the active or alternative one.
    if buf.bufnr == vim.fn.bufnr('%') then
      flags = "%a"
    elseif buf.bufnr == vim.fn.bufnr('#') then
      flags = "# "
    end

    -- If the buffer is modified, add the '+' flag.
    if buf.changed == 1 then
      flags = flags .. "+"
    else
      flags = flags .. " "
    end

    table.insert(bufs, string.format("%2d %s \"%s\"", buf.bufnr, flags, buf.name))
  end
  return bufs
end

-- Display a modifiable list of existing buffers.
function M.BuffedShowBuffers()
  local bufs = ListBuffers()

  -- Create an immutable scratch buffer that is wiped once hidden. Note
  -- that because this buffer is created after the `getbufinfo` call
  -- above, it won't actually show up in the buffer list itself.
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  -- Paste the buffer list to the new buffer/tab.
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, bufs)
  -- Set the buffer to non-modifiable
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  -- Add a mapping to Enter to open the buffer on the current line.
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Enter>', ':lua require("buffed").BuffedOpenBuffer()<CR>', {noremap = true, silent = true})
  -- Add a mapping to delete the buffer on the current line.
  vim.api.nvim_buf_set_keymap(buf, 'n', 'd', ':lua require("buffed").BuffedDeleteBuffer()<CR>', {noremap = true, silent = true})
  -- Add a mapping to quit, switching back to the previous buffer (and
  -- wiping the temporary one in the process).
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':buffer!#<CR>', {noremap = true, silent = true})

  vim.api.nvim_command("silent buffer!" .. buf)
end

return M
