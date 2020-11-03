
-- http://luaq.ru/CreateDataSource.html

log = require "log"

-- Флаг поддержания работы скрипта
IsRun = true;
 

-- Пример получения первой свечи текущего дня
function main()
	-- Создаем таблицу со всеми свечами нужного интервала, класса и кода
	ds, error_desc = CreateDataSource("TQBR", "VTBR", INTERVAL_H1)
	-- Ограничиваем количество попыток (времени) ожидания получения данных от сервера
	
	log.trace(os.date("%d"))
	
	local try_count = 0
	-- Ждем пока не получим данные от сервера,
	--	либо пока не закончится время ожидания (количество попыток)
	while ds:Size() == 0 and try_count < 1000 do
		sleep(100)
		try_count = try_count + 1
	end
	-- Если от сервера пришла ошибка, то выведем ее и прервем выполнение
	if error_desc ~= nil and error_desc ~= "" then
		message("Ошибка получения таблицы свечей:" .. error_desc)
		return 0
	end
	
	log.trace("try_count: "..try_count )
	log.trace("ds:Size(): "..ds:Size())
	log.trace(ds:C())
	log.trace(ds:C(1))
	log.trace(ds:C(2))
	log.trace(ds:C(3000))
	log.trace(tostring(ds:C(3014)))
	
	-- Текущий день месяца (1 - 31)
	local today_day = tonumber(os.date("%d"))
	-- Текущая свеча (с которой начинаем поиск)
	local current_candle = ds:Size()
	log.trace(" ")
	-- Максимальное количество свечей для поиска
	--	не может быть больше чем общее количество свечей в таблице
	local max_candles = math.min(5000, ds:Size())
	-- Индекс первой свечи текущего дня
	local first_candle_index = nil
	
	-- Цикл пока не нашли первую свечу дня либо не проверили
	--	максимальное количество свечей
	while first_candle_index == nil and current_candle > ds:Size() - max_candles do
		-- Если день текущей свечи не совпадает с текущим днем
		if tonumber(ds:T(current_candle).day) ~= today_day then
			-- Тогда индекс искомой свечи
			first_candle_index = current_candle - 1
			message("Найден индекс: " .. tostring(first_candle_index))
		end
		
		current_candle = current_candle - 1
	end
	
	-- Если индекс был найден
	if first_candle_index ~= nil then
		log.trace(" ")
		message("Первая свеча дня:")
		log.trace("Первая свеча дня:")
		message("		индекс: " .. tostring(current_candle))
		log.trace("		индекс: " .. tostring(current_candle))
		message("		время: " .. tostring(ds:T(current_candle).hour) .. ":" .. tostring(ds:T(current_candle).min) .. ":" .. tostring(ds:T(current_candle).sec))
		log.trace("		время: " .. tostring(ds:T(current_candle).hour) .. ":" .. tostring(ds:T(current_candle).min) .. ":" .. tostring(ds:T(current_candle).sec))
		
		message("Последняя свеча предыдущего дня:")
		message("		индекс: " .. tostring(current_candle - 1))
		message("		время: " .. tostring(ds:T(current_candle - 1).hour) .. ":" .. tostring(ds:T(current_candle - 1).min) .. ":" .. tostring(ds:T(current_candle - 1).sec))
	-- Если индекс найти не удалось
	else
		message("Первая свеча дня не найдена. Не достаточно свечей для поиска (" .. tostring(ds:Size()) .. ").")
		message("Самая дальняя свеча:")
		message("		индекс: " .. tostring(1))
		message("		время: " .. tostring(ds:T(1).hour) .. ":" .. tostring(ds:T(1).min) .. ":" .. tostring(ds:T(1).sec))
	end
end	
 
function OnStop()
   IsRun = false;
end;