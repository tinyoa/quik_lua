log = require "log"

-- Флаг поддержания работы скрипта
IsRun = true;
 
function main()
	log.trace('test4 begin')

	-- Пытается открыть файл в режиме "чтения/записи"
	f = io.open(getScriptPath().."\\port.prt","r+");
	-- Если файл не существует
	if f == nil then 
		log.trace('creating file')
		-- Создает файл в режиме "записи"
		f = io.open(getScriptPath().."\\port.prt","w"); 
		-- Закрывает файл
		f:close();
		-- Открывает уже существующий файл в режиме "чтения"
		f = io.open(getScriptPath().."\\port.prt","r");
	end;
   
	-- Записывает в файл 2 строки
	--f:write("Line1\nLine2"); -- "\n" признак конца строки
	-- Сохраняет изменения в файле
	--f:flush();
	-- Встает в начало файла 
	  -- 1-ым параметром задается относительно чего будет смещение: "set" - начало, "cur" - текущая позиция, "end" - конец файла
	  -- 2-ым параметром задается смещение
   
	log.trace('2')
	local a = {} -- объявление должно быть за пределами цикла
	local n = 1  -- инициализируем счётчик элементов таблицы
	io.input(getScriptPath().."\\port.prt") 
	while true do
		local line = io.read("*line") -- читаем целую строку
		if line == nil then break end -- если ничего не прочиталось - конец цикла
			--x,y = string.match(line,"([01]+) (%a)") -- двоичные цифры
			arr = mysplit(line, ';')
			a[n] = { arr }
			
			log.trace('line: '..line)
			log.trace('a[ '..n..']'..arr[1])
			n = n + 1
		--x,y = string.match(line,"([01]+) (%a)") -- двоичные цифры - помещаем в x, букву - в y
		--a[x]=y -- добавляем эту пару в ассоциативный массив
	end
	
	log.trace('3')
   
   
	log.trace('4')
   
	--f:seek("set",0);
	-- Перебирает строки файла, выводит их содержимое в сообщениях
	--for line in f:lines() do message(tostring(line));end
	-- Закрывает файл
	f:close();
   
   
	-- Цикл будет выполнятся, пока IsRun == true
	--while IsRun do
	--   sleep(100);
	--end;   
	log.trace('test4 end')
end;

function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end
 
function OnStop()
   IsRun = false;
end;