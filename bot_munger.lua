-- bot_munger.lua

--[[
Этот скрипт запускается в начале дня и в бесконечном цикле запускает скрипты 
ботов.
]]

IsRun = true;
log = require "log";
qlua_sma_botEELT = require "qlua_sma_botEELT";
qlua_sma_botVTBR = require "qlua_sma_botVTBR";
qlua_sma_botUWGN = require "qlua_sma_botUWGN";
--qlua_sma_botETLN = require "qlua_sma_botETLN";

-- Функция первичной инициализации скрипта (ВЫЗЫВАЕТСЯ ТЕРМИНАЛОМ QUIK в самом начале)
function OnInit()
   
end;


function main()
	log.trace('-- bot_munger begin')
	
	qlua_sma_botEELT.settings()
	qlua_sma_botVTBR.settings()
	--qlua_sma_botUWGN.settings()
	--qlua_sma_botETLN.settings()
	
	while IsRun do
	
		--log.trace('os.date(!): '..os.date('!%Y-%m-%d-%H:%M:%S GMT', curTime));
		
		-- 
		cur_hour = tonumber(os.date('!%H', curTime)) + 3;
		log.trace('cur_hour: '..tostring(cur_hour));
		if cur_hour >= 10 and cur_hour < 19 then
			log.trace('cur_hour: '..tostring(cur_hour)..' time to trade');
			--log.trace('iter')
			qlua_sma_botEELT.main()
			qlua_sma_botVTBR.main()
			--qlua_sma_botUWGN.main()
			--qlua_sma_botETLN.main()
		else
			log.trace('cur_hour: '..tostring(cur_hour)..' too early or late');
		end;
		
		--print("os.date(!): "..os.date('!%Y-%m-%d-%H:%M:%S GMT', curTime))
		
		
		sleep(60 * 60 * 1000); --Пауза 60 минут 
	end;
end;


function OnStop()
   IsRun = false;
   log.trace('-- bot_munger end')
end;


