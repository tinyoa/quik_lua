﻿-- qlua_sma_bot.lua

--[[
qlua_sma_bot

1. Получить текущую стоимость инструмента
2. Если в портфеле еще нет бумаги
    2.1 Если стоимость ниже скользящей средней за 30 дней * 0,9 , то купить
3. Если бумага в портфеле есть
    3.1 Если текущая стоимость выше чем цена в портфеле на 10% и прошло более 30 дней с предыдущей продажи (+10%) 
        3.1.1 продать 50% + 1 <кол-во лотов в портфеле>. 
        3.1.2 Отметить дату продажи
    3.2 Если в портфеле уже есть акция и цена ниже чем <цена в портфеле>
        то при снижении цены ниже чем <цена в портфеле> - 0.1 * <кол-во лотов в портфеле> * <цена в портфеле> купить <кол-во лотов в портфеле> акций по тек. цене
		
		
*Структура файла*
1. Тикер
2. Кол-во на балансе
3. Средняя цена лота
4. Номер уровня продажи
5. Номер уровня покупки
6. Текущая цена
7. Цена продажи
8. Цена покупки
]]


-- Флаг поддержания работы скрипта
IsRun = true;

log = require "log"
myqlua = require "myqlua"

function main()
	
	log.trace('-- -- -- -- -- test6 begin')

	-- Пытается открыть файл в режиме "чтения/записи"
	f = io.open(getScriptPath().."\\port.prt", "r+");
	-- Если файл не существует
	if f == nil then 
		log.trace('creating file')
		-- Создает файл в режиме "записи"
		f = io.open(getScriptPath().."\\port.prt", "w"); 
		-- Закрывает файл
		f:close();
		-- Открывает уже существующий файл в режиме "чтения"
		f = io.open(getScriptPath().."\\port.prt", "r");
	end;
   
	-- Записывает в файл 2 строки
	--f:write("Line1\nLine2"); -- "\n" признак конца строки
	-- Сохраняет изменения в файле
	--f:flush();
	-- Встает в начало файла 
	  -- 1-ым параметром задается относительно чего будет смещение: "set" - начало, "cur" - текущая позиция, "end" - конец файла
	  -- 2-ым параметром задается смещение
   
	log.trace('Считать данные в массив')
	local a = {} -- объявление должно быть за пределами цикла
	local act_list = {} -- 
	local n = 1  -- инициализируем счётчик элементов таблицы
	io.input(getScriptPath().."\\port.prt") 
	while true do
		local line = io.read("*line") -- читаем целую строку
		if line == nil then break end -- если ничего не прочиталось - конец цикла
			--x,y = string.match(line,"([01]+) (%a)") -- двоичные цифры
			arr = mysplit(line, ';')
			a[n] = { arr }
			
			
			log.trace('line: '..line);
			log.trace('a['..n..'][1]:'..arr[1]..' '..'a['..n..'][2]:'..arr[2]..' '..'a['..n..'][3]:'..arr[3]..' ');
			act_list[n] = {}
			act_list[n][1] = arr[1];	-- Название
			act_list[n][2] = arr[2];	-- Лот
			act_list[n][3] = arr[3];	-- Цена
			log.trace('act_list['..n..'][1]:'..act_list[n][1]..' '
					..'act_list['..n..'][2]:'..act_list[n][2]..' '
					..'act_list['..n..'][3]:'..act_list[n][3]..' ');
			
			n = n + 1;
		--x,y = string.match(line,"([01]+) (%a)") -- двоичные цифры - помещаем в x, букву - в y
		--a[x]=y -- добавляем эту пару в ассоциативный массив
	end
	
	log.trace('length act_list: '..#act_list)
	
	-- Надо перебрать элементы массива и получить для них цены
	for i = 1, #act_list do
		log.trace('--: '..act_list[i][1]);
		if (act_list[i][1] ~= 'rur') then
			ticker = act_list[i][1];
			price = myqlua.getPrice(ticker);
			act_list[i][6] = price;
			--log.trace('price: '..price);
			log.trace(ticker..'('..act_list[i][3]..') - '..act_list[i][6] );
		end
		
		-- log.trace('act_list: '..i..' - '..tostring(act_list[i]));
	end
	
	log.trace('test6 end')
end;

-- Функция возвращае массив строк. разделяет входящую строку inputstr разделителями sep
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