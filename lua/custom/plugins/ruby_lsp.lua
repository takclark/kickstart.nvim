return {
  "neovim/nvim-lspconfig",
  priority = 1001,
  config = function()
    -- Make add_ruby_deps_command global
    _G.add_ruby_deps_command = function(client, bufnr)
      vim.api.nvim_buf_create_user_command(bufnr, 'ShowRubyDeps', function(opts)
        local params = vim.lsp.util.make_text_document_params()
        local showAll = opts.args == 'all'

        client.request('rubyLsp/workspace/dependencies', params, function(error, result)
          if error then
            print('Error showing deps: ' .. error)
            return
          end

          local qf_list = {}
          for _, item in ipairs(result) do
            if showAll or item.dependency then
              table.insert(qf_list, {
                text = string.format('%s (%s) - %s', item.name, item.version, item.dependency),
                filename = item.path,
              })
            end
          end

          vim.fn.setqflist(qf_list)
          vim.cmd 'copen'
        end, bufnr)
      end, {
        nargs = '?',
        complete = function()
          return { 'all' }
        end,
      })
    end

    -- Use the ruby-lsp executable directly
    require('lspconfig').ruby_lsp.setup({
      cmd = {
        "/Users/tylerclark/.asdf/installs/ruby/3.1.6/bin/ruby-lsp"
      },
      root_dir = require('lspconfig.util').root_pattern("Gemfile", ".git"),
      on_attach = function(client, buffer)
        _G.add_ruby_deps_command(client, buffer)
      end,
      init_options = {
        enableExperimentalFeatures = false,
        formatter = { 
          command = "rubocop" 
        }
      }
    })
  end
}