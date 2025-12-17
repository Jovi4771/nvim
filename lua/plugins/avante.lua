-- lua/plugins/avante.lua
return {
  "yetone/avante.nvim",
  -- 建議讓它 VeryLazy 或在你常用的事件載入
  event = "VeryLazy",
  build = "make",
  dependencies = {
    -- 必要相依
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",

    -- 你原本的選用相依
    "nvim-treesitter/nvim-treesitter",
    "stevearc/stickybuf.nvim",
    "nvim-mini/mini.pick",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "ibhagwan/fzf-lua",
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
  },

  -- ✅ 只用 opts，不做 config 副作用
  opts = {
    -- 預設 provider
    provider = "qwen3_coder_30b",

    providers = {
      qwen3_coder_30b = {
        __inherited_from = "openai",
        -- vLLM 的 OpenAI 兼容 API base_url 指向 /v1
        endpoint = "http://vllm.phison.com/Qwen3-Coder-30B-A3B-Instruct/v1",
        api_key_name = "AVANTE_OPENAI_API_KEY",
        model = "Qwen3-Coder-30B-A3B-Instruct",

        -- （可選）額外請求參數：你需要時再開啟
        timeout = 30000,
        extra_request_body = {
          temperature = 0.7,
          max_completion_tokens = 4096
        },
      },
    },

    ui = {
      layout = "float",
      icons = {},
      mappings = {},
    },

    agent = {
      -- 內建 diff/Apply Change UI
    },
  },
}
