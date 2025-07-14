local json = require("dkjson") -- Подключаем библиотеку для работы с JSON
local schedule = require('schedule') -- Подключаем файл schedule.lua
local config = require('config') -- Подключаем файл конфигурации
local Logit, LogLevel = require("logit")() 
local os = require("os") -- Для работы с датами

local l = config.l

local commands = {}

local text_add=[[/add <название> <дата YYYY-MM-DD> <время> ```lua
/add "ОСНОВЫ МОЛЕКУЛЯРНОЙ ФИЗИКИ" 2025-14-09 8:52
```]]

-- Экранируем специальные символы
text_add = text_add :gsub("([%[%]])", "\\%1") -- Экранируем [ и ]
--text_add = text_add :gsub("([%_%*%`%~%>%#%+%=%-])", "\\%1")
text_add = text_add :gsub("([%>%-])", "\\%1")
-- Функция для обработки команды /add
function commands.add(tbl)
    local eventDetails = {}
    
    -- Используем регулярное выражение для парсинга команды
    local description, date, time = tbl.m:match("^/add%s+(.+)%s+(%d%d%d%d%-%d%d%-%d%d)%s+(.+)$")

    if description and date and time then
        schedule.addEvent(date, time, description) -- Добавляем событие в расписание
        schedule.saveScheduleToFile("schedule.txt") -- Сохраняем расписание в файл

        tbl.mb = l.w2w('\nСОБЫТИЕ ОТ ПОЛЬЗОВАТЕЛЯ [@{u}] СОБЫТИЕ: {description} на {date} в {time}', "{u}", tbl.username)
        tbl.mb = l.w2w(tbl.mb, "{date}", date)
        tbl.mb = l.w2w(tbl.mb, "{time}", time)
	    tbl.mb = l.w2w(tbl.mb, "{description}", description)

        -- Сохраняем данные пользователя в data.json
        local userData = {
            username = tbl.username,
            event_description = description,
            event_date = date,
            event_time = time
        }

        -- Читаем существующие данные из data.json
        local file = io.open("data.json", "r")
        local data = {}
        if file then
            local content = file:read("*a")
            data = json.decode(content) or {}
            file:close()
        end

        -- Добавляем нового пользователя
        table.insert(data, userData)

        -- Сохраняем обновленные данные обратно в data.json
        file = io.open("data.json", "w")
        if file then
            file:write(json.encode(data, { indent = true }))
            file:close()
        end

        -- Логгирование
        local log = Logit:new(".", "add_event", nil, true, true)
        log:start()
		tbl.mb=l.coolf("%s %s","Добавлено событие:", tbl.mb)
        log(LogLevel.INFO, tbl.mb)
        log:finish()
    else
        tbl.mb = "Неверный формат команды\\."
		tbl.mb = l.coolf("%s %s",tbl.mb,text_add)
    end

	-- Экранируем специальные символы
	tbl.mb = tbl.mb:gsub("([%[%]])", "\\%1") -- Экранируем [ и ]
	tbl.mb = tbl.mb:gsub("([%_%*%`%~%>%#%+%=%-%{%}])", "\\%1")

    return tbl.mb
end

-- Функция для обработки команды /schedule
function commands.schedule(tbl)
    tbl.mb = text_add

    -- Логгирование
    local log = Logit:new(".", "schedule_command", nil, true, true)
    log:start()
    log(LogLevel.INFO, "Пользователь " .. tbl.username .. " запросил информацию о расписании.")
    log:finish()

	return tbl.mb
end

function commands.help(tbl)
    tbl.mb = [[Обычные команды:
    /today - расписание на сегодня
    /tomorrow - расписание на завтра
    /schedule - памятка о /add

    Интерактивные команды:
    /add - добавление нового события
    Не забудьте подтвердить ваше новое событие]]

    -- Логгирование
    local log = Logit:new(".", "help_command", nil, true, true)
    log:start()
    log(LogLevel.INFO, "Пользователь " .. tbl.username .. " запросил помощь.")
    log:finish()

	return tbl.mb
end

-- Функция для обработки команды /today
function commands.today(tbl)
    local todayDate = os.date("%Y-%m-%d") -- Получаем сегодняшнюю дату
    local todaySchedule = "Расписание на сегодня:\n"
    local events = loadEvents()

    for _, event in ipairs(events) do
        if event.event_date == todayDate then
            todaySchedule = todaySchedule .. string.format("- %s в %s: %s\n", event.event_date, event.event_time, event.event_description)
        end
    end

    if todaySchedule == "Расписание на сегодня:\n" then
        todaySchedule = "Нет мероприятий на сегодня."
    end

    -- Логгирование
    local log = Logit:new(".", "today_command", nil, true, true)
    log:start()
    log(LogLevel.INFO, "Пользователь " .. tbl.username .. " запросил расписание на сегодня.")
    log:finish()

    return todaySchedule
end

-- Функция для обработки команды /tomorrow
function commands.tomorrow(tbl)
    local tomorrowDate = os.date("%Y-%m-%d", os.time() + 86400) -- Получаем завтрашнюю дату
    local tomorrowSchedule = "Расписание на завтра:\n"
    local events = loadEvents()

    for _, event in ipairs(events) do
        if event.event_date == tomorrowDate then
            tomorrowSchedule = tomorrowSchedule .. string.format("- %s в %s: %s\n", event.event_date, event.event_time, event.event_description)
        end
    end

    if tomorrowSchedule == "Расписание на завтра:\n" then
        tomorrowSchedule = "Нет мероприятий на завтра."
    end

    -- Логгирование
    local log = Logit:new(".", "tomorrow_command", nil, true, true)
    log:start()
    log(LogLevel.INFO, "Пользователь " .. tbl.username .. " запросил расписание на завтра.")
    log:finish()

    return tomorrowSchedule
end

-- Функция для обработки команды /week
function commands.week(tbl)
    local weekSchedule = "Расписание на неделю:\n"
    local events = loadEvents()
    local currentDate = os.time()

    for i = 0, 6 do
        local date = os.date("%Y-%m-%d", currentDate + (i * 86400)) -- Получаем дату на i-й день от текущей даты
        for _, event in ipairs(events) do
            if event.event_date == date then
                weekSchedule = weekSchedule .. string.format("- %s в %s: %s\n", event.event_date, event.event_time, event.event_description)
            end
        end
    end

    if weekSchedule == "Расписание на неделю:\n" then
        weekSchedule = "Нет мероприятий на этой неделе."
    end

    -- Логгирование
    local log = Logit:new(".", "week_command", nil, true, true)
    log:start()
    log(LogLevel.INFO, "Пользователь " .. tbl.username .. " запросил расписание на неделю.")
    log:finish()

    return weekSchedule
end

-- Функция для загрузки событий из data.json
function loadEvents()
    local file = io.open("data.json", "r")
    local data = {}
    if file then
        local content = file:read("*a")
        data = json.decode(content) or {}
        file:close()
    end
    return data
end

return commands
