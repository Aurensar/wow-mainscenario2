local addonName, addon = ...

function MSAddon:CreatePartFramesForActiveStoryParts()
	for i, part in pairs(self.ActiveStoryParts) do
		MSAddon:CreateNewPartFrame(part)
	end
end

function MSAddon:CreateNewPartFrame(part)
	local frame
	if #MSAddon.TrackerFrame.UnusedPartFrames > 0 then
		MSAddon:Log(string.format("CreateFrame: %d unused frames", #MSAddon.TrackerFrame.UnusedPartFrames))
		frame = table.remove(MSAddon.TrackerFrame.UnusedPartFrames)
		MSAddon:Log("CreateFrame: Chosen unused frame %s", frame:GetName())
	else
		frame = CreateFrame("Frame", addonName..(#MSAddon.TrackerFrame.PartFrames+1).."StoryPartFrame", MSAddon.TrackerFrame, "MS_ActiveStoryPart")
		local backdrop = {
			bgFile = "Interface/Buttons/WHITE8X8"
		}
		frame.AnimationOverlay:SetBackdrop(backdrop)
		frame.AnimationOverlay:SetBackdropColor(150/255, 250/255, 150/255)
		table.insert(MSAddon.TrackerFrame.PartFrames, frame)
		MSAddon:Log(string.format("CreateFrame: Creating brand new frame (might be bad)", frame:GetName()))
	end
	part.Frame = frame
	frame.Part = part
	part.Frame.Complete:Hide()
	part.Frame.New:Show()
	frame.AnimationOverlay:SetAlpha(0)
	self.borderColor = self.dbp.classBorder and self.classColor or self.dbp.borderColor
	frame:SetPoint("TOPLEFT", 0, MSAddon.TrackerFrame:GetHeight()*-1)
	MSAddon.TrackerFrame:SetHeight(MSAddon.TrackerFrame:GetHeight() + frame:GetHeight())
	MSAddon:SetPartFrameContent(frame)
	frame:Show()
	local group = part.Frame:CreateAnimationGroup()
	local animation = group:CreateAnimation("ALPHA")
	animation:SetFromAlpha(0)
	animation:SetToAlpha(1)
	animation:SetDuration(3)
	group:SetScript("OnFinished", function() frame:SetAlpha(1) part.Frame.New:Hide() end)
	group:Play()	
end

function MSAddon:SetPartFrameContent(frame)
	local part = frame.Part
	local ch = frame.Part.ActiveChapter

	MSAddon:Log(string.format("Setting frame content for part %d.%d", part.DisplayNumber, ch))

	frame.ShowURL:Hide()
	frame.Continue:Hide()
	frame.Content:Hide()
	frame.ChapterTitle:Show()
	frame.PartTitle:SetText(string.format("%s, Part %d: %s", part.Act, part.DisplayNumber, part.Name));
	frame.ChapterTitle:SetText(string.format("Chapter %d: %s", ch, MSAddon:GetChapterName(part.Chapters[ch])));
	frame.ProgressHolder.Progress:SetMinMaxValues(0, #part.Chapters)
	frame.ProgressHolder.Progress:SetValue(ch)
	frame.ProgressHolder.Progress.Text:SetText(string.format("Chapter %d of %d", ch, #part.Chapters));
	frame.Instruction:SetText("")

	if part.Chapters[ch].hint then
		frame.Hint:Show()
		frame.Hint:SetText(part.Chapters[ch].hint)
	else
		frame.Hint:Hide()
	end

	if part.Chapters[ch].type == "quest" or part.Chapters[ch].type == "quest-accept" then
		if C_QuestLog.IsOnQuest(part.Chapters[ch].id) then
			frame.Instruction:SetText(string.format("Complete quest '%s'", MSAddon:GetChapterName(part.Chapters[ch])))
		else
			frame.Instruction:SetText(string.format("Accept quest '%s'", MSAddon:GetChapterName(part.Chapters[ch])))
		end
	elseif part.Chapters[ch].type == "multiquest" then
		local accept = ""
		local complete = ""
		local completeCount = 0
		local acceptCount = 0
		for i, qid in pairs(part.Chapters[ch].id) do
			if C_QuestLog.IsOnQuest(qid) then
				complete = string.format("%s%s'%s'", complete, (string.len(complete) == 0 and "" or ", "), C_QuestLog.GetTitleForQuestID(qid) or "Unknown")
				completeCount = completeCount + 1
			elseif not self.QuestsCompleted[qid] then
				accept = string.format("%s%s'%s'", accept, (string.len(accept) == 0 and "" or ", "), C_QuestLog.GetTitleForQuestID(qid) or "Unknown")
				acceptCount = acceptCount + 1
			end
		end

		if acceptCount > 0 then frame.Instruction:SetText(string.format("Accept %s: %s", (acceptCount > 1 and "quests" or "quest"), accept)) end
		if completeCount > 0 then frame.Instruction:SetText(string.format("%s%sComplete %s: %s", frame.Instruction:GetText() or "", (acceptCount > 0 and "\n" or ""), (completeCount > 1 and "quests" or "quest"), complete))end
	elseif part.Chapters[ch].type == "external-cinematic" then
		frame.Instruction:SetText(string.format("This story cinematic must be viewed outside the game. Please copy the URL to watch the cinematic."))
		frame.ShowURL:Show()
		frame.Continue:Show()
	elseif part.Chapters[ch].type == "text" then
		frame.Instruction:SetText(string.format("Complete the instructions above to continue"))
	elseif part.Chapters[ch].type == "raid" then
		frame.Instruction:SetText(string.format("Enter the raid instance %s and defeat the encounter '%s'", part.Chapters[ch].name, part.Chapters[ch].final))
	elseif part.Chapters[ch].type == "level" then
		frame.Instruction:SetText(string.format("Reach level %d to continue the story", part.Chapters[ch].level ))
	elseif part.Chapters[ch].type == "recap" then
		frame.Content:Show()
		frame.Content.ButtonText:SetText("This part of the story is not available in game. Click here to read a recap in the MainScenario UI")
		MSAddon.Deeplink = { Tab = "tab1", Part = part.Id}
		frame.Content:SetScript("OnClick", function() MS_ToggleMainFrame() end)
		frame.Continue:Show()
		frame.ChapterTitle:Hide()
	elseif part.Chapters[ch].type == "ingame-cinematic" then
		frame.Content:Show()
		frame.Content.ButtonText:SetText("View cinematic")
		frame.Content:SetScript("OnClick", function() MovieFrame_PlayMovie(MovieFrame, part.Chapters[ch].id) end)
		frame.Continue:Show()
		frame.ChapterTitle:Hide()
	end
end

function MSAddon:StartCompletePartAndRemoveFrame(part)
	MSAddon:Log(string.format("Part name=%d id=%d is complete, removing from UI", part.DisplayNumber, part.Id))
	part.Frame.Complete:Show()
	part.Frame.ShowURL:Hide()
	part.Frame.Continue:Hide()
	part.Frame.Content:Hide()
	local group = part.Frame:CreateAnimationGroup()
	local animation = group:CreateAnimation("ALPHA")
	animation:SetFromAlpha(1)
	animation:SetToAlpha(0)
	animation:SetDuration(3)
	group:SetScript("OnFinished", function() MSAddon:FinishCompletePartAndRemoveFrame(part) end)
	group:Play()
end

function MSAddon:FinishCompletePartAndRemoveFrame(part)
	local frame = part.Frame
	frame:Hide()
	table.insert(MSAddon.TrackerFrame.UnusedPartFrames, frame)
	part.Frame = nil
	frame.Part = nil

	-- Reposition all frames
	MSAddon.TrackerFrame:SetHeight(MSAddon.TrackerFrame:GetHeight() - frame:GetHeight())
	local offset = MSAddon.TrackerFrame.Header:GetHeight()
	for i, frame in pairs(MSAddon.TrackerFrame.PartFrames) do
		if frame:IsVisible() then
			frame:SetPoint("TOPLEFT", 0, offset*-1)
			offset = offset + frame:GetHeight()
		end
	end
	MSAddon:AddNewActiveStoryParts()
	MSAddon:CreatePartFramesForActiveStoryParts()
end