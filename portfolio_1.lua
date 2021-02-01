-- Сохранить портфель
-- Выводит портфель. Но не сохраняет

IsRun = true
class_code="TQBR"
 
function main()
   -- Получает доступный id для создания
   t_id = AllocTable()   
 
   -- добавить столбцы
   AddColumn(t_id, 1, "Бумага",       true, QTABLE_STRING_TYPE, 20)
   AddColumn(t_id, 2, "Кол-во",       true, QTABLE_INT_TYPE, 7)
   AddColumn(t_id, 3, "Цена покупки", true, QTABLE_DOUBLE_TYPE, 14)
   AddColumn(t_id, 4, "Цена текущая", true, QTABLE_DOUBLE_TYPE, 14)
   AddColumn(t_id, 5, "Прибыль, р",   true, QTABLE_DOUBLE_TYPE, 14)
   AddColumn(t_id, 6, "Прибыль, %",   true, QTABLE_DOUBLE_TYPE, 14)
   t = CreateWindow(t_id)
 
   for iRow = 1, getNumberOf("depo_limits") -1, 1 do
      rowInPortfolioTable = getItem("depo_limits", iRow) -- получить текущую строку из таблицы "Лимиты по бумагам"            
      qtyBoughtLots = tonumber(rowInPortfolioTable.currentbal)
      limitKind = rowInPortfolioTable.limit_kind
      if qtyBoughtLots > 0 and limitKind < 1 then
         InsertRow(t_id, iRow)-- добавить новую строку вниз таблицы   
      end
   end
   local rows, columns = GetTableSize (t_id)
   InsertRow(t_id, rows+1) -- добавить новую строку вниз таблицы для "Итого"
 
   SetWindowCaption(t_id, "Портфель: прибыли и убытки") 
 
   -- исполнять цикл, пока пользователь не остановит скрипт или не закроет окно таблицы
   while IsRun do 
      if IsWindowClosed(t_id)==true then
         IsRun=false
      end
 
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
 
      for iRow=0, getNumberOf("depo_limits")-1, 1 do
         rowInPortfolioTable = getItem("depo_limits", iRow) -- получить текущую строку из таблицы "Лимиты по бумагам"         
 
         qtyBoughtLots  = tonumber(rowInPortfolioTable.currentbal)
 
         limitKind = rowInPortfolioTable.limit_kind 
 
         if qtyBoughtLots>0 and limitKind<1    then      -- если кол-во лотов >0 и тип лимита T0
            currentSecCode = rowInPortfolioTable.sec_code
            fullNameOfInstrument =  tostring(getParamEx(class_code, currentSecCode, "SHORTNAME").param_image or "0") --"LONGNAME"
            avgPrice       = tonumber(rowInPortfolioTable.awg_position_price)                  
            currentPrice = GetAskPrice(currentSecCode)   
            profitAbs = (currentPrice-avgPrice)*qtyBoughtLots      
            profitPerc    = 100*currentPrice/avgPrice   - 100
 
			totalInvest = totalInvest + avgPrice*qtyBoughtLots  
			totalPortfolio = totalPortfolio + currentPrice*qtyBoughtLots   
 
            SetCell(t_id, iRowInOutTable, 1, fullNameOfInstrument) -- "Бумага"
            SetCell(t_id, iRowInOutTable, 2, tostring(qtyBoughtLots)) -- "Кол-во"RemoveZero(tostring(qtyBoughtLots)))
            SetCell(t_id, iRowInOutTable, 3, tostring( math_round(avgPrice, 3) ))  -- tostring(avgPrice))   -- "Цена покупки"
            SetCell(t_id, iRowInOutTable, 4, RemoveZero(tostring(currentPrice)))   -- "Цена текущая"
            SetCell(t_id, iRowInOutTable, 5, tostring( math_round( profitAbs, 0)) ) -- "Прибыль, р"
            SetCell(t_id, iRowInOutTable, 6, tostring(math_round(profitPerc, 1)) .."%") -- "Прибыль, %"
 
            if profitPerc >5 then       -- окрашиваем
               ColourRowInGreen(iRowInOutTable)
            elseif profitPerc<-5 then 
               ColourRowInRed(iRowInOutTable)
            else 
               ColourRowInYellow(iRowInOutTable)
            end   
            iRowInOutTable = iRowInOutTable+1
         end
      end
      totalProfit = totalPortfolio - totalInvest 
      totalPercent   = 100*totalProfit/totalInvest  
	  SetCell(t_id, iRowInOutTable, 1, "Итого") 
      SetCell(t_id, iRowInOutTable, 3, tostring( math_round(totalInvest, 0) ))  
      SetCell(t_id, iRowInOutTable, 4, tostring( math_round(totalPortfolio, 0)))  
      SetCell(t_id, iRowInOutTable, 5, tostring( math_round( totalProfit, 0)) ) 
      SetCell(t_id, iRowInOutTable, 6, tostring(math_round(totalPercent, 1)) .."%") 
 
	  if profitPerc >5 then       -- окрашиваем
               ColourRowInGreen(iRowInOutTable)
            elseif profitPerc<-5 then 
               ColourRowInRed(iRowInOutTable)
            else 
               ColourRowInYellow(iRowInOutTable)
            end   
            iRowInOutTable = iRowInOutTable+1
      sleep(5000) -- пауза 5 сек.
      end
   --message("script table portfolio finished")
end
 
 
function ColourRowInRed(num_row)
   SetColor(t_id, num_row, QTABLE_NO_INDEX, RGB(255,150,150), RGB(0,0,0), RGB(255,150,150), RGB(0,0,0))
end
function ColourRowInYellow(num_row)
   SetColor(t_id, num_row, QTABLE_NO_INDEX, RGB(255,255,200), RGB(0,0,0), RGB(255,255,200), RGB(0,0,0))
end
function ColourRowInGreen(num_row)
   SetColor(t_id, num_row, QTABLE_NO_INDEX, RGB(150,255,150), RGB(0,0,0), RGB(150,255,150), RGB(0,0,0))
end
function GetAskPrice(inp_Sec_Code )
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
   while (string.sub(str,-1) == "0" and str ~= "0") do
      str = string.sub(str,1,-2)
   end
   if (string.sub(str,-1) == ".") then 
      str = string.sub(str,1,-2)
   end   
   return str
end
function OnStop()
   DestroyTable(t_id)
   IsRun = false   
end