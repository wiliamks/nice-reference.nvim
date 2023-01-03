# nice-reference.nvim
A small neovim plugin to see LSP references in a popup window under the cursor.

![screenshot](screenshots/screenshot.png)

## Installation
Requires neovim > 0.5.0, install it with your favorite plugin manager

```lua
use { 
  'wiliamks/nice-reference.nvim', 
  requires = { 
    'kyazdani42/nvim-web-devicons' --optional
    { 'rmagatti/goto-preview', config = function() require('goto-preview').setup {} end } --optional
  } 
}
```

#### Optional dependencies
[nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons/) - For icons
[goto-preview](https://github.com/rmagatti/goto-preview) - For previewing in a floating window

## Setup

This plugin doesn't require calling the setup function, so you just need to call it if you want to customize it.

#### Default configuration
```lua
local actions = require 'nvim-reference.actions'

require 'nice-reference'.setup({
  anchor = "NW", -- Popup position anchor
  relative = "cursor", -- Popup relative position
  row = 1, -- Popup x position
  col = 0, -- Popup y position
  border = "rounded", -- Popup borderstyle
  winblend = 0, -- Popup transaparency 0-100, where 100 is transparent
  max_width = 120, -- Max width of the popup
  max_height = 10, -- Max height of the popup
  auto_choose = false, -- If true go to reference if there is only one
  use_icons = pcall(require, 'nvim-web-devicons'), -- Checks whether nvim-web-devicons is istalled
  mapping = {
  	['<CR>'] = actions.choose,
	['<Esc>'] = actions.close,
	['<C-c>'] = actions.close,
	['q'] = actions.close,
	['p'] = actions.preview,
	['t'] = actions.open_on_new_tab,
	['s'] = actions.open_split,
	['v'] = actions.open_vsplit,
	['<C-q>'] = actions.move_to_quick_fix,
	['<Tab>'] = actions.next,
	['<S-Tab>'] = actions.previous
  }
})
```

Then just map it to a keybind using the command
```vim
nnoremap <silent> gr <cmd>NiceReference<CR>
```

Or the lua function
```lua
vim.keymap.set("n", "gr", require 'nice-reference'.references)
```

or you can just use a handler instead
```lua
vim.lsp.handlers["textDocument/references"] = require 'nice-reference'.reference_handler
```

### Default mappings on the popup

| key    | function                                                      |
|--------|---------------------------------------------------------------|
| Enter  | Go to reference under the cursor                              |
| Escape | Exits the popup                                               |
| Ctrl+c | Exits the popup                                               |
| q      | Exits the popup                                               |
| p      | Preview reference in a floating window(requires goto-preview) |
| t      | Open reference under the cursor in a new tab                  |
| s      | Open reference under the cursor in a horizontal split         |
| v      | Open reference under the cursor in a vertical split           |
| Ctrl+q | Moves all items to quick fix window                           |
| Tab    | Move cursor down one line                                     |
| S-Tab  | Move cursor up one line                                       |

#### Custom keybindins
You can create custom commands on the setup using vim commands or lua functions. For example:
```lua
require 'nice-reference'.setup({
  mapping = {
    ['X'] = "echo 'X key pressed'",
    ['Y'] = function(items, current_item, encoding)
      print('Y key pressed')
    end
  }
})
```
if you are using a lua function it will call it with three parameters, ```items```, ```current_item``` and ```encoding```.
Item will be formated like this:
```lua
{
  col = 7,
  filename = "nice-reference.nvim/lua/nice-reference/init.lua",
  lnum = 7,
  text = "local config = {"
}
```
