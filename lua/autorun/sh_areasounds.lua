
if game.GetMap() != "rp_downtown_tits_v2" then return end

if SERVER then
	AddCSLuaFile()
	return
end

local soundStream = false
local curSoundName = ""

local areas = {}
areas["http://content.glitchfire.com/darkrp/sound/calmjazz.mp3"] = {pos1 = Vector(-2949.321045, -1159.874512, 49.831001), pos2 = Vector(-4483.387695, -2170.191895, -251.266205)}
areas["http://content.glitchfire.com/darkrp/sound/escape.mp3"] = {pos1 = Vector(-2336.536377, 1151.722046, -112.924103), pos2 = Vector(-1886.087158, 1201.756470, -637.627441)}
areas["http://content.glitchfire.com/darkrp/sound/party.mp3"] = {pos1 = Vector(2567.446045, 6724.833008, 317.179901), pos2 = Vector(3261.094482, 7592.013184, -195.756775)}
areas["http://content.glitchfire.com/darkrp/sound/sadharmonica.mp3"] = {pos1 = Vector(-1999.440430, 1105.723267, -165.396164), pos2 = Vector(-2512.066406, 376.635895, 9.822041)}
areas["http://content.glitchfire.com/darkrp/sound/spooky.mp3"] = {pos1 = Vector(4911.024902, -9701.958008, -160.102829), pos2 = Vector(6454.662598, -8183.477539, -328.716888)}

local shouldPlay = CreateClientConVar("gf_areasounds", "1", true, false, "Should area specific sounds play?", 0, 1)

local function endMusic()
	if !soundStream then
		hook.Remove("Think", "GFAreasEndMusic")
	else
		if soundStream != true then
			if IsValid(soundStream) then
				if soundStream:GetVolume() <= 0 then
					hook.Remove("Think", "GFAreasEndMusic")
					soundStream:Stop()
					soundStream = nil
				else
					soundStream:SetVolume(math.max(0, soundStream:GetVolume() - FrameTime()*0.5))
				end
			else
				hook.Remove("Think", "GFAreasEndMusic")
			end
		end
	end
end

local function createSound(song)
	sound.PlayURL(song, "noplay", function(chan, err, str)
		if IsValid(chan) then
			chan:Play()
			chan:SetVolume(3)
			soundStream = chan
		end
	end)
end

hook.Add("Tick", "GFAreasTick", function()
	if (!shouldPlay:GetBool()) then
		if (soundStream) then
			soundStream:Stop()
		end
		soundStream = false
		curSoundName = ""
		return
	end

	local ply = LocalPlayer()

	if (!ply:IsValid()) then return end

	local curArea = "none"

	for k,v in pairs(areas) do
		if (ply:GetPos():WithinAABox(v.pos1, v.pos2)) then
			curArea = k
			break
		end
	end

	if (soundStream) then
		if (curArea != curSoundName) then
			curSoundName = curArea
			hook.Add("Think", "GFAreasEndMusic", endMusic)
		end
	else
		curSoundName = curArea
		if (curSoundName != "none") then
			soundStream = true
			createSound(curArea)
		end
	end
end)

timer.Remove("GFAreaSounds")

--hook.Add("PreDrawTranslucentRenderables", "areasounds_showareas", function ()
--	for k,v in pairs(areas) do
--		render.DrawBox(Vector(0, 0, 0), Angle(0,0,0), v.pos1, v.pos2, Color( 255, 255, 255 ) )
--	end
--end)