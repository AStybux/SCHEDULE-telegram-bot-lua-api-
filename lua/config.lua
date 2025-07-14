local colors = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m"
}

-- Локальные функции
local l = {}
l.split = string.gmatch
l.match = string.match
l.coolf = string.format
l.int = tonumber
l.str = tostring
l.sub = string.sub
l.w2w = string.gsub

-- Дата и время
local bd = {}
bd.date = os.date()
bd.st = os.clock()

for word in string.gmatch(bd.date, "%S+") do
    table.insert(bd, word)
end

local t = {}
t.d1 = bd[1]
t.m = bd[2]
t.d2 = bd[3]
t.t = bd[4]
t.y = bd[5]

-- Функции для работы с форматированием
local f = {}
f.mark = function(t) return l.coolf("\27[%d;%dH%s\n", t.y, t.x, t.s) end
f.nsum = function(n) local s = 0; for d in l.str(n):gmatch("%d") do s = s + l.int(d) end; return s end

-- Параметры для логирования
local p = {}
p.text = "colortext (n)\27[0m"
p.n = 0
p.lw2we = function(text) local s = l.w2w(p.text, "color", colors.red) s = l.w2w(s, "n", p.n) s = l.w2w(s, "%w+", t) s = l.w2w(s, "text", text) return s end
p.lw2wn = function(text) local s = l.w2w(p.text, "color", colors.green) s = l.w2w(s, "n", p.n) s = l.w2w(s, "%w+", t) s = l.w2w(s, "text", text) return s end
p.lw2ww = function(text) local s = l.w2w(p.text, "color", colors.yellow) s = l.w2w(s, "n", p.n) s = l.w2w(s, "%w+", t) s = l.w2w(s, "text", text) return s end
p.el = p.lw2we("ОШИБКА НЕВЕРНЫЙ ТИП ДАННЫХ НУЖНА СТРОКА")
p.s = ""
p.error = function(e, ee) ee = ee or 0 ee = string.rep("\n", ee) p.n = p.n + 1 local s = "" if type(e) == "string" or type(e) == "number" then s = p.lw2we(e, p.n) else s = p.el end return l.coolf("%s%s", ee, s) end
p.normal = function(e, ee) ee = ee or 0 ee = string.rep("\n", ee) p.n = p.n + 1 local s = "" if type(e) == "string" or type(e) == "number" then s = p.lw2wn(e, p.n) else s = p.el end return l.coolf("%s%s", ee, s) end
p.warning = function(e, ee) ee = ee or 0 ee = string.rep("\n", ee) p.n = p.n + 1 local s = "" if type(e) == "string" or type(e) == "number" then s = p.lw2ww(e, p.n) else s = p.el end return l.coolf("%s%s", ee, s) end

-- Функции для работы с файлами
local af = {}
af.c1605p1 = function(filename, tbl) 
    local file = io.open(filename, "w")
    if not file then
        p.error("Не удалось открыть файл для записи.")
        return
    end

    for _, row in ipairs(tbl) do
        local escaped = {}
        for _, value in ipairs(row) do
            if string.find(value, '[,"]') then
                value = '"' .. l.w2w(value, '"', '""') .. '"'
            end
            table.insert(escaped, value)
        end

        local line = table.concat(escaped, ",")
        file:write(line .. "\n")
    end

    file:close()
    p.normal("Таблица успешно записана в файл: " .. filename)
end

af.c1605p2 = function(filename)
    local file = io.open(filename, "r")
    if not file then
        p.error("Не удалось открыть файл для чтения.")
        return nil
    end

    local tbl = {}

    local function parseCSVLine(line)
        local res = {}
        local pos = 1
        local len = #line
        while pos <= len do
            if l.sub(line, pos, pos) == '"' then
                local start_pos = pos + 1
                local end_pos = start_pos
                repeat
                    end_pos = string.find(line, '"', end_pos)
                    if not end_pos then break end
                    if l.sub(line, end_pos + 1, end_pos + 1) == '"' then
                        end_pos = end_pos + 2
                    else
                        break
                    end
                until false
                local value = l.sub(line, start_pos, end_pos - 1)
                value = l.w2w(value, '""', '"')
                table.insert(res, value)
                pos = end_pos + 2
                if l.sub(line, pos, pos) == "," then
                    pos = pos + 1
                end
            else
                local comma_pos = string.find(line, ",", pos)
                if comma_pos then
                    local value = l.sub(line, pos, comma_pos - 1)
                    table.insert(res, value)
                    pos = comma_pos + 1
                else
                    local value = l.sub(line, pos)
                    table.insert(res, value)
                    break
                end
            end
        end
        return res
    end

    for line in file:lines() do
        local row = parseCSVLine(line)
        table.insert(tbl, row)
    end

    file:close()
    p.normal("Таблица успешно прочитана из файла: " .. filename)
    return tbl
end

-- Настройки для бота
local tbl = {}
tbl.text = "text"
tbl.m2b = "{mc} --> БОТ"
tbl.b2m = "БОТ --> {mc}"
tbl.mb = ""
tbl.ml = ""
tbl.username = ""
tbl.id = ""
tbl.m = ""
tbl.fnuser = ""

tbl.users = {
    hexagontal_4k = {"A"}
}

tbl.nusers = {n = 0}
tbl.fuser = "message_#{l}"
tbl.l = ""
tbl.work = true

-- Логирование
local lt = {}
lt.sm = "Получено сообщение"
lt.am = "Отправлено сообщение"

-- Путь для сохранения файлов
local s = {}
s.path = ""

-- Возвращаем все настройки
return {
    colors = colors,
    l = l,
    bd = bd,
    t = t,
    f = f,
    p = p,
    af = af,
    tbl = tbl,
    lt = lt,
    s = s
}
