-- test12.lua

--[[
Тут нужно сделать сохранялку в файл данных из таблицы обезличенных сделок
Баланс покупок/продаж поминутно
]]

log = require "log"

TICER = "SBER";
CLASS_CODE = "TQBR";
FILENAME_PAT = "reqtabl.zvk"

stopped = false;
t_id = nil
H = -1;
M = -1;
VSELL = 0;
VBUY  = 0;
cnt_deals = 0;

function OnInit()
    CreateTable();
end 

function main() 

	filename = os.date("%Y%m%d").."_"..FILENAME_PAT;

	-- Пытается открыть файл в режиме "чтения/записи"
	f = io.open(getScriptPath().."\\"..filename, "r+");
	-- Если файл не существует
	if f == nil then 
		log.trace('creating file')
		-- Создает файл в режиме "записи"
		f = io.open(getScriptPath().."\\"..filename, "w"); 
		-- Закрывает файл
		f:close();
		-- Открывает уже существующий файл в режиме "чтения"
		f = io.open(getScriptPath().."\\"..filename, "r");
	end;
	
	-- цикл
	while not stopped do 
		if IsWindowClosed(t_id) then
			stopped = true;
		end        
		sleep(100);
	end
	
	f:close();
end

function CreateTable()
	t_id = AllocTable(); 
	AddColumn(t_id, 0, "Время", true, QTABLE_STRING_TYPE, 10);
	AddColumn(t_id, 1, "BUY", true, QTABLE_INT_TYPE, 15);
	AddColumn(t_id, 2, "SELL", true, QTABLE_INT_TYPE, 15);
	AddColumn(t_id, 3, "Дельта V", true, QTABLE_INT_TYPE, 15);   
	AddColumn(t_id, 4, "Цена", true, QTABLE_DOUBLE_TYPE, 15);
	tab = CreateWindow(t_id);
	SetWindowCaption(t_id, TICER.." Баланс покупок/продаж");
	SetTableNotificationCallback(t_id, EventCallBack);
end

function OnAllTrade(alltrade)

	if fl == "1025" then tradedir = "sell;"; end --Продажа
	if fl == "1026" then tradedir = "buy;"; end
	
	line = tostring(alltrade.datetime.year ) .."."..tostring(alltrade.datetime.month ).."."..tostring(alltrade.datetime.day ) .. " "
		.. tostring(alltrade.datetime.hour) ..":"..tostring(alltrade.datetime.min)..":"..tostring(alltrade.datetime.sec) .." "
		.. tostring(alltrade.datetime.ms) ..":"..tostring(alltrade.datetime.mcs )..";"
		.. alltrade.sec_code ..";"
		--.. tradedir..";"
		.. tostring(fl)..";"
		.. alltrade.price..";"
		.. alltrade.qty
		;
	
	f:write(line.."\n");
	
	--cnt_deals = cnt_deals + 1
	--if cnt_deals % 1000 == 0 then f:flush() end;
	
end

function Red(row,col)
    SetColor(t_id, row, col, RGB(255,0,0), RGB(0,0,0), RGB(255,0,0), RGB(0,0,0));
end

function Yellow(row,col)
    SetColor(t_id, row, col, RGB(240,240,0), RGB(0,0,0), RGB(240,240,0), RGB(0,0,0));
end

function Green(row,col)
    SetColor(t_id, row, col, RGB(0,200,0), RGB(0,0,0), RGB(0,200,0), RGB(0,0,0));
end


function EventCallBack(t_id, msg, par1, par2)
	if msg==QTABLE_CLOSE then
		OnStop();
	end;
end

function OnStop(s)
	if t_id ~= nil then
		DestroyTable (t_id);
	end;
	stopped = true;
end