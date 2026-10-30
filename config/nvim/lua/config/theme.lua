local M = {}

M.palette = {
    bg = "#1c1c1c",
    fg = "#e2e2e9",
    accent = "#ff4e20",
    accent_soft = "#ff6b4a",
    selection = "#3c3836",
    black = "#282828",
    grey = "#504945",
    red = "#ff4e20",
    red_bright = "#ff6b4a",
    green = "#859900",
    green_bright = "#98971a",
    yellow = "#d79921",
    yellow_bright = "#fabd2f",
    blue = "#458588",
    blue_bright = "#83a598",
    magenta = "#b16286",
    magenta_bright = "#d3869b",
    cyan = "#689d6a",
    cyan_bright = "#8ec07c",
    white = "#a89984",
    white_bright = "#ebdbb2",
}

function M.setup()
    local p = M.palette
    vim.cmd("highlight clear")
    if vim.g.syntax_on then
        vim.cmd("syntax reset")
    end
    vim.g.colors_name = "inari"
    vim.o.background = "dark"

    local groups = {
        Normal = { fg = p.fg, bg = p.bg },
        NormalNC = { fg = p.fg, bg = p.bg },
        NormalFloat = { fg = p.fg, bg = p.bg },
        FloatBorder = { fg = p.accent, bg = p.bg },
        FloatTitle = { fg = p.accent_soft, bg = p.bg, bold = true },
        SignColumn = { fg = p.white, bg = p.bg },
        EndOfBuffer = { fg = p.grey, bg = p.bg },
        Cursor = { fg = p.bg, bg = p.accent },
        lCursor = { fg = p.bg, bg = p.accent },
        CursorLine = { bg = p.black },
        CursorLineNr = { fg = p.accent, bold = true },
        LineNr = { fg = p.grey },
        Visual = { fg = p.fg, bg = p.selection },
        Search = { fg = p.bg, bg = p.yellow_bright },
        IncSearch = { fg = p.bg, bg = p.accent_soft, bold = true },
        CurSearch = { fg = p.bg, bg = p.accent, bold = true },
        MatchParen = { fg = p.accent_soft, bold = true, underline = true },
        Pmenu = { fg = p.fg, bg = p.black },
        PmenuSel = { fg = p.bg, bg = p.accent_soft, bold = true },
        PmenuSbar = { bg = p.selection },
        PmenuThumb = { bg = p.accent },
        StatusLine = { fg = p.fg, bg = p.black },
        StatusLineNC = { fg = p.white, bg = p.bg },
        WinSeparator = { fg = p.grey, bg = p.bg },
        VertSplit = { fg = p.grey, bg = p.bg },
        TabLine = { fg = p.white, bg = p.bg },
        TabLineSel = { fg = p.accent, bg = p.black, bold = true },
        TabLineFill = { bg = p.bg },
        Title = { fg = p.accent_soft, bold = true },
        Directory = { fg = p.blue_bright },
        NonText = { fg = p.grey },
        SpecialKey = { fg = p.grey },
        Folded = { fg = p.white, bg = p.black },
        FoldColumn = { fg = p.grey, bg = p.bg },
        Comment = { fg = p.grey, italic = true },
        Constant = { fg = p.yellow_bright },
        String = { fg = p.green_bright },
        Character = { fg = p.green },
        Number = { fg = p.yellow_bright },
        Boolean = { fg = p.yellow_bright },
        Float = { fg = p.yellow_bright },
        Identifier = { fg = p.blue_bright },
        Function = { fg = p.accent_soft },
        Statement = { fg = p.accent },
        Conditional = { fg = p.accent },
        Repeat = { fg = p.accent },
        Label = { fg = p.accent_soft },
        Operator = { fg = p.white },
        Keyword = { fg = p.accent, bold = true },
        Exception = { fg = p.accent },
        PreProc = { fg = p.magenta_bright },
        Include = { fg = p.magenta_bright },
        Define = { fg = p.magenta_bright },
        Macro = { fg = p.magenta_bright },
        Type = { fg = p.blue_bright },
        StorageClass = { fg = p.accent },
        Structure = { fg = p.blue_bright },
        Typedef = { fg = p.blue_bright },
        Special = { fg = p.cyan_bright },
        SpecialChar = { fg = p.cyan_bright },
        Delimiter = { fg = p.white },
        Underlined = { underline = true },
        Error = { fg = p.red_bright, bold = true },
        Todo = { fg = p.yellow_bright, bold = true },
        DiagnosticError = { fg = p.red_bright },
        DiagnosticWarn = { fg = p.yellow_bright },
        DiagnosticInfo = { fg = p.blue_bright },
        DiagnosticHint = { fg = p.cyan_bright },
        DiagnosticOk = { fg = p.green_bright },
        DiagnosticUnderlineError = { undercurl = true, sp = p.red_bright },
        DiagnosticUnderlineWarn = { undercurl = true, sp = p.yellow_bright },
        DiagnosticUnderlineInfo = { undercurl = true, sp = p.blue_bright },
        DiagnosticUnderlineHint = { undercurl = true, sp = p.cyan_bright },
        DiagnosticVirtualTextError = { fg = p.red_bright, bg = p.black },
        DiagnosticVirtualTextWarn = { fg = p.yellow_bright, bg = p.black },
        DiagnosticVirtualTextInfo = { fg = p.blue_bright, bg = p.black },
        DiagnosticVirtualTextHint = { fg = p.cyan_bright, bg = p.black },
        TelescopeNormal = { fg = p.fg, bg = p.bg },
        TelescopeBorder = { fg = p.grey, bg = p.bg },
        TelescopePromptNormal = { fg = p.fg, bg = p.black },
        TelescopePromptBorder = { fg = p.accent, bg = p.black },
        TelescopePromptTitle = { fg = p.bg, bg = p.accent, bold = true },
        TelescopePreviewTitle = { fg = p.bg, bg = p.blue, bold = true },
        TelescopeResultsTitle = { fg = p.bg, bg = p.grey, bold = true },
        TelescopeSelection = { fg = p.fg, bg = p.selection, bold = true },
        TelescopeMatching = { fg = p.accent_soft, bold = true },
        WhichKey = { fg = p.accent_soft },
        WhichKeyGroup = { fg = p.blue_bright },
        WhichKeyDesc = { fg = p.fg },
    }

    for name, spec in pairs(groups) do
        vim.api.nvim_set_hl(0, name, spec)
    end
    vim.api.nvim_set_hl(0, "@variable", { fg = p.fg })
    vim.api.nvim_set_hl(0, "@function", { fg = p.accent_soft })
    vim.api.nvim_set_hl(0, "@function.call", { fg = p.accent_soft })
    vim.api.nvim_set_hl(0, "@keyword", { fg = p.accent, bold = true })
    vim.api.nvim_set_hl(0, "@type", { fg = p.blue_bright })
    vim.api.nvim_set_hl(0, "@constant", { fg = p.yellow_bright })
    vim.api.nvim_set_hl(0, "@string", { fg = p.green_bright })
    vim.api.nvim_set_hl(0, "@comment", { fg = p.grey, italic = true })
end

return M
