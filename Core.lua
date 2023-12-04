local addonName, addon = ...
local round = function(n) return floor(n + 0.5) end

local function SlashHandler(msg, editbox)
	local cmd, value = msg:match("^(%S*)%s*(.-)$")
	if cmd == "config" then
		--MSAddon:OpenOptions()
	elseif cmd == "hide" then
		MSAddon:Log("Hide", true)
		MSAddon.TrackerFrame:Hide()
	elseif cmd == "show" then
		MSAddon:Log("Show", true)
		MSAddon.TrackerFrame:Show()
	elseif cmd == "gui" then
		MSAddon:Log("GUI", true)
		MS_ToggleMainFrame()
	elseif cmd == "resetframe" then
		MSAddon:Log("Reset Frame: "..MSAddon.db.profile.anchorPoint.." "..MSAddon.db.profile.xOffset.." "..MSAddon.db.profile.yOffset, true)
		MSAddon.db.profile.anchorPoint = MSAddon.defaults.profile.anchorPoint
		MSAddon.db.profile.xOffset = MSAddon.defaults.profile.xOffset
		MSAddon.db.profile.yOffset = MSAddon.defaults.profile.yOffset
		MSAddon:MoveTrackerFrame()
	elseif cmd == "reset" then
		MSAddon:Log("Resetting all stored quest progress")
		print("Resetting all stored quest progress. You must reload the UI for this to take effect.")
		MSAddon.dbc.CompletedStoryParts = {} 
		MSAddon.dbc.CompletedStoryPartChapters = {}
	end
end

function MSAddon:OnInitialize()
    MSAddon.debugEnabled = true
    MSAddon.logNumber = 1
	MSAddon:Log("Starting Oninitialise")
	SLASH_MAINSCENARIO1, SLASH_MAINSCENARIO2 = "/ms", "/mainscenario"
	SlashCmdList["MAINSCENARIO"] = SlashHandler

	-- Get character data
	self.playerName = UnitName("player")
	self.playerFaction = UnitFactionGroup("player")
	self.playerLevel = UnitLevel("player")
	local _, class = UnitClass("player")

    self.db = LibStub("AceDB-3.0"):New(addonName.."DB", MSAddon.defaults, true)
	self.options = options
	MSAddon.dbp = self.db.profile
	MSAddon.dbc = self.db.char
	MSAddon:Log("DB Profile", self.dbp)
	MSAddon:Log("DB Char", self.dbc)

	self.screenWidth = round(GetScreenWidth())
	self.screenHeight = round(GetScreenHeight())

	-- Fetch quests from server. Only do this once
	local quests = C_QuestLog.GetAllCompletedQuestIDs()
	self.QuestsCompleted = {}
	for i, questid in ipairs(quests) do
		self.QuestsCompleted[questid] = true
	end

	MSAddon:CreateTrackerFrame()
	MSAddon:CreateMainFrame()
	MSAddon:RegisterEventHandlers()

	-- Decide which expansion to load at first start, using the following sequence: 
	-- 1) most recently used story in the DB if auto-story setting is off (default is on)
	-- 2) determine story based on zone
	-- 3) most recently released expansion story
	MSAddon.ActiveStoryNumber = MSAddon:GetExpansion()
	MSAddon:SetSelectedStory(self.ActiveStoryNumber)

	MSAddon:Log("MSAddon", MSAddon)
	MSAddon:Log("MSAddonTrackerFrame", MSAddon.TrackerFrame)
	MSAddon:Log("ActiveStoryParts", MSAddon.ActiveStoryParts)
	MSAddon:Log("QuestsCompleted", MSAddon.QuestsCompleted)
	MSAddon:Log("ActiveStoryParts", MSAddon.dbc.ActiveStoryParts)
	MSAddon:Log("CompletedStoryParts", MSAddon.dbc.CompletedStoryParts)
	MSAddon:Log("CompletedStoryChapters", MSAddon.dbc.CompletedStoryPartChapters)

	MSAddon:MoveTrackerFrame()
	MSAddon:SetTrackerFrameBackground()
	--MSAddon:SetStoryPartFramesDisplayConfiguration()
	MSAddon.inWorld = true
end

-- Called during:
-- first start
-- when changing the active story from the database frame
function MSAddon:SetSelectedStory(exp)	
	self.ActiveStory = self.StoryData[exp]
	if self.ActiveStory == nil then
		MSAddon:Log("No story data for "..exp, nil)
		return
	end
	MSAddon:Log("Story data loaded for "..exp, nil)

	self.ActiveStoryParts = {}

	-- Check for saved progress against the loaded story (Load completed and active story parts from saved variables)

	-- If no saved progress, attempt to auto-detect progress (check every part for completion and eligiblity)
	MSAddon:AddNewActiveStoryParts()

	-- With final list of active parts, configure the addon
	MSAddon:CreatePartFramesForActiveStoryParts()
	MSAddon:SetTrackerFrameTitle()
end

function MSAddon:GetExpansion()
    return 9
end

-- Runs whenever the story changes and there's no saved state for the story
-- Runs whenever the current part (not chapter) is completed
function MSAddon:AddNewActiveStoryParts()
	local partsAdded = 0
	if not self.ActiveStory then return 0 end

	for i, part in MSAddon:spairs(self.ActiveStory.Parts) do
		MSAddon:Log(string.format("Checking if part %d[id=%d] should be made active, current volume is %d", part.DisplayNumber, i, MSAddon.ActiveStoryNumber))
		part.Id = i	
		local status = MSAddon:GetPartStatus(MSAddon.ActiveStoryNumber, part)	
		if status == MSAddon.PartStatusEnum.Eligible then
			MSAddon:Log(string.format("Part %d: %s is active", part.DisplayNumber, part.Name), nil)
			MSAddon:DetermineActiveChapterForPart(part)
			--part.ActiveChapter = 1
			partsAdded = partsAdded + 1
			table.insert(MSAddon.ActiveStoryParts, tonumber(i), part)
		end
	end
	MSAddon:Log(string.format("Finished determining that %d parts are active, %d new parts added", #MSAddon.ActiveStoryParts, partsAdded))
	return partsAdded
end

MSAddon.PartStatusEnum = { Active={}, Completed={}, Eligible={}, NotRecommended={}, NotAvailable={}, Unknown={} }

function MSAddon:GetPartStatus(volume, part)

	if MSAddon:IsPartCompleted(volume, part.Id) then
		MSAddon:Log(string.format("PartStatusCheck: %d.%d is completed", volume, part.DisplayNumber))
		return MSAddon.PartStatusEnum.Completed
	end

	if MSAddon:IsPartActive(part.Id) then
		MSAddon:Log(string.format("PartStatusCheck: %d.%d is active", volume, part.DisplayNumber))
		return MSAddon.PartStatusEnum.Active
	end
	
	if part:RequirementsMet() and part:RecommendationsMet() then
		MSAddon:Log(string.format("PartStatusCheck: %d.%d is eligible to be active", volume, part.DisplayNumber))
		return MSAddon.PartStatusEnum.Eligible
	end

	if part:RequirementsMet() and not part:RecommendationsMet() then
		MSAddon:Log(string.format("PartStatusCheck: %d.%d is not recommended content", volume, part.DisplayNumber))
		return MSAddon.PartStatusEnum.NotRecommended
	end

	if not part:RequirementsMet() then
		MSAddon:Log(string.format("PartStatusCheck: %d.%d is not available to the player", volume, part.DisplayNumber))
		return MSAddon.PartStatusEnum.NotAvailable
	end

	MSAddon:Log(string.format("PartStatusCheck: %d.%d has an unknown status", volume, part.DisplayNumber))
	return MSAddon.PartStatusEnum.Unknown
end

function MSAddon:DetermineActiveChapterForPart(part)
	for j, chapter in pairs(part.Chapters) do 
		if not MSAddon:IsChapterCompleted(MSAddon.ActiveStoryNumber, part.Id, chapter) or j == #part.Chapters then 				
			part.ActiveChapter = j
			MSAddon:Log(string.format("Chapter setting: Chapter %d.%d is active", part.Id, j), nil)
			break 
		end
	end
end

function MSAddon:IsPartActive(partId)
	for i, part in pairs(self.ActiveStoryParts) do
		if part.Id == partId then 
			MSAddon:Log(string.format("Part %d is already in the active list", partId))
			return true 
		end
	end
	MSAddon:Log(string.format("Part %d is NOT already in the active list", partId))
	return false
end

function MSAddon:IsPartCompleted(volume, part)
	if not MSAddon.dbc.CompletedStoryParts then return false end
	if not MSAddon.dbc.CompletedStoryParts[volume] then return false end
	--MSAddon:Log(string.format("Part ID %d from Volume %d is completed? %s", part, volume, tostring(MSAddon.dbc.CompletedStoryParts[volume][part])), true)
	return MSAddon.dbc.CompletedStoryParts[volume][part]
end

function MSAddon:IsChapterCompleted(volume, partId, chapter)
	--MSAddon:Log(string.format("Determining if Volume %d Part %d Chapter %d is completed", volume, partId, chapter.index))

	if chapter.type == "quest" then return MSAddon:IsQuestCompleted(chapter.id) end
	if chapter.type == "multiquest" then
		local multiquestCompleted = 0
		for i, questId in pairs(chapter.id) do
			if MSAddon:IsQuestCompleted(questId) then
				print(string.format("Quest %s is completed", questId))
				multiquestCompleted = multiquestCompleted + 1
			end
		end
		return multiquestCompleted == #chapter.id 		
	end
	if chapter.type == "quest-accept" then return MSAddon:IsQuestCompleted(chapter.id) or C_QuestLog.IsOnQuest(chapter.id) end
	if chapter.type == "raid" or chapter.type == "dungeon" then return MSAddon:IsAchievementCompleted(chapter.achId) end
	if chapter.type == "level" then return MSAddon.playerLevel >= chapter.level end
	if chapter.type == "external-cinematic" or chapter.type == "recap" or chapter.type == "ingame-cinematic" then
		return MSAddon.dbc.CompletedStoryPartChapters and MSAddon.dbc.CompletedStoryPartChapters[volume] and MSAddon.dbc.CompletedStoryPartChapters[volume][partId] and MSAddon.dbc.CompletedStoryPartChapters[volume][partId][chapter.index]
	end
	return false
end

function MSAddon:IsQuestCompleted(questId)
	title = C_QuestLog.GetTitleForQuestID(questId)
	if not title then title = "Unknown" end
	if self.QuestsCompleted[questId] then
		--MSAddon:Log(string.format("Quest %d: %s has been completed", questId, title), self.QuestsCompleted)
	else
		--MSAddon:Log(string.format("Quest %d: %s has not been completed", questId, title), self.QuestsCompleted)
	end
	return self.QuestsCompleted[questId]
end

function MSAddon:SetPartCompleted(part)
	self.ActiveStoryParts[part.Id] = nil

	if not MSAddon.dbc.CompletedStoryParts then MSAddon.dbc.CompletedStoryParts = {} end
	if not MSAddon.dbc.CompletedStoryParts[MSAddon.ActiveStoryNumber] then MSAddon.dbc.CompletedStoryParts[MSAddon.ActiveStoryNumber] = {} end

	MSAddon.dbc.CompletedStoryParts[MSAddon.ActiveStoryNumber][part.Id] = true
end

function MSAddon:SetPartChapterCompleted(volume, partId, chapterId)
	MSAddon:Log(string.format("Setting Volume %d Part %d Chapter %d as completed", volume, partId, chapterId))
	if not MSAddon.dbc.CompletedStoryPartChapters then MSAddon.dbc.CompletedStoryPartChapters = {} end
	if not MSAddon.dbc.CompletedStoryPartChapters[volume] then MSAddon.dbc.CompletedStoryPartChapters[volume] = {} end
	if not MSAddon.dbc.CompletedStoryPartChapters[volume][partId] then MSAddon.dbc.CompletedStoryPartChapters[volume][partId] = {} end
	MSAddon.dbc.CompletedStoryPartChapters[volume][partId][chapterId] = true
end

function MSAddon:GetChapterName(chapter)
	if chapter.type == "quest" or chapter.type=="quest-accept" then 
		local name = C_QuestLog.GetTitleForQuestID(chapter.id)
		if not name then
			MSAddon:Log(string.format("WARNING Failed to load quest name for questid %d", chapter.id))
		end
		return name or "Unknown"
	elseif chapter.type == "multiquest" then
		print("here")
		local name = C_QuestLog.GetTitleForQuestID(chapter.id[1])
		if not name then
			MSAddon:Log(string.format("WARNING Failed to load quest name for questid %d", chapter.id[1]))
			return "Multiple quests"
		end
		return string.format("%s and %s more %s", name, (#chapter.id - 1), (#chapter.id > 2 and "quests" or "quest"))
	elseif chapter.type == "level" then
		return "Level up!"
	elseif chapter.name then
		return chapter.name
	end
	return "Unnamed chapter"
end

function MSAddon:GetChapterDisplayType(chapter)
	if chapter.type == "quest" then return "Quest" end
	if chapter.type == "multiquest" then return "Multiple Quests" end
	if chapter.type == "quest-accept" then return "Accept Quest" end
	if chapter.type == "level" then return "Level up" end
	if chapter.type == "ingame-cinematic" then return "Ingame Cinematic" end
	if chapter.type == "recap" then return "Text Recap" end

	return "Unknown Type"
end