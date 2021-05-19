log = require "log"

-- Флаг поддержания работы скрипта
IsRun = true;
 

-- Пример получения первой свечи текущего дня
function main()
	
	-- Пытается открыть файл в режиме "чтения/записи"
	f = io.open(getScriptPath().."\\pday.dls", "r+");
	-- Если файл не существует
	if f == nil then 
		log.trace('creating file')
		-- Создает файл в режиме "записи"
		f = io.open(getScriptPath().."\\day.dls", "w"); 
		-- Закрывает файл
		f:close();
		-- Открывает уже существующий файл в режиме "чтения"
		f = io.open(getScriptPath().."\\day.dls", "r");
	end;
	
	while IsRun do
		while #events > 0 do
			local alltrade = table.sremove(events, 1) --удалить первый элемент списка
			--обработка сделки
		end
		sleep(1)
	end;
	
	f:close();
end	

--- Функция вызывается терминалом QUIK при получении обезличенной сделки
function OnAllTrade(alltrade)
   -- Если сделка по инструменту RTS-6.15(RIM5), то
   --if alltrade.sec_code == "RIM5" then
      -- создает строку информации о сделке			
      DealStr = tostring(alltrade.sec_code)
          ..";"
	      ..tostring(alltrade.trade_num)
          ..";"
	      ..tostring(alltrade.datetime.year)
	      .."-"
	      ..tostring(alltrade.datetime.month)
	      .."-"
	      ..tostring(alltrade.datetime.day)
	      .." "
	      ..tostring(alltrade.datetime.hour)
	      ..":"
	      ..tostring(alltrade.datetime.min)
	      ..":"
	      ..tostring(alltrade.datetime.sec)
	      .."."
	      ..tostring(alltrade.datetime.mcs)
	      ..";"
	      ..tostring(alltrade.price)
	      ..";"
	      ..tostring(alltrade.qty)
	      ..";"
	      ..tostring(alltrade.flags); -- "1" - ПРОДАЖА, "2" - КУПЛЯ
   --end;
   
	f:write(DealStr.."\n"); -- "\n" признак конца строки
	-- Сохраняет изменения в файле
	f:flush();
end;

function OnStop()
   IsRun = false;
end;
