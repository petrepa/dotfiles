-- Overrides on top of the `lazyvim.plugins.extras.lang.markdown` extra.
-- That extra deliberately strips render-markdown back to a minimal look:
-- `heading.icons = {}` and `checkbox.enabled = false`. Re-enable both.
-- Needs a Nerd Font in the terminal or the icons render as tofu boxes.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        width = "block",
        right_pad = 2,
      },
      checkbox = {
        enabled = true,
      },
      -- Also render while typing, not just in normal mode.
      render_modes = { "n", "c", "t", "i" },
    },
  },

  {
    "mfussenegger/nvim-lint",
    -- A function, not a table: lazy.nvim deep-merges table opts, so writing
    -- `linters_by_ft = { markdown = {} }` would merge *into* the extra's
    -- `{ "markdownlint-cli2" }` and change nothing.
    opts = function(_, opts)
      -- Markdown linting off — markdownlint-cli2's diagnostics are noise while
      -- writing prose. Drop these two lines to get it back.
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}

      -- Kept for when linting is re-enabled above: nvim-lint pipes the buffer
      -- over stdin, so markdownlint-cli2 resolves config relative to Neovim's
      -- cwd and does NOT walk up to parent directories. Point it at one global
      -- config so the rules apply wherever the file lives.
      opts.linters = opts.linters or {}
      opts.linters["markdownlint-cli2"] = {
        args = { "--config", vim.fn.expand("~/.config/nvim/markdownlint.yaml"), "-" },
      }

      return opts
    end,
  },
}
