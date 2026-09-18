-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVim's built-in checktime only fires on FocusGained/TermClose/TermLeave,
-- which requires the terminal to report OS-level window focus. That doesn't
-- happen when switching between multiplexer panes in the same window, so also
-- check on CursorHold/CursorHoldI (updatetime = 200ms) to pick up external
-- edits (e.g. from Claude Code in another pane) almost immediately.
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("checktime_cursorhold", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})
