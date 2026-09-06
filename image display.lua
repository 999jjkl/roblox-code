local TweenService = game:GetService("TweenService")

-- find screen part
local model = script.Parent
local screenPart = nil
if not screenPart then
	if model.Name == "screen" then
		screenPart = model
	else
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name == "screen" and obj:IsA("BasePart") then
				screenPart = obj
				break
			end
		end
	end
end
if not screenPart then
	error(spawn.ID,":screen part not found")
	return
else
	print(spawn.ID,"The World")	
end

-- lock all part
local tvBody = screenPart.Parent
if tvBody and tvBody:IsA("Model") then
	for _, part in ipairs(tvBody:GetChildren()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
end

-- 屬性
screenPart.Transparency = 1
screenPart.CanCollide = true
screenPart.Anchored = true

--SurfaceGui
local function createSurfaceGui(name, face)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = name
	surfaceGui.Face = face
	surfaceGui.LightInfluence = 0
	surfaceGui.AlwaysOnTop = false
	surfaceGui.MaxDistance = 0          -- no limit 
	surfaceGui.ClipsDescendants = true
	surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	surfaceGui.PixelsPerStud = 80       -- 1px = 1 stud 
	surfaceGui.Parent = screenPart

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ImageDisplay"
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.Position = UDim2.new(0, 0, 0, 0) --lock in center
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.ImageTransparency = 1    --Transparency
	imageLabel.Parent = surfaceGui

	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 16/12
	aspect.AspectType = Enum.AspectType.FitWithinMaxSize
	aspect.DominantAxis = Enum.DominantAxis.Width
	aspect.Parent = imageLabel

	return imageLabel
end

local displayFace = Enum.NormalId.Back

local currentImage = createSurfaceGui("CurrentImage", displayFace)
local nextImage = createSurfaceGui("NextImage", displayFace)
nextImage.Visible = true

--image list (put your png id here)
local imageIds = {
	"rbxassetid://123775199919008",
	"rbxassetid://7669757647",
}

warn(spawn.ID,": image list:",imageIds)
-- if no image in list use default image
local DEFAULT_IMAGE = "rbxassetid://16871544939"

local currentIndex = 1
local isTransitioning = false

--image change
local function transitionToImage(nextIndex)
	if isTransitioning then return end

	-- if list not have image use default image and stop
	if #imageIds == 0 then
		currentImage.Image = DEFAULT_IMAGE
		currentImage.ImageTransparency = 0
		currentImage.Position = UDim2.new(0, 0, 0, 0)
		warn(spawn.ID,":png lest is empty, display default image: " .. DEFAULT_IMAGE)
		return
	end

	if nextIndex < 1 or nextIndex > #imageIds then return end
	if nextIndex == currentIndex then return end

	isTransitioning = true

	-- set next image
	nextImage.Image = imageIds[nextIndex]
	nextImage.ImageTransparency = 1
	nextImage.Position = UDim2.new(0, 0, 0, 0)

	-- make sure current image is visible and at center
	currentImage.Position = UDim2.new(0, 0, 0, 0)
	currentImage.ImageTransparency = 0

	-- tween current image out and next image in parallel with tweening position 
	local tweenInfo = TweenInfo.new(
		1.5,                    -- time in seconds 
		Enum.EasingStyle.Sine,  -- ease style 
		Enum.EasingDirection.InOut
	)

	local fadeOutTween = TweenService:Create(currentImage, tweenInfo, {
		ImageTransparency = 1
	})

	local fadeInTween = TweenService:Create(nextImage, tweenInfo, {
		ImageTransparency = 0
	})

	fadeOutTween:Play()
	fadeInTween:Play()

	local connection
	connection = fadeInTween.Completed:Connect(function()
		connection:Disconnect()

		-- reset current image for next cycle 
		currentImage.Image = nextImage.Image
		currentImage.ImageTransparency = 0
		currentImage.Position = UDim2.new(0, 0, 0, 0)

		nextImage.ImageTransparency = 1
		nextImage.Position = UDim2.new(0, 0, 0, 0)

		currentIndex = nextIndex
		isTransitioning = false
	end)
end

--automatic image change
local function nextImageFunc()
	local nextIndex = currentIndex + 1
	if nextIndex > #imageIds then
		nextIndex = 1
	end
	transitionToImage(nextIndex)
end

--auto play
local autoPlay = true
local autoPlayCoroutine = nil

local function startAutoPlay()
	if autoPlayCoroutine then return end

	-- if only one image in list stop auto play
	if #imageIds < 2 then
		warn(spawn.ID,":not enough images for auto play")
		return
	end

	autoPlayCoroutine = task.spawn(function()
		while autoPlay do
			task.wait(20) -- wait 20 seconds 
			if autoPlay and not isTransitioning then
				nextImageFunc()
			end
		end
		autoPlayCoroutine = nil
	end)
end

--setup
math.randomseed(tick())

task.wait(1)

if #imageIds > 0 then
	-- randomly pick a starting image 
	local startIndex = math.random(1, #imageIds)
	currentImage.Image = imageIds[startIndex]
	currentImage.ImageTransparency = 0
	currentImage.Position = UDim2.new(0, 0, 0, 0)
	currentIndex = startIndex
else
	-- if no images in list, display default image 
	currentImage.Image = DEFAULT_IMAGE
	currentImage.ImageTransparency = 0
	currentImage.Position = UDim2.new(0, 0, 0, 0)
	warn(spawn.ID,":no images in list was found, display default image: " .. DEFAULT_IMAGE)
end

task.wait(1)
startAutoPlay()
--some part use ai maybe have some shit here or old-data
