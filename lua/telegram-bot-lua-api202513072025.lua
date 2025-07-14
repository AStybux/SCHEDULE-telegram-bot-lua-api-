local api = require('telegram-bot-lua.core').configure('okak')
-- local LoggerFactory = require "lil.LoggerFactory"
local https = require('ssl.https')
local url = require('socket.url')
local json = require('dkjson')
local Logit, LogLevel = require("logit")()
--local schedule = require('schedule') -- Подключаем файл schedule.lua

local event_checker = require('event') 
local commands = require('index1')
local config = require('config')

local colors = config.colors
local l = config.l
local bd = config.bd
local t = config.t
local f = config.f
local p = config.p
local af = config.af
local tbl = config.tbl
local lt = config.lt
local s = config.s

function send_reminders()
	print(1)
    local events = event_checker.read_json_file("data.json")
    if events then
        local reminders = event_checker.check_events(events)
        for _, reminder in ipairs(reminders) do
            api.send_message(tbl.id, reminder)
        end
    else
        print("Не удалось прочитать файл data.json")
    end
end

function api.on_message(message) --> #ревизия 03-05-2025
    if message.text then
        tbl.username = message.from.username or "неизвестный"
        -- print(tbl.username)
        tbl.id=message.chat.id
        tbl.m=message.text

        tbl.fnuser = l.w2w(tbl.fuser, "{u}", tbl.username)
        -- print(l.str(tbl.username))
        tbl.l=tbl.users[l.str(tbl.username)][1] --TODO: 
        tbl.fnuser = l.w2w(tbl.fnuser, "{l}", tbl.l)

        local log = Logit:new(".", tbl.fnuser, nil, true, true)

        log:start()

        log(LogLevel.INFO, p.normal(lt.sm))
        log(LogLevel.INFO, p.normal(tbl.m))
        log(LogLevel.INFO, p.normal(tbl.username))
        log(LogLevel.INFO, "UwU\n")

        log:finish()

		-- Обработка команд
        if tbl.m:match('^/add') then
   		 api.send_message(tbl.id,commands.add(tbl),nil,"MarkdownV2")
        elseif tbl.m:match('^/help') then
            api.send_message(tbl.id,commands.help(tbl))
        elseif tbl.m:match('^/schedule') then
            api.send_message(tbl.id,commands.schedule(tbl),nil,"MarkdownV2")
        elseif tbl.m:match('^/today') then
            api.send_message(tbl.id,commands.today(tbl))
        elseif tbl.m:match('^/tomorrow') then
            api.send_message(tbl.id,commands.tomorrow(tbl))
        elseif tbl.m:match('^/week') then
            api.send_message(tbl.id,commands.week(tbl))
        end

        if tbl.l == "A" then
            if tbl.m:match('ping') then
                tbl.mb=l.w2w(tbl.text,"text","pong")
                api.send_message(tbl.id,tbl.mb)

                local log = Logit:new(".", "answer_bot", nil, true, true)

                log:start()

                log(LogLevel.INFO, p.normal(lt.am))
                log(LogLevel.INFO, p.normal(tbl.mb))
                log(LogLevel.INFO, "UwU\n")

                log:finish()
            end

            if tbl.m:match('time') then
                tbl.mb=l.w2w(tbl.text,"text",(os.clock()-bd.st)*100)
                api.send_message(tbl.id,tbl.mb)

                local log = Logit:new(".", "answer_bot", nil, true, true)

                log:start()

                log(LogLevel.INFO, p.normal(lt.am))
                log(LogLevel.INFO, p.normal(tbl.mb))
                log(LogLevel.INFO, "UwU\n")
            
                log:finish()
            end

            if tbl.m:match('clear') then

                -- tbl.mb=l.w2w(tbl.text,"text","")
                -- api.send_message(tbl.id,tbl.mb)

                local log = Logit:new(".", "answer_bot", nil, true, true)

                log:start()

                p.n=0
                log(LogLevel.INFO, p.normal("\27[1J\27[0H\nПроведена глубокая очистка"))
                log(LogLevel.INFO, "UwU\n")

                log:finish()
            end

            if tbl.m:match('kill') and not(p.n==3) then
                log:start()

                log(LogLevel.INFO, l.str(p.n))
                log(LogLevel.INFO, p.normal(lt.am))
                log(LogLevel.INFO, p.normal(tbl.mb))
                log(LogLevel.INFO, "UwU\n")

                log:finish()

                tbl.work=false
                tbl.mb=l.w2w(tbl.text,"text","Бот прилёг ненадолго")
                api.send_message(tbl.id,tbl.mb)

                local log = Logit:new(".", "answer_bot", nil, true, true)

            end
		end
--[[            ]]

        -- if tbl.mb == "" then tbl.mb = ""
        tbl.ml=l.w2w(tbl.m2b, "{mc}", tbl.m)
        -- tbl.ml=l.w2w(tbl.ml, "{m}", tbl.mb or "")
        -- tbl.ml=l.w2w(tbl.ml, "{u}", tbl.username)
        -- tbl.ml=l.w2w(tbl.ml, "{l}", tbl.users[l.str(tbl.username)][1])
        -- tbl.ml=l.w2w(tbl.ml, "{mci}", tbl.id)
        p.normal(tbl.ml)
    end

    if not(tbl.work) then os.exit() end
end

--function api.on_message(message)

--end

api.run()

-- logger.error("Danger!")
-- logger.warn("Warning!")



