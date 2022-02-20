log = require "log"

local myqlua = { _version = "0.1.1" }

-- myqlua.getPrice(ticker) - получить цену инструмента ticker

function myqlua.getPrice(ticker)
   
   	-- Создаем таблицу со всеми свечами нужного интервала, класса и кода
	ds, error_desc = CreateDataSource("TQBR", ticker, INTERVAL_H1)
	-- Ограничиваем количество попыток (времени) ожидания получения данных от сервера
	
	--log.trace("myqlua.getPrice")
	
	-- Если от сервера пришла ошибка, то выведем ее и прервем выполнение
	if error_desc ~= nil and error_desc ~= "" then
		message("Ошибка получения таблицы свечей:" .. error_desc);
		res = nil;
		return 0;
		
	end
	
	local try_count = 0
	-- Ждем пока не получим данные от сервера,
	--	либо пока не закончится время ожидания (количество попыток)
	while ds:Size() == 0 and try_count < 1000 do
		sleep(100)
		try_count = try_count + 1
	end
	
	res = ds:C(ds:Size());
	
	
	--log.trace("myqlua. try_count: "..try_count )
	log.trace("myqlua.getPrice("..ticker.."): "..tostring(ds:C(ds:Size())))
	
	return res;
	
end;


function myqlua.getSMA_7d(ticker)
   
   	ds, error_desc = CreateDataSource("TQBR", ticker, INTERVAL_D1)

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
	
	last_tick = ds:Size()
	
	res = (ds:C(last_tick) 
		+ ds:C(last_tick - 1) 
		+ ds:C(last_tick - 2) 
		+ ds:C(last_tick - 3) 
		+ ds:C(last_tick - 4) 
		+ ds:C(last_tick - 5) 
		+ ds:C(last_tick - 6) ) / 7
	
	
	-- log.trace("myqlua.getSMA_7d: "..tostring(res))
	
	return res
	
end;


function myqlua.getSMA(ticker, interval, cnt_periods)
   
   	ds, error_desc = CreateDataSource("TQBR", ticker, interval)

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
	
	last_tick = ds:Size()
	
	summ = 0
	for i = 1, cnt_periods do
		summ = summ + (ds:C(last_tick - i + 1))
	end
	
	--log.trace("myqlua.getSMA summ: "..tostring(summ))
	
	res = summ / cnt_periods;
	
	log.trace("myqlua.getSMA("..ticker..", "..interval.."; "..cnt_periods.."): "..tostring(res))
	
	return res
	
end;


function myqlua.getPriceTest(ticker)
   log.trace("myqlua.getPriceTest: "..tostring(0.00400))
   
   	-- Создаем таблицу со всеми свечами нужного интервала, класса и кода
	ds, error_desc = CreateDataSource("TQBR", ticker, INTERVAL_H1)
	if ticker == 'VTBR' then return 0.0400 end
	
end;

-- Функция возвращае массив строк. разделяет входящую строку inputstr разделителями sep
function myqlua.mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i = 1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
	
	log.trace("myqlua.mysplit: "..t)
    return t
end

function myqlua.buy(ticker, price, quant)

	log.trace("myqlua.buy("..ticker..", "..price..","..quant..")");
	
	t = {
		["CLASSCODE"]="TQBR",
		["SECCODE"]=ticker,
		["ACTION"]="NEW_ORDER",
		["ACCOUNT"]="L01+00000F00",
		["CLIENT_CODE"]="9298",
		["TYPE"]="L",
		["OPERATION"]="B",
		["QUANTITY"]=tostring(quant),
		["PRICE"]=tostring(price),
		["TRANS_ID"]="1"
	}

	res = sendTransaction(t)

	-- message(res,1)
	log.trace("myqlua.buy: "..res)
	return res
end

function myqlua.sell(ticker, price, quant)
	t = {
		["CLASSCODE"]="TQBR",
		["SECCODE"]=ticker,
		["ACTION"]="NEW_ORDER",
		["ACCOUNT"]="L01+00000F00",
		["CLIENT_CODE"]="9298",
		["TYPE"]="L",		-- «L» – лимитированная (по умолчанию), «M» – рыночная
		["OPERATION"]="S",	-- «S» – продать, «B» – купить
		["QUANTITY"]=tostring(quant),
		["PRICE"]=tostring(price),
		["TRANS_ID"]="1"
	}

	res = sendTransaction(t)

	-- message(res,1)
	log.trace("myqlua.sell: "..res)
	return res
end

function myqlua.isempty(s)
    return s == nil or s == ''
end

function myqlua.isnil(s)
    return s == nil
end

function myqlua.ifnull(s, repl)
    if myqlua.isnil(s) then
		return repl
	else 
		return s
	end 
end

-- Округляет число до указанной точности
function myqlua.math_round (num, idp)
   local mult = 10^(idp or 0)
   return math.floor(num * mult + 0.5) / mult
end

-- Удаление точки и нулей после нее
function myqlua.RemoveZero(str)
   while (string.sub(str,-1) == "0" and str ~= "0") do
      str = string.sub(str,1,-2)
   end
   if (string.sub(str,-1) == ".") then 
      str = string.sub(str,1,-2)
   end   
   return str
end

function myqlua.CurrentDate(format_num)
	format_num = format_num or 0;

	datetime = os.date("!*t",os.time());
	y = tostring(datetime.year);
	m = tostring(datetime.month);
	d = tostring(datetime.day);

	m = string.sub("0"..m, string.len(m), string.len(m) + 1);
	d = string.sub("0"..d, string.len(d), string.len(d) + 1);

	if format_num == 0 
		then current_date = y.."-"..m.."-"..d
	elseif format_num == 1
		then current_date = y.." "..m.." "..d
	elseif format_num == 2
		then current_date = y.."\\"..m.."\\"..d
	else current_date = y.."-"..m.."-"..d
	end;
	
	log.trace("current_date "..current_date)
	return current_date
end

function myqlua.trim(s)
  local l = 1
  while strsub(s,l,l) == ' ' do
    l = l+1
  end
  local r = strlen(s)
  while strsub(s,r,r) == ' ' do
    r = r-1
  end
  return strsub(s,l,r)
end

function myqlua.remove_blanks (s)
  local b = strfind(s, ' ')
  while b do
    s = strsub(s, 1, b-1) .. strsub(s, b+1)
    b = strfind(s, ' ')
  end
  return s
end


-- (http://luaq.ru/sendTransaction.html)
function random_max()
	-- не принимает параметры и возвращает от 0 до 2147483647 (макс. полож. 32 битное число) подходит нам для транзакций
	local res = (16807*(RANDOM_SEED or 137137))%2147483647
	RANDOM_SEED = res
	return res
end


-- (http://luaq.ru/sendTransaction.html)
function to_price(security, value, class)
	-- преобразования значения value к цене инструмента правильного ФОРМАТА (обрезаем лишнии знаки после разделителя)
	-- Возвращает строку
	if (security == nil or value == nil) then return nil end
	local scale = getSecurityInfo(class or getSecurityInfo("", security).class_code, security).scale
	return string.format("%."..string.format("%d", scale).."f", tonumber(value))
end


-- Код класса
class_code = "TQBR"
-- Код бумаги
sec_code = "SBER"
-- Номер счета
account = "L01+00000F00"

-- Функция для отправки рыночной заявки  (http://luaq.ru/sendTransaction.html)
function send_market(direction, volume, comment)
	-- отправка рыночной заявки
	-- все параметры кроме кода клиента и коментария должны быть не nil
	-- если код клиента nil - подлставляем счет
	-- Данная функция возвращает 2 параметра
	--     1. ID присвоенный транзакции либо nil если транзакция отвергнута на уровне сервера Квик
	--     2. Ответное сообщение сервера Квик либо строку с параметрами транзакции
	if (class_code == nil or sec_code == nil or direction == nil or volume == nil or account == nil) then		
		return nil, "Can`t send order. Nil parameters."
	end

    -- Получаем случайное уникальное число для id
    local trans_id = random_max()
    -- Таблица параметров транзацкии
	local transaction={
		["TRANS_ID"] = tostring(trans_id),
		["ACTION"] = "NEW_ORDER",
		["CLASSCODE"] = class_code,
		["SECCODE"] = sec_code,
		["OPERATION"] = direction,
		["TYPE"] = "M",
		["QUANTITY"] = string.format("%d", tostring(volume)),
		["ACCOUNT"] = account
    }
    -- Если нет кода клиента, то вместо него подставляем номер счета
	if client_code == nil then
		transaction.client_code = account
	else
		transaction.client_code = client_code
	end

    -- Если это заявка для Фьючерсов
    if string.find(FUT_OPT_CLASSES, class_code) ~= nil then
        local sign = 0
        -- Для покупки
        if direction == "B" then
            sign = 1
            -- Получаем максимальную цену
            transaction.price = getParamEx(class_code, sec_code, "pricemax").param_value
            -- Если текущая цена 0
            if transaction.price == 0 then
                -- Берем цену предложения и добавляем 10 шагов
				transaction.price = getParamEx(class_code, sec_code, "offer").param_value + 10 * getParamEx(class_code, sec_code, "SEC_PRICE_STEP").param_value
			end
        else
            sign = -1
            -- Для продажи берем минимальную цену
            transaction.price = getParamEx(class_code, sec_code, "pricemin").param_value
            -- Если текущая цена 0
            if transaction.price == 0 then
                -- Берем цену Bid и отнимаем 10 шагов
				transaction.price = getParamEx(class_code, sec_code, "bid").param_value - 10 * getParamEx(class_code, sec_code, "SEC_PRICE_STEP").param_value
			end
        end
        -- Если цена так и не установилась
        if transaction.price == 0 then
            -- То пытаемся отнять/прибавть 10 шагов к последней известной цене
			transaction.price = getParamEx(class_code, sec_code, "last").param_value + sign * 10 * getParamEx(class_code, sec_code, "SEC_PRICE_STEP").param_value
        end
        -- Форматируем цену
		transaction.price = to_price(sec_code, transaction.price, class_code)
	else
		transaction.price = "0"
	end

    -- Если комментарий не указан
	if comment ~= nil then
		transaction.client_code = string.sub(transaction.client_code .. '/' .. tostring(comment), 0, 20)
	else
		transaction.client_code = string.sub(transaction.client_code, 0, 20)
	end
		
    -- Отправляем транзацкию
    local res = sendTransaction(transaction)
    -- Если незультат не пустой
	if res ~= "" then		
		return nil, res
    else        
		local msg = 
			"Market order sended sucesfully. Class = " .. class_code ..
			" Sec = " .. sec_code ..
			" Dir = " .. direction ..
			" Vol = " .. volume ..
			" Acc = " .. account ..
			" Trans_id = " .. trans_id ..
			" Price = " .. transaction.price
		
		return trans_id, msg
	end
end



-- Функция вызывается терминалом, когда с сервера приходит новая информация о транзакциях
-- https://quikluacsharp.ru/quik-qlua/proverka-vystavleniya-zayavki-po-otpravlennoj-tranzaktsii-qlua-lua/
function OnTransReply(trans_reply)
    -- Если пришла информация по нашей транзакции
    if trans_reply.trans_id == trans_id then
        -- Если данный статус уже был обработан, выходит из функции, иначе запоминает статус, чтобы не обрабатывать его повторно
        if trans_reply.status == LastStatus then return else LastStatus = trans_reply.status end
        -- Выводит в сообщении статусы выполнения транзакции
        if trans_reply.status < 2 then 
            -- Статусы меньше 2 являются промежуточными (0 - транзакция отправлена серверу, 1 - транзакция получена на сервер QUIK от клиента),
            -- при появлении такого статуса делать ничего не нужно, а ждать появления значащего статуса
            -- Выходит из функции
            return
        elseif trans_reply.status == 3 then -- транзакция выполнена
            message('OnTransReply(): По транзакции №'..trans_reply.trans_id..
				' УСПЕШНО ВЫСТАВЛЕНА заявка №'..trans_reply.order_num..
				' по цене '..trans_reply.price..
				' объемом '..trans_reply.quantity) 
        elseif trans_reply.status >  3 then -- произошла ошибка
            message('OnTransReply(): ОШИБКА выставления заявки по транзакции №'..trans_reply.trans_id..
				', текст ошибки: '..trans_reply.result_msg) 
        end
    end
end
 
return myqlua;