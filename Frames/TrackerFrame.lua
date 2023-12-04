local addonName, addon = ...

function MSAddon:CreateTrackerFrame()
	-- Main frame
    MSAddon.TrackerFrame = CreateFrame("Frame", addonName.."Frame", UIParent, "BackdropTemplate")
    MSAddon.TrackerFrame.PartFrames = {}
    MSAddon.TrackerFrame.UnusedPartFrames = {}
	MSAddon.TrackerFrame:SetWidth(MSAddon.db.profile.trackerFrameWidth)
	MSAddon.TrackerFrame:SetFrameStrata("LOW")
	MSAddon.TrackerFrame:SetFrameLevel(MSAddon.TrackerFrame:GetFrameLevel() + 25)
	MSAddon.TrackerFrame:Show()
	MSAddon.TrackerFrame:SetMovable(true)
	MSAddon.TrackerFrame:EnableMouse(true)
	MSAddon.TrackerFrame:RegisterForDrag("LeftButton")
	MSAddon.TrackerFrame:SetScript("OnDragStart", MSAddon.TrackerFrame.StartMoving)
	MSAddon.TrackerFrame:SetScript("OnDragStop", MSAddon.StopMoveTrackerFrame)

	-- MSF:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
	-- 	MS:Log(string.format("%s %s %s %s", event, tostring(arg1), tostring(arg2), tostring(arg3)))
	-- 	if event == "PLAYER_ENTERING_WORLD" then
	-- 		MS.inWorld = true
	-- 		if not MS.initialized then
	-- 			Init()
	-- 		end
	-- 	elseif event == "QUEST_WATCH_LIST_CHANGED" then
	-- 	elseif event == "QUEST_AUTOCOMPLETE" then
	-- 	elseif event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED" then
	-- 		MS:HandleQuestAcceptedOrAbandoned(arg1)
	-- 	elseif event == "QUEST_TURNED_IN" then
	-- 		MS:HandleQuestTurnedIn(arg1)
	-- 	elseif event == "ACHIEVEMENT_EARNED" then		
	-- 		MS:HandleAchievementCompleted(arg1)
	-- 	elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then	
	-- 	elseif event == "PLAYER_LEVEL_UP" then		
	-- 		MS:HandleLevelUp(arg1)
	-- 	elseif event == "GOSSIP_SHOW" then		
	-- 		--local title1, level1, isTrivial1, frequency1, isRepeatable1, isLegendary1, isIgnored1, questID1, ... = GetGossipAvailableQuests()
	-- 		--MS:Log("GOSSIP_SHOW", GetGossipAvailableQuests())
	-- 		-- Use this to warn players about accepting quests that are ahead in the story
	-- 	end
	-- end)
	-- MSF:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- MSF:RegisterEvent("QUEST_AUTOCOMPLETE")
	-- MSF:RegisterEvent("QUEST_ACCEPTED")
	-- MSF:RegisterEvent("QUEST_REMOVED")
	-- MSF:RegisterEvent("ACHIEVEMENT_EARNED")
	-- MSF:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	-- MSF:RegisterEvent("ZONE_CHANGED")
	-- MSF:RegisterEvent("PLAYER_LEVEL_UP")
	-- MSF:RegisterEvent("GOSSIP_SHOW")
	-- MSF:RegisterEvent("QUEST_TURNED_IN")
	-- MSF:RegisterEvent("QUEST_DATA_LOAD_RESULT")
	
	-- Header frame
	local header = CreateFrame("Frame", addonName.."Header", MSAddon.TrackerFrame, "MS_Header")
	header:SetPoint("TOPLEFT", 0, 0)
	header:Show()
	MSAddon.TrackerFrame.Header = header
	MSAddon.TrackerFrame:SetHeight(header:GetHeight())
    
	MSAddon:Log("Finished CreateTrackerFrame", nil)
end

function MSAddon:SetTrackerFrameTitle()
	if MSAddon.ActiveStory then
		MSAddon.TrackerFrame.Header.AddonTitle:SetText(string.format("MainScenario: %s", MSAddon.ActiveStory.Title))
	else
		MSAddon.TrackerFrame.Header.AddonTitle:SetText(string.format("MainScenario: No active story"))
	end
end

function MSAddon:MoveTrackerFrame()
	MSAddon.TrackerFrame:ClearAllPoints()
	MSAddon.TrackerFrame:SetPoint(MSAddon.db.profile.anchorPoint, UIParent, MSAddon.db.profile.anchorPoint, MSAddon.db.profile.xOffset, MSAddon.db.profile.yOffset)
end

function MSAddon:SetTrackerFrameBackground()
	local backdrop = {
		bgFile = LSM:Fetch("background", MSAddon.db.profile.bgr),
		edgeFile = LSM:Fetch("border", MSAddon.db.profile.border),
		edgeSize = MSAddon.db.profile.borderThickness,
		insets = { left=MSAddon.db.profile.bgrInset, right=MSAddon.db.profile.bgrInset, top=MSAddon.db.profile.bgrInset, bottom=MSAddon.db.profile.bgrInset }
	}
	self.borderColor = MSAddon.db.profile.classBorder and self.classColor or MSAddon.db.profile.borderColor

	MSAddon.TrackerFrame:SetBackdrop(backdrop)
	MSAddon.TrackerFrame:SetBackdropColor(MSAddon.db.profile.bgrColor.r, MSAddon.db.profile.bgrColor.g, MSAddon.db.profile.bgrColor.b, MSAddon.db.profile.bgrColor.a)
	MSAddon.TrackerFrame:SetBackdropBorderColor(self.borderColor.r, self.borderColor.g, self.borderColor.b, MSAddon.db.profile.borderAlpha)
end

function MSAddon:StopMoveTrackerFrame()
	point, relativeTo, relativePoint, xOfs, yOfs = MSAddon.TrackerFrame:GetPoint()
	MSAddon:Log(string.format("%s %d %d", point, xOfs, yOfs))
	MSAddon.db.profile.xOffset = xOfs
	MSAddon.db.profile.yOffset = yOfs
	MSAddon.TrackerFrame:StopMovingOrSizing()
end