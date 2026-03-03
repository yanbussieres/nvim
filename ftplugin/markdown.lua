vim.keymap.set('n', '<CR>', function()
  vim.lsp.buf.definition {
    on_list = function(list)
      local seen = {}
      list.items = vim.tbl_filter(function(item)
        if seen[item.filename] then return false end
        seen[item.filename] = true
        return true
      end, list.items)
      vim.fn.setqflist({}, ' ', { title = list.title, items = list.items })
      vim.cmd 'cfirst'
    end,
  }
end, { buffer = true, desc = 'Follow [M]arkdown link' })
