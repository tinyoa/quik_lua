-- qlua_sma_botEELT.lua



local qlua_sma_botEELT = { _version = "0.1.1" }

-- Флаг поддержания работы скрипта
IsRun = true;

log = require "log"
myqlua = require "myqlua"

local PRICE_STEP = 0.03		-- отклонение, которое считается достаточным для перехода на следующий уровень
local act_list = {} 	-- матрица с инструментами
local order_list = {}	-- список заявок
local amount_rur = 0			-- кол-во денег
local class_code = "TQBR"
local PORTFOLIO_FILE = "portEELT.prt"

function qlua_sma_botEELT.settings()
	log.trace("PORTFOLIO_FILE: "..PORTFOLIO_FILE..", PRICE_STEP: "..PRICE_STEP.."")
end;

function qlua_sma_botEELT.main()
	
	log.trace('-- -- -- '..PORTFOLIO_FILE)

	-- Пытается открыть файл в режиме "чтения/записи"
	f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "r+");
	-- Если файл не существует
	if f == nil then 
		log.trace('creating file')
		-- Создает файл в режиме "записи"
		f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "w"); 
		-- Закрывает файл
		f:close();
		-- Открывает уже существующий файл в режиме "чтения"
		f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "r");
	end;
   
	-- Записывает в файл 2 строки
	--f:write("Line1\nLine2"); -- "\n" признак конца строки
	-- Сохраняет изменения в файле
	--f:flush();
	-- Встает в начало файла 
	  -- 1-ым параметром задается относительно чего будет смещение: "set" - начало, "cur" - текущая позиция, "end" - конец файла
	  -- 2-ым параметром задается смещение
   
	--log.trace('Считать данные в массив')
	local a = {} 			-- объявление должно быть за пределами цикла
	local n = 1  			-- инициализируем счётчик элементов таблицы
	io.input(getScriptPath().."\\"..PORTFOLIO_FILE) 
	while true do
		local line = io.read("*line") -- читаем целую строку
		if line == nil then break end -- если ничего не прочиталось - конец цикла
			arr = mysplit(line, ';')
			a[n] = { arr }
			
			
			--log.trace('line: '..line);
			--log.trace('a['..n..'][1]:'..arr[1]..' '..'a['..n..'][2]:'..arr[2]..' '..'a['..n..'][3]:'..arr[3]..' ');
			act_list[n] = {}
			act_list[n][1] = arr[1];	-- Название
			act_list[n][2] = arr[2];	-- Лот
			act_list[n][3] = arr[3];	-- Цена
			if (act_list[n][1] ~= 'rur') then
				act_list[n][4] = arr[4];	-- Номер уровня продажи
				act_list[n][5] = arr[5];	-- Номер уровня покупки
			end	
			--[[log.trace('act_list['..n..'][1]:'..act_list[n][1]..' '
					..'act_list['..n..'][2]:'..act_list[n][2]..' '
					..'act_list['..n..'][3]:'..act_list[n][3]..' ');]]
					
			
			
			n = n + 1;
		--x,y = string.match(line,"([01]+) (%a)") -- двоичные цифры - помещаем в x, букву - в y
		--a[x]=y -- добавляем эту пару в ассоциативный массив
	end
	io.input():close()
	
	--log.trace('length act_list: '..#act_list)
	
	-- Надо перебрать элементы массива и получить для них цены
	for i = 1, #act_list do
		log.trace('--: '..act_list[i][1]);
		if (act_list[i][1] ~= 'rur') then
			ticker = act_list[i][1];
			price = myqlua.getPrice(ticker);		-- !!! Заменить обратно, когда заработает сервер
			--price = myqlua.getPriceTest(ticker);
			
			act_list[i][6] = price;
			--log.trace(ticker..'('..act_list[i][3]..') - '..price );
			
			cnt_share = math.floor(tonumber(act_list[i][2]));		-- Кол-во на балансе
			avg_price = tonumber(act_list[i][3]);		-- Средняя цена лота
			sell_level = act_list[i][4];	-- Номер уровня продажи
			buy_level = act_list[i][5];		-- Номер уровня покупки
			--[[log.trace("ticker"..ticker
						.."cnt_share: "..cnt_share
						.."price: "..price
						.."avg_price: "..avg_price
						.."sell_level: "..sell_level
						.."buy_level: "..buy_level
					);]]
			
			
			-- Если есть что продавать, то сравнивается со средней ценой в портфеле
			if cnt_share > 0 then
				if avg_price > 0 then 
					-- Определить условия при которых будет совершена продажа
					log.trace("avg_price: "..avg_price.." sell_level: "..sell_level.." PRICE_STEP: "..PRICE_STEP);
					sell_price = avg_price + avg_price * (sell_level + 1) * PRICE_STEP;	-- Цена продажи	
					--log.trace("sell_price: "..sell_price);
					act_list[i][8] = sell_price;	
					
					-- Определить условия при которых будет совершена покупка
					buy_price = avg_price - avg_price * (buy_level + 1) * PRICE_STEP;		-- Цена покупки
					
					--log.trace("buy_price: "..buy_price);
					act_list[i][7] = buy_price;	
				else
					log.trace("ERROR. avg_price = 0");
					
					-- Цену продажи ставлю заградительную
					sell_price = price * 2;
				end;
			else
				-- возможна только покупка
				-- Определить условия при которых будет совершена покупка
				--buy_price = myqlua.getSMA_7d(ticker) -- Цена покупки
				buy_price = myqlua.getSMA(ticker, INTERVAL_D1, 7)   -- Цена покупки
				--log.trace("buy_price: "..buy_price);
				act_list[i][7] = buy_price;	
				--log.trace("buy_price act_list[i][7]: "..act_list[i][7]);
				
				-- Цену продажи ставлю заградительную
				sell_price = price * 2;
			end
			
			log.trace("--ticker: "..ticker
						.."; cnt_share: "..myqlua.ifnull(cnt_share, "-")
						.."; price: "..myqlua.ifnull(price, "-")
						--.."; avg_price: "..avg_price
						--.."; sell_level: "..sell_level
						.."; sell_price: "..myqlua.ifnull(sell_price, "-")
						--.."; buy_level: "..buy_level
						.."; buy_price: "..myqlua.ifnull(buy_price, "-")
					);
			
			-- Если текущая цена выше чем цена продажи, то продаю
			if myqlua.ifnull(sell_price, 0) > 0 and price > sell_price then 
				sell_ticker (ticker) 
			end	
			 
			-- Если текущая цена ниже, чем цена покупки, то покупаю
			if myqlua.ifnull(buy_price, 0) > 0 and price < buy_price then 
				lotsize = getParamEx(class_code, ticker, "LOTSIZE").param_value;
				if amount_rur > (buy_price * lotsize) then
					buy_ticker (ticker) 
				else
					log.trace("Нет денег на покупку "..ticker)
				end
			end
		else
			amount_rur = tonumber(act_list[i][2])
		end
		
		-- log.trace('act_list: '..i..' - '..tostring(act_list[i]));
	end
	
	
	log.trace('qlua_sma_bot end')
	
	return 0
end;

-- Функция продажи инструмента
function buy_ticker (ticker)
	-- Поставить заявку на покупку
	log.trace('BUYING '..ticker);
	-- Найти строку с этим инструментом 
	for i = 1, #act_list do
		if act_list[i][1] == ticker then
			cnt_share = act_list[i][2];		-- Кол-во на балансе
			avg_price = tonumber(act_list[i][3]);		-- Средняя цена лота
			sell_level = act_list[i][4];	-- Номер уровня продажи
			buy_level = act_list[i][5];	-- Номер уровня покупки
			sell_price = act_list[i][8];	
			buy_price = act_list[i][7];		
			
			
			-- Определить количество лотов на покупку 
			cnt_share_to_buy = math.floor(2 ^ buy_level);
			
			-- Костыль, чтобы попасть в шаг цены
			--buy_price = getParamEx("TQBR", ticker, "pricemax").param_value;
			buy_price = myqlua.getPrice(ticker)
			log.trace('buy_price: '..buy_price.." cnt_share_to_buy:"..cnt_share_to_buy.." "..type(cnt_share_to_buy));
			
			-- Поставить заявку на продажу
			log.trace('cnt_share_to_buy: '..cnt_share_to_buy..' for price'..buy_price);
			myqlua.buy(ticker, buy_price, cnt_share_to_buy)									-- !!!
			
			-- Обновить остатки в портфеле
			act_list[i][2] = act_list[i][2] + cnt_share_to_buy;
			
			-- Обновить счетчик уровней
			act_list[i][4] = 0					-- Номер уровня продажи
			act_list[i][5] = buy_level + 1;		-- Номер уровня покупки
			
			
			--log.trace('sell_price: '..sell_price..' lotsize..'..lotsize);
			
			-- Уменьшить счет рублей на цену покупки
			lotsize = getParamEx(class_code, ticker, "LOTSIZE").param_value;
			add_rubles(-buy_price * lotsize)
			
			-- Средняя цена должна снизиться
			if avg_price == 0 then
				act_list[i][3] = buy_price;
			else
				act_list[i][3] = avg_price * (1 - PRICE_STEP / 2);
			end;
			
		end; 
	end;
	save_portfolio();
end


-- Функция покупки инструмента
-- Добавить проверку на наличие достаточного количества денег
function sell_ticker (ticker)

	log.trace('CELLING '..ticker);
	-- Найти строку с этим инструментом 
	for i = 1, #act_list do
		if act_list[i][1] == ticker then
			cnt_share = act_list[i][2];		-- Кол-во на балансе
			avg_price = act_list[i][3];		-- Средняя цена лота
			sell_level = act_list[i][4];	-- Номер уровня продажи
			buy_level = act_list[i][5];		-- Номер уровня покупки
			-- sell_price = act_list[i][8];	-- 
			sell_price = myqlua.getPrice(ticker);	-- Цену продажи ставлю текущую
			buy_price = act_list[i][7];		-- 
			
			--log.trace('cnt_share: '..cnt_share);
			
			
			-- Определить количество лотов на продажу 
			if cnt_share == '1' then
				cnt_share_to_cell = 1;
				-- Обнуляю среднюю цену лота
				act_list[i][3] = 0
			else 
				cnt_share_to_cell = math.floor(cnt_share / 2);
			end
			
			
			-- Костыль, чтобы попасть в шаг цены
			--sell_price = getParamEx("TQBR", ticker, "pricemin").param_value
			sec_price_step = getParamEx(class_code, ticker, "SEC_PRICE_STEP").param_value
			log.trace('sec_price_step: '..sec_price_step);
			log.trace('sell_price: '..sell_price);
			ostatok = sell_price % sec_price_step
			log.trace('ostatok: '..tostring(ostatok));
			sell_price = sell_price - ostatok
			log.trace('sell_price: '..sell_price);
			
			-- Поставить заявку на продажу
			log.trace('cnt_share_to_cell: '..cnt_share_to_cell..' with price '..tostring(sell_price));
			myqlua.sell(ticker, sell_price, cnt_share_to_cell)								-- !!!
			
			-- Увеличить счет рублей на цену продажи
			lotsize = getParamEx(class_code, ticker, "LOTSIZE").param_value;
			add_rubles(sell_price * lotsize)
			
			-- Обновить остатки в портфеле
			act_list[i][2] = act_list[i][2] - cnt_share_to_cell;
			
			-- Обновить счетчик уровней
			act_list[i][4] = sell_level		-- Номер уровня продажи
			act_list[i][5] = 0;				-- Номер уровня покупки
			
		end; 
	end;
	
	save_portfolio();
end

-- Функция добавляет сумму рублей amnt на счет
function add_rubles(amnt)

	prev_amnt = amount_rur
	amount_rur = prev_amnt + amnt
	
	log.trace("add_rubles: "..prev_amnt.." + "..amnt.." = "..amount_rur)

end

-- Функция должна сохранить портфель из списка act_list
function save_portfolio(amnt)
	log.trace("save_portfolio")

-- Пытается открыть файл в режиме "чтения/записи"
    f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "w");
	
	f:write('rur;'..amount_rur..';1'..'\n');
    for i = 1, #act_list do
		line = nil
		if (act_list[i][1] ~= 'rur') then
			line = myqlua.ifnull(act_list[i][1], 0)
				..';'..math.floor(myqlua.ifnull(act_list[i][2], 0))
				..';'..myqlua.ifnull(act_list[i][3], 0)
				..';'..math.floor(myqlua.ifnull(act_list[i][4], 0))
				..';'..math.floor(myqlua.ifnull(act_list[i][5], 0))
				..';'..myqlua.ifnull(act_list[i][6], 0)
				..';'..myqlua.ifnull(act_list[i][7], 0)
				..';'..myqlua.ifnull(act_list[i][8], 0)
		end
		
		if not myqlua.isnil(line) then
			log.trace("line: "..i..' '..line)
			f:write(line..'\n');
		end 
	end;
	f:close();
 end
   
   
   
   
-- Функция возвращает массив строк. разделяет входящую строку inputstr разделителями sep
function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i = 1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function OnStop()
   IsRun = false;
end;

return qlua_sma_botEELT;