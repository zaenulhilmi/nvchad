require("CopilotChat").setup({
    model = "gpt-4",
    debug = true,
    show_help = false,

})

local function prompt_actions(mode)
    local actions = require("CopilotChat.actions")

    return function()
        if mode == 'v' then
            local select = require("CopilotChat.select")
            require("CopilotChat.integrations.fzflua").pick(actions.prompt_actions(
                {
                    selection = select.visual,
                }
            ))
            return
        end
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
    end
end



vim.api.nvim_set_keymap('n', '<leader>cc', '<Nop>', {
    callback = function()
        local chat = require("CopilotChat")
        chat.toggle({ window = { layout = "vertical" } })
    end
})

local function quick_chat()
    local input = vim.fn.input("Quick Chat: ")
    if input ~= "" then
        require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
    end
end


vim.api.nvim_set_keymap('n', '<leader>cca', '<Nop>', { callback = prompt_actions('n') })
vim.api.nvim_set_keymap('v', '<leader>cca', '<Nop>', { callback = prompt_actions('v') })
vim.api.nvim_set_keymap('n', '<leader>ccq', '<Nop>', { callback = quick_chat })
