function MSAddon:RegisterEventHandlers()
	MSAddon.TrackerFrame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
		MSAddon:Log(string.format("%s %s %s %s", event, tostring(arg1), tostring(arg2), tostring(arg3)))
		if event == "PLAYER_ENTERING_WORLD" then
			-- MS.inWorld = true
			-- if not MS.initialized then
			-- 	Init()
			-- end
		elseif event == "QUEST_WATCH_LIST_CHANGED" then
		elseif event == "QUEST_AUTOCOMPLETE" then
		elseif event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED" then
			MSAddon:HandleQuestAcceptedOrAbandoned(arg1)
		elseif event == "QUEST_TURNED_IN" then
			MSAddon:HandleQuestTurnedIn(arg1)
		elseif event == "ACHIEVEMENT_EARNED" then		
			MSAddon:HandleAchievementCompleted(arg1)
		elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then	
		elseif event == "PLAYER_LEVEL_UP" then		
			MSAddon:HandleLevelUp(arg1)
		elseif event == "GOSSIP_SHOW" then		
			--local title1, level1, isTrivial1, frequency1, isRepeatable1, isLegendary1, isIgnored1, questID1, ... = GetGossipAvailableQuests()
			--MSAddon:Log("GOSSIP_SHOW", GetGossipAvailableQuests())
			-- Use this to warn players about accepting quests that are ahead in the story
		end
	end)
	MSAddon.TrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	MSAddon.TrackerFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
	MSAddon.TrackerFrame:RegisterEvent("QUEST_ACCEPTED")
	MSAddon.TrackerFrame:RegisterEvent("QUEST_REMOVED")
	MSAddon.TrackerFrame:RegisterEvent("ACHIEVEMENT_EARNED")
	MSAddon.TrackerFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	MSAddon.TrackerFrame:RegisterEvent("ZONE_CHANGED")
	MSAddon.TrackerFrame:RegisterEvent("PLAYER_LEVEL_UP")
	MSAddon.TrackerFrame:RegisterEvent("GOSSIP_SHOW")
	MSAddon.TrackerFrame:RegisterEvent("QUEST_TURNED_IN")
	MSAddon.TrackerFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
end

function MSAddon:HandleQuestAcceptedOrAbandoned(qid)
	for i, part in pairs(MSAddon.ActiveStoryParts) do
		local ch = part.ActiveChapter
		MSAddon:Log(string.format("Quest %d accepted or removed: checking against active chapter %d.%d/%d", qid, part.Id, ch, #part.Chapters))
		if part.Chapters[ch].type == "quest" and part.Chapters[ch].id == qid then
			MSAddon:Log(string.format("Quest %d accepted or removed: relevant to part %d.%d", qid, part.Id, ch))
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MSAddon:SetPartFrameContent(part.Frame)
		elseif part.Chapters[ch].type == "multiquest" then
			for i, questId in pairs(part.Chapters[ch].id) do
				if questId == qid then
					MSAddon:Log(string.format("Quest %d accepted or removed: relevant to part %d.%d", qid, part.Id, ch))
					part.Frame.AnimationOverlay.FlashAnimation:Play()
					MSAddon:SetPartFrameContent(part.Frame)
				end
			end
		elseif part.Chapters[ch].type == "quest" and part.Chapters[ch].breadcrumbTo == qid then
			MSAddon:Log(string.format("Quest %d accepted or removed, this breadcrumb can be skipped %d.%d", qid, part.Id, ch))
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS_AdvanceChapter(part.Frame)
		elseif part.Chapters[ch].type == "quest-accept" and part.Chapters[ch].id == qid then
			MSAddon:Log(string.format("Quest %d accept only, advance to next chapter", qid, part.Id, ch))
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS_AdvanceChapter(part.Frame)
		end
	end
end

function MSAddon:HandleQuestTurnedIn(qid)
	--MS:AddNewActiveStoryParts()
	MSAddon:Log(string.format("Quest %d turned in", qid))
	self.QuestsCompleted[qid] = true
	for i, part in pairs(MSAddon.ActiveStoryParts) do
		local ch = part.ActiveChapter
		if part.Chapters[ch].type == "quest" and part.Chapters[ch].id == qid then
			MSAddon:Log(string.format("Quest %d turned in is relevant to part %d.%d", qid, part.DisplayNumber, ch))			
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS_AdvanceChapter(part.Frame)
		elseif part.Chapters[ch].type == "multiquest" then
			print("multiquest handed in - checking progress")
			local multiquestCompleted = 0
			for i, questId in pairs(part.Chapters[ch].id) do
				if self.QuestsCompleted[questId] then
					print(string.format("Quest %s is completed", questId))
					multiquestCompleted = multiquestCompleted + 1
				end
			end

			if multiquestCompleted == #part.Chapters[ch].id then		
				part.Frame.AnimationOverlay.FlashAnimation:Play()
				MS_AdvanceChapter(part.Frame)
			end
		end
	end
end

function MSAddon:HandleAchievementCompleted(aid)
end