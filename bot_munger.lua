-- bot_munger.lua



--[[
Этот скрипт запускается в начале дня и в бесконечном цикле запускает скрипты 
ботов.
]]

IsRun = true;
log = require "log"


function main()
	
end;


function OnStop()
   IsRun = false;
end;


