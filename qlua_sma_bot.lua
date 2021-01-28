-- qlua_sma_bot.lua

--[[
qlua_sma_bot

1. �������� ������� ��������� �����������
2. ���� � �������� ��� ��� ������
    2.1 ���� ��������� ���� ���������� ������� �� 30 ���� * 0,9 , �� ������
3. ���� ������ � �������� ����
    3.1 ���� ������� ��������� ���� ��� ���� � �������� �� 10% � ������ ����� 30 ���� � ���������� ������� (+10%) 
        3.1.1 ������� 50% + 1 <���-�� ����� � ��������>. 
        3.1.2 �������� ���� �������
    3.2 ���� � �������� ��� ���� ����� � ���� ���� ��� <���� � ��������>
        �� ��� �������� ���� ���� ��� <���� � ��������> - 0.1 * <���-�� ����� � ��������> * <���� � ��������> ������ <���-�� ����� � ��������> ����� �� ���. ����
		
		
*��������� �����*
1. �����
2. ���-�� �� �������
3. ������� ���� ����
4. ����� ������ �������
5. ����� ������ �������
6. ������� ����
7. ���� �������
8. ���� �������
]]


-- ���� ����������� ������ �������
IsRun = true;

log = require "log"
myqlua = require "myqlua"
PRICE_STEP = 0.1
local act_list = {} 	-- ������� � �������������
local order_list = {}	-- ������ ������
amount_rur = 0			-- ���-�� �����

function main()
	
	log.trace('-- -- -- -- -- qlua_sma_bot begin')

	-- �������� ������� ���� � ������ "������/������"
	f = io.open(getScriptPath().."\\port.prt", "r+");
	-- ���� ���� �� ����������
	if f == nil then 
		log.trace('creating file')
		-- ������� ���� � ������ "������"
		f = io.open(getScriptPath().."\\port.prt", "w"); 
		-- ��������� ����
		f:close();
		-- ��������� ��� ������������ ���� � ������ "������"
		f = io.open(getScriptPath().."\\port.prt", "r");
	end;
   
	-- ���������� � ���� 2 ������
	--f:write("Line1\nLine2"); -- "\n" ������� ����� ������
	-- ��������� ��������� � �����
	--f:flush();
	-- ������ � ������ ����� 
	  -- 1-�� ���������� �������� ������������ ���� ����� ��������: "set" - ������, "cur" - ������� �������, "end" - ����� �����
	  -- 2-�� ���������� �������� ��������
   
	log.trace('������� ������ � ������')
	local a = {} 			-- ���������� ������ ���� �� ��������� �����
	local n = 1  			-- �������������� ������� ��������� �������
	io.input(getScriptPath().."\\port.prt") 
	while true do
		local line = io.read("*line") -- ������ ����� ������
		if line == nil then break end -- ���� ������ �� ����������� - ����� �����
			arr = mysplit(line, ';')
			a[n] = { arr }
			
			
			log.trace('line: '..line);
			log.trace('a['..n..'][1]:'..arr[1]..' '..'a['..n..'][2]:'..arr[2]..' '..'a['..n..'][3]:'..arr[3]..' ');
			act_list[n] = {}
			act_list[n][1] = arr[1];	-- ��������
			act_list[n][2] = arr[2];	-- ���
			act_list[n][3] = arr[3];	-- ����
			if (act_list[n][1] ~= 'rur') then
				act_list[n][4] = arr[4];	-- ����� ������ �������
				act_list[n][5] = arr[5];	-- ����� ������ �������
			end	
			log.trace('act_list['..n..'][1]:'..act_list[n][1]..' '
					..'act_list['..n..'][2]:'..act_list[n][2]..' '
					..'act_list['..n..'][3]:'..act_list[n][3]..' ');
					
			
			
			n = n + 1;
		--x,y = string.match(line,"([01]+) (%a)") -- �������� ����� - �������� � x, ����� - � y
		--a[x]=y -- ��������� ��� ���� � ������������� ������
	end
	io.input():close()
	
	log.trace('length act_list: '..#act_list)
	
	-- ���� ��������� �������� ������� � �������� ��� ��� ����
	for i = 1, #act_list do
		log.trace('--: '..act_list[i][1]);
		if (act_list[i][1] ~= 'rur') then
			ticker = act_list[i][1];
			price = myqlua.getPrice(ticker);		-- !!! �������� �������, ����� ���������� ������
			--price = myqlua.getPriceTest(ticker);
			
			act_list[i][6] = price;
			log.trace(ticker..'('..act_list[i][3]..') - '..price );
			
			cnt_share = tonumber(act_list[i][2]);		-- ���-�� �� �������
			avg_price = act_list[i][3];		-- ������� ���� ����
			cell_level = act_list[i][4];	-- ����� ������ �������
			buy_level = act_list[i][5];		-- ����� ������ �������
			log.trace("cnt_share: "..cnt_share);
			log.trace("avg_price: "..avg_price);
			log.trace("cell_level: "..cell_level);
			log.trace("buy_level: "..buy_level);
			
			-- ���� ���� ��� ���������, �� ������������ �� ������� ����� � ��������
			if cnt_share > 0 then
				-- ���������� ������� ��� ������� ����� ��������� �������
				log.trace("avg_price: "..avg_price.." cell_level: "..cell_level.." PRICE_STEP: "..PRICE_STEP);
				cell_price = avg_price + avg_price * (cell_level + 1) * PRICE_STEP;	-- ���� �������	
				log.trace("cell_price: "..cell_price);
				act_list[i][8] = cell_price;	
				
				-- ���������� ������� ��� ������� ����� ��������� �������
				buy_price = avg_price - avg_price * (buy_level + 1) * PRICE_STEP;		-- ���� �������
				log.trace("buy_price: "..buy_price);
				act_list[i][7] = buy_price;	
			else
				-- �������� ������ �������
				-- ���������� ������� ��� ������� ����� ��������� �������
				buy_price = myqlua.getSMA_7d(ticker) * (1 - PRICE_STEP)  -- ���� �������
				log.trace("buy_price: "..buy_price);
				act_list[i][7] = buy_price;	
				
				-- ���� ������� ������ ��������������
				cell_price = price * 2;
			end
			
						
			-- ���� ������� ���� ���� ��� ���� �������, �� ������
			if  price > cell_price then cell_ticker (ticker) end
			
			 
			-- ���� ������� ���� ����, ��� ���� �������, �� �������
			if price < buy_price then buy_ticker (ticker) end
		else
			amount_rur = act_list[i][2]
		end
		
		-- log.trace('act_list: '..i..' - '..tostring(act_list[i]));
	end
	
	
	
	
	log.trace('test6 end')
end;

-- ������� ������� �����������
function buy_ticker (ticker)
	-- ��������� ������ �� �������
	log.trace('BUYING '..ticker);
	-- ����� ������ � ���� ������������ 
	for i = 1, #act_list do
		if act_list[i][1] == ticker then
			cnt_share = act_list[i][2];		-- ���-�� �� �������
			avg_price = act_list[i][3];		-- ������� ���� ����
			cell_level = act_list[i][4];	-- ����� ������ �������
			buy_level = act_list[i][5] + 1;	-- ����� ������ �������
			cell_price = act_list[i][8];	
			buy_price = act_list[i][7];		
			
			
			-- ���������� ���������� ����� �� ������� 
			cnt_share_to_buy = 2 ^ buy_level;
			
			-- �������, ����� ������� � ��� ����
			buy_price = getParamEx("TQBR", ticker, "pricemax").param_value
			
			-- ��������� ������ �� �������
			log.trace('cnt_share_to_buy: '..cnt_share_to_buy..' for price..'..buy_price);
			--myqlua.buy(ticker, buy_price, cnt_share_to_buy)
			
			-- �������� ������� � ��������
			act_list[i][2] = act_list[i][2] + cnt_share_to_buy;
			
			-- �������� ������� �������
			act_list[i][4] = 0					-- ����� ������ �������
			act_list[i][5] = buy_level;			-- ����� ������ �������
			
			-- ��������� ���� ������ �� ���� �������
			lotsize = getParamEx(class_code, ticker, "LOTSIZE").param_value;
			add_rubles(-cell_price * lotsize)
			
		end; 
	end;
	save_portfolio();
end


-- ������� ������� �����������
-- �������� �������� �� ������� ������������ ���������� �����
function cell_ticker (ticker)

	log.trace('CELLING '..ticker);
	-- ����� ������ � ���� ������������ 
	for i = 1, #act_list do
		if act_list[i][1] == ticker then
			cnt_share = act_list[i][2];		-- ���-�� �� �������
			avg_price = act_list[i][3];		-- ������� ���� ����
			cell_level = act_list[i][4];	-- ����� ������ �������
			buy_level = act_list[i][5];		-- ����� ������ �������
			cell_price = act_list[i][8];	-- 
			buy_price = act_list[i][7];		-- 
			
			--log.trace('cnt_share: '..cnt_share);
			
			
			-- ���������� ���������� ����� �� ������� 
			if cnt_share == '1' then
				cnt_share_to_cell = 1;
			else 
				cnt_share_to_cell = math.floor(cnt_share / 2);
			end
			
			
			-- �������, ����� ������� � ��� ����
			--cell_price = getParamEx("TQBR", ticker, "pricemin").param_value
			sec_price_step = getParamEx(class_code, ticker, "SEC_PRICE_STEP").param_value
			log.trace('sec_price_step: '..sec_price_step);
			ostatok = cell_price % sec_price_step
			log.trace('ostatok: '..tostring(ostatok));
			cell_price = cell_price - ostatok
			log.trace('cell_price: '..cell_price);
			
			-- ��������� ������ �� �������
			log.trace('cnt_share_to_cell: '..cnt_share_to_cell..' with price '..tostring(cell_price));
			---myqlua.sell(ticker, cell_price, cnt_share_to_cell)
			
			-- ��������� ���� ������ �� ���� �������
			lotsize = getParamEx(class_code, ticker, "LOTSIZE").param_value;
			add_rubles(cell_price * lotsize)
			
			-- �������� ������� � ��������
			act_list[i][2] = act_list[i][2] - cnt_share_to_cell;
			
			-- �������� ������� �������
			act_list[i][4] = cell_level		-- ����� ������ �������
			act_list[i][5] = 0;				-- ����� ������ �������
			
		end; 
	end;
	
	save_portfolio();
end

-- ������� ��������� ����� ������ amnt �� ����
function add_rubles(amnt)

	prev_amnt = amount_rur
	amount_rur = prev_amnt + amnt
	
	log.trace("add_rubles: "..prev_amnt.." + "..amnt.." = "..amount_rur)

end

-- ������� ������ ��������� �������� �� ������ act_list
function save_portfolio(amnt)


-- �������� ������� ���� � ������ "������/������"
    f = io.open(getScriptPath().."\\port2.prt", "w");
	
	f:write('rur;'..amount_rur..';1'..'\n');
    for i = 1, #act_list do
		if (act_list[i][1] ~= 'rur') then
			line = myqlua.ifnull(act_list[i][1], '')
				..';'..myqlua.ifnull(act_list[i][2], '')
				..';'..myqlua.ifnull(act_list[i][3], '')
				..';'..myqlua.ifnull(act_list[i][4], '')
				..';'..myqlua.ifnull(act_list[i][5], '')
				..';'..myqlua.ifnull(act_list[i][6], '')
				..';'..myqlua.ifnull(act_list[i][7], '')
				..';'..myqlua.ifnull(act_list[i][8], '')
				..'\n'
		end
		
		if not myqlua.isnil(line) then
			log.trace("line: "..i..' '..line)
			f:write(line);
		end 
	end;
	f:close();
 end
   
   
   
   
-- ������� ���������� ������ �����. ��������� �������� ������ inputstr ������������� sep
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