local M = {}
M.screen = {
    next_raffle = nil,
    raffle = nil,
    prize_cards = nil,
    prizes = nil
}

M.raffle = {
    cards = {},
    board_coup_info_grid = nil,
    balls_nodes = {}
}

M.sequence = 0

function M.turn_on_lights(id, n, t, callback, d)
    gui.play_particlefx(gui.get_node(id .. "particlefx" .. 1))
    for i = 2 , n do
        timer.delay((i-2) * t, false, function ()
            gui.play_particlefx(gui.get_node(id .. "particlefx" .. i))
            if i == n and callback then
                if not d then d = 0.5 end
                timer.delay(d, false, function ()
                    callback()
                end)
            end
        end)
    end
end
local function remove_duplicate(value)
    local duplicates = {}
    local table_to_return = {}

    for _, v in ipairs(value) do
        if not duplicates[v] then
            table.insert(table_to_return, v)
            duplicates[v] = true
        end
    end

    return table_to_return
end

local function string_to_table(str)
    local t = {}

    str:gsub(".", function(c) table.insert(t, c) end)
    return t
end

-- VALORES INTEIROS FUNCIONAM COM ATE 14 DIGITOS, SE QUEBRAR O NUMERO EM 14 DIGITOS E CONTATENAR VAI FUNCIONAR, STRING NAO TEM LIMITE
function M.money_mask(value, mask)
    mask = mask or ".,"
    local symbols = remove_duplicate(string_to_table(mask:gsub("%d","")))

    if #symbols <= 1 then
        error("must have at least 2 punctuation. ex: 0,000.00")
    end

    local negative = ""
    if value < 0 then negative = "-" end

    local mask_no_punct = mask:gsub("%p", "")
    local money_string = tostring(math.abs(value))
    local convert_to_mask = mask_no_punct:gsub("%d", "", #money_string)
    money_string = convert_to_mask .. math.abs(value)

    if #money_string == 1 then return negative .. "0" .. symbols[2] .. "0" .. money_string end
    if #money_string == 2 then return negative .. "0" .. symbols[2] .. money_string end

    local cents = string.sub(money_string, #money_string:reverse() - 1)
    local money = string.sub(money_string, 1 , #money_string - 2)

    -- COLOCANDO OS PONTOS
    local money_formated = money:reverse():gsub("(%d%d%d)", "%1" .. symbols[1])
    local is_reversed = false

    -- RETIRANDO PONTO NO FINAL DA STRING
    if money_formated:sub(#money_formated) == symbols[1] then
        money_formated = money_formated:reverse():gsub("%" .. symbols[1], "", 1)
        is_reversed = true
    end

    if not is_reversed then money_formated = money_formated:reverse() end

    local result = negative .. money_formated .. symbols[2] .. cents

    return result
end

function M.update_card(card, info)
    gui.set_text(card["prize_card/title"], info.title)
    gui.set_text(card["prize_card/id"], info.id)
    gui.set_text(card["prize_card/value"], "R$".. M.money_mask(tonumber(info.value)))
    for i = 1, 15 do
        gui.set_text(card["prize_card/pos_txt_"..i], info.nums[i][1])
        gui.set_visible(card["prize_card/pos"..i], info.nums[i][2])
    end
end

local cards_info = {}
local coupons = {}
local balls = {}
M.prize_cards_info = {
    prize1 = {},
    prize2 = {},
    prize3 = {}
}
M.prize_coupons = {
}

function M.get_coupons() return coupons end
function M.set_coupons(v) coupons = v end
function M.get_cards_info() return cards_info end
function M.set_cards_info(v) cards_info = v end
function M.get_balls() return balls end
function M.set_balls(v) balls = v end
return M