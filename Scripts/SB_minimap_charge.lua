--<<фаст чардж через минимапу на ближайшего к курсору крипа, по дефолту Q>>

local play = false

function SBKey(msg,code)
	if msg ~= KEY_UP or client.chat then return end
	if code == string.byte("Q") then		
		local coor = MinimapToMap()
		if coor ~= nil then
			local me = entityList:GetMyHero()
			local list = entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_CREEP and v.alive and v.visible and v.team ~= me.team end)
			table.sort( list, function (a,b) return a:GetDistance2D(coor) < b:GetDistance2D(coor) end )
			me:CastAbility(me:GetAbility(1),list[1])
			return true
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId == CDOTA_Unit_Hero_SpiritBreaker then			
			play = true
			script:RegisterEvent(EVENT_KEY,SBKey)
			script:UnregisterEvent(Load)
		else
			script:Disable()
		end
	end
end

function GameClose()	
  if play then
		script:UnregisterEvent(SBKey)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
