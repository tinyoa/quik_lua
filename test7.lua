
log = require "log"



function main()
	log.trace("test7.lua begin")
	
	--ticker = "VTBR"
	ticker = "UWGN";
	
	log.trace('os.date()'..os.date())
	log.trace('os.date()'..os.date("%y-%m-%d"))
	-- os.date("%d")
	
	-- РЎРѕР·РґР°РµРј С‚Р°Р±Р»РёС†Сѓ СЃРѕ РІСЃРµРјРё СЃРІРµС‡Р°РјРё РЅСѓР¶РЅРѕРіРѕ РёРЅС‚РµСЂРІР°Р»Р°, РєР»Р°СЃСЃР° Рё РєРѕРґР°
	ds, error_desc = CreateDataSource("TQBR", ticker, INTERVAL_H1)

	local try_count = 0
	-- Р–РґРµРј РїРѕРєР° РЅРµ РїРѕР»СѓС‡РёРј РґР°РЅРЅС‹Рµ РѕС‚ СЃРµСЂРІРµСЂР°,
	--	Р»РёР±Рѕ РїРѕРєР° РЅРµ Р·Р°РєРѕРЅС‡РёС‚СЃСЏ РІСЂРµРјСЏ РѕР¶РёРґР°РЅРёСЏ (РєРѕР»РёС‡РµСЃС‚РІРѕ РїРѕРїС‹С‚РѕРє)
	while ds:Size() == 0 and try_count < 1000 do
		sleep(100)
		try_count = try_count + 1
	end
	-- Р•СЃР»Рё РѕС‚ СЃРµСЂРІРµСЂР° РїСЂРёС€Р»Р° РѕС€РёР±РєР°, С‚Рѕ РІС‹РІРµРґРµРј РµРµ Рё РїСЂРµСЂРІРµРј РІС‹РїРѕР»РЅРµРЅРёРµ
	if error_desc ~= nil and error_desc ~= "" then
		message("РћС€РёР±РєР° РїРѕР»СѓС‡РµРЅРёСЏ С‚Р°Р±Р»РёС†С‹ СЃРІРµС‡РµР№:" .. error_desc)
		return 0
	end
	
	log.trace("ds:size()"..ds:Size())
	
	for i = 1, ds:Size() do 
		log.trace("ds:T: "
				..ds:T(i).year..'-'..ds:T(i).month..'-'..ds:T(i).day..' '
				..ds:T(i).hour..':'..ds:T(i).min..':'..ds:T(i).sec..'.'..ds:T(i).ms..' '
				..'close(i)'..tostring(ds:C(i))
				)
		--log.trace("myqlua.getPrice: "..tostring(ds:C(ds:Size())))
	end 
	
	
	log.trace("test7.lua end") 

	
end;