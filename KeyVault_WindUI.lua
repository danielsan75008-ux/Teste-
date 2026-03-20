-- ================================================================
--  KeyVault — Sistema de Key com Wind UI v2
--  Cole no Delta e execute
-- ================================================================

local HttpService  = game:GetService("HttpService")
local Players      = game:GetService("Players")
local player       = Players.LocalPlayer

-- ================================================================
--  CONFIG
-- ================================================================
local BIN_ID = "69bce0feaa77b81da9ffb9ee"
local URL    = "https://api.jsonbin.io/v3/b/" .. BIN_ID .. "/latest"

-- ================================================================
--  CARREGA WIND UI v2
-- ================================================================
local WindUI
local ok, err = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
end)

if not ok then
    warn("[KeyVault] Falha ao carregar Wind UI: " .. tostring(err))
    return
end

-- ================================================================
--  FUNÇÃO: Busca key válida no jsonbin
-- ================================================================
local function getValidKey()
    local success, result = pcall(function()
        return HttpService:GetAsync(URL, true)
    end)
    if not success then return nil end
    local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, result)
    if not ok2 then return nil end
    if decoded and decoded.record and decoded.record.key then
        return decoded.record.key
    end
    return nil
end

-- ================================================================
--  CRIA A JANELA COM WIND UI v2
-- ================================================================
local Window = WindUI:CreateWindow({
    Title       = "KeyVault",
    Icon        = "lock",
    Author      = "Sistema de Key",
    Folder      = "KeyVault",
    Size        = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme       = "Dark",
    Background  = true,
    Acrylic     = true,
    MenuOpen    = true,
})

-- ================================================================
--  TABS
-- ================================================================
local TabKey  = Window:Tab({ Title = "Key",  Icon = "key-round"    })
local TabInfo = Window:Tab({ Title = "Info", Icon = "info"          })

-- ================================================================
--  TAB: KEY
-- ================================================================
local SecKey = TabKey:Section({ Title = "Verificação de Acesso", Side = "Left" })

-- Input da key
local keyInput = ""

SecKey:Input({
    Title       = "Sua Key",
    Description = "Cole a key que você recebeu",
    Placeholder = "XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    Callback    = function(value)
        keyInput = value
    end,
})

-- Status label
local statusParagraph = SecKey:Paragraph({
    Title   = "Status",
    Content = "Aguardando verificação...",
})

-- Botão verificar
SecKey:Button({
    Title       = "Verificar Key",
    Description = "Clique para validar sua key",
    Callback    = function()

        if keyInput == "" then
            statusParagraph:Set({
                Title   = "⚠ Atenção",
                Content = "Cole sua key no campo acima antes de verificar.",
            })
            WindUI:Notify({
                Title   = "Campo vazio",
                Content = "Digite ou cole sua key primeiro.",
                Icon    = "alert-circle",
                Time    = 4,
            })
            return
        end

        -- Buscando
        statusParagraph:Set({
            Title   = "⏳ Verificando...",
            Content = "Consultando o servidor, aguarde.",
        })

        task.spawn(function()
            local validKey = getValidKey()

            if validKey == nil then
                -- Erro de conexão
                statusParagraph:Set({
                    Title   = "✕ Erro de Conexão",
                    Content = "Não foi possível conectar ao servidor. Verifique sua internet.",
                })
                WindUI:Notify({
                    Title   = "Erro de Conexão",
                    Content = "Não foi possível verificar a key. Tente novamente.",
                    Icon    = "wifi-off",
                    Time    = 5,
                })

            elseif keyInput == validKey then
                -- KEY CORRETA ✓
                statusParagraph:Set({
                    Title   = "✓ Acesso Liberado!",
                    Content = "Key válida. Carregando script...",
                })
                WindUI:Notify({
                    Title   = "Acesso Liberado!",
                    Content = "Key verificada com sucesso. Bem-vindo!",
                    Icon    = "check-circle",
                    Time    = 4,
                })

                task.wait(1)

                -- Fecha a janela
                Window:Destroy()

                -- Executa o script principal
                loadstring(game:HttpGet("https://raw.githubusercontent.com/danielsan75008-ux/Teste-/refs/heads/main/E%20vc%20e%20corno"))()

            else
                -- KEY ERRADA ✗
                statusParagraph:Set({
                    Title   = "✕ Key Inválida",
                    Content = "A key informada não é válida ou foi alterada.",
                })
                WindUI:Notify({
                    Title   = "Key Invalid",
                    Content = "🇧🇷 Key invalida vá até o nosso Discord pegar a versão atualizada\n🇺🇸 Invalid key, go to our Discord server to get the updated version.",
                    Icon    = "x-circle",
                    Time    = 20,
                })
            end
        end)
    end,
})

-- ================================================================
--  TAB: INFO
-- ================================================================
local SecInfo = TabInfo:Section({ Title = "Sobre o Sistema", Side = "Left" })

SecInfo:Paragraph({
    Title   = "Como funciona?",
    Content = "Este sistema verifica sua key em tempo real. Quando o dono do script atualizar a key, a antiga para de funcionar imediatamente.",
})

SecInfo:Paragraph({
    Title   = "Key Inválida?",
    Content = "Se sua key não funcionar, pode ter sido alterada pelo administrador. Entre em contato para obter a key atual.",
})

SecInfo:Paragraph({
    Title   = "KeyVault System",
    Content = "Powered by jsonbin.io • Wind UI v2",
})
