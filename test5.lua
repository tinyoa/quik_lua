log = require "log"
myqlua = require "myqlua"

-- Флаг поддержания работы скрипта
IsRun = true;
 
function main()
	log.trace("trace")
	
	-- Subscribe_Level_II_Quotes(STRING class_code, STRING sec_code)
	
	-- ret = Subscribe_Level_II_Quotes("TQBR", "VTBR")
	--ret = CreateDataSource("TQBR", "VTBR", INTERVAL_D1)

	log.trace("получил цену: "..myqlua.getPrice("VTBR")) 

	
end;
 
function OnStop()
   IsRun = false;
end;