﻿-- Флаг поддержания работы скрипта
IsRun = true;

-- Создает файл Text.txt если его нет
-- Записывает в файл две строчки: "Line1\nLine2"
-- Должен в цикле перебрать строки и показать все строки. Показывает только вторую

function main()
   -- Пытается открыть файл в режиме "чтения/записи"
   f = io.open(getScriptPath().."\\Test.txt","r+");
   -- Если файл не существует
   if f == nil then 
      -- Создает файл в режиме "записи"
      f = io.open(getScriptPath().."\\Test.txt","w"); 
      -- Закрывает файл
      f:close();
      -- Открывает уже существующий файл в режиме "чтения/записи"
      f = io.open(getScriptPath().."\\Test.txt","r+");
   end;
   
   -- Записывает в файл 2 строки
   f:write("Line1\nLine2\nLine3\nLine4\nLine5"); -- "\n" признак конца строки
   -- Сохраняет изменения в файле
   f:flush();
   -- Встает в начало файла 
      -- 1-ым параметром задается относительно чего будет смещение: "set" - начало, "cur" - текущая позиция, "end" - конец файла
      -- 2-ым параметром задается смещение
   f:seek("set",0);
   -- Перебирает строки файла, выводит их содержимое в сообщениях
   for line in f:lines() do message(tostring(line));end
   -- Закрывает файл
   f:close();
   -- Цикл будет выполнятся, пока IsRun == true
   while IsRun do
      sleep(100);
   end;   
end;
 
function OnStop()
   IsRun = false;
end;