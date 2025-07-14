
local json = require("dkjson")

local config = require("config")

local l = config.l

local event_text = "НАПОМИНАНИЕ: []"

-- Функция для чтения JSON файла
local function read_json_file(filename)
    local file = io.open(filename, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return json.decode(content)
end

-- Функция для проверки событий
local function check_events(events)
    local reminders = {}
    local current_time = os.time()
    local one_hour_later = current_time + 3600

    for _, event in ipairs(events) do
        local event_date = event.event_date
        local event_time = event.event_time
        local event_datetime_str = event_date .. " " .. event_time
        local event_datetime = os.time({
            year = tonumber(event_date:sub(1, 4)),
            month = tonumber(event_date:sub(6, 7)),
            day = tonumber(event_date:sub(9, 10)),
            hour = tonumber(event_time:sub(1, 2)),
            min = tonumber(event_time:sub(4, 5)),
            sec = 0
        })
		print(event_datetime, current_time, one_hour_later)
        if event_datetime > current_time and event_datetime <= one_hour_later then
			event_text = l.w2w(event_text,"[]",event.event_description)
			print(event_text,event_description)
            table.insert(reminders, event_text)
        end
    end

    return reminders
end

-- Экспорт функции для использования в другом файле
return {
    read_json_file = read_json_file,
    check_events = check_events
}
