local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
	Title = "Anura Gaming | https://discord.gg/FPqaFFZCN6",
	Subtitle = "Đăng kí kênh Youtube: Anura Gaming",
	Size = UDim2.fromOffset(730, 460),
	DragStyle = 1,
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true,
})

-- Cài đặt toàn cục
local globalSettings = {
	UIBlurToggle = Window:GlobalSetting({
		Name = "UI Blur",
		Default = Window:GetAcrylicBlurState(),
		Callback = function(bool)
			Window:SetAcrylicBlurState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
				Lifetime = 5
			})
		end,
	}),
	NotificationToggler = Window:GlobalSetting({
		Name = "Notifications",
		Default = Window:GetNotificationsState(),
		Callback = function(bool)
			Window:SetNotificationsState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Enabled" or "Disabled") .. " Notifications",
				Lifetime = 5
			})
		end,
	}),
	ShowUserInfo = Window:GlobalSetting({
		Name = "Show User Info",
		Default = Window:GetUserInfoState(),
		Callback = function(bool)
			Window:SetUserInfoState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Showing" or "Redacted") .. " User Info",
				Lifetime = 5
			})
		end,
	})
}

-- Tạo Tabs
local tabGroups = { TabGroup1 = Window:TabGroup() }
local tabs = { Main = tabGroups.TabGroup1:Tab({ Name = "Full Moon", Image = "rbxassetid://18821914323" }) }
local sections = { MainSection1 = tabs.Main:Section({ Side = "Left" }), MainSection2 = tabs.Main:Section({ Side = "Right" }) }

-- Hàm lấy danh sách JobId từ API
local jobIds, TS = {}, 0
local function scrapeAPI()
    local success, response = pcall(function()
        return request({ Url = "https://hostserver.porry.store/bloxfruit/bot/JobId/fullmoon", Method = "GET" })
    end)

    if success and response.Success then
        local data = game.HttpService:JSONDecode(response.Body)
        if data.Amount and data.Amount > 0 then
            local newJobIds = {}
            for _, job in ipairs(data.JobId) do
                for jobId, _ in pairs(job) do
                    table.insert(newJobIds, jobId)
                end
            end
            TS = tick()
            return newJobIds
        end
    end
    
    return "Failed"
end

-- UI chính
sections.MainSection1:Header({ Name = "Full Moon Hopper" })

-- Tự động tìm server
sections.MainSection1:Button({
    Name = "Auto Hop Server",
    Callback = function()
        if tick() - TS > 100 then
            jobIds = scrapeAPI()
            if jobIds == "Failed" then
                return Window:Notify({ Title = Window.Settings.Title, Description = "Failed to scrape API.", Lifetime = 5 })
            end
        end

        spawn(function()
            for _, jobId in ipairs(jobIds) do
                game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", jobId)
                wait(5)
            end
        end)
    end    
})

-- Chuyển đến server đã chọn
local ChoosenID
sections.MainSection1:Button({
    Name = "Hop To Choosen Server",
    Callback = function()
        if not ChoosenID then
            return Window:Notify({ Title = Window.Settings.Title, Description = "No server selected!", Lifetime = 5 })
        end
        
        if tick() - TS > 100 then
            Window:Dialog({
                Title = Window.Settings.Title,
                Description = "It seems like the JobID is outdated. Would you like to refresh the server list and then hop?",
                Buttons = {
                    { Name = "Yes, refresh and TP", Callback = function()
                        jobIds = scrapeAPI()
                        if jobIds ~= "Failed" then
                            ChoosenID = jobIds[math.random(#jobIds)]
                            game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", ChoosenID)
                        else
                            Window:Notify({ Title = Window.Settings.Title, Description = "Failed to scrape API.", Lifetime = 5 })
                        end
                    end },
                    { Name = "No, keep TP", Callback = function()
                        game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", ChoosenID)
                    end }
                }
            })
        else
            game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", ChoosenID)
        end
    end
})

-- Làm mới danh sách server
local Dropdown
sections.MainSection1:Button({
    Name = "Refresh Server List",
    Callback = function()
        jobIds = scrapeAPI()
        if jobIds ~= "Failed" then
            local newID = jobIds[math.random(#jobIds)]
            Dropdown:ClearOptions()
            Dropdown:InsertOptions(jobIds)
            Dropdown:UpdateSelection(newID)
            ChoosenID = newID
        else
            Window:Notify({ Title = Window.Settings.Title, Description = "Failed to scrape API.", Lifetime = 5 })
        end
    end
})

-- Dropdown chọn server
Dropdown = sections.MainSection1:Dropdown({
    Name = "Servers",
    Multi = false,
    Required = true,
    Options = jobIds ~= "Failed" and jobIds or {},
    Default = 1,
    Callback = function(Value)
        ChoosenID = Value
    end
}, "Dropdown")

-- Phần thông tin
sections.MainSection2:Paragraph({
    Header = "Tại sao anh còn thương em mãi",
    Body = "Nhưng lòng đau thì ai có hay"
})

sections.MainSection2:Label({ Text = "@anura_v4 ( Kênh Tiktok, Youtube có hướng dẫn hack )." })

sections.MainSection2:SubLabel({ Text = "Hãy làm SKY đi, đom đóm con như lol. @anura_gaming" })

-- Cấu hình thư mục lưu trữ
MacLib:SetFolder("MacLib")

Window.onUnloaded(function()
    print("Unloaded!")
end)

tabs.Main:Select()
