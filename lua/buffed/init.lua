-- Copyright (C) 2021-2024 Daniel Mueller <deso@posteo.net>
-- SPDX-License-Identifier: GPL-3.0-or-later

local M = {}

function M.BuffedOpenBuffer()
  vim.api.nvim_input("^:bw! | buffer!<C-r><C-w><CR>")
end

function M.BuffedDeleteBuffer()
  vim.api.nvim_input("^:set modifiable | bw!<C-r><C-w> | delete | set nomodifiable<CR>")
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
