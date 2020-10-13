-- ©2020 by Evgeny Shibaev for Weddy
-- Таблица, отображающая в процентах рост(падение) инструмента финансового рынка от заданных дат
-- Какие инструменты(тикеры) отслеживаем. Таблица пар тикер - площадка
tickers = {SiU0 = "SPBFUT", RIU0 = "SPBFUT", BRQ0 = "SPBFUT", GZU0 = "SPBFUT", SRU0 = "SPBFUT", GAZP = "TQBR", SBER = "TQBR", YNDX = "TQBR",
           GMKN = "TQBR", MGNT = "TQBR", SU26207RMFS9 = "TQOB"} --IMOEX = "SNDX"
-- От конкретных дат   start month     year low      year high   MICEX INDEX
dates = {"10/07/2020", "02/07/2020", "19/03/2020", "20/01/2020"}
events = {"Week          ", "Month        ", "MICEX YrL ", "MICEX YrH "} -- Список событий, соответствующих заданной выше дате
sources = {} -- Список источников данных по количеству тикеров
rows = {} -- Список строк в таблице LOW по количеству тикеров
screener = AllocTable() -- Указатель на таблицу FromLow
rowsH = {} -- Список строк в таблице HIGH по количеству тикеров
screenerH = AllocTable() -- Указатель на таблицу FromHigh
stopped = false -- Остановка скрипта
col_shift = 1 -- смещение основных столбцов в таблице
local max = math.max  -- локальная ссылка на math.max
local min = math.min  -- локальная ссылка на math.min
     
-- Функция вызывается перед вызовом main
function OnInit(path)
   -- "Ticker"- название первого столбца в таблице
   AddColumn(screener, 0, "Ticker", true, QTABLE_STRING_TYPE, 15)
   AddColumn(screener, 1, "Price", true, QTABLE_DOUBLE_TYPE, 12) 
   -- Названия остальных столбцов в таблице по количеству dates
   for column, date in ipairs(dates) do
       AddColumn(screener, column + col_shift, events[column].." "..date, true, QTABLE_DOUBLE_TYPE, 10)
   end
   CreateWindow(screener)
  -- Даем название  таблице
   SetWindowCaption(screener, "Percent change from LOW from date")
  -- Вторая таблица - от максимумов за период.
   AddColumn(screenerH, 0, "Ticker", true, QTABLE_STRING_TYPE, 15)
   AddColumn(screenerH, 1, "Price", true, QTABLE_DOUBLE_TYPE, 12)   
   -- Названия остальных столбцов в таблице по количеству dates
   for column, date in ipairs(dates) do
       AddColumn(screenerH, column + col_shift, events[column].." "..date, true, QTABLE_DOUBLE_TYPE, 10)
   end
   CreateWindow(screenerH)
   SetWindowCaption(screenerH, "Percent change from HIGH from date")
   for ticker, board in pairs(tickers) do
       --Для каждого тикера создаем источник данных - "дневки"
       sources[ticker] = CreateDataSource(board, ticker, INTERVAL_D1)
       --ИСПРАВЛЕНО! Когда я в OnInit устанавливал коллбэк, то загрузка была долгой, из за того что при приходе очередной свечи 
       -- каждый раз вызывался этот коллбэк. Я перенес определение коллбэка в main с небольшой задержкой sleep(100).
       -- После этого тормоза исчезли. Строка ниже в этом месте тормозила:
       -- sources[ticker]:SetUpdateCallback(function(index) InvalidateCallback(index, ticker) end)
       --Для каждого тикера определяем строку в таблице и запоминаем ее в rows
       rows[ticker] = InsertRow(screener, -1)
       rowsH[ticker] = InsertRow(screenerH, -1)
       --В первом столбце каждой строки устанавливаем имя тикера
       SetCell(screener, rows[ticker], 0, ticker)
       SetCell(screenerH, rowsH[ticker], 0, ticker)
   end
end

-- Коллбэк функция вызывается при изменении значения текущей цены тикера. Обновляет строку тикера в таблице сразу, как происходит изменение.
function InvalidateCallback(index, ticker)
   price = sources[ticker]:C(sources[ticker]:Size())
   ap = getSecurityInfo(tickers[ticker], ticker).scale
   if ap == 0 then price = math.floor(price) end 
   SetCell(screener, rows[ticker], 1, tostring(price))
   SetCell(screenerH, rows[ticker], 1, tostring(price))
   for column, date in ipairs(dates) do
      -- Определяем процентр изменения цены тикера за days-дней от минимальных значений за этот период
      percent = DateLow(ticker, date)
      -- Определяем процентр изменения цены тикера за days-дней от максимальных значений за этот период
      percentH = DateHigh(ticker, date)
      SetCell(screener, rows[ticker], column + col_shift, string.format("%.2f", percent))
      SetCell(screenerH, rowsH[ticker], column + col_shift, string.format("%.2f", percentH))
      -- Подкрашиваем ячейку соответственно росту(падению) и величины роста(падения)
      SetColor(screener, rows[ticker], column + col_shift, BCellColor(percent), FCellColor(percent), BCellColor(percent), FCellColor(percent))
      SetColor(screenerH, rowsH[ticker], column + col_shift, BCellColor(percentH), FCellColor(percentH), BCellColor(percentH), FCellColor(percentH))
   end
end

-- Определяет процент изменения текущей цены от минимума дня указанной даты
function DateLow(ticker, date)
  local len = sources[ticker]:Size() --Сколько всего "дневных" свечей в источнике данных конкретного тикера
  local dt = StrToDate(date)
  for i = len, 1, -1 do
    local candle_time = sources[ticker]:T(i)
    if dt.day == candle_time.day and dt.month == candle_time.month and dt.year == candle_time.year then
       return (sources[ticker]:C(len) - sources[ticker]:L(i)) / sources[ticker]:L(i) * 100 end
  end
  return 0
end

-- Определяет процент изменения текущей цены от максимума дня указанной даты
function DateHigh(ticker, date)
  local len = sources[ticker]:Size() --Сколько всего "дневных" свечей в источнике данных конкретного тикера
  local dt = StrToDate(date)
  for i = len, 1, -1 do
    local candle_time = sources[ticker]:T(i)
    if dt.day == candle_time.day and dt.month == candle_time.month and dt.year == candle_time.year then
       return (sources[ticker]:C(len) - sources[ticker]:H(i)) / sources[ticker]:H(i) * 100 end
  end
  return 0
end

-- Цвет текста в ячейке. Если рост - то цвет "зеленый", падение - "красный"
--function FCellColor(change) if change > 0 then return RGB(0,128,0) else return RGB(158,0,0) end end
function FCellColor(change) if change > 0 then return RGB(0,0,0) else return RGB(0,0,0) end end

-- Маленькая "тепловая карта". Делает фон ячейки более интенсивным, взависимости от величины роста(падения)
function BCellColor(change)
  bright = math.floor(255 - min(math.abs(change*5), 235),1)  --10 110
  if change > 0 then return RGB(bright,255,bright) else return RGB(255,bright,bright) end
end

-- Преобразует строку вида "05/07/2020" в таблицу {year = 2020, month = 7, day = 5}
function StrToDate(str)
   dt = {}
   dt.day,dt.month,dt.year = string.match(str, "(%d*)/(%d*)/(%d*)")
   for key,val in pairs(dt) do dt[key] = tonumber(val) end
   return dt
end

-- Функция вызывается перед остановкой скрипта
function OnStop(signal) stopped = true end

-- Функция вызывается перед закрытием квика
function OnClose() stopped = true end;

-- Основная функция выполнения скрипта
function main()
   for ticker, board in pairs(tickers) do
       sleep(300)
       --Устанавливаем коллбэк функцию для каждого тикера. Она вызывается при изменении цены тикера. "А что, так можно было?"
       sources[ticker]:SetUpdateCallback(function(index) InvalidateCallback(index, ticker) end)
       sleep(50)
       -- Вызываем первый раз явно для полной отрисовки таблицы, следующая отрисовка строк только при изменении цены
       InvalidateCallback(sources[ticker]:Size(), ticker)
   end
  while not stopped do sleep(1) end
end  	  