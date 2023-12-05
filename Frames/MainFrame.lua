local addonName, addon = ...
local AceGUI = LibStub("AceGUI-3.0")

function MSAddon:CreateMainFrame()

    local frame = AceGUI:Create("Frame")
    frame:SetLayout("Flow")
    frame:SetWidth(1200)
    frame:SetHeight(800)
    frame:SetTitle("World of Warcraft Story Database and Tracker")
    frame:Hide()

    local header = AceGUI:Create("SimpleGroup")
    header:SetFullWidth(true)
    header:SetHeight(100)
    header:SetLayout("Flow")
    frame:AddChild(header)

    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetList( {[1]="Classic", [2]="The Burning Crusade", [3]="Wrath of the Lich King", [4]="Cataclysm", [5]="Mists of Pandaria", [6]="Warlords of Draenor", [7]="Legion", [8]="Battle for Azeroth", [9]="Volume 9: Shadowlands",[10]="Dragonflight"})
    dropdown:SetValue(9)
    header:AddChild(dropdown)

    local changeStoryButton = AceGUI:Create("Button")
    changeStoryButton:SetText("Change Story")
    changeStoryButton:SetDisabled(true)
    changeStoryButton:SetWidth(150)
    header:AddChild(changeStoryButton)

    local tabs = AceGUI:Create("TabGroup")
    tabs:SetFullWidth(true)
    tabs:SetFullHeight(true)
    tabs:SetTabs({{text="Main Story", value="tab1"}, {text="Optional and Side Stories", value="tab2"}})
    tabs:SetLayout("Flow")
    tabs:SetCallback("OnGroupSelected", function(container, event, group) MSAddon:MainFrameSelectTab(container, event, group) end)
    frame:AddChild(tabs)

    MSAddon.ContentFrame = frame
    MSAddon.ContentFrame.Tabs = tabs

    -- do this properly later
    MSAddon.MainFrameSelectedVolume = 9
end

function MSAddon:MainFrameSelectTab(container, event, group)
    container:ReleaseChildren()
    if group == "tab1" then
         MSAddon:DrawMainFrame(container)
    elseif group == "tab2" then
        --DrawGroup2(container)
    end
end

function MSAddon:MainFrameSelectPart(container, event, group)
    --MSAddon:Log("container", container)
    --MSAddon:Log("event", event)
    --MSAddon:Log("group", group)
    container:ReleaseChildren()
    container:SetLayout("Flow")

    local scrollcontainer = AceGUI:Create("SimpleGroup") 
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) 
    scrollcontainer:SetLayout("Fill") 

    container:AddChild(scrollcontainer)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)
    
    local part = MSAddon.StoryData[MSAddon.MainFrameSelectedVolume].Parts[group]

    local header = AceGUI:Create("Label")
    header:SetText(string.format("%s, Part %s: %s", part.Act, part.DisplayNumber, part.Name))
    header:SetFullWidth(true)
    header:SetFont("Fonts\\FRIZQT__.TTF", 18, "")
    scroll:AddChild(header)

    local partStatus = AceGUI:Create("Label")
    partStatus:SetFullWidth(true)
    partStatus:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    local ps = MSAddon:GetPartStatus(MSAddon.MainFrameSelectedVolume, part)
    if ps == MSAddon.PartStatusEnum.Completed then partStatus:SetText("|cff00ff00You've completed this part of the story|r") end
    if ps == MSAddon.PartStatusEnum.Active then partStatus:SetText("|cFF0096FFYou're currently on this part of the story|r") end
    if ps == MSAddon.PartStatusEnum.Eligible then partStatus:SetText("|cFF800080You're ready to start this part of the story. Click this button to activate it in the tracker window|r") end
    if ps == MSAddon.PartStatusEnum.NotRecommended then partStatus:SetText("|cFFFFFF00This story part is available to start, but it is not recommended. Playing it now would result in the story being played out of order. If you want to play this part anyway, click the button to start.|r") end
    if ps == MSAddon.PartStatusEnum.NotAvailable then partStatus:SetText("|cFFFFA500Your character doesn't meet the requirements to play this part of the story yet. Try completing the recommended parts first|r") end
    scroll:AddChild(partStatus)

    if part.Removed then
        local partRemoved = AceGUI:Create("Label")
        partRemoved:SetFullWidth(true)
        partRemoved:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        partRemoved:SetText("|cFFFFA500This part of the story contains content that is no longer available to play in-game. Please write to Blizzard and/or your local elected representative and ask them to stop doing this so that the players can enjoy the entire story in-game! For the purposes of this addon, text recaps, ingame cinematics and links to external videos are still available.|r")
        scroll:AddChild(partRemoved)
    end

    if part.Recap and ps == MSAddon.PartStatusEnum.Completed then
        local recapGroup = AceGUI:Create("InlineGroup")
        recapGroup:SetFullWidth(true)
        recapGroup:SetLayout("Flow")

        local recapMainTitle = AceGUI:Create("Label")
        recapMainTitle:SetText("Recap")
        recapMainTitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
        recapMainTitle:SetFullWidth(true)
        recapGroup:AddChild(recapMainTitle)

        for i, recapPart in ipairs(part.Recap) do
            local recapTitle = AceGUI:Create("Label")
            recapTitle:SetText(recapPart.title)
            recapTitle:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
            recapTitle:SetFullWidth(true)
            recapGroup:AddChild(recapTitle)

            local recapText = AceGUI:Create("Label")
            recapText:SetText(recapPart.text)
            recapText:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
            recapText:SetFullWidth(true)
            recapGroup:AddChild(recapText)
        end

        scroll:AddChild(recapGroup)
    end

    local chapterCount = MSAddon:GetEligibleChapterCount(part)
    local chapterNumber = 0

    for i, chapter in pairs(part.Chapters) do
        if MSAddon:IsEligibleForChapter(chapter.eligibility) then
            chapter.index = i
            chapterNumber = chapterNumber + 1
            local chapterGroup = AceGUI:Create("InlineGroup")
            chapterGroup:SetFullWidth(true)
            chapterGroup:SetLayout("Flow")
    
            local chapterNumberLabel = AceGUI:Create("Label")
            chapterNumberLabel:SetText(string.format("Chapter %d of %d", chapterNumber, chapterCount))
            chapterNumberLabel:SetFont("Fonts\\FRIZQT__.TTF", 9, "")
            chapterNumberLabel:SetFullWidth(true)
            chapterGroup:AddChild(chapterNumberLabel)
    
            local chapterTitle = AceGUI:Create("Label")
            chapterTitle:SetText(MSAddon:GetChapterName(chapter))
            chapterTitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
            chapterTitle:SetWidth(500)
            chapterGroup:AddChild(chapterTitle)
    
            local chapterType = AceGUI:Create("Label")
            chapterType:SetText("Type: "..MSAddon:GetChapterDisplayType(chapter))
            chapterType:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
            chapterType:SetJustifyH("RIGHT")
            chapterGroup:AddChild(chapterType)
            
    
            if MSAddon:IsChapterCompleted(MSAddon.MainFrameSelectedVolume, group, chapter) then
            local completedMessage = AceGUI:Create("Label")
            completedMessage:SetText("|cff00ff00This chapter has been completed|r")
            completedMessage:SetFont("Fonts\\FRIZQT__.TTF", 9, "")
            chapterGroup:AddChild(completedMessage)
            end
    
            local spacer = AceGUI:Create("Label")
            spacer:SetText("")
            spacer:SetFullWidth(true)
            chapterGroup:AddChild(spacer)
    
    
            if chapter.type == "ingame-cinematic" then
                local cinematicLabel = AceGUI:Create("Label")
                cinematicLabel:SetText(chapter.text)
                cinematicLabel:SetFullWidth(true)
                chapterGroup:AddChild(cinematicLabel)
    
                local cinematicButton = AceGUI:Create("Button")
                cinematicButton:SetText("Play Cinematic")
                cinematicButton:SetHeight(30)
                cinematicButton:SetWidth(200)
                cinematicButton:SetCallback("OnClick", function() MSAddon:PlayCinematic(chapter.id) end)
                chapterGroup:AddChild(cinematicButton)            
            end
            scroll:AddChild(chapterGroup)
        end       
    end
end

function MSAddon:DrawMainFrame(container)
    scrollcontainer = AceGUI:Create("SimpleGroup")
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetLayout("Fill") -- important!

    container:AddChild(scrollcontainer)
    local treeData = { }
    local currentAct = ""

    for i, part in MSAddon:spairs(MSAddon.StoryData[MSAddon.MainFrameSelectedVolume].Parts) do

        print(string.format("part %s, current %s", part.Act, currentAct))
        if part.Act ~= currentAct then
            table.insert(treeData, { value = part.Act, text = string.format("%s", part.Act), icon = nil, disabled = true })
            currentAct = part.Act
        end

        local icon, disabled, visible, faded
        local ps = MSAddon:GetPartStatus(MSAddon.MainFrameSelectedVolume, part)
        if ps == MSAddon.PartStatusEnum.Completed then
            icon = "Interface\\Icons\\Achievement_quests_completed_uldum"
            faded = true
            visible = true
        elseif ps == MSAddon.PartStatusEnum.Active then
            icon = "Interface\\Icons\\Misc_arrowright"
            visible = true
        else
            -- if spoiler mode enabled, show the content
            visible = true
        end

        if visible then
            table.insert(treeData, { value = i, text = string.format("Part %s: %s", part.DisplayNumber, part.Name), icon = icon, disabled = disabled, faded = faded})
        end 
    end

    local tree = AceGUI:Create("TreeGroup")
    tree:SetFullHeight(true)
    tree:SetFullWidth(true)
    tree:SetTreeWidth(300)
    tree:SetTree(treeData)
    tree:SetCallback("OnGroupSelected", function(container, event, group) MSAddon:MainFrameSelectPart(container, event, group) end)
    scrollcontainer:AddChild(tree)

    local selectedPart
    if MSAddon.Deeplink then
        selectedPart = MSAddon.Deeplink.Part
    elseif MSAddon.ContentFrame.SelectedPart then
        selectedPart = MSAddon.ContentFrame.SelectedPart
    end

    if selectedPart then
        MSAddon:Log("Candidate selected part ID "..selectedPart)
        MSAddon.ContentFrame.SelectedPart = selectedPart
        tree:SelectByValue(selectedPart)
        MSAddon.Deeplink = nil
    end
end

function MS_ToggleMainFrame(frame)
    if not MSAddon.ContentFrame:IsVisible() then
        MSAddon.ContentFrame:Show()
    else
        MSAddon.ContentFrame:Hide()
    end  
    --local part = frame.Part
    --local ch = frame.Part.ActiveChapter
    MSAddon:RedrawMainFrame()
end

function MSAddon:RedrawMainFrame()
    local tab = "tab1"

    if MSAddon.Deeplink then
        tab = MSAddon.Deeplink.Tab
    elseif MSAddon.ContentFrame.SelectedTab then
        tab = MSAddon.ContentFrame.SelectedTab
    end

    MSAddon.ContentFrame.SelectedTab = tab
    MSAddon.ContentFrame.Tabs:SelectTab(tab)
end

function MSAddon:CalculateContentSectionHeight(copy)
    local height = 30
    local breaks = select(2, copy:gsub('\n', '\n'))
    height = height + (math.ceil(string.len(copy) / 110) * 15)
    height = height + (breaks * 10)
    MSAddon:Log(string.format("Calculate height len=%d breaks=%d lines=%d height=%d", string.len(copy), breaks, string.len(copy) / 110, height))
    return height
end

function MSAddon:PlayCinematic(movieId)
    MSAddon:Log("Play cinematic")
    MovieFrame_PlayMovie(MovieFrame, movieId)
end