-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Deteksi Parent GUI
local parentGui
pcall(function()
	if gethui then
		parentGui = gethui()
	elseif syn and syn.protect_gui then
		local gui = Instance.new("ScreenGui")
		syn.protect_gui(gui)
		parentGui = CoreGui
	else
		parentGui = LocalPlayer:WaitForChild("PlayerGui")
	end
end)
if not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

-- Hapus UI lama jika ada
if parentGui:FindFirstChild("CustomRobloxPanelUI") then
	parentGui.CustomRobloxPanelUI:Destroy()
end

-- Create ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomRobloxPanelUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

-- Tabel Penyimpanan Data Log (Untuk di-save ke .txt)
local savedLogsData = {}

---------------------------------------------------------
-- 1. COMPACT LOADING MODAL (0% - 100%)
---------------------------------------------------------
local LoadingCard = Instance.new("Frame")
LoadingCard.Name = "LoadingCard"
LoadingCard.Size = UDim2.new(0, 320, 0, 140)
LoadingCard.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingCard.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingCard.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
LoadingCard.BorderSizePixel = 0
LoadingCard.ZIndex = 100
LoadingCard.Parent = ScreenGui

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 10)
LoadingCorner.Parent = LoadingCard

local LoadingStroke = Instance.new("UIStroke")
LoadingStroke.Color = Color3.fromRGB(0, 162, 255)
LoadingStroke.Thickness = 1.5
LoadingStroke.Transparency = 0.3
LoadingStroke.Parent = LoadingCard

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(1, -20, 0, 22)
LoadingTitle.Position = UDim2.new(0, 10, 0, 8)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "sedang mendapatkan assets game"
LoadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingTitle.TextSize = 13
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.Parent = LoadingCard

-- Keterangan Game yang sedang di-get assets
local LoadingGameInfo = Instance.new("TextLabel")
LoadingGameInfo.Name = "LoadingGameInfo"
LoadingGameInfo.Size = UDim2.new(1, -20, 0, 18)
LoadingGameInfo.Position = UDim2.new(0, 10, 0, 28)
LoadingGameInfo.BackgroundTransparency = 1
LoadingGameInfo.Text = "Game: Mengambil data game..."
LoadingGameInfo.TextColor3 = Color3.fromRGB(0, 162, 255)
LoadingGameInfo.TextSize = 11
LoadingGameInfo.Font = Enum.Font.GothamMedium
LoadingGameInfo.TextTruncate = Enum.TextTruncate.AtEnd
LoadingGameInfo.Parent = LoadingCard

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -30, 0, 18)
StatusText.Position = UDim2.new(0, 15, 0, 48)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Memulai pemindaian..."
StatusText.TextColor3 = Color3.fromRGB(150, 155, 175)
StatusText.TextSize = 10
StatusText.Font = Enum.Font.Gotham
StatusText.TextTruncate = Enum.TextTruncate.AtEnd
StatusText.Parent = LoadingCard

local ProgressBackground = Instance.new("Frame")
ProgressBackground.Size = UDim2.new(1, -30, 0, 8)
ProgressBackground.Position = UDim2.new(0, 15, 0, 74)
ProgressBackground.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
ProgressBackground.BorderSizePixel = 0
ProgressBackground.Parent = LoadingCard

local ProgressBgCorner = Instance.new("UICorner")
ProgressBgCorner.CornerRadius = UDim.new(1, 0)
ProgressBgCorner.Parent = ProgressBackground

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBackground

local ProgressBarCorner = Instance.new("UICorner")
ProgressBarCorner.CornerRadius = UDim.new(1, 0)
ProgressBarCorner.Parent = ProgressBar

local PercentText = Instance.new("TextLabel")
PercentText.Size = UDim2.new(1, 0, 0, 20)
PercentText.Position = UDim2.new(0, 0, 0, 94)
PercentText.BackgroundTransparency = 1
PercentText.Text = "0%"
PercentText.TextColor3 = Color3.fromRGB(0, 162, 255)
PercentText.TextSize = 13
PercentText.Font = Enum.Font.GothamBold
PercentText.Parent = LoadingCard

---------------------------------------------------------
-- 2. MAIN PANEL UI
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 460)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 48, 65)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- TopBar / Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local PanelTitle = Instance.new("TextLabel")
PanelTitle.Size = UDim2.new(1, -90, 1, 0)
PanelTitle.Position = UDim2.new(0, 14, 0, 0)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Text = "SERIKA ENGINEERING TOOLS"
PanelTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
PanelTitle.TextSize = 13
PanelTitle.Font = Enum.Font.GothamBold
PanelTitle.TextXAlignment = Enum.TextXAlignment.Left
PanelTitle.Parent = TopBar

-- Tombol Minimize (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -62, 0.5, -12)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 5)
MinBtnCorner.Parent = MinimizeBtn

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 5)
CloseBtnCorner.Parent = CloseBtn

-- Tombol Restore (Buka Kembali Saat Minimize)
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Name = "RestoreBtn"
RestoreBtn.Size = UDim2.new(0, 110, 0, 34)
RestoreBtn.Position = UDim2.new(0, 20, 1, -54)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
RestoreBtn.Text = "Open Panel"
RestoreBtn.TextColor3 = Color3.fromRGB(0, 162, 255)
RestoreBtn.TextSize = 13
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.Visible = false
RestoreBtn.Parent = ScreenGui

local RestoreCorner = Instance.new("UICorner")
RestoreCorner.CornerRadius = UDim.new(0, 8)
RestoreCorner.Parent = RestoreBtn

local RestoreStroke = Instance.new("UIStroke")
RestoreStroke.Color = Color3.fromRGB(0, 162, 255)
RestoreStroke.Thickness = 1.5
RestoreStroke.Parent = RestoreBtn

-- Area Konten Utama
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -24, 1, -50)
ContentArea.Position = UDim2.new(0, 12, 0, 44)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentArea

-- 1. Card Judul Game
local GameCard = Instance.new("Frame")
GameCard.LayoutOrder = 1
GameCard.Size = UDim2.new(1, 0, 0, 40)
GameCard.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
GameCard.BorderSizePixel = 0
GameCard.Parent = ContentArea

local GameCardCorner = Instance.new("UICorner")
GameCardCorner.CornerRadius = UDim.new(0, 6)
GameCardCorner.Parent = GameCard

local GameLabelTitle = Instance.new("TextLabel")
GameLabelTitle.Size = UDim2.new(1, -20, 0, 14)
GameLabelTitle.Position = UDim2.new(0, 10, 0, 4)
GameLabelTitle.BackgroundTransparency = 1
GameLabelTitle.Text = "GAME TITLE"
GameLabelTitle.TextColor3 = Color3.fromRGB(0, 162, 255)
GameLabelTitle.TextSize = 10
GameLabelTitle.Font = Enum.Font.GothamBold
GameLabelTitle.TextXAlignment = Enum.TextXAlignment.Left
GameLabelTitle.Parent = GameCard

local GameNameText = Instance.new("TextLabel")
GameNameText.Size = UDim2.new(1, -20, 0, 18)
GameNameText.Position = UDim2.new(0, 10, 0, 18)
GameNameText.BackgroundTransparency = 1
GameNameText.Text = "Fetching game name..."
GameNameText.TextColor3 = Color3.fromRGB(240, 240, 245)
GameNameText.TextSize = 12
GameNameText.Font = Enum.Font.GothamMedium
GameNameText.TextXAlignment = Enum.TextXAlignment.Left
GameNameText.TextTruncate = Enum.TextTruncate.AtEnd
GameNameText.Parent = GameCard

task.spawn(function()
	local name = "Unknown Game"
	pcall(function()
		local info = MarketplaceService:GetProductInfo(game.PlaceId)
		if info and info.Name then name = info.Name end
	end)
	if name == "Unknown Game" and game.Name ~= "" then name = game.Name end
	GameNameText.Text = name
	LoadingGameInfo.Text = "Game: " .. name
end)

-- 2. Baris Tombol Get Assets & Get RemoteEvent
local ActionBtnsRow = Instance.new("Frame")
ActionBtnsRow.LayoutOrder = 2
ActionBtnsRow.Size = UDim2.new(1, 0, 0, 34)
ActionBtnsRow.BackgroundTransparency = 1
ActionBtnsRow.Parent = ContentArea

local GetAssetsBtn = Instance.new("TextButton")
GetAssetsBtn.Size = UDim2.new(0.49, 0, 1, 0)
GetAssetsBtn.Position = UDim2.new(0, 0, 0, 0)
GetAssetsBtn.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
GetAssetsBtn.Text = "Get Assets"
GetAssetsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetAssetsBtn.TextSize = 12
GetAssetsBtn.Font = Enum.Font.GothamBold
GetAssetsBtn.Parent = ActionBtnsRow

local AssetsCorner = Instance.new("UICorner")
AssetsCorner.CornerRadius = UDim.new(0, 6)
AssetsCorner.Parent = GetAssetsBtn

local AssetsStroke = Instance.new("UIStroke")
AssetsStroke.Color = Color3.fromRGB(0, 162, 255)
AssetsStroke.Thickness = 1
AssetsStroke.Transparency = 0.5
AssetsStroke.Parent = GetAssetsBtn

local GetRemotesBtn = Instance.new("TextButton")
GetRemotesBtn.Size = UDim2.new(0.49, 0, 1, 0)
GetRemotesBtn.Position = UDim2.new(0.51, 0, 0, 0)
GetRemotesBtn.BackgroundColor3 = Color3.fromRGB(38, 30, 52)
GetRemotesBtn.Text = "Get RemoteEvent"
GetRemotesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetRemotesBtn.TextSize = 12
GetRemotesBtn.Font = Enum.Font.GothamBold
GetRemotesBtn.Parent = ActionBtnsRow

local RemotesCorner = Instance.new("UICorner")
RemotesCorner.CornerRadius = UDim.new(0, 6)
RemotesCorner.Parent = GetRemotesBtn

local RemotesStroke = Instance.new("UIStroke")
RemotesStroke.Color = Color3.fromRGB(170, 0, 255)
RemotesStroke.Thickness = 1
RemotesStroke.Transparency = 0.5
RemotesStroke.Parent = GetRemotesBtn

-- 3. Baris Save Name As (TextBox + Tombol Save .txt)
local SaveRow = Instance.new("Frame")
SaveRow.Name = "SaveRow"
SaveRow.LayoutOrder = 3
SaveRow.Size = UDim2.new(1, 0, 0, 32)
SaveRow.BackgroundTransparency = 1
SaveRow.Parent = ContentArea

local FileNameInput = Instance.new("TextBox")
FileNameInput.Name = "FileNameInput"
FileNameInput.Size = UDim2.new(0.68, -4, 1, 0)
FileNameInput.Position = UDim2.new(0, 0, 0, 0)
FileNameInput.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
FileNameInput.PlaceholderText = "Ketik nama file (opsional)..."
FileNameInput.PlaceholderColor3 = Color3.fromRGB(120, 125, 145)
FileNameInput.Text = ""
FileNameInput.TextColor3 = Color3.fromRGB(240, 240, 245)
FileNameInput.TextSize = 11
FileNameInput.Font = Enum.Font.GothamMedium
FileNameInput.ClearTextOnFocus = false
FileNameInput.Parent = SaveRow

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = FileNameInput

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(45, 48, 65)
InputStroke.Thickness = 1
InputStroke.Parent = FileNameInput

local SaveFileBtn = Instance.new("TextButton")
SaveFileBtn.Name = "SaveFileBtn"
SaveFileBtn.Size = UDim2.new(0.32, 0, 1, 0)
SaveFileBtn.Position = UDim2.new(0.68, 0, 0, 0)
SaveFileBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
SaveFileBtn.Text = "Save .txt"
SaveFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveFileBtn.TextSize = 11
SaveFileBtn.Font = Enum.Font.GothamBold
SaveFileBtn.Parent = SaveRow

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 6)
SaveCorner.Parent = SaveFileBtn

-- 4. Baris Search / Find Box & Tombol Clear Logs
local FilterRow = Instance.new("Frame")
FilterRow.Name = "FilterRow"
FilterRow.LayoutOrder = 4
FilterRow.Size = UDim2.new(1, 0, 0, 32)
FilterRow.BackgroundTransparency = 1
FilterRow.Parent = ContentArea

local SearchInput = Instance.new("TextBox")
SearchInput.Name = "SearchInput"
SearchInput.Size = UDim2.new(0.68, -4, 1, 0)
SearchInput.Position = UDim2.new(0, 0, 0, 0)
SearchInput.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
SearchInput.PlaceholderText = "Find in logs (cari nama / path)..."
SearchInput.PlaceholderColor3 = Color3.fromRGB(120, 125, 145)
SearchInput.Text = ""
SearchInput.TextColor3 = Color3.fromRGB(0, 220, 255)
SearchInput.TextSize = 11
SearchInput.Font = Enum.Font.GothamMedium
SearchInput.ClearTextOnFocus = false
SearchInput.Parent = FilterRow

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchInput

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = Color3.fromRGB(0, 162, 255)
SearchStroke.Thickness = 1
SearchStroke.Transparency = 0.6
SearchStroke.Parent = SearchInput

local ClearLogsBtn = Instance.new("TextButton")
ClearLogsBtn.Name = "ClearLogsBtn"
ClearLogsBtn.Size = UDim2.new(0.32, 0, 1, 0)
ClearLogsBtn.Position = UDim2.new(0.68, 0, 0, 0)
ClearLogsBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 55)
ClearLogsBtn.Text = "Clear Logs"
ClearLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearLogsBtn.TextSize = 11
ClearLogsBtn.Font = Enum.Font.GothamBold
ClearLogsBtn.Parent = FilterRow

local ClearLogsCorner = Instance.new("UICorner")
ClearLogsCorner.CornerRadius = UDim.new(0, 6)
ClearLogsCorner.Parent = ClearLogsBtn

-- 5. Label Header Log
local LogHeader = Instance.new("TextLabel")
LogHeader.LayoutOrder = 5
LogHeader.Size = UDim2.new(1, 0, 0, 16)
LogHeader.BackgroundTransparency = 1
LogHeader.Text = "LIVE PANEL LOGS (0 ITEMS):"
LogHeader.TextColor3 = Color3.fromRGB(150, 155, 175)
LogHeader.TextSize = 10
LogHeader.Font = Enum.Font.GothamBold
LogHeader.TextXAlignment = Enum.TextXAlignment.Left
LogHeader.Parent = ContentArea

-- 6. Scrolling Frame untuk Live Log
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Name = "LogScroll"
LogScroll.LayoutOrder = 6
LogScroll.Size = UDim2.new(1, 0, 1, -196)
LogScroll.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 4
LogScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = ContentArea

local LogScrollCorner = Instance.new("UICorner")
LogScrollCorner.CornerRadius = UDim.new(0, 6)
LogScrollCorner.Parent = LogScroll

local LogLayout = Instance.new("UIListLayout")
LogLayout.Padding = UDim.new(0, 6)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Parent = LogScroll

LogLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 10)
end)

-- Resize Grip Pointer
local ResizeGrip = Instance.new("ImageLabel")
ResizeGrip.Name = "ResizeGrip"
ResizeGrip.Size = UDim2.new(0, 14, 0, 14)
ResizeGrip.Position = UDim2.new(1, -16, 1, -16)
ResizeGrip.BackgroundTransparency = 1
ResizeGrip.Image = "rbxassetid://6035047409"
ResizeGrip.ImageColor3 = Color3.fromRGB(130, 135, 155)
ResizeGrip.ZIndex = 10
ResizeGrip.Parent = MainFrame

---------------------------------------------------------
-- 3. FUNGSI PEMBUAT ITEM LOG & PENCARIAN
---------------------------------------------------------
local logCount = 0

local function updateHeaderCount()
	LogHeader.Text = "LIVE PANEL LOGS (" .. logCount .. " ITEMS):"
end

-- Logika Filter Pencarian Log
local function filterLogs()
	local query = string.lower(SearchInput.Text)
	for _, item in ipairs(LogScroll:GetChildren()) do
		if item:IsA("Frame") then
			if query == "" then
				item.Visible = true
			else
				local matched = false
				for _, lbl in ipairs(item:GetChildren()) do
					if lbl:IsA("TextLabel") and string.find(string.lower(lbl.Text), query, 1, true) then
						matched = true
						break
					end
				end
				item.Visible = matched
			end
		end
	end
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(filterLogs)

-- Fungsi menampilkan log ke UI sekaligus menyimpannya ke tabel save
local function createLogEntry(titleText, titleColor, pathString, infoString, remoteObj, method, args)
	logCount += 1
	updateHeaderCount()

	local logRecord = string.format("[%d] %s | Path: %s | Info: %s", logCount, titleText, pathString, infoString or "N/A")
	table.insert(savedLogsData, logRecord)

	local logItem = Instance.new("Frame")
	logItem.Name = "LogItem_" .. logCount
	logItem.Size = UDim2.new(1, -8, 0, 72)
	logItem.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
	logItem.BorderSizePixel = 0
	logItem.Parent = LogScroll

	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 6)
	itemCorner.Parent = logItem

	local itemStroke = Instance.new("UIStroke")
	itemStroke.Color = Color3.fromRGB(40, 44, 60)
	itemStroke.Thickness = 1
	itemStroke.Parent = logItem

	local remoteTitle = Instance.new("TextLabel")
	remoteTitle.Size = UDim2.new(1, -12, 0, 16)
	remoteTitle.Position = UDim2.new(0, 8, 0, 4)
	remoteTitle.BackgroundTransparency = 1
	remoteTitle.Text = titleText
	remoteTitle.TextColor3 = titleColor or Color3.fromRGB(0, 162, 255)
	remoteTitle.TextSize = 11
	remoteTitle.Font = Enum.Font.GothamBold
	remoteTitle.TextXAlignment = Enum.TextXAlignment.Left
	remoteTitle.TextTruncate = Enum.TextTruncate.AtEnd
	remoteTitle.Parent = logItem

	local pathLabel = Instance.new("TextLabel")
	pathLabel.Size = UDim2.new(1, -12, 0, 14)
	pathLabel.Position = UDim2.new(0, 8, 0, 20)
	pathLabel.BackgroundTransparency = 1
	pathLabel.Text = "Path: " .. pathString
	pathLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	pathLabel.TextSize = 10
	pathLabel.Font = Enum.Font.Code
	pathLabel.TextXAlignment = Enum.TextXAlignment.Left
	pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
	pathLabel.Parent = logItem

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -12, 0, 14)
	infoLabel.Position = UDim2.new(0, 8, 0, 34)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = infoString or ""
	infoLabel.TextColor3 = Color3.fromRGB(140, 145, 165)
	infoLabel.TextSize = 10
	infoLabel.Font = Enum.Font.Code
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.TextTruncate = Enum.TextTruncate.AtEnd
	infoLabel.Parent = logItem

	local copyBtn = Instance.new("TextButton")
	copyBtn.Size = UDim2.new(0, 75, 0, 16)
	copyBtn.Position = UDim2.new(0, 8, 0, 50)
	copyBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	copyBtn.Text = "Copy Path"
	copyBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
	copyBtn.TextSize = 9
	copyBtn.Font = Enum.Font.GothamBold
	copyBtn.Parent = logItem

	local copyCorner = Instance.new("UICorner")
	copyCorner.CornerRadius = UDim.new(0, 4)
	copyCorner.Parent = copyBtn

	copyBtn.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(pathString)
			copyBtn.Text = "Copied!"
		else
			print("[PATH]: " .. pathString)
			copyBtn.Text = "Printed!"
		end
		task.wait(1.2)
		copyBtn.Text = "Copy Path"
	end)

	if remoteObj and (remoteObj:IsA("RemoteEvent") or remoteObj:IsA("RemoteFunction")) then
		local fireBtn = Instance.new("TextButton")
		fireBtn.Size = UDim2.new(0, 75, 0, 16)
		fireBtn.Position = UDim2.new(0, 88, 0, 50)
		fireBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
		fireBtn.Text = "Fire Event"
		fireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		fireBtn.TextSize = 9
		fireBtn.Font = Enum.Font.GothamBold
		fireBtn.Parent = logItem

		local fireCorner = Instance.new("UICorner")
		fireCorner.CornerRadius = UDim.new(0, 4)
		fireCorner.Parent = fireBtn

		fireBtn.MouseButton1Click:Connect(function()
			pcall(function()
				if remoteObj:IsA("RemoteEvent") then
					if args then remoteObj:FireServer(unpack(args)) else remoteObj:FireServer() end
				elseif remoteObj:IsA("RemoteFunction") then
					if args then remoteObj:InvokeServer(unpack(args)) else remoteObj:InvokeServer() end
				end
			end)
			fireBtn.Text = "Fired!"
			task.wait(1)
			fireBtn.Text = "Fire Event"
		end)
	end

	-- Periksa filter saat ini jika sedang melakukan pencarian
	local query = string.lower(SearchInput.Text)
	if query ~= "" then
		local combined = string.lower(titleText .. " " .. pathString .. " " .. (infoString or ""))
		if not string.find(combined, query, 1, true) then
			logItem.Visible = false
		end
	end
end

-- Fungsi pembantu untuk Remote Spy
local function addRemoteLog(remoteInstance, method, args)
	local argString = ""
	if args then
		for i, arg in ipairs(args) do
			argString = argString .. tostring(arg) .. (i < #args and ", " or "")
		end
	end
	if argString == "" then argString = "No Args" end

	createLogEntry(
		"[" .. method .. "] " .. remoteInstance.Name,
		Color3.fromRGB(0, 200, 255),
		remoteInstance:GetFullName(),
		"Args: {" .. argString .. "}",
		remoteInstance,
		method,
		args
	)
end

---------------------------------------------------------
-- 4. LOGIC TOMBOL GET ASSETS, REMOTES, CLEAR & SAVE .TXT
---------------------------------------------------------
-- Tombol Clear Logs
ClearLogsBtn.MouseButton1Click:Connect(function()
	for _, child in ipairs(LogScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	table.clear(savedLogsData)
	logCount = 0
	updateHeaderCount()
	ClearLogsBtn.Text = "Cleared!"
	task.wait(1)
	ClearLogsBtn.Text = "Clear Logs"
end)

-- Tombol Get Assets
GetAssetsBtn.MouseButton1Click:Connect(function()
	GetAssetsBtn.Text = "Scanning..."
	task.wait()
	local count = 0
	local maxDisplay = 150

	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("MeshPart") or v:IsA("SpecialMesh") or v:IsA("Decal") or v:IsA("Texture") or v:IsA("Sound") then
			count += 1
			local fullPath = v:GetFullName()
			if count <= maxDisplay then
				createLogEntry(
					"[ASSET - " .. v.ClassName .. "] " .. v.Name,
					Color3.fromRGB(80, 220, 140),
					fullPath,
					"Class: " .. v.ClassName,
					nil
				)
			else
				table.insert(savedLogsData, string.format("[%d] [ASSET - %s] %s | Path: %s", count, v.ClassName, v.Name, fullPath))
			end
			if count % 50 == 0 then task.wait() end
		end
	end

	GetAssetsBtn.Text = "Loaded " .. count .. " Assets!"
	task.wait(1.5)
	GetAssetsBtn.Text = "Get Assets"
end)

-- Tombol Get RemoteEvent
GetRemotesBtn.MouseButton1Click:Connect(function()
	GetRemotesBtn.Text = "Scanning..."
	task.wait()
	local count = 0

	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			count += 1
			local methodType = v:IsA("RemoteEvent") and "FireServer" or "InvokeServer"
			createLogEntry(
				"[REMOTE - " .. v.ClassName .. "] " .. v.Name,
				Color3.fromRGB(190, 100, 255),
				v:GetFullName(),
				"Ready to Fire (" .. methodType .. ")",
				v,
				methodType,
				{}
			)
			if count % 30 == 0 then task.wait() end
		end
	end

	GetRemotesBtn.Text = "Loaded " .. count .. " Remotes!"
	task.wait(1.5)
	GetRemotesBtn.Text = "Get RemoteEvent"
end)

-- Tombol Save ke File .txt
SaveFileBtn.MouseButton1Click:Connect(function()
	local rawName = FileNameInput.Text
	
	-- Jika textbox kosong, buat default: Nama Game + Tanggal + Jam
	if not rawName or rawName:match("^%s*$") then
		local gName = GameNameText.Text
		if not gName or gName == "" or gName == "Fetching game name..." or gName == "Unknown Game" then
			gName = "Place_" .. tostring(game.PlaceId)
		end
		local dateTime = os.date("%Y-%m-%d_%H-%M-%S")
		rawName = gName .. "_" .. dateTime
	end

	-- Bersihkan karakter ilegal untuk nama file dan pastikan ekstensi .txt
	rawName = rawName:gsub("[\\/:*?\"<>|]", "_")
	if not rawName:lower():match("%.txt$") then
		rawName = rawName .. ".txt"
	end

	if #savedLogsData == 0 then
		SaveFileBtn.Text = "Log Kosong!"
		task.wait(1.5)
		SaveFileBtn.Text = "Save .txt"
		return
	end

	local header = "========================================\n"
		.. "GAME: " .. GameNameText.Text .. " (PlaceId: " .. tostring(game.PlaceId) .. ")\n"
		.. "SAVED AT: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
		.. "TOTAL LOGS: " .. tostring(#savedLogsData) .. "\n"
		.. "========================================\n\n"

	local fullContent = header .. table.concat(savedLogsData, "\n")

	if writefile then
		local success, err = pcall(function()
			writefile(rawName, fullContent)
		end)
		if success then
			SaveFileBtn.Text = "Saved: " .. rawName
		else
			SaveFileBtn.Text = "Error Save!"
			warn("Gagal menyimpan file:", err)
		end
	elseif setclipboard then
		setclipboard(fullContent)
		SaveFileBtn.Text = "Copied (No writefile)"
	else
		print(fullContent)
		SaveFileBtn.Text = "Printed to F9"
	end

	task.wait(2)
	SaveFileBtn.Text = "Save .txt"
end)

---------------------------------------------------------
-- 5. HOOK REMOTE SPY
---------------------------------------------------------
task.spawn(function()
	local hooked = false

	pcall(function()
		if hookmetamethod and getnamecallmethod then
			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
					local args = {...}
					task.spawn(function()
						addRemoteLog(self, method, args)
					end)
				end
				return oldNamecall(self, ...)
			end)
			hooked = true
		end
	end)

	if not hooked then
		pcall(function()
			local rawmeta = getrawmetatable and getrawmetatable(game)
			local setreadonly = setreadonly or make_writeable
			if rawmeta and setreadonly then
				setreadonly(rawmeta, false)
				local oldNamecall = rawmeta.__namecall
				local wrap = newcclosure or function(f) return f end
				rawmeta.__namecall = wrap(function(self, ...)
					local method = getnamecallmethod and getnamecallmethod() or ""
					if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
						local args = {...}
						task.spawn(function()
							addRemoteLog(self, method, args)
						end)
					end
					return oldNamecall(self, ...)
				end)
				setreadonly(rawmeta, true)
				hooked = true
			end
		end)
	end

	if hooked then
		createLogEntry(
			"[SYSTEM] Remote Spy Active",
			Color3.fromRGB(0, 255, 150),
			"hookmetamethod / __namecall",
			"Klik 'Get Assets' atau 'Get RemoteEvent' untuk memuat daftar.",
			nil
		)
	else
		createLogEntry(
			"[SYSTEM] Ready",
			Color3.fromRGB(255, 180, 50),
			"Mode Scanner Aktif",
			"Gunakan tombol di atas untuk scan assets atau remotes.",
			nil
		)
	end
end)

---------------------------------------------------------
-- 6. INTERAKSI UI (Drag, Resize, Minimize, Close)
---------------------------------------------------------
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- Resize Panel
local resizing = false
local resizeStartPos, startSize
local MIN_WIDTH, MIN_HEIGHT = 340, 340

ResizeGrip.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		resizeStartPos = UserInputService:GetMouseLocation()
		startSize = MainFrame.AbsoluteSize

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then resizing = false end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mousePos = UserInputService:GetMouseLocation()
		local delta = mousePos - resizeStartPos

		local newWidth = math.max(MIN_WIDTH, startSize.X + delta.X)
		local newHeight = math.max(MIN_HEIGHT, startSize.Y + delta.Y)

		MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
	end
end)

-- Minimize & Close Logic
MinimizeBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	RestoreBtn.Visible = true
end)

RestoreBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	RestoreBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

---------------------------------------------------------
-- 7. REAL LOADING GAME ASSETS (0% - 100%)
---------------------------------------------------------
task.spawn(function()
	local assetsToLoad = {}

	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("MeshPart") or obj:IsA("Sound") or obj:IsA("SpecialMesh") then
			table.insert(assetsToLoad, obj)
		end
	end

	local total = #assetsToLoad
	if total == 0 then total = 1 table.insert(assetsToLoad, workspace) end

	local loadedCount = 0
	local maxPreload = math.min(total, 200)

	for i = 1, maxPreload do
		local asset = assetsToLoad[i]
		pcall(function()
			ContentProvider:PreloadAsync({asset})
		end)
		loadedCount += 1

		local percentage = math.clamp(math.floor((loadedCount / maxPreload) * 100), 0, 100)
		
		ProgressBar.Size = UDim2.new(percentage / 100, 0, 1, 0)
		PercentText.Text = percentage .. "%"
		StatusText.Text = "Loading: " .. asset.Name

		if loadedCount % 5 == 0 then task.wait() end
	end

	if not game:IsLoaded() then game.Loaded:Wait() end

	StatusText.Text = "Selesai!"
	PercentText.Text = "100%"
	ProgressBar.Size = UDim2.new(1, 0, 1, 0)
	task.wait(0.3)

	local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for _, elem in ipairs(LoadingCard:GetDescendants()) do
		if elem:IsA("TextLabel") then
			TweenService:Create(elem, fadeInfo, {TextTransparency = 1}):Play()
		elseif elem:IsA("Frame") then
			TweenService:Create(elem, fadeInfo, {BackgroundTransparency = 1}):Play()
		elseif elem:IsA("UIStroke") then
			TweenService:Create(elem, fadeInfo, {Transparency = 1}):Play()
		end
	end

	local fadeCard = TweenService:Create(LoadingCard, fadeInfo, {BackgroundTransparency = 1})
	fadeCard:Play()
	fadeCard.Completed:Connect(function()
		LoadingCard:Destroy()
		MainFrame.Visible = true
	end)
end)