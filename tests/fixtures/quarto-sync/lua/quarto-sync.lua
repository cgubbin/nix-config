return {
  setup = function()
    vim.g.quarto_sync_fixture_setups = (vim.g.quarto_sync_fixture_setups or 0) + 1
    vim.api.nvim_create_user_command("QuartoSyncPreview", function(args)
      vim.g.quarto_sync_fixture_preview = args.fargs[1]
    end, { nargs = "*" })
  end,
}
