--[[
Name: Broker kFriends
Description: Shows how many online friends and guildmates there are

Copyright 2016 Mateusz Kasprzak

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local playerName, playerRealm = UnitName("player"), GetRealmName()

function GetClassColoredName(name, class)
	local color = "|cffffffff"
	if (class == 'Death Knight') then
		color = "|cffC41F3B"
	elseif (class == 'Druid') then
		color = "|cffFF7D0A"
	elseif (class == 'Hunter') then
		color = "|cffABD473"
	elseif (class == 'Mage') then
		color = "|cff69CCF0"
	elseif (class == 'Monk') then
		color = "|cff00FF96"
	elseif (class == 'Paladin') then
		color = "|cffF58CBA"
	elseif (class == 'Priest') then
		color = "|cffFFFFFF"
	elseif (class == 'Rogue') then
		color = "|cffFFF569"
	elseif (class == 'Shaman') then
		color = "|cff0070DE"
	elseif (class == 'Warlock') then
		color = "|cff9482C9"
	elseif (class == 'Warrior') then
		color = "|cffC79C6E"
	end
	return color..name.."|r"
end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("kFriends") or ldb:NewDataObject("kFriends", {
	type = "data source", icon = [[Interface\Icons\Inv_cask_04]], text = "All alone",
	OnClick = function(self, button)
		if button == "RightButton" then
			ToggleGuildFrame()
			if (IsInGuild()) then
				GuildFrameTab2:Click()
			end
		else
			ToggleFriendsFrame(1)
		end
	end,
	OnTooltipShow = function(tip)
		tip:AddLine("Friends List")	
		for j = 1, BNGetNumFriends() do
			local _, presenceName, _, _, toonName, _, _, online = BNGetFriendInfo(j)
			if (online) then
				tip:AddLine('|cff00EEE6'..presenceName..' ('..toonName..')|r ')
			end
		end
		for i = 1, GetNumFriends() do
			local name, level, class, area, online = GetFriendInfo(i)
			if (online) then
				tip:AddLine('['..level..'] '..GetClassColoredName(name, class))
			end
		end
		tip:AddLine(" ")
		
		if (IsInGuild()) then	
			tip:AddLine("Guild List")		
			for i = 0, select(1, GetNumGuildMembers()) do
				local name, _, _, level, class, zone, _, _, online = GetGuildRosterInfo(i)
				if (online) then
					tip:AddLine('['..level..'] '..GetClassColoredName(name, class))
				end
			end
			tip:AddLine(" ")
		end
		
		tip:AddLine("|cff69ccf0Left Click|cffffd200 to toggle Friends List|r")
		tip:AddLine("|cff69ccf0Right Click|cffffd200 to toggle Roster|r")	
	end,
})

local function OnEvent(self, event, addonName, ...)
	--if (event == "ADDON_LOADED" and addonName ~= "Broker_kFriends") then
	--	return
	--end

	friendsOn, guildOn = 0, 0
	for i = 1, GetNumFriends() do
		local _, _, _, _, online = GetFriendInfo(i)
		if (online) then
			friendsOn = friendsOn + 1
		end
	end
	
	for j = 1, BNGetNumFriends() do
		local _, _, _, _, _, _, _, online = BNGetFriendInfo(j)
		if (online) then
			friendsOn = friendsOn + 1
		end
	end
	
	if (IsInGuild()) then		
		for i = 0, select(1, GetNumGuildMembers()) do
			local _, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
			if (online) then
				guildOn = guildOn + 1
			end
		end
	
		dataobj.text = string.format("|cffffffffFriends: |cffffcc00%d |cffc0c0c0/ |cffffffffGuild: |cffffcc00%d", friendsOn, guildOn)
	else
		dataobj.text = string.format("|cffffffffFriends: |cffffcc00%d |cffc0c0c0/ |cffffffffNo Guild", friendsOn)
	end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("FRIENDLIST_UPDATE")
f:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
f:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
f:RegisterEvent("GUILD_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_GUILD_UPDATE")