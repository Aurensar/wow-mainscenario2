-- Prologue > Prepatch > Maw Intro > Oribos > Bastion > Maldraxxus > Ardenwewald > Revendreth
-- Choose Covenant > Chosen Covenant Chapter 1 > Covenant Maw Intro (Rules 1-3) > Finish Covenant Chapter 1
-- Torghast Intro (The Highlord Calls) (Rescue Baine) > Runecarver Intro (ends with The Weak Link quest)
-- In parallel:
    -- Covenant Chapter 2-9
    -- Non-selected Covenants Chapter 2-9
    -- Venari Rules 4-7
    -- Maw/Torghast Storyline [REMOVED] - [Explore Torghast] through [The Captive King] (+cinematics)
-- Raid: Castle Nathria > Sword Quest (Redemption for the Redeemer)
-- Patch 9.0 Ending
-- Patch 9.1 Intro Cinematic (Arthas+Archon)
-- Battle of Ardenweald (The First Move) > Maw Walkers > Focusing the Eye > The Last Sigil
-- In parallel
    -- Campaign: An Army of Bone and Steel > The Unseen Guests > The Power of Night > A New Path
    -- Raid: Sanctum of Domination (Storming the Sanctum)
-- Campaign: What Lies Ahead

local S = MSAddon:GetStringsTable()

MSAddon.StoryData[9] = 
{
    Title = "Shadowlands",
    Parts = {
        [10]={
            DisplayNumber = "1",
            Act = "Prologue",
            Name = "Shadowlands - The Story So Far",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return true end,
            Chapters = {               
                { type = "recap", name=S["sl-10-title"], button=S["sl-10-button"],
                  Sections = {
                      {title=S["sl-10-10-title"],text =S["sl-10-10-copy"]},
                  }
                },
                { type = "ingame-cinematic", id = 931, name = "931 Exile's Reach shipwreck Horde", text=""},
                { type = "ingame-cinematic", id = 932, name = "932 Uther backstory", text=""},
                { type = "ingame-cinematic", id = 933, name = "933 Denathrius/Revendreth intro", text=""},
                { type = "ingame-cinematic", id = 934, name = "934 Draka", text=""},
                { type = "ingame-cinematic", id = 935, name = "935 Ursoc", text=""},
                { type = "ingame-cinematic", id = 941, name = "941 halfway through Ardenweald campaign?", text=""},
                { type = "ingame-cinematic", id = 943, name = "943 quick intro to all 4 factions", text=""},
                { type = "ingame-cinematic", id = 944, name = "944 Revendreth outro", text=""},
                { type = "ingame-cinematic", id = 946, name = "946 Jailer and Sylvanas with Jaina and Thrall being tortured", text=""},
                { type = "ingame-cinematic", id = 947, name = "947 Arthas confronted by Sylvanas in Torghast", text=""},
                { type = "ingame-cinematic", id = 948, name = "948 9.0.1 ending - post raid", text=""},
            },
            IsComplete = function() return MSAddon:IsPartCompleted(9, 10) end,
        },
        [20]={
            DisplayNumber = "2",
            Act = "Prologue",
            Name = "The Shattering", 
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[10]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                
                { type = "ingame-cinematic", id = 936, name = "The Shattering", text=""},
            },
            IsComplete = function() return MSAddon:IsPartCompleted(9, 20)end,
            Recap = {
                {title=S["recap-09-20-10-title"],text =S["recap-09-20-10-copy"]},
                {title=S["recap-09-20-20-title"],text =S["recap-09-20-20-copy"]},     
            }
        },
        [30]={
            DisplayNumber = "3",
            Act = "Prologue",
            Name = "Prologue - Death Rising",
            Removed = true,
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[20]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                
                { type = "ingame-cinematic", id = 937, name = "Death Rising", text=""},
                { type = "ingame-cinematic", id = 942, name = "Fall of Nathanos", text=""},
            },
            Recap = {
                {title=S["recap-09-30-10-title"],text=S["recap-09-30-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsPartCompleted(9, 30) end,
        },
        [40]={
            DisplayNumber = "4",
            Act = "Prologue",
            Name = "Through the Shattered Sky",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MSAddon.StoryData[9].Parts[30]:IsComplete()  end,
            Chapters = {                
                { type = "quest", id = 60545},
                { type = "quest", id = 59751},
                { type = "multiquest", id = {59907, 59752}},
                { type = "quest", id = 59753},
                { type = "quest", id = 59914},
                { type = "quest", id = 59754},
                { type = "quest", id = 59755},
                { type = "quest", id = 59756},
                { type = "quest", id = 59757},
                { type = "quest", id = 59758},
                { type = "quest", id = 59915},
                { type = "quest", id = 59759},
                { type = "multiquest", id = {59760, 59761}},
                { type = "quest", id = 59776},
                { type = "quest", id = 59762},
                { type = "multiquest", id = {59765, 59766}},
                { type = "quest", id = 60644},
                { type = "quest", id = 59767}, -- The Path to Salvation
                { type = "quest", id = 59770}, -- Stand as One
            },
            Characters={
                "Jaina Proudmoore",
                "Darion Mograine",
                "Thrall",
                "Anduin Wrynn",
                "Sylvanas Windrunner",
                "Baine Bloodhoof",
                "The Jailer",
                "Helya",
                "Bolvar Fordragon",
            },
            Mentioned={
                "Tyrande Whisperwind",
            },
            Recap = {
                {title=S["recap-09-40-10-title"],text=S["recap-09-40-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(59770) end,
        },
        [50]={
            DisplayNumber = "5A",
            Act = "Prologue",
            Name = "Arrival in the Shadowlands",
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[40]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {          
               --{ type = "quest", id = 62704}, -- The Threads of Fate, option to skip story completely
                { type = "quest", id = 60129, hint="If you have completed the story before, you'll need to complete quest 'The Threads of Fate' first and choose not to skip the story."},
                { type = "quest", id = 60148},
                { type = "quest", id = 60149},
                { type = "ingame-cinematic", id = 945, name = "Audience with the Arbiter"},
                { type = "quest", id = 60150},
                { type = "quest", id = 60151},
                { type = "quest", id = 60152},
                { type = "quest", id = 60154},
                { type = "quest", id = 60156}, -- The Path to Bastion
            },
            Characters={
                "Overseer Kah-Sher",
                "Overseer Kah-Delen",
                "Tal-Inara, Honored Voice",
                "The Arbiter",
                "Bolvar Fordragon",
            },
            Mentioned={
                "The Jailer",
            },
            Recap = {
                {title=S["recap-09-50-10-title"],text=S["recap-09-50-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(60156) end,
        },
        [60]={
            DisplayNumber = "1",
            Act = "Act One: The Path to Ascension",
            Name = "Eternity's Call",
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[50]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                
                { type = "quest", id = 59773},
                { type = "quest", id = 59774},
                { type = "quest", id = 57102},
                { type = "quest", id = 57584},
                { type = "quest", id = 60735},
                { type = "quest", id = 57261},
                { type = "multiquest", id = {57676,57677}},
            },
            Characters={
                "Kleia",
                "Sika",
                "Greeter Mnemis",
                "Kalisthene",
                "Pelagos",
            },
            Mentioned={
                "Archon Kyrestia the Firstborne",
            },
            Recap = {
                {title=S["recap-09-60-10-title"],text=S["recap-09-60-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(57676) and MSAddon:IsQuestCompleted(57677) end,
        },
        [70]={
            DisplayNumber = "2",
            Act = "Act One: The Path to Ascension",
            Name = "The Aspirant's Crucible",
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[60]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                
                { type = "quest", id = 57709},
                { type = "quest", id = 57710},
                { type = "quest", id = 57711},
                { type = "multiquest", id = {57263,57267}},
                { type = "quest", id = 57265},
                { type = "quest", id = 59920},
                { type = "quest", id = 57713}, 
                { type = "quest", id = 57908}, 
                { type = "multiquest", id = {57909,57288}},
                { type = "quest", id = 57714}, 
                { type = "quest", id = 57291}, 
                { type = "quest", id = 57266}, 

                { type = "quest", id = 57715, eligibility="c:DEATHKNIGHT"}, -- The Archon's Answer, different quest for each class
                { type = "quest", id = 60217, eligibility="c:DEMONHUNTER|EVOKER"},
                { type = "quest", id = 60218, eligibility="c:DRUID"},
                { type = "quest", id = 60219, eligibility="c:HUNTER"},
                { type = "quest", id = 60220, eligibility="c:MAGE"},
                { type = "quest", id = 60221, eligibility="c:MONK"},
                { type = "quest", id = 60222, eligibility="c:PALADIN"},
                { type = "quest", id = 60223, eligibility="c:PRIEST"},
                { type = "quest", id = 60224, eligibility="c:ROGUE"},
                { type = "quest", id = 60225, eligibility="c:SHAMAN"},
                { type = "quest", id = 60226, eligibility="c:WARLOCK"},
                { type = "quest", id = 60229, eligibility="c:WARRIOR"},

                { type = "quest", id = 58174}, 
            },
            Characters={
                "Forgelite Sophone",
                "Kleia",
                "Pelagos",
                "Sika",
                "Kalisthene",
            },
            Mentioned={
                "Archon Kyrestia the Firstborne",
            },
            Recap = {
                {title=S["recap-09-70-10-title"],text=S["recap-09-70-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(58174) end,
        },
        [80]={
            DisplayNumber = "3",
            Act = "Act One: The Path to Ascension",
            Name = "The Temple of Purity",
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[70]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                
                { type = "quest", id = 57270},
                { type = "multiquest", id = {57977,57264}},
                { type = "quest", id = 57716},
                { type = "quest", id = 57717},
                { type = "multiquest", id = {57037,59147,57719}},
                { type = "quest", id = 57446},
                { type = "quest", id = 57269},
                { type = "quest", id = 57447},
            },
            Characters={
                { name=S["eridia-name"], title=S["eridia-09-80-title"], context=S["eridia-09-80-context"] },
                "Vesiphone, Paragon of Purity",
                "Kleia",
                "Pelagos",
                "Disciple Kosmas",
                "Nikolon",
                "Uther",
                "Lysonia, Hand of Doubt",
            },
            Mentioned={
            },
            Recap = {
                {title=S["recap-09-80-10-title"],text=S["recap-09-80-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(57447) end,
        },
        [90]={
            DisplayNumber = "4",
            Act = "Act One: The Path to Ascension",
            Name = "Chasing a Memory",
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[80]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                
                { type = "quest", id = 58976},
                { type = "multiquest", id = {58771,58799}},
                { type = "quest", id = 58800},
                { type = "quest", id = 58977},
                { type = "quest", id = 58978},
                { type = "quest", id = 58979},
                { type = "quest", id = 58980},
                { type = "quest", id = 58843},
                { type = "quest", id = 60180},
                { type = "quest", id = 60013},
            },
            Characters={
               
            },
            Mentioned={
               
            },
            Recap = {
                {title=S["recap-09-90-10-title"],text=S["recap-09-90-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(60013) end,
        },
        [100]={
            DisplayNumber = "5",
            Act = "Act One: The Path to Ascension",
            Name = "By the Archon's Will",
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[90]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                


                { type = "quest", id = 59200},
            },
            Characters={

            },
            Mentioned={
               
            },
            Recap = {
                {title=S["recap-09-100-10-title"],text=S["recap-09-100-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(59200) end,
        },
        [110]={
            DisplayNumber = "6",
            Act = "Act One: The Path to Ascension",
            Name = "The Temple of Courage",
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[100]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                


                { type = "quest", id = 60055},
            },
            Characters={

            },
            Mentioned={
               
            },
            Recap = {
                {title=S["recap-09-110-10-title"],text=S["recap-09-110-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(60055) end,
        },
        [120]={
            DisplayNumber = "7",
            Act = "Act One: The Path to Ascension",
            Name = "The Necrotic Wake",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MSAddon.StoryData[9].Parts[110]:IsComplete() end,
            Chapters = {                
                { type = "quest-accept", id = 60057},
                { type = "quest", id = 60057},
            },
            Characters={

            },
            Mentioned={
               
            },
            Recap = {
                {title=S["recap-09-120-10-title"],text=S["recap-09-120-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(60057) end,
        },
        [130]={
            DisplayNumber = "8",
            Act = "Act One: The Path to Ascension",
            Name = "Tidings of War",
            RequirementsMet = function() return MSAddon.StoryData[9].Parts[110]:IsComplete() end,
            RecommendationsMet = function() return MSAddon.StoryData[9].Parts[120]:IsComplete() end,
            Chapters = {                
         
                { type = "quest", id = 61107},
            },
            Characters={

            },
            Mentioned={
               
            },
            Recap = {
                {title=S["recap-09-130-10-title"],text=S["recap-09-130-10-copy"]},
            },
            IsComplete = function() return MSAddon:IsQuestCompleted(61107) end,
        },
    },
}

-- optional quests-
-- An Inspired Moral Inventory 57444 is avaialable during the Temple of purity chapter after "Step back from that ledge, my friend"