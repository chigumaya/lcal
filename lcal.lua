#!/usr/local/bin/lua
-- 祝日対応カレンダー

-- 初期設定を変更するときは、スクリプトはいじらず ~/.lcal で上書きするとよさげ
-- 書式は Lua そのもの

-- 休日じゃないけど特別な日
memorial_day = {
    -- サンプル
    -- { name = "飲み会", year = 2010, month = 1, day = 10 }
    -- 詳細な書式は後にある holiday テーブルのコメントを参照
}

-- 曜日ラベル
wday = { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" }
-- wday = { "日", "月", "火", "水", "木", "金", "土" }

-- 色をつけたりつけなかったり
use_color = "auto"
--[[
     auto: てきとーに判別する
 terminfo: terminfo を使う
  termcap: termcap を使う
      raw: 生のエスケープシーケンスを出力する
     none: 色をつけない
]]
day_attr = {
    -- どんなキーワードが使えるかは後の方にある term_attr テーブルを参照
    sunday =	{ "red" },
    saturday =	{ "blue" },
    national_holiday = { "red", "bold" },	-- 祝日
    holiday =	{ "red" },			-- 振替休日など
    memorial =	{ "green", "underline" },
    today =	{ "reverse" },
    reset =	{ "reset" }	-- この行は変更禁止
}
tput = "/usr/bin/tput"

-- ここから下も ~/.lcal で設定できるけど、まあたいてい必要ないかな

-- 春分/秋分
-- http://homepage1.nifty.com/chibipage/pgsyunbun.html
function shunbun(y)
    local f = math.floor
    if y >= 1851 and y < 1899 then
	return f(19.8277 + 0.242194*(y-1980) - f((y-1983)/4))
    elseif y<= 1979 then
	return f(20.8357 + 0.242194*(y-1980) - f((y-1983)/4))
    elseif y<= 2099 then
	return f(20.8431 + 0.242194*(y-1980) - f((y-1980)/4))
    elseif y<= 2150 then
	return f(21.8510 + 0.242194*(y-1980) - f((y-1980)/4))
    end
end
function shuubun(y)
    local f = math.floor
    if y >= 1851 and y < 1899 then
	return f(22.2588 + 0.242194*(y-1980) - f((y-1983)/4))
    elseif y<= 1979 then
	return f(23.2588 + 0.242194*(y-1980) - f((y-1983)/4))
    elseif y<= 2099 then
	return f(23.2488 + 0.242194*(y-1980) - f((y-1980)/4))
    elseif y<= 2150 then
	return f(24.2488 + 0.242194*(y-1980) - f((y-1980)/4))
    end
end

--[[
祝日テーブル
 { name = "名前", month = 月, day = 日, first = 年1, last = 年2 }

name:  その祝日の名前
day:
  数値   -> そのまま
  {m, n} -> ハッピーマンデー ex:第2月曜 {2,1} 
  関数   -> 年を引数にして日を返す関数
month: 必須
  数値   -> そのまま
  関数   -> 年を引数にして月,日を返す関数
year:  その祝日が適用される年(その年だけ)
first: その祝日が適用される最初の年
last:  その祝日が適用される最後の年
]]
holiday = {
    -- 現在の祝日: 1948/7/20 から
    { name = "元旦",		month = 1, day = 1, first = 1949 },
    { name = "成人の日",	month = 1, day = 15, first = 1949, last = 1999 },
    { name = "成人の日",	month = 1, day = {2 ,1} , first = 2000 },
    { name = "建国記念の日",	month = 2, day = 11, first = 1966 },
    { name = "春分の日",	month = 3, day = shunbun, first = 1949 },
    { name = "天皇誕生日",	month = 4, day = 29, first = 1949, last = 1988 },
    { name = "みどりの日",	month = 4, day = 29, first = 1989, last = 2006 },
    { name = "昭和の日",	month = 4, day = 29, first = 2007 },
    { name = "憲法記念日",	month = 5, day = 3, first = 1949 },
    { name = "みどりの日",	month = 5, day = 4, first = 2007 },
    { name = "こどもの日",	month = 5, day = 5, first = 1949 },
    { name = "海の日",		month = 7, day = 20, first = 1996, last = 2002 },
    { name = "海の日",		month = 7, day = {3, 1}, first = 2003 },
    { name = "山の日",		month = 8, day = 11, first = 2016 },
    { name = "敬老の日",	month = 9, day = 15, first = 1966, last = 2002 },
    { name = "敬老の日",	month = 9, day = {3, 1}, first = 2003 },
    { name = "秋分の日",	month = 9, day = shuubun, first = 1948 },
    { name = "体育の日",	month = 10, day = 10, first = 1966, last = 1999 },
    { name = "体育の日",	month = 10, day = {2, 1}, first = 2000 },
    { name = "文化の日",	month = 11, day = 3, first = 1948 },
    { name = "勤労感謝の日",	month = 11, day = 23, first = 1948 },
    { name = "天皇誕生日",	month = 12, day = 23, first = 1989 },
    -- 明治の祝日: 1873/10/14-1948/7/20
    { name = "元始祭",		month = 1, day = 3, first = 1874, last = 1948 },
    { name = "新年宴會",	month = 1, day = 5, first = 1874, last = 1948 },
    { name = "孝明天皇祭",	month = 1, day = 30, first = 1874, last = 1912 },
    { name = "紀元節",		month = 2, day = 11, first = 1874, last = 1948 },
    { name = "春季皇靈祭",	month = 3, day = shunbun, first = 1879, last = 1948 },
    { name = "神武天皇祭",	month = 4, day = 3, first = 1874, last = 1948 },
    { name = "明治天皇祭",	month = 7, day = 30, first = 1913, last = 1947 },
    { name = "神嘗祭",		month = 9, day = 17, first = 1874, last = 1878 },
    { name = "神嘗祭",		month = 10, day = 17, first = 1879, last = 1947 },
    { name = "秋季皇靈祭",	month = 9, day = shuubun, first = 1878, last = 1947 },
    { name = "天長節",		month = 11, day = 3, first = 1873, last = 1912 },
    { name = "天長節",		month = 8, day = 31, first = 1913, last = 1926 },
    { name = "天長節",		month = 4, day = 29, first = 1927, last = 1947 },
    { name = "天長節祝日",	month = 10, day = 31, first = 1913, last = 1947 },
    { name = "明治節",		month = 11, day = 3, first = 1927, last = 1947 },
    { name = "新嘗祭",		month = 11, day = 23, first = 1873, last = 1947 },
    { name = "大正天皇祭",	month = 12, day = 25, first = 1927, last = 1947 },
    -- http://koyomi.vis.ne.jp/syukujitsu.htm#old によると
    -- 1/1 が「四方拝」なる祝日らしいが文献不明なのでとりあえず除外
}

-- 祝日ではない休日 (祝日の谷間の休日などは定義しなくてよい)
holiday2 = {
    { name = "即位ノ禮", year = 1915, month = 11, day = 10 },
    { name = "大嘗祭", year = 1915, month = 11, day = 14 },
    { name = "即位禮及大嘗祭後大饗第一日", year = 1915, month = 11, day = 16 },
    { name = "即位ノ禮", year = 1928, month = 11, day = 10 },
    { name = "大嘗祭", year = 1928, month = 11, day = 14 },
    { name = "即位禮及大嘗祭後大饗第一日", year = 1928, month = 11, day = 16 },
    { name = "皇太子明仁親王の結婚の儀", year = 1959, month = 4, day = 10 },
    { name = "昭和天皇の大喪の礼", year = 1989, month = 2, day = 24 },
    { name = "即位礼正殿の儀", year = 1990, month = 11, day = 12 },
    { name = "皇太子徳仁親王の結婚の儀", year = 1993, month = 6, day = 9 },
}

--[[
-- 複雑な設定の例: イースター
-- http://ja.wikipedia.org/wiki/%E3%82%B3%E3%83%B3%E3%83%97%E3%83%88%E3%82%A5%E3%82%B9
table.insert(memorial_day, { name = "イースター", month = function (y)
    local floor = math.floor
    local a = y%19
    local b = floor(y/100)
    local c = y%100
    local d = floor(b/4)
    local e = b%4
    local f = floor((b+8)/25)
    local g = floor((b-f+1)/3)
    local h = (19*a+b-d-g+15)%30
    local i = floor(c/4)
    local k = c%4
    local l = (32+2*e+2*i-h-k)%7
    local m = floor((a+11*h+22*l)/451)
    local n = h+l-7*m+114
    return floor(n/31), n%31+1
end } )
]]

term_attr = {
    -- 		{ terminfo, termcap, 生シーケンス }
    black =	{ 'setaf 0', 'AF 0', '\27[30m' },
    red =	{ 'setaf 1', 'AF 1', '\27[31m' },
    green =	{ 'setaf 2', 'AF 2', '\27[32m' },
    yellow =	{ 'setaf 3', 'AF 3', '\27[33m' },
    blue =	{ 'setaf 4', 'AF 4', '\27[34m' },
    magenta =	{ 'setaf 5', 'AF 5', '\27[35m' },
    cyan =	{ 'setaf 6', 'AF 6', '\27[36m' },
    white =	{ 'setaf 7', 'AF 7', '\27[37m' },
    bg_black =	{ 'setab 0', 'AB 0', '\27[40m' },
    bg_red =	{ 'setab 1', 'AB 1', '\27[41m' },
    bg_green =	{ 'setab 2', 'AB 2', '\27[42m' },
    bg_yellow =	{ 'setab 3', 'AB 3', '\27[43m' },
    bg_blue =	{ 'setab 4', 'AB 4', '\27[44m' },
    bg_magenta ={ 'setab 5', 'AB 5', '\27[45m' },
    bg_cyan =	{ 'setab 6', 'AB 6', '\27[46m' },
    bg_white =	{ 'setab 7', 'AB 7', '\27[47m' },
    bold =	{ 'bold', 'md', '\27[1m' },
    underline =	{ 'smul', 'us', '\27[4m' },
    reverse =	{ 'rev', 'mr', '\27[7m' },
    reset =	{ 'sgr0', 'me', '\27[m' },
}

-- ~/.lcal: 個人ごとの設定ファイルのパス
userconf = (os.getenv"HOME" or "").."/.lcal"

nmonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

-- カレンダー月表示
function calendar_month(y, m, flag)
    local w, d
    local j, hol

    w = get_wday(y,m,1)
    d = nmonth[m] + (m==2 and is_leap_year(y) and 1 or 0)

    if flag then
	hol = list_holidays(y, m)
	j = 1
    end

    io.write(string.format('      %4d/%2d\n%s\n', y, m, wheader))
    io.write(string.rep(' ', w*3))
    for i=1,d do
	io.write(format_date(i, {y, m, i}))
	if i==d or (w+i)%7 == 0 then
	    if flag and j <= #hol then
		io.write(string.format('%s%2d/%2d %s\n', string.rep(' ', 20-(w+i-1)%7*3),
		    hol[j].month, hol[j].day, hol[j].name))
		j = j + 1
	    else
		io.write'\n'
	    end
	else
	    io.write' '
	end
    end
    if not flag then return end
    for i=j,#hol do
	io.write(string.format('%s%2d/%2d %s\n', string.rep(' ', 22),
	    hol[i].month, hol[i].day, hol[i].name))
    end
end

-- カレンダー3ヶ月表示
function calendar_3months(y, m, flag)
    local year =  { m==1 and y-1 or y,  y, m==12 and y+1 or y }
    local month = { m==1 and 12 or m-1, m, m==12 and 1 or m+1 }
    local p = {}
    local nmonth = nmonth
    nmonth[2] = nmonth[2] + (is_leap_year(y) and 1 or 0)

    io.write(string.format('      %4d/%2d         ', year[1], month[1]))
    io.write(string.format('      %4d/%2d         ', year[2], month[2]))
    io.write(string.format('      %4d/%2d\n', year[3], month[3]))
    io.write(wheader.."  "..wheader.."  "..wheader.."\n")
    p[1] = -get_wday(year[1], month[1], 1)
    p[2] = -get_wday(year[2], month[2], 1)
    p[3] = -get_wday(year[3], month[3], 1)
    for i=1,6 do
	for j,k in ipairs(month) do
	    for l=1,7 do
		p[j] = p[j] + 1
		if p[j] <= 0 or p[j] > nmonth[k] then
		    io.write'  '
		else
		    io.write(format_date(p[j], {year[j], month[j], p[j]}))
		end
		if k==month[3] and l==7 then
		    io.write'\n'
		elseif l==7 then
		    io.write'  '
		else
		    io.write' '
		end
	    end
	end
    end

    if flag then
	local hol
	for i=1,3 do
	    hol = list_holidays(year[i], month[i])
	    for j=1,#hol do
		io.write(string.format('%2d/%2d %s\n',
		    hol[j].month, hol[j].day, hol[j].name))
	    end
	end
    end
end

-- カレンダー年表示
function calendar_year(y)
    calendar_3months(y, 2)
    calendar_3months(y, 5)
    calendar_3months(y, 8)
    calendar_3months(y, 11)
end

-- うるう年判定
function is_leap_year(y)
    return (y%400==0 or (y%4==0 and y%100~=0)) and true or false
end

-- 曜日判定: zeller の公式
-- lua は負数の剰余の問題がないので、変形式ではなく本来の式を使う
function get_wday(y, m, d)
    local f = math.floor
    if m <= 2 then
	y = y-1
	m = m+12
    end
    local k = y%100
    local j = f((y-k)/100)
    return (d + f((m+1)*26/10) + k + f(k/4) + f(j/4) - 2*j + 6)%7
end

-- 休日判定
function is_holiday(y, m, d)
    local r1, r2
    r1, r2 = is_national_holiday(y, m, d)
    if r1 then return r1, r2 end
    r1, r2 = is_national_holiday2(y, m, d)
    if r1 then return r1, r2 end
    r1, r2 = is_substitute_holiday(y, m, d)
    if r1 then return r1, r2 end
    -- if get_wday(y, m, d) == 0 then return true end
    return false
end

-- 休日テーブル検索
function lookup_holiday_table(t, y, m, d)
    local p, q
    for i=1, #t do
	if (t[i].year and t[i].year ~= y ) or
	   (t[i].first and t[i].first > y) or (t[i].last and t[i].last < y) then
	    -- skip
	else
	    if type(t[i].month) == "number" and t[i].month == m then
		if type(t[i].day) == "table" then
		    -- {2,1} を第二月曜と解釈して当月の日付を返す
		    p = (t[i].day[1]-1)*7 + (t[i].day[2]-get_wday(y, m, 1))%7 + 1
		elseif type(t[i].day) == "function" then
		    p = t[i].day(y)
		else
		    p = t[i].day
		end
		if p == d then
		    return true, t[i].name
		end
	    elseif type(t[i].month) == "function" then
		-- 月が関数の場合は m, d のふたつを返す関数であること
		p, q = t[i].month(y)
		if p == m and q == d then
		    return true, t[i].name
		end
	    end
	end
    end
    return false    
end

-- 祝日判定
function is_national_holiday(y, m, d)
    return lookup_holiday_table(holiday, y, m, d)
end

-- 振替休日
-- S48.4.12 祝日法に第三条第二項が追加(即日施行)
-- 「国民の祝日」が日曜日にあたるときは、その翌日を休日とする。
furikae = { first = 1973, month = 4, day = 12, --[[ name = "振替休日" ]] }
-- H17.5.20 改正(H19.1.1施行)
-- 「国民の祝日」が日曜日に当たるときは、その日後において
-- その日に最も近い「国民の祝日」でない日を休日とする。
furikae2 = { first = 2007, month = 1, day = 1, name = furikae.name }
function is_substitute_holiday(y, m, d)
    if is_national_holiday(y, m, d) then
	return false
    end
    if cmp_dates({y, m, d}, {furikae2.first, furikae2.month, furikae2.day}) then
	-- 今の振替休日
	local y2, m2, d2 = y, m, d
	while true do
	    y2, m2, d2 = get_prev_date(y2, m2, d2)
	    if is_national_holiday(y2, m2, d2) then
		if get_wday(y2, m2, d2) == 0 then
		    return true, furikae.name
		end
	    else
		return false
	    end
	end
    elseif cmp_dates({y, m, d}, {furikae.first, furikae.month, furikae.day}) then
	-- ちょっと前の振替休日
	if get_wday(y, m, d) == 1 and
	   is_national_holiday(get_prev_date(y, m, d)) then
	    return true, furikae.name
	else
	    return false
	end
    else
	-- 振替休日のなかった時代
	return false
    end
end

-- 国民の休日
-- S60.12.27 祝日法に第三条第三項が追加(即日施行)
-- 祝日にはさまれた日曜、振替休日でない日
kokumin = { first = 1985, month = 12, day = 27, --[[ name = "国民の休日" ]] }
-- H17.5.20 改正(H19.1.1施行)
-- 祝日にはさまれた祝日でない日
kokumin2 = { first = 2007, month = 1, day = 1, name = kokumin.name}
-- 祝日法の条文に「国民の休日」という文字はないので kokumin というのは
-- おかしいけど、まあ、通称として広まってるからいいよね
function is_national_holiday2(y, m, d)
    -- まずはテーブル検索
    local r1, r2 = lookup_holiday_table(holiday2, y, m, d)
    if r1 then return r1, r2 end

    -- いちおう厳密に定義に従ってはいるけど、ぶっちゃけ結果は大差ない
    if cmp_dates({y, m, d}, {kokumin2.first, kokumin2.month, kokumin2.day}) then
	if is_national_holiday(get_prev_date(y, m, d)) and
	   is_national_holiday(get_next_date(y, m, d)) and
	   not is_national_holiday(y, m, d) then
	    return true, kokumin.name
	end
    elseif cmp_dates({y, m, d}, {kokumin.first, kokumin.month, kokumin.day}) then
	if is_national_holiday(get_prev_date(y, m, d)) and
	   is_national_holiday(get_next_date(y, m, d)) and
	   get_wday(y, m, d) ~= 0 and
	   not is_substitute_holiday(y, m, d) then
	    return true, kokumin.name
	end
    end
    return false
end

-- 休日リスト
function list_holidays(y, m)
    local r = {}
    local r1, r2

    local nmonth = nmonth
    nmonth[2] = nmonth[2] + (is_leap_year(y) and 1 or 0)

    local a,b=1,12
    if m then a,b = m,m end
    for i=a,b do
	for j=1,nmonth[i] do
	    r1, r2 = is_holiday(y, i, j)
	    if r1 and r2 then
		table.insert(r, { month = i, day = j, name = r2 })
	    end
	    r1, r2 = lookup_holiday_table(memorial_day, y, i, j)
	    if r1 and r2 then
		table.insert(r, { month = i, day = j, name = r2 })
	    end
	end
    end
    return r
end

-- 日付の大小を比較
-- t1 と t2 が同じであれば true, true を返す
-- t1 の方が t2 より後の日付であれば true, false 
-- t1 の方が t2 より前であれば false, false
function cmp_dates(t1, t2)
    if t1[1] > t2[1] then
	return true, false
    elseif t1[1] == t2[1] then
	if t1[2] > t2[2] then
	    return true, false
	elseif t1[2] == t2[2] then
	    if t1[3] > t2[3] then
		return true, false
	    elseif t1[3] == t2[3] then
		return true, true
	    end
	end
    end
    return false, false
end

-- 前後の日付を取得
function get_prev_date(y, m, d)
    local y2, m2, d2 = y, m, d-1
    if d2 == 0 then
	y2 = m==1 and y-1 or y
	m2 = m==1 and 12 or m-1
	d2 = nmonth[m2] + (m2 == 2 and is_leap_year(y2) and 1 or 0)
    end
    return y2, m2, d2
end

function get_next_date(y, m, d)
    local y2, m2, d2 = y, m, d+1
    if d == nmonth[m] + (m==2 and is_leap_year(y) and 1 or 0) then
	y2 = m==12 and y+1 or y
	m2 = m==12 and 1 or m+1
	d2 = 1
    end
    return y2, m2, d2
end

-- terminfo/termcap の初期化
-- lua で curses ライブラリを使えるようにするモジュールもあるみたいだけど
-- まあ、そこまでおおげさにしなくてもいいかな、ってことで tput を叩く
function terminit()
    local r = {}
    local p

    -- stdout が端末でなければエスケープシーケンスを抑制する
    if attr_flag and (posix and not posix.ttyname(1) or os.execute"test -t 1" ~= 0) then
	return {}
    end

    if use_color == "auto" then
	for i=1,2 do
	    local f = io.popen(tput.." "..term_attr.reset[i].." 2>/dev/null")
	    if io.type(f) == "file" then
		local s = f:read()
		f:close()
		if s and s ~= "" then
		    p = i
		    break
		end
	    end
	end
	p = p or 3
    elseif use_color == "terminfo" then
	p = 1
    elseif use_color == "termcap" then
	p = 2
    elseif use_color == "raw" then
	p = 3
    end
    if p == 1 or p == 2 then
	for i,j in pairs(day_attr) do
	    for _, k in ipairs(j) do
		if term_attr[k] and term_attr[k][p] then
		    local f = io.popen(tput.." "..term_attr[k][p].." 2>/dev/null")
		    r[i] = (r[i] or "")..(io.type(f) == "file" and f:read() or term_attr[k][3] or "")
		    f:close()
		else
		    r[i] = ""
		end
	    end
	end
    elseif p == 3 then
	for i,j in pairs(day_attr) do
	    for _, k in ipairs(j) do
		r[i] = term_attr[k] and term_attr[k][3] and (r[i] or "")..(term_attr[k][3] or "") or ""
	    end
	end
    else
	-- r は {} のまま
    end
    return r
end

-- 文字装飾
function format_date(p, q, esc)
    local s 
    esc = esc or escseq or {}
    if type(q) == "string" then
	s = esc[q]=="" and tostring(p) or (esc[q] or "")..tostring(p)..(esc["reset"] or "")
    elseif type(q) == "table" then
	local y, m, d = q[1], q[2], q[3]
	local w = get_wday(y, m, d)
	if w == 6 then
	    s = esc["saturday"]
	elseif w == 0 then
	    s = esc["sunday"]
	end
	if is_national_holiday(y, m, d) then
	    s = esc["national_holiday"]
	elseif is_holiday(y, m, d) then
	    s = esc["holiday"]
	end
	if lookup_holiday_table(memorial_day, y, m, d) then
	    s = (s or "")..(esc["memorial"] or "")
	end
	if y == now.year and m == now.month and d == now.day then
	    s = (s or "")..(esc["today"] or "")
	end
	s = s=="" and string.format("%2d", p) or string.format("%s%2s%s", s or "", tostring(p), esc["reset"] or "")
    end
    return s
end

function usage(m)
    local f
    if m then
	f = io.stderr
	f:write(m)
    else
	f = io.stdout
    end
    f:write("usage: "..arg[0].." [-y3nt] [month [year]]\n")
    f:write("       "..arg[0].." [-y3nt] year month\n")
    f:write("       "..arg[0].." [-t] year\n")
    f:write("       "..arg[0].." -h\n")
    f:write("year: 1873-\n")
    os.exit(m and 1 or 0)
end

-- main

-- posix 拡張ライブラリがあればロードする(なくても気にしない)
-- http://luaforge.net/projects/luaposix/
-- 単にインストールするだけでなく、README にあるとおりに
-- posix.lua の中の SOPATH を手で書き換える必要あり
-- FreeBSD ports の devel/lua-posix はこれをやってないので注意
pcall(require, 'posix')

-- ~/.lcal があればそれを読む
if posix then
    -- 読めなかったらスルー、読めるけど文法的に間違ってたらエラー終了
    if posix.access(userconf, 'r') then
	local r, f, e = pcall(loadfile, userconf)
	if r and f then
	    f()
	else
	    usage(e.."\n")
	end
    end
else
    -- posix ライブラリがないと、ファイルが存在しないのと存在するけど
    -- 文法的に間違ってるのが区別つかないのでエラー終了しないでスルー
    local r, f = pcall(loadfile, userconf)
    if r and f then
	f()
    end
end

now = os.date"*t"
escseq = terminit()

wheader = format_date(wday[1], "sunday")
for i=2,6 do
    wheader = wheader.." "..wday[i]
end
wheader = wheader.." "..format_date(wday[7], "saturday")

display_calendar = calendar_month
holiday_flag = true
attr_flag = false
n = 1
while arg[n] do
    if arg[n]:sub(1,1) == "-" then
	for s in arg[n]:sub(2):gmatch"%w" do
	    if s == 'h' then
		usage()
	    elseif s == '3' then   -- 3ヶ月表示
		display_calendar = calendar_3months
	    elseif s == 'y' then   -- 年表示
		display_calendar = calendar_year
	    elseif s == 'n' then   -- 祝日名などを表示しない
		holiday_flag = not holiday_flag
	    elseif s == 't' then   -- stdout がリダイレクト/パイプでも色をつける
		attr_flag = not attr_flag
	    else
		usage("illegal option: "..s.."\n")
	    end
	end
    else
	break
    end
    n = n + 1
end
if #arg == n-1 then
    -- 年月指定なし
    display_calendar(now.year, now.month, holiday_flag)
elseif #arg == n then
    -- 年 or 月の片方のみ指定
    p = tonumber(arg[n]) or -1
    if p >= 1873 then	-- 1873/1/1: 日本におけるグレゴリオ暦導入日
	calendar_year(p) -- -3 で起動されてても無視
	--[[
	if display_calendar == calendar_3months then
	    display_calendar(p, now.month, holiday_flag)
	else
	    calendar_year(p)
	end
	]]
    elseif p >= 1 and p <= 12 and display_calendar ~= calendar_year then
	if p >= now.month then
	    display_calendar(now.year, p, holiday_flag)
	else
	    display_calendar(now.year+1, p, holiday_flag)
	end
    else
	usage"invalid month or year\n"
    end
elseif #arg == n+1 then
    -- 年月どちらも指定
    p = tonumber(arg[n]) or -1
    q = tonumber(arg[n+1]) or -1
    if p >= 1873 and q >= 1 and q <= 12 then
	display_calendar(p, q, holiday_flag)
    elseif q >= 1873 and p >= 1 and p <= 12 then
	display_calendar(q, p, holiday_flag)
    else
	usage"invalid month or year\n"
    end
else
    usage""
end
