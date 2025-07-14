local schedule = {}

-- Функция для добавления события в расписание
function schedule.addEvent(date, time, description)
    table.insert(schedule, {date = date, time = time, description = description})
end

-- Функция для записи расписания в текстовый файл
function schedule.saveScheduleToFile(filename)
    local file = io.open(filename, "w")
    if not file then
        print("Не удалось открыть файл для записи.")
        return
    end

    -- Записываем заголовок
    file:write("Расписание:\n")
    file:write(string.format("%-15s %-10s %s\n", "Дата", "Время", "Описание"))
    file:write(string.rep("-", 40) .. "\n")

    -- Записываем каждое событие
    for _, event in ipairs(schedule) do
        file:write(string.format("%-15s %-10s %s\n", event.date, event.time, event.description))
    end

    file:close() -- Закрываем файл
    print("Расписание успешно сохранено в " .. filename)
end

return schedule
