local M = {};

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local widget = require( "widget" )

M.newBar = function (params)
	
	if params == nil then
		return nil;
	end
	
	if params.width == nil then
		return nil;
	end
	
	if params.height == nil then
		return nil;
	end
	
	if params.buttons == nil then
		return nil;
	end
	
	if params.notifications == nil then
		return nil;
	end
	
	
	local barShowing = true;
	
	local barButtonSelected = -1;
	local barFunctions = {};
	
	local buttonObjects = {};
	
	local buttons = params.buttons;
	local barWidth = params.width;
	local barHeight = params.height;
	local buttonYOff = -barHeight*0.5;
	local notifications = params.notifications;

	local bottomBarContainer = display.newGroup();
	
	-- local transparentBackground = display.newImageRect("media/images/transparent.png",barWidth,barHeight);
	local transparentBackground = display.newRect(0,0,barWidth,barHeight);
	transparentBackground:setFillColor(0,0,0);
	transparentBackground.alpha = 0.25;
	transparentBackground.anchorX = 0.5;
	transparentBackground.anchorY = 1.0;
	transparentBackground.x = 0;
	transparentBackground.y = 0;
	bottomBarContainer:insert(transparentBackground);
	
	local totalButtons = #buttons;
	local widthStep = barWidth/totalButtons;
	
	for i=1, #buttons do
		local buttonDesc = buttons[i];
		
		local activeNotifications = 0;
		local animationTransition = nil;
		
		local buttonGroup = display.newGroup();
		
		local buttonDefaultImage = display.newImageRect(buttonDesc["default"]["image"],buttonDesc["default"]["width"],buttonDesc["default"]["height"]);
		buttonDefaultImage:setFillColor(buttonDesc["default"]["color"][1],buttonDesc["default"]["color"][2],buttonDesc["default"]["color"][3]);
		buttonDefaultImage.anchorX = 0.5;
		buttonDefaultImage.anchorY = 0.5;
		buttonDefaultImage.x = (i-0.5)*widthStep - barWidth*0.5;
		buttonDefaultImage.y = buttonYOff;
		buttonDefaultImage.default_alpha = buttonDesc["default"]["alpha"];
		buttonDefaultImage.alpha = buttonDesc["default"]["alpha"];
		buttonGroup:insert(buttonDefaultImage);
		
		local buttonOverImage = display.newImageRect(buttonDesc["over"]["image"],buttonDesc["over"]["width"],buttonDesc["over"]["height"]);
		buttonOverImage:setFillColor(buttonDesc["over"]["color"][1],buttonDesc["over"]["color"][2],buttonDesc["over"]["color"][3]);
		buttonOverImage.anchorX = buttonDefaultImage.anchorX;
		buttonOverImage.anchorY = buttonDefaultImage.anchorY;
		buttonOverImage.x = buttonDefaultImage.x;
		buttonOverImage.y = buttonDefaultImage.y;
		buttonOverImage.default_alpha = buttonDesc["over"]["alpha"];
		buttonOverImage.alpha = 0.0;
		buttonGroup:insert(buttonOverImage);
		
		local transparentController = display.newImageRect("media/images/transparent.png",buttonDesc["over"]["width"],buttonDesc["over"]["height"]);
		transparentController.anchorX = buttonDefaultImage.anchorX;
		transparentController.anchorY = buttonDefaultImage.anchorY;
		transparentController.x = buttonDefaultImage.x;
		transparentController.y = buttonDefaultImage.y;
		buttonGroup:insert(transparentController);
		
		transparentController.currentStatus = "default";
		transparentController.onButtonPress = buttonDesc["onPress"];
		transparentController.onButtonRelease = buttonDesc["onRelease"];
		transparentController.buttonNumber = i;
		
		transparentController.switchStatus = function (status)
			if status ~= nil and status ~= transparentController.currentStatus then
				if status == "default" then
					buttonDefaultImage.alpha = buttonDefaultImage.default_alpha;
					buttonOverImage.alpha = 0.0;
					
					if animationTransition ~= nil then
						transition.cancel(animationTransition);
						animationTransition = nil;
						
						buttonDefaultImage.x = (i-0.5)*widthStep - barWidth*0.5;
						buttonDefaultImage.y = buttonYOff;
					end
				elseif status == "over" then
					buttonDefaultImage.alpha = 0.0;
					buttonOverImage.alpha = buttonOverImage.default_alpha;
				elseif status == "selected" then
					buttonDefaultImage.alpha = 0.0;
					buttonOverImage.alpha = buttonOverImage.default_alpha;
				else
					buttonDefaultImage.alpha = buttonDefaultImage.default_alpha;
					buttonOverImage.alpha = 0.0;
				end
				
				transparentController.currentStatus = status;
			end
			
			
			if status == "default" then		
				if activeNotifications > 0 then
					buttonDefaultImage:setFillColor(notifications["color"][1],notifications["color"][2],notifications["color"][3]);
				else
					buttonDefaultImage:setFillColor(buttonDesc["default"]["color"][1],buttonDesc["default"]["color"][2],buttonDesc["default"]["color"][3]);
				end
			end
		end
		
		local function onButtonTouch(event)
			if barShowing == true then
				if barButtonSelected ~= i then
					return barFunctions.onButtonTouch(event);
				end
			end
		end
		transparentController:addEventListener( "touch", onButtonTouch );
		
		buttonGroup.onSetSelected = function (buttonSelected)
			if buttonSelected == i then
				if barButtonSelected ~= i then
					logger.log("Selected button #"..tostring(i));
					transparentController.switchStatus("selected");
				
					barButtonSelected = buttonSelected;
				end
			else
				transparentController.switchStatus("default");
			end
		end
		
		local function checkNotificationAnimation()
			if animationTransition ~= nil then
				-- do nothing
			else
				logger.log("Start animation for notifications");
				buttonDefaultImage.y = -barHeight*0.8;
				animationTransition = transition.to( buttonDefaultImage, { time=2000, y=buttonYOff, iterations=-1, transition=easing.outElastic } );
			end
		end
		
		buttonGroup.onSetNotifications = function (notificationsAmount)
			if notificationsAmount ~= nil then
				activeNotifications = notificationsAmount;
				if barButtonSelected ~= i then
					transparentController.switchStatus("default");
					if activeNotifications > 0 then
						checkNotificationAnimation();
					else
						if animationTransition ~= nil then
							transition.cancel(animationTransition);
							animationTransition = nil;
							
							buttonDefaultImage.x = (i-0.5)*widthStep - barWidth*0.5;
							buttonDefaultImage.y = buttonYOff;
						end
					end
				end
			end
		end
		
		buttonGroup.onGetNotifications = function ()
			return activeNotifications;
		end
		
		bottomBarContainer:insert(buttonGroup);
		buttonObjects[#buttonObjects+1] = buttonGroup;
	end
	
	-- FUNCTIONS BEGIN
	
	barFunctions.onButtonTouch = function (e)
		if e ~= nil and e.target ~= nil then
			if(e.phase == "began") then
				display.getCurrentStage():setFocus(e.target, e.id);
				e.target.isFocus = true;
				e.target.switchStatus("over");
				if e.target.onButtonPress ~= nil then
					e.target.onButtonPress(e);
				end
			elseif(e.target.isFocus == true) then
				if(e.phase == "moved") then
					e.target.switchStatus("over");
				elseif(e.phase == "ended" or e.phase == "cancelled") then
					display.getCurrentStage():setFocus(e.target, nil);
					e.target.isFocus = false;
				
					e.target.switchStatus("default");
					if e.target.onButtonRelease ~= nil then
						e.target.onButtonRelease(e);
					end

					return true;
				end
			end
		end
	end
	
	barFunctions.setSelected = function (buttonIndex)
		if buttonIndex ~= nil and buttonIndex > 0 then
			if buttonIndex <= #buttonObjects then
				for i=1,#buttonObjects do
					local buttonObject = buttonObjects[i];
					if buttonObject ~= nil then
						if buttonObject.onSetSelected ~= nil then
							buttonObject.onSetSelected(buttonIndex);
						end
					else
						logger.log("buttonObject "..tostring(buttonIndex).." not found!");
					end
				end
			else
				logger.log("button index out of range: "..tostring(buttonIndex).." on "..tostring(#buttonObjects));
			end
		end
	end
	
	barFunctions.setNotifications = function (buttonIndex, notificationsAmount)
		if notificationsAmount ~= nil and notificationsAmount >= 0 and buttonIndex ~= nil and buttonIndex > 0 then
			if buttonIndex <= #buttonObjects then
				local buttonObject = buttonObjects[buttonIndex];
				if buttonObject ~= nil then
					if buttonObject.onSetNotifications ~= nil then
						buttonObject.onSetNotifications(notificationsAmount);
					end
				else
					logger.log("buttonObject "..tostring(buttonIndex).." not found!");
				end
			else
				logger.log("button index out of range: "..tostring(buttonIndex).." on "..tostring(#buttonObjects));
			end
		end
	end
	
	barFunctions.getNotifications = function (buttonIndex)
		if buttonIndex ~= nil and buttonIndex > 0 then
			if buttonIndex <= #buttonObjects then
				local buttonObject = buttonObjects[buttonIndex];
				if buttonObject ~= nil then
					if buttonObject.onGetNotifications ~= nil then
						return buttonObject.onGetNotifications();
					end
				else
					logger.log("buttonObject "..tostring(buttonIndex).." not found!");
				end
			else
				logger.log("button index out of range: "..tostring(buttonIndex).." on "..tostring(#buttonObjects));
			end
		end
	end
	
	barFunctions.show = function ()
		logger.log("CALLING SHOW FUNC!!!");
		
		if barShowing ~= true then
			bottomBarContainer.alpha = 1.0;
			barShowing = true;
		end
	end
	
	barFunctions.hide = function ()
		logger.log("CALLING HIDE FUNC!!!");
	
		if barShowing == true then
			bottomBarContainer.alpha = 0.0;
			barShowing = false;
		end
	end
	
	-- FUNCTION END
	
	-- MAPPING PUBLIC FUNCTIONS
	bottomBarContainer.setSelected = barFunctions.setSelected;
	bottomBarContainer.setNotifications = barFunctions.setNotifications;
	bottomBarContainer.getNotifications = barFunctions.getNotifications;
	bottomBarContainer.show = barFunctions.show;
	bottomBarContainer.hide = barFunctions.hide;
	
	return bottomBarContainer;
end



return M;