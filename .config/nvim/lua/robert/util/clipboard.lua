-- lua/robert/util/clipboard.lua

return function(text)
  vim.fn.setreg('+', text)
  vim.api.nvim_echo({ { string.format('copied "%s" to clipboard', text) } }, false, {})
end
