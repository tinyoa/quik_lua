-- save_portfolio.lua

--[[
Получить текущий портфель и записать в файл
]]

Run = true; -- флаг работы цикла в main
log = require "log";
myqlua = require "myqlua"
 
DataFolder = ''; -- Полный путь к папке "Данные(c)quikluacsharp.ru"
TradesFiles = {};-- Массив дескрипторов файлов
local PORTFOLIO_FILE = "pfolio.pf"
class_code="TQBR"
 
function OnInit()
	log.trace('-- save_portfolio INIT');
   -- Получает полный путь к папке "Данные(c)quikluacsharp.ru"
   DataFolder = getWorkingFolder()..'\\luas\\';
   log.trace('-- save_portfolio INIT. DataFolder:'..DataFolder);
   
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
	
	-- Сохранить портфель
	PrintPortfolio();
   -- Создает папки по всем найденным счетам
   --CreateAccountsFolders();
   -- Записывает все ранее не записанные сделки из таблицы "Сделки" в файлы
   --CheckAndSaveTerminalTrades();
end;
 
function main()
	--while Run do      
	--sleep(1);
	--end;   
end;
 

function PrintPortfolio()

	for iRow=1, getNumberOf("depo_limits")-1, 1 do
		rowInPortfolioTable = getItem("depo_limits", iRow) -- получить текущую строку из таблицы "Лимиты по бумагам"            
		qtyBoughtLots  = tonumber(rowInPortfolioTable.currentbal)         
		limitKind = rowInPortfolioTable.limit_kind          
		if qtyBoughtLots>0 and limitKind<1 then      
		--InsertRow(t_id, iRow)-- добавить новую строку вниз таблицы   
		end;
	end;
   
	local currentPrice=0
	local qtyBoughtLots=0
	local profitAbs = 0
	local profitPerc = 0
	local currentSecCode= ""
	local fullNameOfInstrument = ""
	local limitKind = 0
	local rowInPortfolioTable = {}    -- строка из таблицы "Лимиты по бумагам"
	local tableInstrument = {}    -- данные "Таблицы текущих торгов"
	local iRowInOutTable = 1
	local totalInvest = 0
	local totalPortfolio = 0
	local totalProfit = 0
	local totalPercent = 0

	f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "a");

	for iRow=0, getNumberOf("depo_limits")-1, 1 do
         rowInPortfolioTable = getItem("depo_limits", iRow) -- получить текущую строку из таблицы "Лимиты по бумагам"         
 
         qtyBoughtLots  = tonumber(rowInPortfolioTable.currentbal)
 
         limitKind = rowInPortfolioTable.limit_kind 
 
         if qtyBoughtLots > 0 and limitKind < 1    then      -- если кол-во лотов >0 и тип лимита T0
            currentSecCode = rowInPortfolioTable.sec_code
			log.trace('-- save_portfolio INIT. currentSecCode:'..tostring(currentSecCode));
			
            fullNameOfInstrument =  tostring(getParamEx(class_code, currentSecCode, "SHORTNAME").param_image or "0") --"LONGNAME"
            avgPrice = tonumber(rowInPortfolioTable.awg_position_price)
            currentPrice = myqlua.ifnull(GetAskPrice(currentSecCode), 0)  
            profitAbs = (currentPrice - avgPrice) * qtyBoughtLots      
            profitPerc = 100 * currentPrice / avgPrice - 100
 
			totalInvest = totalInvest + avgPrice * qtyBoughtLots  
			totalPortfolio = totalPortfolio + currentPrice * qtyBoughtLots   
 
            iRowInOutTable = iRowInOutTable + 1
			
			line = nil
			CurrentDate = myqlua.CurrentDate(format_num);
			datetime = os.date("!*t",os.time())
			line = CurrentDate
				..';'..fullNameOfInstrument
				..';'..tostring(qtyBoughtLots)
				..';'..tostring(myqlua.math_round(avgPrice, 3))
				..';'..myqlua.RemoveZero(tostring(currentPrice))
				..';'..tostring(myqlua.math_round(profitAbs, 0))
				..';'..tostring(myqlua.math_round(profitPerc, 1))

			f:write(line..'\n');
		 	
         end;
      
	  totalProfit = totalPortfolio - totalInvest 
      totalPercent   = 100*totalProfit / totalInvest  
	  
	end;
	f:close();
	
end; 
 
function GetAskPrice(inp_Sec_Code )
   local ask = tostring(getParamEx(class_code, inp_Sec_Code, "OFFER").param_value or 0)
   return ask
end

-- Создает каталоги по всем найденным счетам
function CreateAccountsFolders()
	log.trace('-- save_portfolio : CreateAccountsFolders');
   -- Перебирает все счета
   log.trace('-- save_portfolio.CreateAccountsFolders. Number of trade_accounts: '..
		tostring(getNumberOf("trade_accounts")));
   --for i = 0, getNumberOf("trade_accounts") - 1 do
   for i = 0, 10 do
   
      -- Получает номер счета
      local Account = getItem("trade_accounts", i).trdaccid;
	  
	  log.trace('-- save_portfolio.CreateAccountsFolders. iter: '..tostring(i)..
			'. Account'..Account);
			
      -- Получает путь
      local Path = '"'..DataFolder..Account..'\\"';
	  
	  log.trace('-- save_portfolio.CreateAccountsFolders. Path: '..Path);
		
      -- Если каталог не существует
      if os.execute('cd '..Path) == 1 then
         -- Создает каталог
		 log.trace('-- save_portfolio.CreateAccountsFolders. mkdir: '..Path);
         os.execute('mkdir '..Path); 
      end;
   end;
end;
 
-- Проверяет записана ли данная сделка в файл истории
function CheckTradeInFile(trade)
	log.trace('-- save_portfolio : CheckTradeInFile');
   -- Получает путь к файлу инструмента в папке торгового счета
   local PathAccountSec = DataFolder..trade.account..'\\'..trade.sec_code..'.csv';
   
   -- Пытается открыть файл текущего инструмента в режиме "чтения"
   local TradesFile = io.open(PathAccountSec,"r");
   
   -- Если файл не существует, то сделка не записана
   if TradesFile == nil then return false;
   else -- Если файл существует
      -- Получает индекс файла
      local FileIndex = trade.account..'_'..trade.sec_code;
      -- Если файл еще не открыт для дописывания
      if TradesFiles[FileIndex] == nil then
         -- Открывает файл текущего инструмента в режиме "дописывания"
         TradesFiles[FileIndex] = io.open(PathAccountSec,"a+");
      end;
      -- Перебирает строки файла
      local Count = 0; -- Счетчик строк
      for line in TradesFile:lines() do
         Count = Count + 1;
         if Count > 1 and line ~= "" then
            -- Если номера сделок совпадают, то сделка записана
            local i = 0;
            for str in line:gmatch("[^;^\n]+") do
               i = i + 1;
               if i == 3 and tonumber(str) == trade.trade_num then
                  TradesFile:close();
                  return true; 
               end;
            end;
         end;      
      end;
   end;
   TradesFile:close();
   return false;
end;

-- Записывает все ранее не записанные сделки из таблицы "Сделки" в файлы
function CheckAndSaveTerminalTrades()
	log.trace('-- save_portfolio : CheckAndSaveTerminalTrades');
   local trade = nil;
   -- Перебирает все сделки в таблице "Сделки"
   for i = 0, getNumberOf("trades") - 1, 1 do      
      trade = getItem ("trades", i);
      -- Если данная сделка еще не записана в файл истории
      if not CheckTradeInFile(trade) then        
         -- Добавляет сделку в файл истории
         AddTradeInFile(trade);
      end;
   end;
end;

-- Добавляет новую сделку в файл истории
function AddTradeInFile(trade)
	log.trace('-- save_portfolio : AddTradeInFile');
   local DateTime = trade.datetime;
   local Date = tonumber(DateTime.year);
   local month = tostring(DateTime.month);
   if #month == 1 then Date = Date.."0"..month; else Date = Date..month; end;
   local day = tostring(DateTime.day);
   if #day == 1 then Date = Date.."0"..day; else Date = Date..day; end;
   Date = tonumber(Date);
   local Time = "";
   local hour = tostring(DateTime.hour);
   if #hour == 1 then Time = Time.."0"..hour; else Time = Time..hour; end;
   local minute = tostring(DateTime.min);
   if #minute == 1 then Time = Time.."0"..minute; else Time = Time..minute; end;
   local sec = tostring(DateTime.sec);
   if #sec == 1 then Time = Time.."0"..sec; else Time = Time..sec; end;
   Time = tonumber(Time);
   -- Если ночная сделка, смещает дату на 1 день вперед
   if Time < 90000 then
      local seconds = os.time(DateTime);
      seconds = seconds + 24*60*60;
      DateTime = os.date("*t",seconds);
      Date = tonumber(DateTime.year);
      month = tostring(DateTime.month);
      if #month == 1 then Date = Date.."0"..month; else Date = Date..month; end;
      day = tostring(DateTime.day);
      if #day == 1 then Date = Date.."0"..day; else Date = Date..day; end;
      Date = tonumber(Date);
   end;
   local Operation = "";
   if CheckBit(trade.flags, 2) == 1 then Operation = "S"; else Operation = "B"; end;
 
   -- Добавляет сделку в массив
   local Trade = {};
   Trade.Account = trade.account;
   Trade.Sec_code = trade.sec_code;
   Trade.Num = trade.trade_num;
   Trade.Date = Date;
   Trade.Time = Time;
   Trade.Operation = Operation;
   Trade.Qty = tonumber(trade.qty);
   Trade.Price = tonumber(trade.price);
   Trade.Hint = "Account: "..Trade.Account.."_Number: "..trade.trade_num.."_Date: ";
   if #day == 1 then Trade.Hint = Trade.Hint.."0"..day.."/"; else Trade.Hint = Trade.Hint..day.."/"; end;
   if #month == 1 then Trade.Hint = Trade.Hint.."0"..month.."/"..DateTime.year; else Trade.Hint = Trade.Hint..month.."/"..DateTime.year; end;
   if #hour == 1 then Trade.Hint = Trade.Hint.."_Time: 0"..hour..":"; else Trade.Hint = Trade.Hint.."_Time: "..hour..":"; end;
   if #minute == 1 then Trade.Hint = Trade.Hint.."0"..minute..":"; else Trade.Hint = Trade.Hint..minute..":"; end;
   if #sec == 1 then Trade.Hint = Trade.Hint.."0"..sec; else Trade.Hint = Trade.Hint..sec; end;
   Trade.Hint = Trade.Hint.."_Quantity: "..trade.qty;
   Trade.Hint = Trade.Hint.."_Price: "..trade.price;
 
   -- Получает путь к файлу инструмента в папке торгового счета
   local PathAccountSec = DataFolder..Trade.Account..'\\'..Trade.Sec_code..'.csv';
   local FileIndex = Trade.Account..'_'..Trade.Sec_code;
   -- Если файл еще не открыт, или не существует
   if TradesFiles[FileIndex] == nil then
      -- Пытается открыть файл текущего инструмента в режиме "дописывания"
      TradesFiles[FileIndex] = io.open(PathAccountSec,"a+");
      -- Если файл не существует, то сделка не записана
      if TradesFiles[FileIndex] == nil then 
         -- Создает файл в режиме "записи"
         TradesFiles[FileIndex] = io.open(PathAccountSec,"w");
         -- Закрывает файл
         TradesFiles[FileIndex]:close();
         -- Открывает уже существующий файл в режиме "дописывания"
         TradesFiles[FileIndex] = io.open(PathAccountSec,"a+");
      end;
   end;
   -- Встает в начало файла
   TradesFiles[FileIndex]:seek("set",0);
   -- Если файл пустой
   if TradesFiles[FileIndex]:read() == nil then
      -- Добавляет строку заголовков
      TradesFiles[FileIndex]:write("Account;Sec code;Deal number;Deal date;Deal time;Direction;Quantity;Price;Hint", "\n");
   end;
   -- Встает в конец файла
   TradesFiles[FileIndex]:seek("end",0);
   -- Записывает сделку в файл
   TradesFiles[FileIndex]:write(Trade.Account..";"..Trade.Sec_code..";"..Trade.Num..";"..Trade.Date..";"..Trade.Time..";"..Trade.Operation..";"..Trade.Qty..";"..Trade.Price..";"..Trade.Hint, "\n");TradesFiles[FileIndex]:flush();
end;
 
function OnTrade(trade)
	log.trace('-- save_portfolio : OnTrade');
   -- Если данная сделка еще не записана в файл истории
   if not CheckTradeInFile(trade) then        
      -- Добавляет сделку в файл истории
      AddTradeInFile(trade);
   end;
end;
 
function OnStop()
	log.trace('-- save_portfolio : OnStop');
   -- Закрывает все файлы
   for key,Handle in pairs(TradesFiles) do
      if Handle ~= nil then Handle:close(); end;
   end;
   Run = false;
end;
 
-- Функция возвращает значение бита (число 0, или 1) под номером bit (начинаются с 0) в числе flags, если такого бита нет, возвращает nil
function CheckBit(flags, bit)
	log.trace('-- save_portfolio : CheckBit');
   -- Проверяет, что переданные аргументы являются числами
   if type(flags) ~= "number" then error("Ошибка!!! Checkbit: 1-й аргумент не число!"); end;
   if type(bit) ~= "number" then error("Ошибка!!! Checkbit: 2-й аргумент не число!"); end;
   local RevBitsStr  = ""; -- Перевернутое (задом наперед) строковое представление двоичного представления переданного десятичного числа (flags)
   local Fmod = 0; -- Остаток от деления 
   local Go = true; -- Флаг работы цикла
   while Go do
      Fmod = math.fmod(flags, 2); -- Остаток от деления
      flags = math.floor(flags/2); -- Оставляет для следующей итерации цикла только целую часть от деления           
      RevBitsStr = RevBitsStr ..tostring(Fmod); -- Добавляет справа остаток от деления
      if flags == 0 then Go = false; end; -- Если был последний бит, завершает цикл
   end;
   -- Возвращает значение бита
   local Result = RevBitsStr :sub(bit+1,bit+1);
   if Result == "0" then return 0;     
   elseif Result == "1" then return 1;
   else return nil;
   end;
end;
