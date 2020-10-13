-- Сохранить портфель
IsRun = true
class_code = "TQBR"
FILE_NAME = "portfolio.txt"
LOG_FILE_NAME = "log.txt"

function main()
	-- Получает доступный id для создания
	--t_id = AllocTable()   

	-- f = io.open(getScriptPath().."\\log.txt","w");
	f = io.open(getScriptPath().."\\"..LOG_FILE_NAME,"w");
	f:write(tostring(rowInPortfolioTable));
	f:flush();
    f:close();
	

	-- добавить столбцы
	--AddColumn(t_id, 1, "Бумага",       true, QTABLE_STRING_TYPE, 20)
	--AddColumn(t_id, 2, "Кол-во",       true, QTABLE_INT_TYPE, 7)
	--AddColumn(t_id, 3, "Цена покупки", true, QTABLE_DOUBLE_TYPE, 14)
	--AddColumn(t_id, 4, "Цена текущая", true, QTABLE_DOUBLE_TYPE, 14)
	--AddColumn(t_id, 5, "Прибыль, р",   true, QTABLE_DOUBLE_TYPE, 14)
	--AddColumn(t_id, 6, "Прибыль, %",   true, QTABLE_DOUBLE_TYPE, 14)
	--t = CreateWindow(t_id)
 
 
	io.open(getScriptPath().."\\"..FILE_NAME,"w"):close()	-- Открыть и закрыть файл. Файл должен очиститься.
	-- Пытается открыть файл в режиме "чтения/записи"
	f = io.open(getScriptPath().."\\"..FILE_NAME,"r+");
	-- Если файл не существует
	--if f == nil then 
	--	-- Создает файл в режиме "записи"
	--	f = io.open(getScriptPath().."\\"..FILE_NAME,"w"); 
	--	-- Закрывает файл
	--	f:close();
	--	-- Открывает уже существующий файл в режиме "чтения/записи"
	--	f = io.open(getScriptPath().."\\"..FILE_NAME,"w");
	--end;
	f:write("Код бумаги\tКол-во\tСр.Цена бал\tТек.Цена");
 
	for iRow = 1, getNumberOf("depo_limits") -1, 1 do
		rowInPortfolioTable = getItem("depo_limits", iRow) -- получить текущую строку из таблицы "Лимиты по бумагам"            
		qtyBoughtLots = tonumber(rowInPortfolioTable.currentbal)
		limitKind = rowInPortfolioTable.limit_kind
		
		-- Пробую писать в файл
		if qtyBoughtLots > 0 and limitKind < 1 then
			currentSecCode = rowInPortfolioTable.sec_code
			currentPrice 	= GetAskPrice(currentSecCode)
			
			f:write("\n"..tostring(rowInPortfolioTable.sec_code).."\t"..
				tostring(rowInPortfolioTable.currentbal).."\t"..
				tostring(rowInPortfolioTable.awg_position_price).."\t"..
				tostring(currentPrice).."\t"
				);
		end

	end
	
	-- Сохраняет изменения в файле
	f:flush();
	-- Закрывает файл
	f:close();
	
	local rows, columns = GetTableSize (t_id)
	InsertRow(t_id, rows + 1) -- добавить новую строку вниз таблицы для "Итого"
 
	SetWindowCaption(t_id, "Портфель: прибыли и убытки") 
 
end


function GetAskPrice(inp_Sec_Code)
	local ask = tostring(getParamEx(class_code, inp_Sec_Code, "OFFER").param_value or 0)
	return ask
end

-- Округляет число до указанной точности
function math_round (num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- удаление точки и нулей после нее
function RemoveZero(str)
	while (string.sub(str, -1) == "0" and str ~= "0") do
		str = string.sub(str, 1, -2)
	end
	if (string.sub(str, -1) == ".") then 
		str = string.sub(str, 1, -2)
	end   
	return str
end

function OnStop()
	DestroyTable(t_id)
	IsRun = false   
end