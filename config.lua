-- local rainbow = require 'ts-rainbow'
--
require "nvim-treesitter.configs".setup {
    ensure_installed = {},
    highlight = {
        enable = true,
        -- nix-vim provide better syntax highlighting
        disable = { "nix" }
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<C-S-I>',
            scope_incremental = '<C-S-I>',
            node_incremental = '<C-S-K>',
            node_decremental = '<C-S-J>',
        },
    },
    -- rainbow = {
    --         query = {
    --            'rainbow-parens'
    --         },
    --         strategy = rainbow.strategy.global,
    --         hlgroups = {
    --            'TSRainbowRed',
    --            'TSRainbowYellow',
    --            'TSRainbowBlue',
    --            'TSRainbowOrange',
    --            'TSRainbowGreen',
    --            'TSRainbowViolet',
    --            'TSRainbowCyan'
    --         },
    --     -- enable = false,
    --     -- -- Which query to use for finding delimiters
    --     -- query = 'rainbow-parens',
    --     -- -- Highlight the entire buffer all at once
    --     -- strategy = require('ts-rainbow').strategy.global,
    -- }
}
