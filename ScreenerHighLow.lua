-- В©2020 by Evgeny Shibaev
-- РўР°Р±Р»РёС†Р°, РѕС‚РѕР±СЂР°Р¶Р°СЋС‰Р°СЏ РІ РїСЂРѕС†РµРЅС‚Р°С… СЂРѕСЃС‚(РїР°РґРµРЅРёРµ) РёРЅСЃС‚СЂСѓРјРµРЅС‚Р° С„РёРЅР°РЅСЃРѕРІРѕРіРѕ СЂС‹РЅРєР° Р·Р° РѕРїСЂРµРґРµР»РµРЅРЅРѕРµ РєРѕР»РёС‡РµСЃС‚РІРѕ РґРЅРµР№
-- РљР°РєРёРµ РёРЅСЃС‚СЂСѓРјРµРЅС‚С‹(С‚РёРєРµСЂС‹) РѕС‚СЃР»РµР¶РёРІР°РµРј. РўР°Р±Р»РёС†Р° РїР°СЂ С‚РёРєРµСЂ - РїР»РѕС‰Р°РґРєР°
tickers = {VSMO = "TQBR",
		PLZL = "TQBR",
		CHMF = "TQBR",
		ALRS = "TQBR",
		RTKMP = "TQBR",
		AFKS = "TQBR",
		MAGN = "TQBR",
		HIMCP = "TQBR",
		MTSS = "TQBR",
		MRKP = "TQBR",
		RSTIP = "TQBR",
		VTBR = "TQBR",
		MOEX = "TQBR",
		LKOH = "TQBR",
		MGNT = "TQBR",
		ROSN = "TQBR",
		SIBN = "TQBR",
		PHOR = "TQBR",
		NKNC = "TQBR",
		NKHP = "TQBR",
		SBER = "TQBR", 
		STSBP = "TQBR",
		GAZP = "TQBR", 
		NLMK = "TQBR",
		CNTLP = "TQBR",
		RLMNP = "TQBR",
		TATNP = "TQBR",
		LSRG = "TQBR",
		AFLT = "TQBR",
		NKNCP = "TQBR",
		MTLRP = "TQBR",
		MRKV = "TQBR",
		DIOD = "TQBR",
		TGKD = "TQBR",
        GMKN = "TQBR", 
		MGNT = "TQBR"} --IMOEX = "SNDX"
-- Р—Р° РїРѕСЃР»РµРґРЅРёРµ n-РґРЅРµР№
days_before = {0, 1, 2, 3, 5, 10, 30, 44, 67, 90} -- СЌРєРІРёРІР°Р»РµРЅС‚РЅРѕ "РІС‡РµСЂР°", "РїРѕР·Р°РІС‡РµСЂР°", 3-РґРЅСЏ РЅР°Р·Р°Рґ, 7 Рё 30 С‚РѕСЂРіРѕРІС‹С… СЃРµСЃСЃРёР№ РЅР°Р·Р°Рґ.
sources = {} -- РЎРїРёСЃРѕРє РёСЃС‚РѕС‡РЅРёРєРѕРІ РґР°РЅРЅС‹С… РїРѕ РєРѕР»РёС‡РµСЃС‚РІСѓ С‚РёРєРµСЂРѕРІ
rows = {} -- РЎРїРёСЃРѕРє СЃС‚СЂРѕРє РІ С‚Р°Р±Р»РёС†Рµ РїРѕ РєРѕР»РёС‡РµСЃС‚РІСѓ С‚РёРєРµСЂРѕРІ
screener = AllocTable() -- РЈРєР°Р·Р°С‚РµР»СЊ РЅР° С‚Р°Р±Р»РёС†Сѓ FromLow
rowsH = {} -- РЎРїРёСЃРѕРє СЃС‚СЂРѕРє РІ С‚Р°Р±Р»РёС†Рµ РїРѕ РєРѕР»РёС‡РµСЃС‚РІСѓ С‚РёРєРµСЂРѕРІ
screenerH = AllocTable() -- РЈРєР°Р·Р°С‚РµР»СЊ РЅР° С‚Р°Р±Р»РёС†Сѓ FromHigh
stopped = false -- РћСЃС‚Р°РЅРѕРІРєР° СЃРєСЂРёРїС‚Р°
col_shift = 1
local max = math.max  -- Р»РѕРєР°Р»СЊРЅР°СЏ СЃСЃС‹Р»РєР° РЅР° math.max
local min = math.min  -- Р»РѕРєР°Р»СЊРЅР°СЏ СЃСЃС‹Р»РєР° РЅР° math.min

-- Р¤СѓРЅРєС†РёСЏ РІС‹Р·С‹РІР°РµС‚СЃСЏ РїРµСЂРµРґ РІС‹Р·РѕРІРѕРј main
function OnInit(path)
    -- "Ticker"- РЅР°Р·РІР°РЅРёРµ РїРµСЂРІРѕРіРѕ СЃС‚РѕР»Р±С†Р° РІ С‚Р°Р±Р»РёС†Рµ
    AddColumn(screener, 0, "Ticker", true, QTABLE_STRING_TYPE, 15)
    AddColumn(screener, 1, "Price", true, QTABLE_DOUBLE_TYPE, 12)   
    -- РќР°Р·РІР°РЅРёСЏ РѕСЃС‚Р°Р»СЊРЅС‹С… СЃС‚РѕР»Р±С†РѕРІ РІ С‚Р°Р±Р»РёС†Рµ РїРѕ РєРѕР»РёС‡РµСЃС‚РІСѓ days_before
    for column, days in ipairs(days_before) do
        if days == 0 then header = "Today" else header = days.." days" end
        AddColumn(screener, column + col_shift, header, true, QTABLE_DOUBLE_TYPE, 8)
    end
    CreateWindow(screener)
   -- Р”Р°РµРј РЅР°Р·РІР°РЅРёРµ  С‚Р°Р±Р»РёС†Рµ
    SetWindowCaption(screener, "Percent change from LOW for last days")
   -- Р’С‚РѕСЂР°СЏ С‚Р°Р±Р»РёС†Р° - РѕС‚ РјР°РєСЃРёРјСѓРјРѕРІ Р·Р° РїРµСЂРёРѕРґ.
    AddColumn(screenerH, 0, "Ticker", true, QTABLE_STRING_TYPE, 15)
    AddColumn(screenerH, 1, "Price", true, QTABLE_DOUBLE_TYPE, 12)   
    -- РќР°Р·РІР°РЅРёСЏ РѕСЃС‚Р°Р»СЊРЅС‹С… СЃС‚РѕР»Р±С†РѕРІ РІ С‚Р°Р±Р»РёС†Рµ РїРѕ РєРѕР»РёС‡РµСЃС‚РІСѓ days_before
    for column, days in ipairs(days_before) do
        if days == 0 then header = "Today" else header = days.." days" end
        AddColumn(screenerH, column + col_shift, header, true, QTABLE_DOUBLE_TYPE, 8)
    end
    CreateWindow(screenerH)
    SetWindowCaption(screenerH, "Percent change from HIGH for last days")
    for ticker, board in pairs(tickers) do
        --Р”Р»СЏ РєР°Р¶РґРѕРіРѕ С‚РёРєРµСЂР° СЃРѕР·РґР°РµРј РёСЃС‚РѕС‡РЅРёРє РґР°РЅРЅС‹С… - "РґРЅРµРІРєРё"
        sources[ticker] = CreateDataSource(board, ticker, INTERVAL_D1)
        --РЈСЃС‚Р°РЅР°РІР»РёРІР°РµРј РєРѕР»Р»Р±СЌРє С„СѓРЅРєС†РёСЋ РґР»СЏ РєР°Р¶РґРѕРіРѕ С‚РёРєРµСЂР°. РћРЅР° РІС‹Р·С‹РІР°РµС‚СЃСЏ РїСЂРё РёР·РјРµРЅРµРЅРёРё С†РµРЅС‹ С‚РёРєРµСЂР°. "Рђ С‡С‚Рѕ, С‚Р°Рє РјРѕР¶РЅРѕ Р±С‹Р»Рѕ?"
        sources[ticker]:SetUpdateCallback(function(index) InvalidateCallback(index, ticker) end)
        --Р”Р»СЏ РєР°Р¶РґРѕРіРѕ С‚РёРєРµСЂР° РѕРїСЂРµРґРµР»СЏРµРј СЃС‚СЂРѕРєСѓ РІ С‚Р°Р±Р»РёС†Рµ Рё Р·Р°РїРѕРјРёРЅР°РµРј РµРµ РІ rows
        rows[ticker] = InsertRow(screener, -1)
        rowsH[ticker] = InsertRow(screenerH, -1)
        --Р’ РїРµСЂРІРѕРј СЃС‚РѕР»Р±С†Рµ РєР°Р¶РґРѕР№ СЃС‚СЂРѕРєРё Р±СѓРґРµС‚ РёРјСЏ С‚РёРєРµСЂР°
        SetCell(screener, rows[ticker], 0, ticker)
        SetCell(screenerH, rowsH[ticker], 0, ticker)
    end
end

-- РљРѕР»Р»Р±СЌРє С„СѓРЅРєС†РёСЏ РІС‹Р·С‹РІР°РµС‚СЃСЏ РїСЂРё РёР·РјРµРЅРµРЅРёРё Р·РЅР°С‡РµРЅРёСЏ С‚РµРєСѓС‰РµР№ С†РµРЅС‹ С‚РёРєРµСЂР°. РћР±РЅРѕРІР»СЏРµС‚ СЃС‚СЂРѕРєСѓ С‚РёРєРµСЂР° РІ С‚Р°Р±Р»РёС†Рµ СЃСЂР°Р·Сѓ, РєР°Рє РїСЂРѕРёСЃС…РѕРґРёС‚ РёР·РјРµРЅРµРЅРёРµ.
function InvalidateCallback(index, ticker)
    price = sources[ticker]:C(sources[ticker]:Size())
    ap = getSecurityInfo(tickers[ticker], ticker).scale
    if ap == 0 then price = math.floor(price) end 
    SetCell(screener, rows[ticker], 1, tostring(price))
    SetCell(screenerH, rows[ticker], 1, tostring(price))
    for column, days in ipairs(days_before) do
        -- РћРїСЂРµРґРµР»СЏРµРј РїСЂРѕС†РµРЅС‚СЂ РёР·РјРµРЅРµРЅРёСЏ С†РµРЅС‹ С‚РёРєРµСЂР° Р·Р° days-РґРЅРµР№ РѕС‚ РјРёРЅРёРјР°Р»СЊРЅС‹С… Р·РЅР°С‡РµРЅРёР№ Р·Р° СЌС‚РѕС‚ РїРµСЂРёРѕРґ
        percent = FromLow(ticker, days)
        -- РћРїСЂРµРґРµР»СЏРµРј РїСЂРѕС†РµРЅС‚СЂ РёР·РјРµРЅРµРЅРёСЏ С†РµРЅС‹ С‚РёРєРµСЂР° Р·Р° days-РґРЅРµР№ РѕС‚ РјР°РєСЃРёРјР°Р»СЊРЅС‹С… Р·РЅР°С‡РµРЅРёР№ Р·Р° СЌС‚РѕС‚ РїРµСЂРёРѕРґ
        percentH = FromHigh(ticker, days)
        SetCell(screener, rows[ticker], column + col_shift, string.format("%.2f", percent))
        SetCell(screenerH, rowsH[ticker], column + col_shift, string.format("%.2f", percentH))
        -- РџРѕРґРєСЂР°С€РёРІР°РµРј СЏС‡РµР№РєСѓ СЃРѕРѕС‚РІРµС‚СЃС‚РІРµРЅРЅРѕ СЂРѕСЃС‚Сѓ(РїР°РґРµРЅРёСЋ) Рё РІРµР»РёС‡РёРЅС‹ СЂРѕСЃС‚Р°(РїР°РґРµРЅРёСЏ)
        SetColor(screener, rows[ticker], column + col_shift, BCellColor(percent), FCellColor(percent), BCellColor(percent), FCellColor(percent))
        SetColor(screenerH, rowsH[ticker], column + col_shift, BCellColor(percentH), FCellColor(percentH), BCellColor(percentH), FCellColor(percentH))
    end
end

--Р¤СѓРЅРєС†РёСЏ РѕРїСЂРµРґРµР»СЏРµС‚ РЅР° СЃРєРѕР»СЊРєРѕ РїСЂРѕС†РµРЅС‚РѕРІ РІС‹СЂРѕСЃР»Р° РёР»Рё СѓРїР°Р»Р° Р±СѓРјР°РіР° РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ N-РґРЅРµР№ РЅР°Р·Р°Рґ
function Change(ticker, days_before)
    local len = sources[ticker]:Size() --РЎРєРѕР»СЊРєРѕ РІСЃРµРіРѕ "РґРЅРµРІРЅС‹С…" СЃРІРµС‡РµР№ РІ РёСЃС‚РѕС‡РЅРёРєРµ РґР°РЅРЅС‹С… РєРѕРЅРєСЂРµС‚РЅРѕРіРѕ С‚РёРєРµСЂР°
    local maxval = DaysHigh(ticker, days_before)
    --Р’РѕР·РІСЂР°С‰Р°РµРј СЂРѕСЃС‚(РїР°РґРµРЅРёРµ) РІ РїСЂРѕС†РµРЅС‚Р°С… С‚РµРєСѓС‰РµР№ С†РµРЅС‹ РѕС‚ С†РµРЅС‹ Р·Р°РєСЂС‹С‚РёСЏ days_before-С‚РѕСЂРіРѕРІС‹С… СЃРµСЃСЃРёР№ РЅР°Р·Р°Рґ
    return (sources[ticker]:C(len) - maxval) / maxval * 100
end

function FromHigh(ticker, days_before)
    local len = sources[ticker]:Size() --РЎРєРѕР»СЊРєРѕ РІСЃРµРіРѕ "РґРЅРµРІРЅС‹С…" СЃРІРµС‡РµР№ РІ РёСЃС‚РѕС‡РЅРёРєРµ РґР°РЅРЅС‹С… РєРѕРЅРєСЂРµС‚РЅРѕРіРѕ С‚РёРєРµСЂР°
    local maxval = DaysHigh(ticker, days_before)
    --Р’РѕР·РІСЂР°С‰Р°РµРј РїР°РґРµРЅРёРµ РІ РїСЂРѕС†РµРЅС‚Р°С… С‚РµРєСѓС‰РµР№ С†РµРЅС‹ РѕС‚ РјР°РєСЃРёРјР°Р»СЊРЅРѕР№ С†РµРЅС‹ Р·Р° days_before-С‚РѕСЂРіРѕРІС‹С… СЃРµСЃСЃРёР№ РЅР°Р·Р°Рґ (РІРєР»СЋС‡Р°СЏ С‚РµРєСѓС‰СѓСЋ)
    return (sources[ticker]:C(len) - maxval) / maxval * 100
end

function FromLow(ticker, days_before)
    local len = sources[ticker]:Size() --РЎРєРѕР»СЊРєРѕ РІСЃРµРіРѕ "РґРЅРµРІРЅС‹С…" СЃРІРµС‡РµР№ РІ РёСЃС‚РѕС‡РЅРёРєРµ РґР°РЅРЅС‹С… РєРѕРЅРєСЂРµС‚РЅРѕРіРѕ С‚РёРєРµСЂР°
    local minval = DaysLow(ticker, days_before)
    --Р’РѕР·РІСЂР°С‰Р°РµРј СЂРѕСЃС‚ РІ РїСЂРѕС†РµРЅС‚Р°С… С‚РµРєСѓС‰РµР№ С†РµРЅС‹ РѕС‚ РјРёРЅРёРјР°Р»СЊРЅРѕР№ С†РµРЅС‹ Р·Р° days_before-С‚РѕСЂРіРѕРІС‹С… СЃРµСЃСЃРёР№ РЅР°Р·Р°Рґ (РІРєР»СЋС‡Р°СЏ С‚РµРєСѓС‰СѓСЋ)
    return (sources[ticker]:C(len) - minval) / minval * 100
end

-- Р¦РІРµС‚ С‚РµРєСЃС‚Р° РІ СЏС‡РµР№РєРµ. Р•СЃР»Рё СЂРѕСЃС‚ - С‚Рѕ С†РІРµС‚ "Р·РµР»РµРЅС‹Р№", РїР°РґРµРЅРёРµ - "РєСЂР°СЃРЅС‹Р№"
--function FCellColor(change) if change > 0 then return RGB(0,128,0) else return RGB(158,0,0) end end
function FCellColor(change) if change > 0 then return RGB(0,0,0) else return RGB(0,0,0) end end

-- РњР°Р»РµРЅСЊРєР°СЏ "С‚РµРїР»РѕРІР°СЏ РєР°СЂС‚Р°". Р”РµР»Р°РµС‚ С„РѕРЅ СЏС‡РµР№РєРё Р±РѕР»РµРµ РёРЅС‚РµРЅСЃРёРІРЅС‹Рј, РІР·Р°РІРёСЃРёРјРѕСЃС‚Рё РѕС‚ РІРµР»РёС‡РёРЅС‹ СЂРѕСЃС‚Р°(РїР°РґРµРЅРёСЏ)
function BCellColor(change)
    bright = math.floor(255 - min(math.abs(change*11), 235),1)  --10 110
    if change > 0 then return RGB(bright,255,bright) else return RGB(255,bright,bright) end
end

function DaysHigh(ticker, days_before)
    local hi,len = -1000000000,sources[ticker]:Size()
    for i = len, len - days_before, -1 do hi = max(hi,sources[ticker]:H(i)) end
    return hi
end

function DaysLow(ticker, days_before)
    local lo,len = 1000000000,sources[ticker]:Size()
    for i = len, len - days_before, -1 do lo = min(lo,sources[ticker]:L(i)) end
    return lo
end

-- Р¤СѓРЅРєС†РёСЏ РІС‹Р·С‹РІР°РµС‚СЃСЏ РїРµСЂРµРґ РѕСЃС‚Р°РЅРѕРІРєРѕР№ СЃРєСЂРёРїС‚Р°
function OnStop(signal) stopped = true end

-- Р¤СѓРЅРєС†РёСЏ РІС‹Р·С‹РІР°РµС‚СЃСЏ РїРµСЂРµРґ Р·Р°РєСЂС‹С‚РёРµРј РєРІРёРєР°
function OnClose() stopped = true end;

-- РћСЃРЅРѕРІРЅР°СЏ С„СѓРЅРєС†РёСЏ РІС‹РїРѕР»РЅРµРЅРёСЏ СЃРєСЂРёРїС‚Р°
function main()
    while not stopped do sleep(1) end
end  	  