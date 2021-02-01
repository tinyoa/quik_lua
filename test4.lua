log = require "log"
myqlua = require "myqlua"

-- Флаг поддержания работы скрипта
IsRun = true;


LEVEL_STEP = 0.1;


-- Нужен объект - списов заявок робота
 
function main()
	log.trace('test4 begin')

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
			
			log.trace('line: '..line)
			log.trace('a['..n..'][1]:'..arr[1]..' '..'a['..n..'][2]:'..arr[2]..' '..'a['..n..'][3]:'..arr[3]..' ')
			
			act_list[n] = {}
			act_list[n][1] = arr[1];
			act_list[n][2] = arr[2];
			act_list[n][3] = arr[3];
			act_list[n][4] = arr[4];
			act_list[n][5] = arr[5];
			log.trace('act_list['..n..'][1]:'..act_list[n][1]..' '
					..'act_list['..n..'][2]:'..act_list[n][2]..' '
					..'act_list['..n..'][3]:'..act_list[n][3]..' ');
			
			n = n + 1
		--x,y = string.match(line,"([01]+) (%a)") -- двоичные цифры - помещаем в x, букву - в y
		--a[x]=y -- добавляем эту пару в ассоциативный массив
	end
	
	-- Закрывает файл
	f:close();
	
	-- получить цену по инструменту
	log.trace('3. Получить цены по инструментам')
	for i = 1, #act_list do
		log.trace('--: '..act_list[i][1]);
		if (act_list[i][1] ~= 'rur') then
			log.trace('--: ');
			ticker = act_list[i][1];
			price = myqlua.getPrice(ticker);
			act_list[i][6] = price;
			--log.trace('price: '..price);
			-- log.trace(ticker..'('..act_list[i][3]..') - '..act_list[i][6]);
			
			-- -- сформулировать намерение, что делать и на каких уровнях
			-- Если в портфеле есть позиции, то считать покупки/продажи от средней цены в портфеле. Иначе - от средней за 7 дней 
			if act_list[i][2] > 0 then
				-- покупать при этой цене
				act_list[i][7] = act_list[i][3] + act_list[i][3] * (act_list[i][3] + 1) * LEVEL_STEP;
				
				-- продавать при этой цене
				act_list[i][8] = act_list[i][3] - act_list[i][3] * (act_list[i][3] + 1) * LEVEL_STEP;
				
				-- log.trace(': '..((act_list[i][3] + 1) * LEVEL_STEP));
				log.trace('-- Тикер:             '..act_list[i][1]);
				log.trace('Кол-во на балансе:    '..act_list[i][2]);
				log.trace('Средняя цена лота:    '..act_list[i][3]);
				log.trace('Номер уровня продажи: '..act_list[i][4]);	--
				log.trace('Номер уровня покупки: '..act_list[i][5]);
				log.trace('Текущая цена:         '..act_list[i][6]);
				log.trace('Цена продажи:         '..act_list[i][7]);
				log.trace('Цена покупки:         '..act_list[i][8]);
			else
				-- тут должен быть расчет на цену покупки и заглушка на цену продажи
				act_list[i][7] = 0;		-- цена продажи
				-- цена покупки должна считаться от средней за 7 дней 
				act_list[i][8] = act_list[i][3] - act_list[i][3] * (act_list[i][3] + 1) * LEVEL_STEP;
			end if
			
		end
		
		-- log.trace('act_list: '..i..' - '..tostring(act_list[i]));
	end
	
	-- Проверить наступление условий для 
	
	
	
	
	
--	for i = 1, #a do
--	   MsgBox("Значение элемента №"..i.." : "..a[i][1])
--	end
   
	log.trace('4')
   
	--f:seek("set",0);
	-- Перебирает строки файла, выводит их содержимое в сообщениях
	--for line in f:lines() do message(tostring(line));end
	
	
	
	-- -- Вычислить условия покупки и продажи
	
	
	
    -- Покупка
	-- Продажа
   
	-- Цикл будет выполнятся, пока IsRun == true
	--while IsRun do
	--   Получить текущую цену
	
	--	 В цикле проверять наступление этих условий
	--   sleep(100);
	--end;   
	log.trace('test4 end')
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

-- Функция для отправки приказа на покупку count штук акции ticker 
function mybuy(ticker, count, price)
-- поставить заявку на покупку
-- проконтролировать исполнение заявки
-- обновить данные в портфеле
	-- уменьшить кол-во рублей
	-- увеличить размер позиции
-- переписать портфель в файл
	log.trace('mybuy')

end 

-- Функция для отправки приказа на продажу count штук акции ticker 
function mysell(ticker, count, price)
-- поставить заявку на продажу
-- проконтролировать исполнение заявки
-- обновить данные в портфеле
	-- увеличить кол-во рублей
	-- уменьшить размер позиции
-- переписать портфель в 
	log.trace('mysell')
end 
 
function OnStop()
   IsRun = false;
end;