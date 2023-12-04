local addonName, addon = ...
MSAddon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName)
LSM = LibStub("LibSharedMedia-3.0")

MSAddon:SetDefaultModuleState(false)
MSAddon.title = GetAddOnMetadata(addonName, "Title")
MSAddon.version = GetAddOnMetadata(addonName, "Version")
MSAddon.gameVersion = GetBuildInfo()
MSAddon.locale = GetLocale()
MSAddon.StoryData = {}

MSAddon.defaults = {
	profile = {
		anchorPoint = "TOPRIGHT",
		xOffset = -500,
		yOffset = -50,
		maxHeight = 400,
        trackerFrameWidth = 400,
		frameScrollbar = true,
		frameStrata = "LOW",
		
		bgr = "Solid",
		bgrColor = { r=0, g=0, b=0, a=0.7 },
		border = "Blizzard Dialog Gold",
		borderColor = { r=1, g=0.82, b=0 },
		borderAlpha = 1,
		borderThickness = 16,
		bgrInset = 4,
		progressBar = "Blizzard",

		font = LSM:GetDefault("font"),
		fontSize = 12,
		fontFlag = "",
		fontShadow = 1,
		textWordWrap = false,
		objNumSwitch = false,

		hdrBgr = 2,
		hdrBgrColor = { r=1, g=0.82, b=0 },
		hdrBgrColorShare = false,
		hdrTxtColor = { r=1, g=0.82, b=0 },
		hdrTxtColorShare = false,
		hdrBtnColor = { r=1, g=0.82, b=0 },
		hdrBtnColorShare = false,
		hdrQuestsTitleAppend = true,
		hdrAchievsTitleAppend = true,
		hdrPetTrackerTitleAppend = true,
		hdrCollapsedTxt = 3,
		hdrOtherButtons = true,
		keyBindMinimize = "",
	},
	char = {
		collapsed = false,
	}
}

function MSAddon:Log(strName, tData) 
    if DevTool and MSAddon.debugEnabled then 
		DevTool:AddData(tData, "MS "..MSAddon.logNumber.." "..strName) 
		MSAddon.logNumber = MSAddon.logNumber + 1
    end
end

function MSAddon:GetStringsTable()
	MSAddon:Log("Getting strings table")
	return MSAddon.StringsEN
end

function MS_AdvanceChapter(partFrame)
	local part = partFrame.Part
	MSAddon:SetPartChapterCompleted(MSAddon.ActiveStoryNumber, part.Id, part.ActiveChapter)
	-- if part.Chapters[part.ActiveChapter].type == "external-cinematic" 
	-- or part.Chapters[part.ActiveChapter].type == "ingame-cinematic"
	-- or part.Chapters[part.ActiveChapter].type == "recap" then
		
	-- end

	local chapterSelected = false
	while not chapterSelected do
		part.ActiveChapter = part.ActiveChapter + 1
		if part.ActiveChapter > #part.Chapters then
			MSAddon:Log(string.format("Advance chapter for part %d when on the last part (%d/%d)", part.DisplayNumber, part.ActiveChapter, #part.Chapters))
			MSAddon:SetPartCompleted(part)
			if MSAddon.ContentFrame:IsVisible() then
				MSAddon:RedrawMainFrame()
			end
			MSAddon:StartCompletePartAndRemoveFrame(part)
			chapterSelected = true		
		--elseif not MS:IsChapterCompletedWeakTest(part.Id, part.Chapters[part.ActiveChapter], part.ActiveChapter) then
		else
			MSAddon:Log(string.format("Advance chapter for part %d to (%d/%d)", part.DisplayNumber, part.ActiveChapter, #part.Chapters))
			MSAddon:SetPartFrameContent(partFrame)
			chapterSelected = true
		end
	end
end

function MSAddon:spairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end
  
	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys 
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end
  
	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end