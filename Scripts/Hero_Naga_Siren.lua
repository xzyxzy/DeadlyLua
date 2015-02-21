require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("ToggleKey", "T", config.TYPE_HOTKEY)
config:SetParameter("RipTide", "W", config.TYPE_HOTKEY)
config:Load()

local toggleKey = config.ToggleKey
local rt = config.RipTide
local play = false
local click = false

local Wheel = {}
Wheel.smallFont = drawMgr:CreateFont("defaultFont","Arial",25,1000)
Wheel.bigFont = drawMgr:CreateFont("defaultFont","Arial",40,1000)
Wheel.whilesize = 180*(math.floor(client.screenSize.x/160))/10

local main = {}
main.block = {}
main.icon = {}
main.ill = {}
main.sleep = {}
main.time = nil
main.stage = nil
main.action = 0
main.good = {Vector(1625,-3690,256),Vector(3136,-3472,256),Vector(3080,-4664,256),Vector(-279,-2975,128),Vector(-1191,-4100,128)}
main.bad = {Vector(-4491,3538,256),Vector(-3062,4595,256),Vector(-308,3711,256),Vector(-1592,2600,256),Vector(1172,3298,256)}

function Tick(tick)

	Menu()

    if not client.console and SleepCheck() then

		local me = entityList:GetMyHero() 
		if not me then return end
		
		local illusion = entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_HERO and v.team == me.team and v.illusion and v.alive and v.controllable and v.classId == CDOTA_Unit_Hero_Naga_Siren end)
		
		--draw
		for i = 1, 8 do
		
			local v = illusion[i]
			if v then
				if not main.icon[i] then
					main.icon[i] = {}
					main.icon[i].siren = drawMgr:CreateRect(24,-12+i*70,72,42,0x000000FF,drawMgr:GetTextureId("NyanUI/heroes_horizontal/naga_siren"))
					main.icon[i].sirenR = drawMgr:CreateRect(24-1,-12+i*70,73,44,0x00000095,true)
					main.icon[i].sirenBG = drawMgr:CreateRect(24,-12+i*70,72,42,0x00000010)
					main.icon[i].hp = drawMgr:CreateRect(24,31+i*70,72,5,0x3EB209ff)
					main.icon[i].hpR = drawMgr:CreateRect(23,30+i*70,73,7,0x010102ff,true)
					main.icon[i].hpBG = drawMgr:CreateRect(24,31+i*70,72,5,0x01010280)
					main.icon[i].mp = drawMgr:CreateRect(24,38+i*70,72,5,0x0C4A97ff)
					main.icon[i].mpR = drawMgr:CreateRect(23,37+i*70,73,7,0x010102ff,true)
					main.icon[i].mpBG = drawMgr:CreateRect(24,38+i*70,72,5,0x01010280)
					--main.icon[i].map = drawMgr:CreateText(0,0,-1,"",drawMgr:CreateFont("F13","Arial",12,600))
					Visible(false,i)
				end	
				
				main.icon[i].siren.y = -12+i*70
				main.icon[i].sirenR.y = -12+i*70
				main.icon[i].sirenBG.y = -12+i*70
				main.icon[i].hp.y = 31+i*70
				main.icon[i].hpR.y = 30+i*70
				main.icon[i].hpBG.y = 31+i*70
				main.icon[i].mp.y = 38+i*70
				main.icon[i].mpR.y = 37+i*70
				main.icon[i].mpBG.y = 38+i*70
		
				local modifer = v:FindModifier("modifier_illusion")
				if modifer then
				
					--[[local activity = v.activity

					if main.action == 0 and (activity == LuaEntityNPC.ACTIVITY_IDLE or activity == LuaEntityNPC.ACTIVITY_IDLE1) and v.recentDamage ~= 0 then
						v:AttackMove(v.position)
					end]]
					
					--[[if entityList:GetMyPlayer().selection[1].handle == v.handle then
						main.icon[i].sirenBG.color = 0x00000001
					else
						main.icon[i].sirenBG.color = 0x00000060
					end	]]
					
					--[[if IsMouseOnButton(24,-12+i*70,72,72) and click then
						player:Select(v)
					end]]
					
					--local Minimaps = MapToMinimap(v.position.x,v.position.y)				
					local hpPercent = v.health/v.maxHealth
					local printMe = string.format("%i",math.floor(v.health))				
					local mpPercent = modifer.remainingTime/modifer.duration
					
					main.icon[i].hp.w = 72*hpPercent 
					main.icon[i].hpBG.x = 24+72*hpPercent 
					main.icon[i].hpBG.w = 72*(1-hpPercent)
					main.icon[i].mp.w = 72*mpPercent 
					main.icon[i].mpBG.x = 24+72*mpPercent 
					main.icon[i].mpBG.w = 72*(1-mpPercent)
					
					--[[main.icon[i].map.text = ""..i
					main.icon[i].map.x = Minimaps.x
					main.icon[i].map.y = Minimaps.y]]			
					
					if not main.icon[i].siren.visible then
						Visible(true,i)
					end
					
				end

			elseif main.icon[i] and main.icon[i].siren.visible then
				Visible(false,i)
			end

			
		end
		--farm
		if main.action ~= 0 then
			if not main.stage then
				main.stage = true
				main.time = client.gameTime
				for i,v in ipairs(illusion) do
					main.ill[v.handle] = true 
					local spot = GetSpots(v,GetSide())
					if type(spot) == "table" then
						main.block[spot[2]] = true
						v:Move(spot[1],false)	
						v:AttackMove(spot[1],true)
					end					
				end	
				Sleep(1000)
				return
			else
				for i,v in ipairs(illusion) do
					if main.ill[v.handle] then
						if (v.activity == LuaEntityNPC.ACTIVITY_IDLE or v.activity == LuaEntityNPC.ACTIVITY_IDLE1) and v.recentDamage == 0 then
							if not main.sleep[v.handle] then
								main.sleep[v.handle] = tick + 1000
							end
							if main.sleep[v.handle] < tick then
								local spot = GetSpots(v,GetSide())
								if type(spot) == "table" then
									main.block[spot[2]] = true
									v:Move(spot[1],false)	
									v:AttackMove(spot[1],true)								
								else
									local creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,visible=true,alive=true,team=5-me.team})
									if #creeps > 0 then
										table.sort( creeps, function (a,b) return GetDistance2D(a,v) < GetDistance2D(b,v) end )
										v:AttackMove(creeps[1].position)
									else
										v:AttackMove(me.position)
									end
									main.ill[v.handle] = true
								end
							end
						else 
							main.sleep[v.handle] = nil
						end
					end
				end
			end
			if client.gameTime - main.time > 30 then 
				main.action = 0
				Clear()
			end
		elseif main.stage then
			Clear()
		end
			
		Sleep(250)	
		
	end		
	
end

function Key(msg,code)
	if client.chat or client.console then return end
	if msg == KEY_DOWN then
		if code == toggleKey then
			activated = true
			--main.action == 0
		elseif code == rt then
			local selected = entityList:GetMyPlayer().selection[1]		
			local me = entityList:GetMyHero()
			if selected.handle ~= me.handle and selected.classId == CDOTA_Unit_Hero_Naga_Siren then				
				me:CastAbility(me:GetAbility(3))
			end
		end
	elseif msg == LBUTTON_DOWN then
		click = true
		activated = false
	else
		activated = false
		click = false
	end
end

function Clear()
	main.time = nil
	main.stage = false
	main.block = {}
	main.ill = {}
	main.sleep = {}
end

function Visible(set,num)
	main.icon[num].siren.visible = set
	main.icon[num].sirenR.visible = set
	main.icon[num].sirenBG.visible = set
	main.icon[num].hp.visible = set
	main.icon[num].hpR.visible = set
	main.icon[num].hpBG.visible = set
	main.icon[num].mp.visible = set
	main.icon[num].mpR.visible = set
	main.icon[num].mpBG.visible = set
	--main.icon[num].map.visible = set
end

function GetSpots(ent,tab)
	local sp = nil
	if main.action == 1 or main.action == 4 then
		local distance = 20000		
		for k,l in ipairs(tab) do	
			if not main.block[k] then
				local dis = ent:GetDistance2D(l)
				if distance > dis then
					distance = dis
					sp = {l,k}
				end
			end
		end
	else
		local distance = 0
		for k,l in ipairs(tab) do	
			if not main.block[k] then
				local dis = ent:GetDistance2D(l)
				if distance < dis then
					distance = dis
					sp = {l,k}
				end
			end
		end
	end
	return sp
end

function GetSide()
	if main.action > 2 then
		return main.good
	else
		return main.bad
	end
end

function GetRelativePlacement(alpha,font,text)
	local alphaR = alpha/math.pi
	if alphaR < .25 then
		return Vector2D(0,2*(.25 - alphaR)*font:GetTextSize(text).y)
	elseif alphaR < .5 then
		return Vector2D(4*(alphaR - .25)*font:GetTextSize(text).x/2,0)
	elseif alphaR < .75 then
		return Vector2D(2*(alphaR - .25)*font:GetTextSize(text).x,0)
	elseif alphaR < 1.25 then
		return Vector2D(font:GetTextSize(text).x,2*(alphaR - .75)*font:GetTextSize(text).y)
	elseif alphaR < 1.75 then
		return Vector2D(2*(1.75 - alphaR)*font:GetTextSize(text).x,font:GetTextSize(text).y)
	else
		return Vector2D(0,2*(2.25 - alphaR)*font:GetTextSize(text).y)
	end
end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end

function Menu()
	if activated then
		local func = {"Stop","Near Dire","Far Dire","Far Radiant","Near Radiant"}
		if not Wheel.Pos then
			Wheel.Pos = client.mouseScreenPosition
			Wheel.wheel = drawMgr:CreateRect(Wheel.Pos.x - Wheel.whilesize/2,Wheel.Pos.y - Wheel.whilesize/2,Wheel.whilesize,Wheel.whilesize,0x000000FF,drawMgr:GetTextureId("FWT/wheel"))
			Wheel.cursor = drawMgr:CreateRect(Wheel.Pos.x - Wheel.whilesize/4,Wheel.Pos.y - Wheel.whilesize/4,Wheel.whilesize/2,Wheel.whilesize/2,0x000000FF,drawMgr:GetTextureId("FWT/cursor"))
			Wheel.wheel.visible = true
			Wheel.cursor.visible = true
			Wheel.names = {}
			Wheel.recs = {}	
			for i,v in ipairs(func) do
				local alpha = (2*math.pi*(i - 1)/#func - math.pi/2)%(2*math.pi)
				local center = Wheel.Pos + Vector2D(85*math.cos(alpha),85*math.sin(alpha))
				local font = Wheel.smallFont
				name = v
				center = center - GetRelativePlacement(alpha,font,name)
				Wheel.names[i] = drawMgr:CreateText(center.x,center.y,0xD9D9D9FF,name,font)
				Wheel.names[i].visible = true
			end
		else
			local newPos = client.mouseScreenPosition
			local dist = GetDistance2D(Wheel.Pos,newPos)
			if dist > 38 then
				newPos = (newPos - Wheel.Pos) * 38 / dist + Wheel.Pos
			end		
			Wheel.cursor:SetPosition(newPos - Vector2D(Wheel.whilesize/4,Wheel.whilesize/4), Vector2D(Wheel.whilesize/2,Wheel.whilesize/2))
			local currentIndex = nil
			if dist >= 30 then
				currentIndex = math.floor(((math.atan2(Wheel.Pos.y - newPos.y,Wheel.Pos.x - newPos.x) - math.pi/2 + math.pi/#func)%(2*math.pi))/(2*math.pi/#func)) + 1
			end
			for i,v in ipairs(Wheel.names) do
				if i ~= currentIndex then
					if v.font.tall == Wheel.bigFont.tall then
						local alpha = (2*math.pi*(i - 1)/#func - math.pi/2)%(2*math.pi)
						local center = Wheel.Pos + Vector2D(85*math.cos(alpha),85*math.sin(alpha))
						center = center - GetRelativePlacement(alpha,Wheel.smallFont,name)
						v.font = Wheel.smallFont
						v.position = center
					end
				else
					if v.font.tall == Wheel.smallFont.tall then
						local alpha = (2*math.pi*(i - 1)/#func - math.pi/2)%(2*math.pi)
						local center = Wheel.Pos + Vector2D(85*math.cos(alpha),85*math.sin(alpha))
						center = center - GetRelativePlacement(alpha,Wheel.bigFont,name)
						v.font = Wheel.bigFont
						v.position = center
						main.action = i - 1
					end
				end
			end
		end
	elseif Wheel.Pos then
		Wheel.Pos = nil
		Wheel.wheel.visible = false
		Wheel.cursor.visible = false
		for i = 1,5 do
			if Wheel.names[i] then
				Wheel.names[i].visible = false
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_Naga_Siren then			
			play = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()
	Clear()
	collectgarbage("collect")
	main.stage = false
	main.action = 0
	if play then
		script:UnregisterEvent(Key)
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end
 
script:RegisterEvent(EVENT_CLOSE,GameClose) 
script:RegisterEvent(EVENT_TICK,Load)
