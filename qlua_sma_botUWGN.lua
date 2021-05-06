-- qlua_sma_botUWGN.lua



local qlua_sma_botUWGN = { _version = "0.1.1" }

-- Р¤Р»Р°Рі РїРѕРґРґРµСЂР¶Р°РЅРёСЏ СЂР°Р±РѕС‚С‹ СЃРєСЂРёРїС‚Р°
IsRun = true;

log = require "log"
myqlua = require "myqlua"

local PRICE_STEP = 0.03		-- РѕС‚РєР»РѕРЅРµРЅРёРµ, РєРѕС‚РѕСЂРѕРµ СЃС‡РёС‚Р°РµС‚СЃСЏ РґРѕСЃС‚Р°С‚РѕС‡РЅС‹Рј РґР»СЏ РїРµСЂРµС…РѕРґР° РЅР° СЃР»РµРґСѓСЋС‰РёР№ СѓСЂРѕРІРµРЅСЊ
local act_list = {} 	-- РјР°С‚СЂРёС†Р° СЃ РёРЅСЃС‚СЂСѓРјРµРЅС‚Р°РјРё
local order_list = {}	-- СЃРїРёСЃРѕРє Р·Р°СЏРІРѕРє
local amount_rur = 0			-- РєРѕР»-РІРѕ РґРµРЅРµРі
local class_code = "TQBR"
local PORTFOLIO_FILE = "portUWGN.prt"

function qlua_sma_botUWGN.settings()
	log.trace("PORTFOLIO_FILE: "..PORTFOLIO_FILE..", PRICE_STEP: "..PRICE_STEP.."")
end;

function qlua_sma_botUWGN.main()
	
	log.trace('-- -- -- '..PORTFOLIO_FILE)

	-- РџС‹С‚Р°РµС‚СЃСЏ РѕС‚РєСЂС‹С‚СЊ С„Р°Р№Р» РІ СЂРµР¶РёРјРµ "С‡С‚РµРЅРёСЏ/Р·Р°РїРёСЃРё"
	f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "r+");
	-- Р•СЃР»Рё С„Р°Р№Р» РЅРµ СЃСѓС‰РµСЃС‚РІСѓРµС‚
	if f == nil then 
		log.trace('creating file')
		-- РЎРѕР·РґР°РµС‚ С„Р°Р№Р» РІ СЂРµР¶РёРјРµ "Р·Р°РїРёСЃРё"
		f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "w"); 
		-- Р—Р°РєСЂС‹РІР°РµС‚ С„Р°Р№Р»
		f:close();
		-- РћС‚РєСЂС‹РІР°РµС‚ СѓР¶Рµ СЃСѓС‰РµСЃС‚РІСѓСЋС‰РёР№ С„Р°Р№Р» РІ СЂРµР¶РёРјРµ "С‡С‚РµРЅРёСЏ"
		f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "r");
	end;
   
	-- Р—Р°РїРёСЃС‹РІР°РµС‚ РІ С„Р°Р№Р» 2 СЃС‚СЂРѕРєРё
	--f:write("Line1\nLine2"); -- "\n" РїСЂРёР·РЅР°Рє РєРѕРЅС†Р° СЃС‚СЂРѕРєРё
	-- РЎРѕС…СЂР°РЅСЏРµС‚ РёР·РјРµРЅРµРЅРёСЏ РІ С„Р°Р№Р»Рµ
	--f:flush();
	-- Р’СЃС‚Р°РµС‚ РІ РЅР°С‡Р°Р»Рѕ С„Р°Р№Р»Р° 
	  -- 1-С‹Рј РїР°СЂР°РјРµС‚СЂРѕРј Р·Р°РґР°РµС‚СЃСЏ РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ С‡РµРіРѕ Р±СѓРґРµС‚ СЃРјРµС‰РµРЅРёРµ: "set" - РЅР°С‡Р°Р»Рѕ, "cur" - С‚РµРєСѓС‰Р°СЏ РїРѕР·РёС†РёСЏ, "end" - РєРѕРЅРµС† С„Р°Р№Р»Р°
	  -- 2-С‹Рј РїР°СЂР°РјРµС‚СЂРѕРј Р·Р°РґР°РµС‚СЃСЏ СЃРјРµС‰РµРЅРёРµ
   
	--log.trace('РЎС‡РёС‚Р°С‚СЊ РґР°РЅРЅС‹Рµ РІ РјР°СЃСЃРёРІ')
	local a = {} 			-- РѕР±СЉСЏРІР»РµРЅРёРµ РґРѕР»Р¶РЅРѕ Р±С‹С‚СЊ Р·Р° РїСЂРµРґРµР»Р°РјРё С†РёРєР»Р°
	local n = 1  			-- РёРЅРёС†РёР°Р»РёР·РёСЂСѓРµРј СЃС‡С‘С‚С‡РёРє СЌР»РµРјРµРЅС‚РѕРІ С‚Р°Р±Р»РёС†С‹
	io.input(getScriptPath().."\\"..PORTFOLIO_FILE) 
	while true do
		local line = io.read("*line") -- С‡РёС‚Р°РµРј С†РµР»СѓСЋ СЃС‚СЂРѕРєСѓ
		if line == nil then break end -- РµСЃР»Рё РЅРёС‡РµРіРѕ РЅРµ РїСЂРѕС‡РёС‚Р°Р»РѕСЃСЊ - РєРѕРЅРµС† С†РёРєР»Р°
			arr = mysplit(line, ';')
			a[n] = { arr }
			
			
			--log.trace('line: '..line);
			--log.trace('a['..n..'][1]:'..arr[1]..' '..'a['..n..'][2]:'..arr[2]..' '..'a['..n..'][3]:'..arr[3]..' ');
			act_list[n] = {}
			act_list[n][1] = arr[1];	-- РќР°Р·РІР°РЅРёРµ
			act_list[n][2] = arr[2];	-- Р›РѕС‚
			act_list[n][3] = arr[3];	-- Р¦РµРЅР°
			if (act_list[n][1] ~= 'rur') then
				act_list[n][4] = arr[4];	-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїСЂРѕРґР°Р¶Рё
				act_list[n][5] = arr[5];	-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїРѕРєСѓРїРєРё
			end	
			--[[log.trace('act_list['..n..'][1]:'..act_list[n][1]..' '
					..'act_list['..n..'][2]:'..act_list[n][2]..' '
					..'act_list['..n..'][3]:'..act_list[n][3]..' ');]]
					
			
			
			n = n + 1;
		--x,y = string.match(line,"([01]+) (%a)") -- РґРІРѕРёС‡РЅС‹Рµ С†РёС„СЂС‹ - РїРѕРјРµС‰Р°РµРј РІ x, Р±СѓРєРІСѓ - РІ y
		--a[x]=y -- РґРѕР±Р°РІР»СЏРµРј СЌС‚Сѓ РїР°СЂСѓ РІ Р°СЃСЃРѕС†РёР°С‚РёРІРЅС‹Р№ РјР°СЃСЃРёРІ
	end
	io.input():close()
	
	log.trace('length act_list: '..#act_list)			-- remove
	
	-- РќР°РґРѕ РїРµСЂРµР±СЂР°С‚СЊ СЌР»РµРјРµРЅС‚С‹ РјР°СЃСЃРёРІР° Рё РїРѕР»СѓС‡РёС‚СЊ РґР»СЏ РЅРёС… С†РµРЅС‹
	for i = 1, #act_list do
		log.trace('--: '..act_list[i][1]);
		if (act_list[i][1] ~= 'rur') then
			ticker = act_list[i][1];
			price = myqlua.getPrice(ticker);		-- !!! Р—Р°РјРµРЅРёС‚СЊ РѕР±СЂР°С‚РЅРѕ, РєРѕРіРґР° Р·Р°СЂР°Р±РѕС‚Р°РµС‚ СЃРµСЂРІРµСЂ
			--price = myqlua.getPriceTest(ticker);
			
			act_list[i][6] = price;
			--log.trace(ticker..'('..act_list[i][3]..') - '..price );
			
			cnt_share = math.floor(tonumber(act_list[i][2]));		-- РљРѕР»-РІРѕ РЅР° Р±Р°Р»Р°РЅСЃРµ
			avg_price = tonumber(act_list[i][3]);		-- РЎСЂРµРґРЅСЏСЏ С†РµРЅР° Р»РѕС‚Р°
			sell_level = act_list[i][4];	-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїСЂРѕРґР°Р¶Рё
			buy_level = act_list[i][5];		-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїРѕРєСѓРїРєРё
			log.trace("ticker"..ticker
						.."cnt_share: "..cnt_share
						.."price: "..price
						.."avg_price: "..avg_price
						.."sell_level: "..sell_level
						.."buy_level: "..buy_level
					);--[[]]
			
			
			-- Р•СЃР»Рё РµСЃС‚СЊ С‡С‚Рѕ РїСЂРѕРґР°РІР°С‚СЊ, С‚Рѕ СЃСЂР°РІРЅРёРІР°РµС‚СЃСЏ СЃРѕ СЃСЂРµРґРЅРµР№ С†РµРЅРѕР№ РІ РїРѕСЂС‚С„РµР»Рµ
			if cnt_share > 0 then
				if avg_price > 0 then 
					-- РћРїСЂРµРґРµР»РёС‚СЊ СѓСЃР»РѕРІРёСЏ РїСЂРё РєРѕС‚РѕСЂС‹С… Р±СѓРґРµС‚ СЃРѕРІРµСЂС€РµРЅР° РїСЂРѕРґР°Р¶Р°
					log.trace("avg_price: "..avg_price.." sell_level: "..sell_level.." PRICE_STEP: "..PRICE_STEP);
					sell_price = avg_price + avg_price * (sell_level + 1) * PRICE_STEP;	-- Р¦РµРЅР° РїСЂРѕРґР°Р¶Рё	
					--log.trace("sell_price: "..sell_price);
					act_list[i][8] = sell_price;	
					
					-- РћРїСЂРµРґРµР»РёС‚СЊ СѓСЃР»РѕРІРёСЏ РїСЂРё РєРѕС‚РѕСЂС‹С… Р±СѓРґРµС‚ СЃРѕРІРµСЂС€РµРЅР° РїРѕРєСѓРїРєР°
					buy_price = avg_price - avg_price * (buy_level + 1) * PRICE_STEP;		-- Р¦РµРЅР° РїРѕРєСѓРїРєРё
					
					--log.trace("buy_price: "..buy_price);
					act_list[i][7] = buy_price;	
				else
					log.trace("ERROR. avg_price = 0");
					
					-- Р¦РµРЅСѓ РїСЂРѕРґР°Р¶Рё СЃС‚Р°РІР»СЋ Р·Р°РіСЂР°РґРёС‚РµР»СЊРЅСѓСЋ
					sell_price = price * 2;
				end;
			else
				-- РІРѕР·РјРѕР¶РЅР° С‚РѕР»СЊРєРѕ РїРѕРєСѓРїРєР°
				-- РћРїСЂРµРґРµР»РёС‚СЊ СѓСЃР»РѕРІРёСЏ РїСЂРё РєРѕС‚РѕСЂС‹С… Р±СѓРґРµС‚ СЃРѕРІРµСЂС€РµРЅР° РїРѕРєСѓРїРєР°
				--buy_price = myqlua.getSMA_7d(ticker) -- Р¦РµРЅР° РїРѕРєСѓРїРєРё
				buy_price = myqlua.getSMA(ticker, INTERVAL_D1, 7)   -- Р¦РµРЅР° РїРѕРєСѓРїРєРё
				--log.trace("buy_price: "..buy_price);
				act_list[i][7] = buy_price;	
				--log.trace("buy_price act_list[i][7]: "..act_list[i][7]);
				
				-- Р¦РµРЅСѓ РїСЂРѕРґР°Р¶Рё СЃС‚Р°РІР»СЋ Р·Р°РіСЂР°РґРёС‚РµР»СЊРЅСѓСЋ
				sell_price = price * 2;
			end
			
			log.trace("--ticker: "..ticker
						.."; cnt_share: "..myqlua.ifnull(cnt_share, "-")
						.."; price: "..myqlua.ifnull(price, "-")
						--.."; avg_price: "..avg_price
						--.."; sell_level: "..sell_level
						.."; sell_price: "..myqlua.ifnull(sell_price, "-")
						--.."; buy_level: "..buy_level
						.."; buy_price: "..myqlua.ifnull(buy_price, "-")
					);
			
			-- Р•СЃР»Рё С‚РµРєСѓС‰Р°СЏ С†РµРЅР° РІС‹С€Рµ С‡РµРј С†РµРЅР° РїСЂРѕРґР°Р¶Рё, С‚Рѕ РїСЂРѕРґР°СЋ
			if myqlua.ifnull(sell_price, 0) > 0 and price > sell_price then 
				sell_tickerUWGN (ticker) 
			end	
			 
			-- Р•СЃР»Рё С‚РµРєСѓС‰Р°СЏ С†РµРЅР° РЅРёР¶Рµ, С‡РµРј С†РµРЅР° РїРѕРєСѓРїРєРё, С‚Рѕ РїРѕРєСѓРїР°СЋ
			if myqlua.ifnull(buy_price, 0) > 0 and price < buy_price then 
				lotsize = getParamEx(class_code, ticker, "LOTSIZE").param_value;
				if amount_rur > (buy_price * lotsize) then
					buy_tickerUWGN (ticker) 
				else
					log.trace("РќРµС‚ РґРµРЅРµРі РЅР° РїРѕРєСѓРїРєСѓ "..ticker)
				end
			end
		else
			amount_rur = tonumber(act_list[i][2])
		end
		
		log.trace('act_list: '..i..' - '..tostring(act_list[i]));			-- remove
	end
	
	
	log.trace('qlua_sma_bot end')
	
	return 0
end;

-- Р¤СѓРЅРєС†РёСЏ РїСЂРѕРґР°Р¶Рё РёРЅСЃС‚СЂСѓРјРµРЅС‚Р°
function buy_tickerUWGN (ticker)
	-- РџРѕСЃС‚Р°РІРёС‚СЊ Р·Р°СЏРІРєСѓ РЅР° РїРѕРєСѓРїРєСѓ
	log.trace('BUYING '..ticker);
	-- РќР°Р№С‚Рё СЃС‚СЂРѕРєСѓ СЃ СЌС‚РёРј РёРЅСЃС‚СЂСѓРјРµРЅС‚РѕРј 
	qlua_sma_botUWGN.settings()							-- remove
	log.trace('length act_list: '..#act_list)			-- remove
	for i = 1, #act_list do
		log.trace('buying_iter '..i);			-- remove
		if act_list[i][1] == ticker then
			cnt_share = act_list[i][2];		-- РљРѕР»-РІРѕ РЅР° Р±Р°Р»Р°РЅСЃРµ
			avg_price = tonumber(act_list[i][3]);		-- РЎСЂРµРґРЅСЏСЏ С†РµРЅР° Р»РѕС‚Р°
			sell_level = act_list[i][4];	-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїСЂРѕРґР°Р¶Рё
			buy_level = act_list[i][5];	-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїРѕРєСѓРїРєРё
			sell_price = act_list[i][8];	
			buy_price = act_list[i][7];		
			
			
			-- РћРїСЂРµРґРµР»РёС‚СЊ РєРѕР»РёС‡РµСЃС‚РІРѕ Р»РѕС‚РѕРІ РЅР° РїРѕРєСѓРїРєСѓ 
			cnt_share_to_buy = math.floor(2 ^ buy_level);
			
			-- РљРѕСЃС‚С‹Р»СЊ, С‡С‚РѕР±С‹ РїРѕРїР°СЃС‚СЊ РІ С€Р°Рі С†РµРЅС‹
			--buy_price = getParamEx("TQBR", ticker, "pricemax").param_value;
			buy_price = myqlua.getPrice(ticker)
			log.trace('buy_price: '..buy_price.." cnt_share_to_buy:"..cnt_share_to_buy.." "..type(cnt_share_to_buy));
			
			-- РџРѕСЃС‚Р°РІРёС‚СЊ Р·Р°СЏРІРєСѓ РЅР° РїСЂРѕРґР°Р¶Сѓ
			log.trace('cnt_share_to_buy: '..cnt_share_to_buy..' for price'..buy_price);
			myqlua.buy(ticker, buy_price, cnt_share_to_buy)									-- !!!
			
			-- РћР±РЅРѕРІРёС‚СЊ РѕСЃС‚Р°С‚РєРё РІ РїРѕСЂС‚С„РµР»Рµ
			act_list[i][2] = act_list[i][2] + cnt_share_to_buy;
			
			-- РћР±РЅРѕРІРёС‚СЊ СЃС‡РµС‚С‡РёРє СѓСЂРѕРІРЅРµР№
			act_list[i][4] = 0					-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїСЂРѕРґР°Р¶Рё
			act_list[i][5] = buy_level + 1;		-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїРѕРєСѓРїРєРё
			
			
			--log.trace('sell_price: '..sell_price..' lotsize..'..lotsize);
			
			-- РЈРјРµРЅСЊС€РёС‚СЊ СЃС‡РµС‚ СЂСѓР±Р»РµР№ РЅР° С†РµРЅСѓ РїРѕРєСѓРїРєРё
			lotsize = getParamEx(class_code, ticker, "LOTSIZE").param_value;
			add_rublesUWGN(-buy_price * lotsize)
			
			-- РЎСЂРµРґРЅСЏСЏ С†РµРЅР° РґРѕР»Р¶РЅР° СЃРЅРёР·РёС‚СЊСЃСЏ
			if avg_price == 0 then
				act_list[i][3] = buy_price;
			else
				act_list[i][3] = avg_price * (1 - PRICE_STEP / 2);
			end;
			
		end; 
	end;
	save_portfolioUWGN();
end


-- Р¤СѓРЅРєС†РёСЏ РїРѕРєСѓРїРєРё РёРЅСЃС‚СЂСѓРјРµРЅС‚Р°
-- Р”РѕР±Р°РІРёС‚СЊ РїСЂРѕРІРµСЂРєСѓ РЅР° РЅР°Р»РёС‡РёРµ РґРѕСЃС‚Р°С‚РѕС‡РЅРѕРіРѕ РєРѕР»РёС‡РµСЃС‚РІР° РґРµРЅРµРі
function sell_tickerUWGN (ticker)

	log.trace('CELLING '..ticker);
	-- РќР°Р№С‚Рё СЃС‚СЂРѕРєСѓ СЃ СЌС‚РёРј РёРЅСЃС‚СЂСѓРјРµРЅС‚РѕРј 
	for i = 1, #act_list do
		if act_list[i][1] == ticker then
			cnt_share = act_list[i][2];		-- РљРѕР»-РІРѕ РЅР° Р±Р°Р»Р°РЅСЃРµ
			avg_price = act_list[i][3];		-- РЎСЂРµРґРЅСЏСЏ С†РµРЅР° Р»РѕС‚Р°
			sell_level = act_list[i][4];	-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїСЂРѕРґР°Р¶Рё
			buy_level = act_list[i][5];		-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїРѕРєСѓРїРєРё
			-- sell_price = act_list[i][8];	-- 
			sell_price = myqlua.getPrice(ticker);	-- Р¦РµРЅСѓ РїСЂРѕРґР°Р¶Рё СЃС‚Р°РІР»СЋ С‚РµРєСѓС‰СѓСЋ
			buy_price = act_list[i][7];		-- 
			
			--log.trace('cnt_share: '..cnt_share);
			
			
			-- РћРїСЂРµРґРµР»РёС‚СЊ РєРѕР»РёС‡РµСЃС‚РІРѕ Р»РѕС‚РѕРІ РЅР° РїСЂРѕРґР°Р¶Сѓ 
			if cnt_share == '1' then
				cnt_share_to_cell = 1;
				-- РћР±РЅСѓР»СЏСЋ СЃСЂРµРґРЅСЋСЋ С†РµРЅСѓ Р»РѕС‚Р°
				act_list[i][3] = 0
			else 
				cnt_share_to_cell = math.floor(cnt_share / 2);
			end
			
			
			-- РљРѕСЃС‚С‹Р»СЊ, С‡С‚РѕР±С‹ РїРѕРїР°СЃС‚СЊ РІ С€Р°Рі С†РµРЅС‹
			--sell_price = getParamEx("TQBR", ticker, "pricemin").param_value
			sec_price_step = getParamEx(class_code, ticker, "SEC_PRICE_STEP").param_value
			log.trace('sec_price_step: '..sec_price_step);
			log.trace('sell_price: '..sell_price);
			ostatok = sell_price % sec_price_step
			log.trace('ostatok: '..tostring(ostatok));
			sell_price = sell_price - ostatok
			log.trace('sell_price: '..sell_price);
			
			-- РџРѕСЃС‚Р°РІРёС‚СЊ Р·Р°СЏРІРєСѓ РЅР° РїСЂРѕРґР°Р¶Сѓ
			log.trace('cnt_share_to_cell: '..cnt_share_to_cell..' with price '..tostring(sell_price));
			myqlua.sell(ticker, sell_price, cnt_share_to_cell)								-- !!!
			
			-- РЈРІРµР»РёС‡РёС‚СЊ СЃС‡РµС‚ СЂСѓР±Р»РµР№ РЅР° С†РµРЅСѓ РїСЂРѕРґР°Р¶Рё
			lotsize = getParamEx(class_code, ticker, "LOTSIZE").param_value;
			add_rublesUWGN(sell_price * lotsize)
			
			-- РћР±РЅРѕРІРёС‚СЊ РѕСЃС‚Р°С‚РєРё РІ РїРѕСЂС‚С„РµР»Рµ
			act_list[i][2] = act_list[i][2] - cnt_share_to_cell;
			
			-- РћР±РЅРѕРІРёС‚СЊ СЃС‡РµС‚С‡РёРє СѓСЂРѕРІРЅРµР№
			act_list[i][4] = sell_level		-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїСЂРѕРґР°Р¶Рё
			act_list[i][5] = 0;				-- РќРѕРјРµСЂ СѓСЂРѕРІРЅСЏ РїРѕРєСѓРїРєРё
			
		end; 
	end;
	
	save_portfolioUWGN();
end

-- Р¤СѓРЅРєС†РёСЏ РґРѕР±Р°РІР»СЏРµС‚ СЃСѓРјРјСѓ СЂСѓР±Р»РµР№ amnt РЅР° СЃС‡РµС‚
function add_rublesUWGN(amnt)

	prev_amnt = amount_rur
	amount_rur = prev_amnt + amnt
	
	log.trace("add_rubles: "..prev_amnt.." + "..amnt.." = "..amount_rur)

end

-- Р¤СѓРЅРєС†РёСЏ РґРѕР»Р¶РЅР° СЃРѕС…СЂР°РЅРёС‚СЊ РїРѕСЂС‚С„РµР»СЊ РёР· СЃРїРёСЃРєР° act_list
function save_portfolioUWGN(amnt)
	log.trace("save_portfolio")

-- РџС‹С‚Р°РµС‚СЃСЏ РѕС‚РєСЂС‹С‚СЊ С„Р°Р№Р» РІ СЂРµР¶РёРјРµ "С‡С‚РµРЅРёСЏ/Р·Р°РїРёСЃРё"
    f = io.open(getScriptPath().."\\"..PORTFOLIO_FILE, "w");
	
	f:write('rur;'..amount_rur..';1'..'\n');
    for i = 1, #act_list do
		line = nil
		if (act_list[i][1] ~= 'rur') then
			line = myqlua.ifnull(act_list[i][1], 0)
				..';'..math.floor(myqlua.ifnull(act_list[i][2], 0))
				..';'..myqlua.ifnull(act_list[i][3], 0)
				..';'..math.floor(myqlua.ifnull(act_list[i][4], 0))
				..';'..math.floor(myqlua.ifnull(act_list[i][5], 0))
				..';'..myqlua.ifnull(act_list[i][6], 0)
				..';'..myqlua.ifnull(act_list[i][7], 0)
				..';'..myqlua.ifnull(act_list[i][8], 0)
		end
		
		if not myqlua.isnil(line) then
			log.trace("line: "..i..' '..line)
			f:write(line..'\n');
		end 
	end;
	f:close();
 end
   
   
   
   
-- Р¤СѓРЅРєС†РёСЏ РІРѕР·РІСЂР°С‰Р°РµС‚ РјР°СЃСЃРёРІ СЃС‚СЂРѕРє. СЂР°Р·РґРµР»СЏРµС‚ РІС…РѕРґСЏС‰СѓСЋ СЃС‚СЂРѕРєСѓ inputstr СЂР°Р·РґРµР»РёС‚РµР»СЏРјРё sep
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

return qlua_sma_botUWGN;