-- bot_munger.lua

--[[
Этот скрипт запускается в начале дня и в бесконечном цикле запускает скрипты 
ботов.
]]

IsRun = true;
log = require "log";
qlua_sma_botEELT = require "qlua_sma_botEELT";
qlua_sma_botVTBR = require "qlua_sma_botVTBR";

-- Функция первичной инициализации скрипта (ВЫЗЫВАЕТСЯ ТЕРМИНАЛОМ QUIK в самом начале)
function OnInit()
   
end;


function main()
	log.trace('-- bot_munger begin')
	
	qlua_sma_botEELT.settings()
	qlua_sma_botVTBR.settings()
	
	while IsRun do
		--log.trace('iter')
		--qlua_sma_botEELT.ddd()
		qlua_sma_botEELT.main()
		qlua_sma_botVTBR.main()
		sleep(60 * 60 * 1000); --Пауза 60 минут 
	end;
end;


function OnStop()
   IsRun = false;
   log.trace('-- bot_munger end')
end;


