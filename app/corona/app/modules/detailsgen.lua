local M = {};

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local widget = require( "widget" )
local datagen = require ("app.test.datagen") ;

local orderData;
local receivedData;
local actionEnabled;
local nextStatusCode;

local mainTextColor = parameters.GRAPHICS.COLORS["main_text"];

-- Display objects
local actionButtonOverColor;
local actionButtonActiveColor;
local actionButtonBg;
local actionButtonText;
local orderCurrentStatusText;
local orderNextEventCounter;
local orderNumberText;
local orderPoNumberText;
local orderTypeText;
local orderTypeTargetIcon;
local orderTypeASAPIcon;
local orderPickupMinuteBox;
local orderPickupMinuteText;
local orderPickupMinuteIcon;
local orderTimelineRect;
local orderDropoffMinuteBox;
local orderDropoffMinuteText;
local orderDropoffMinuteIcon;

local pickupTimeText;
local pickupDetailsGroup;
local pickupButtonsGroup;

local dropoffTimeText;
local dropoffDetailsGroup;
local dropoffButtonsGroup;

local backgroundOrderTargetTypeIcon;
local backgroundOrderASAPTypeIcon;
local topGradient;
local bottomGradient;
local backButtonBg;
local roadmapSpacerTop;
local roadmapSpacerBottom;
local notesSpacerBottom;
-- local summaryGroup;
local roadmapGroup;
local itemsGroup;
local feesGroup;
local discountGroup;
local paymentGroup;
local totalGroup;
local checkPartialLine;
local checkDiscountLine;
local paymentTypeLine;
local totalLine;
local notesSpacerBottom;
local checkPartialLine;
local checkDiscountLine;
local paymentTypeLine;
local totalLine;
local finalSpacerBottom;


M.newPage = function (params)
	local containerWidth = _W;
	local containerHeight = _H;
	
	local navigationCallback = nil;
	local panelEnabled = false;

	if params ~= nil then
		if params["width"] ~= nil then containerWidth = params["width"]; end
		if params["height"] ~= nil then containerHeight = params["height"]; end
		if params["loader"] ~= nil then externalLoader = params["loader"]; end
	end

	local Container = display.newGroup();
	
	local Background = display.newGroup();
  	local Foreground = display.newGroup();
  	local GUI = display.newGroup();
  	
  	Container:insert(Background);
  	Container:insert(Foreground);
  	Container:insert(GUI);
  	
  	local navButtonWidth = parameters.GRAPHICS.BUTTONS.NAVIGATION["width"];
  	local navButtonHeight = parameters.GRAPHICS.BUTTONS.NAVIGATION["height"];
  	local navButtonCorner = parameters.GRAPHICS.BUTTONS.NAVIGATION["corner_radius"];
  	local navButtonFontName = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_name"];
  	local navButtonFontSize = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_size"];
  	
  	local navButtonOverColor = parameters.GRAPHICS.COLORS["button_navigation_over"];
  	local navButtonActiveColor = parameters.GRAPHICS.COLORS["button_navigation_active"];
  	
  	local loaderBuilder = require( "app.lib.loader" );
  	local loader = loaderBuilder.newLoader(loaderParams);
  	
  	local backgroundBox = display.newRect(0,0,containerWidth,containerHeight);
  	backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	backgroundBox.anchorX = 0.5;
  	backgroundBox.anchorY = 0.0;
  	backgroundBox.x = _CX;
  	backgroundBox.y = 0;
  	Background:insert(backgroundBox);
  	
  	backgroundOrderTargetTypeIcon = display.newImageRect("media/images/icons/target.png",containerWidth*0.75,containerWidth*0.75);
  	backgroundOrderTargetTypeIcon:setFillColor(1.0,1.0,1.0);
  	backgroundOrderTargetTypeIcon.anchorX = 0.5;
  	backgroundOrderTargetTypeIcon.anchorY = 0.5;
  	backgroundOrderTargetTypeIcon.x = _CX;
  	backgroundOrderTargetTypeIcon.y = _CY - 24;
  	backgroundOrderTargetTypeIcon.alpha = 0.0;
  	Background:insert(backgroundOrderTargetTypeIcon);
  	
  	backgroundOrderASAPTypeIcon = display.newImageRect("media/images/icons/clock.png",containerWidth*0.75,containerWidth*0.75);
  	backgroundOrderASAPTypeIcon:setFillColor(1.0,1.0,1.0);
  	backgroundOrderASAPTypeIcon.anchorX = backgroundOrderTargetTypeIcon.anchorX;
  	backgroundOrderASAPTypeIcon.anchorY = backgroundOrderTargetTypeIcon.anchorY;
  	backgroundOrderASAPTypeIcon.x = backgroundOrderTargetTypeIcon.x;
  	backgroundOrderASAPTypeIcon.y = backgroundOrderTargetTypeIcon.y;
  	backgroundOrderASAPTypeIcon.alpha = backgroundOrderTargetTypeIcon.alpha;
  	Background:insert(backgroundOrderASAPTypeIcon);
  	
  	local backButtonGroup = display.newGroup();
  	
  	backButtonBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	backButtonBg:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
  	backButtonBg.anchorX = 0.5;
  	backButtonBg.anchorY = 1.0;
  	backButtonBg.x = _CX;
  	backButtonBg.y = containerHeight - 6;
  	
  	local backButtonText = textmaker.newText(parameters.GRAPHICS.TEXT["back"],0,0,{navButtonFontName}, navButtonFontSize);
  	backButtonText:setFillColor(parameters.GRAPHICS.COLORS["button_navigation_text"][1],parameters.GRAPHICS.COLORS["button_navigation_text"][2],parameters.GRAPHICS.COLORS["button_navigation_text"][3]);
  	backButtonText.anchorX = 0.5;
  	backButtonText.anchorY = 0.5;
  	backButtonText.x = backButtonBg.x;
  	backButtonText.y = backButtonBg.y - backButtonBg.height*0.5;
  	
  	local function onBack(event)
  		if panelEnabled == true then
			if ( "began" == event.phase) then
				backButtonBg:setFillColor(navButtonActiveColor[1],navButtonActiveColor[2],navButtonActiveColor[3]);
			elseif ( "ended" == event.phase ) then
				backButtonBg:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
				logger.log("Back Button Pressed!");
				
				if navigationCallback ~= nil then
					local backEvent = {};
					backEvent.phase = "will";
					navigationCallback(backEvent);
				end
			end
		end
  	end
  	
  	local backButtonAction = widget.newButton {
		width = navButtonWidth,
		height = navButtonHeight,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onBack
	};
	backButtonAction.anchorX = backButtonText.anchorX;
  	backButtonAction.anchorY = backButtonText.anchorX;
  	backButtonAction.x = backButtonText.x;
  	backButtonAction.y = backButtonText.y;
  	
  	backButtonGroup:insert(backButtonBg);
  	backButtonGroup:insert(backButtonText);
  	backButtonGroup:insert(backButtonAction);
  	
  	actionButtonOverColor = parameters.GRAPHICS.COLORS["button_action_over"];
  	actionButtonActiveColor = parameters.GRAPHICS.COLORS["button_action_active"];
  	local actionButtonTextColor = {1.0,1.0,1.0};
  	
  	local actionButtonGroup = display.newGroup();
  	
  	actionButtonBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	actionButtonBg:setFillColor(actionButtonOverColor[1],actionButtonOverColor[2],actionButtonOverColor[3]);
  	actionButtonBg.anchorX = 0.5;
  	actionButtonBg.anchorY = 1.0;
  	actionButtonBg.x = backButtonBg.x;
  	actionButtonBg.y = backButtonBg.y - navButtonHeight - (containerHeight - backButtonBg.y);
  	
  	actionButtonText = textmaker.newText("Action",0,0,{navButtonFontName}, navButtonFontSize);
  	actionButtonText:setFillColor(actionButtonTextColor[1],actionButtonTextColor[2],actionButtonTextColor[3]);
  	actionButtonText.anchorX = 0.5;
  	actionButtonText.anchorY = 0.5;
  	actionButtonText.x = actionButtonBg.x;
  	actionButtonText.y = actionButtonBg.y - actionButtonBg.height*0.5;
  	
  	local function onAction(event)
  		if panelEnabled == true and actionEnabled == true then
			if ( "began" == event.phase) then
				actionButtonBg:setFillColor(actionButtonActiveColor[1],actionButtonActiveColor[2],actionButtonActiveColor[3]);
			elseif ( "ended" == event.phase ) then
				actionButtonBg:setFillColor(actionButtonOverColor[1],actionButtonOverColor[2],actionButtonOverColor[3]);
				logger.log("Action Button Pressed!");
				
				local function onAlertReply( event )
					if ( event.action == "clicked" ) then
						local i = event.index
						if ( i == 1 ) then
							-- Do nothing
						elseif ( i == 2 ) then
							logger.log("Change Delivery Status to: "..tostring(nextStatusCode));
							
							local statusToRequest = nextStatusCode;
							receivedData = null;
							nextStatusCode = null;
		
							local function orderReceivedCB(response)
								receivedData = response["data"];
							end
							
							loader.start();
  							actionButtonGroup.alpha = 0.0;
  							
  							local function orderConfirmedChangeCB(response)
  								local function emptyListener( event )
  								end
  								
								if response["error"] ~= nil and response["error"] == true then
									local errorMessage = "Unknown error";
									if response["message"] ~= nil then
										errorMessage = tostring(response["message"]);
									end
									local alert = native.showAlert( "Change Status Error", errorMessage, { "Ok" }, emptyListener );
								else
									local data = response["data"];
									if data ~= nil then
										local success = data["success"];
										if success ~= nil and success == true then
											logger.log("Status changed successfuly!!!");
										else
											local reason = "Unknown reason";
											if data["reason"] ~= nil then
												reason = tostring(data["reason"]);
											end
											local alert = native.showAlert( "Change Status Error", reason, { "Ok" }, emptyListener );
										end
									else
										local alert = native.showAlert( "Change Status Error", "No data", { "Ok" }, emptyListener );
									end
								end
								
  								menunu.getOrderDetails(orderData["info_code"],orderReceivedCB);
  							end
  							
  							menunu.changeOrderStatus(orderData["info_code"],statusToRequest,orderConfirmedChangeCB);
						end
					end
				end
				
				local alert = native.showAlert( "Delivery Update", "Do you want to update the delivery status?", { "No", "Yes" }, onAlertReply );
			end
		end
  	end
  	
  	local actionButtonAction = widget.newButton {
		width = navButtonWidth,
		height = navButtonHeight,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onAction
	};
	actionButtonAction.anchorX = actionButtonText.anchorX;
  	actionButtonAction.anchorY = actionButtonText.anchorX;
  	actionButtonAction.x = actionButtonText.x;
  	actionButtonAction.y = actionButtonText.y;
  	
  	actionButtonGroup:insert(actionButtonBg);
  	actionButtonGroup:insert(actionButtonText);
  	actionButtonGroup:insert(actionButtonAction);
  	
  	actionButtonGroup.alpha = 0.0;
  	
  	local orderHeaderGroup = display.newGroup();
  	
  	--[[
  	local otIS = 32;
  	
  	orderTypeTargetIcon = display.newImageRect("media/images/icons/target.png",otIS,otIS);
  	orderTypeTargetIcon:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderTypeTargetIcon.anchorX = 0.0;
  	orderTypeTargetIcon.anchorY = 0.0;
  	orderTypeTargetIcon.x = 4;
  	orderTypeTargetIcon.y = 4;
  	orderTypeTargetIcon.alpha = 0.0;
  	
  	orderTypeASAPIcon = display.newImageRect("media/images/icons/clock.png",otIS,otIS);
  	orderTypeASAPIcon:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderTypeASAPIcon.anchorX = orderTypeTargetIcon.anchorX;
  	orderTypeASAPIcon.anchorY = orderTypeTargetIcon.anchorY;
  	orderTypeASAPIcon.x = 4;
  	orderTypeASAPIcon.y = 4;
  	orderTypeASAPIcon.alpha = 0.0;
  	--]]
  	
  	orderNumberText = textmaker.newText("Unknown",0,0,{"roboto-black"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
  	orderNumberText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderNumberText.anchorX = 0.0;
  	orderNumberText.anchorY = 0.0;
  	orderNumberText.x = 4;
  	orderNumberText.y = 4;
  	
  	orderPoNumberText = textmaker.newText("Unknown",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.0);
  	orderPoNumberText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderPoNumberText.anchorX = orderNumberText.anchorX;
  	orderPoNumberText.anchorY = 1.0;
  	orderPoNumberText.x = orderNumberText.x + orderNumberText.width + 4;
  	orderPoNumberText.y = orderNumberText.y + orderNumberText.height*0.9;
  	
  	orderCurrentStatusText = textmaker.newText("Unknown",0,0,{"roboto-black"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.25);
  	orderCurrentStatusText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderCurrentStatusText.anchorX = 0.0;
  	orderCurrentStatusText.anchorY = 0.0;
  	orderCurrentStatusText.x = orderNumberText.x;
  	orderCurrentStatusText.y = orderNumberText.y + orderNumberText.height*0.8;
  	
  	orderNextEventCounter = textmaker.newText("0'",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
  	orderNextEventCounter:setFillColor(1.0,1.0,1.0);
  	orderNextEventCounter.anchorX = 1.0;
  	orderNextEventCounter.anchorY = orderNumberText.anchorY;
  	orderNextEventCounter.x = _W - 4;
  	orderNextEventCounter.y = orderNumberText.y;
  	orderNextEventCounter.updateCounter = function (seconds)
  		if seconds ~= nil then
  			local min = math.floor(seconds/60);
  			local sec = seconds - min*60;
  			if min > 999 then
  				min = 999;
  				sec = 59;
  			end
  			
  			local isLate = false;
  			local counterColor = parameters.GRAPHICS.COLORS["countdown_good"];
  			if seconds <= parameters.DRIVERS.LATE_TIME_COUNTER then
  				counterColor = parameters.GRAPHICS.COLORS["countdown_late"];
  				if seconds < 0 then
  					isLate = true;
  				end
  			elseif seconds <= parameters.DRIVERS.WARNING_TIME_COUNTER then
  				counterColor = parameters.GRAPHICS.COLORS["countdown_warning"];
  			end
  			
  			if isLate ~= true then
  				orderNextEventCounter.text = string.format("%d",min);
  			else
  				orderNextEventCounter.text = "+"..string.format("%d",-min);
  			end
  			orderNextEventCounter:setTextColor(counterColor[1],counterColor[2],counterColor[3]);
  		end
  	end
  	
  	orderTypeText = textmaker.newText("Unknown",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.0);
  	orderTypeText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderTypeText.anchorX = 1.0;
  	orderTypeText.anchorY = 1.0;
  	orderTypeText.x = containerWidth - orderNumberText.x;
  	orderTypeText.y = orderCurrentStatusText.y + orderCurrentStatusText.height;
  	
  	orderHeaderGroup:insert(orderNumberText);
  	orderHeaderGroup:insert(orderPoNumberText);
  	orderHeaderGroup:insert(orderCurrentStatusText);
  	orderHeaderGroup:insert(orderNextEventCounter);
  	-- orderHeaderGroup:insert(orderTypeTargetIcon);
  	-- orderHeaderGroup:insert(orderTypeASAPIcon);
	orderHeaderGroup:insert(orderTypeText);
	orderHeaderGroup.y = device.safeYOffset;
  	
  	GUI:insert(orderHeaderGroup);
  	
  	topGradient = display.newImageRect("media/images/icons/gradient.png",_W,16);
  	topGradient:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	topGradient.anchorX = 0.5;
  	topGradient.anchorY = 0.0;
  	topGradient.x = _CX;
  	topGradient.y = orderHeaderGroup.y + 80;
  	topGradient.yScale = -1;
  	
  	bottomGradient = display.newImageRect("media/images/icons/gradient.png",_W,16);
  	bottomGradient:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	bottomGradient.anchorX = 0.5;
  	bottomGradient.anchorY = 1.0;
  	bottomGradient.x = _CX;
  	bottomGradient.y = actionButtonBg.y - actionButtonBg.height - (containerHeight - backButtonBg.y);
	
  	
  	local orderMainGroup = display.newGroup();
  	
  	local scrollViewListener = function (event)
  		local phase = event.phase
  		local toRefresh = false;
  		
		if ( phase == "began" ) then
			-- logger.log( "Scroll view was touched" );
		elseif ( phase == "moved" ) then
			-- logger.log( "Scroll view was moved" );
		elseif ( phase == "ended" ) then
			-- logger.log( "Scroll view was released" );
		end

		-- In the event a scroll limit is reached...
		if ( event.limitReached ) then
			if ( event.direction == "up" ) then
				-- logger.log( "Reached bottom limit" )
			elseif ( event.direction == "down" ) then
				logger.log( "Reached top limit" )
				toRefresh = true;
			elseif ( event.direction == "left" ) then
				-- logger.log( "Reached right limit" )
			elseif ( event.direction == "right" ) then
				-- logger.log( "Reached left limit" )
			end
		end
		
		if toRefresh == true then
			-- TODO
		end

		return true;
  	end
  	
  	local scrollView = widget.newScrollView {
		left = 0,
		top = topGradient.y - topGradient.height + 1,
		width = containerWidth,
		height = containerHeight - topGradient.y - (containerHeight - bottomGradient.y) + bottomGradient.height - 2,
		hideBackground = true,
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollViewListener
	}
	scrollView.anchorX = 0.0;
  	scrollView.anchorY = 0.0;
  	scrollView.x = 0;
  	scrollView.y = topGradient.y - topGradient.height + 1;
	orderMainGroup:insert(scrollView);
	
	--[[
	summaryGroup = display.newGroup();
	
	orderNumberText = textmaker.newText("Order unknown",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
  	orderNumberText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderNumberText.anchorX = 0.0;
  	orderNumberText.anchorY = 0.0;
  	orderNumberText.x = 4;
  	orderNumberText.y = 10;
  	
  	summaryGroup:insert(orderNumberText);
  	--]]
  	
  	--[[
  	orderPoNumberText = textmaker.newText("Unknown po number",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.2);
  	orderPoNumberText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderPoNumberText.anchorX = 0.0;
  	orderPoNumberText.anchorY = 0.0;
  	orderPoNumberText.x = 4;
  	orderPoNumberText.y = 10;
  	
  	summaryGroup:insert(orderPoNumberText);
  	--]]
  	
  	--[[
  	orderTypeText = textmaker.newText("TARGET",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
  	orderTypeText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderTypeText.anchorX = 0.0;
  	orderTypeText.anchorY = 0.0;
  	orderTypeText.x = orderPoNumberText.x;
  	orderTypeText.y = orderPoNumberText.y + orderPoNumberText.height;
  	
  	summaryGroup:insert(orderTypeText);
  	
  	orderTypeTargetIcon = display.newImageRect("media/images/icons/target.png",64,64);
  	orderTypeTargetIcon:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderTypeTargetIcon.anchorX = 1.0;
  	orderTypeTargetIcon.anchorY = 0.0;
  	orderTypeTargetIcon.x = containerWidth - orderPoNumberText.x;
  	orderTypeTargetIcon.y = orderPoNumberText.y;
  	orderTypeTargetIcon.alpha = 0.0;
  	
  	orderTypeASAPIcon = display.newImageRect("media/images/icons/clock.png",64,64);
  	orderTypeASAPIcon:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderTypeASAPIcon.anchorX = orderTypeTargetIcon.anchorX;
  	orderTypeASAPIcon.anchorY = orderTypeTargetIcon.anchorY;
  	orderTypeASAPIcon.x = orderTypeTargetIcon.x;
  	orderTypeASAPIcon.y = orderTypeTargetIcon.y;
  	orderTypeASAPIcon.alpha = 0.0;
  	
  	summaryGroup:insert(orderTypeTargetIcon);
  	summaryGroup:insert(orderTypeASAPIcon);
  	
  	scrollView:insert(summaryGroup);
  	--]]
  	
  	roadmapGroup = display.newGroup();
  	
  	orderPickupMinuteBox = display.newRoundedRect( 0, 0, 48, 48, navButtonCorner );
  	orderPickupMinuteBox:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderPickupMinuteBox.anchorX = 0.5;
  	orderPickupMinuteBox.anchorY = 0.5;
  	orderPickupMinuteBox.x = 4 + orderPickupMinuteBox.width*0.5;
  	orderPickupMinuteBox.y = topGradient.y - 28;
  	
  	orderPickupMinuteText = textmaker.newText("5",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*2);
  	orderPickupMinuteText:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	orderPickupMinuteText.anchorX = orderPickupMinuteBox.anchorX;
  	orderPickupMinuteText.anchorY = orderPickupMinuteBox.anchorY;
  	orderPickupMinuteText.x = orderPickupMinuteBox.x;
  	orderPickupMinuteText.y = orderPickupMinuteBox.y;
  	orderPickupMinuteText.updateMinutes = function (minutes)
  		local boxColor = {255/255,255/255,255/255};
  		local seconds = minutes*60;
  		if seconds < parameters.DRIVERS.LATE_DELIVERY_RUN_EVENT then
  			boxColor = parameters.GRAPHICS.COLORS["countdown_late"];
  		elseif seconds < parameters.DRIVERS.WARNING_DELIVERY_RUN_EVENT then
  			boxColor = parameters.GRAPHICS.COLORS["countdown_warning"];
  		end
  		
  		local minutesString = "";
  		if minutes < 0 then
  			minutesString = "+"..tostring(math.abs(minutes));
  		else
  			minutesString = tostring(minutes);
  		end
  	
  		local msLen = string.len( minutesString );
  		
  		orderPickupMinuteText.text = minutesString
  		if msLen <= 1 then
  			orderPickupMinuteText.xScale = 1.0;
  			orderPickupMinuteText.yScale = 1.0; 
  		elseif msLen <= 2 then
  			orderPickupMinuteText.xScale = 0.8;
  			orderPickupMinuteText.yScale = 0.8; 
  		elseif msLen <= 3 then
  			orderPickupMinuteText.xScale = 0.7;
  			orderPickupMinuteText.yScale = 0.7;
  		elseif msLen <= 4 then
  			orderPickupMinuteText.xScale = 0.6;
  			orderPickupMinuteText.yScale = 0.6;
  		else
  			orderPickupMinuteText.xScale = 0.5;
  			orderPickupMinuteText.yScale = 0.5;
  		end
  		
  		orderPickupMinuteBox:setFillColor(boxColor[1],boxColor[2],boxColor[3]);
  	end
  	
  	orderPickupMinuteIcon = display.newImageRect("media/images/icons/restaurant.png",orderPickupMinuteBox.width*0.85,orderPickupMinuteBox.height*0.85);
  	orderPickupMinuteIcon:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	orderPickupMinuteIcon.anchorX = orderPickupMinuteBox.anchorX;
  	orderPickupMinuteIcon.anchorY = orderPickupMinuteBox.anchorY;
  	orderPickupMinuteIcon.x = orderPickupMinuteBox.x;
  	orderPickupMinuteIcon.y = orderPickupMinuteBox.y;
  	orderPickupMinuteIcon.alpha = 0.0;
  	
  	orderTimelineRect = display.newRect( 0, 0, 4, 320 );
  	orderTimelineRect:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderTimelineRect.anchorX = 0.5;
  	orderTimelineRect.anchorY = 0.0;
  	orderTimelineRect.x = orderPickupMinuteBox.x;
  	orderTimelineRect.y = orderPickupMinuteBox.y;
  	
  	orderDropoffMinuteBox = display.newRoundedRect( 0, 0, 48, 48, navButtonCorner );
  	orderDropoffMinuteBox:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	orderDropoffMinuteBox.anchorX = 0.5;
  	orderDropoffMinuteBox.anchorY = 0.5;
  	orderDropoffMinuteBox.x = orderTimelineRect.x;
  	orderDropoffMinuteBox.y = orderTimelineRect.y + orderTimelineRect.height;
  	
  	orderDropoffMinuteText = textmaker.newText("20",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*2);
  	orderDropoffMinuteText:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	orderDropoffMinuteText.anchorX = orderDropoffMinuteBox.anchorX;
  	orderDropoffMinuteText.anchorY = orderDropoffMinuteBox.anchorY;
  	orderDropoffMinuteText.x = orderDropoffMinuteBox.x;
  	orderDropoffMinuteText.y = orderDropoffMinuteBox.y;
  	orderDropoffMinuteText.updateMinutes = function (minutes)
  		local boxColor = {255/255,255/255,255/255};
  		local seconds = minutes*60;
  		if seconds < parameters.DRIVERS.LATE_DELIVERY_RUN_EVENT then
  			boxColor = parameters.GRAPHICS.COLORS["countdown_late"];
  		elseif seconds < parameters.DRIVERS.WARNING_DELIVERY_RUN_EVENT then
  			boxColor = parameters.GRAPHICS.COLORS["countdown_warning"];
  		end
  		
  		local minutesString = "";
  		if minutes < 0 then
  			minutesString = "+"..tostring(math.abs(minutes));
  		else
  			minutesString = tostring(minutes);
  		end
  	
  		local msLen = string.len( minutesString );
  		
  		orderDropoffMinuteText.text = minutesString
  		if msLen <= 1 then
  			orderDropoffMinuteText.xScale = 1.0;
  			orderDropoffMinuteText.yScale = 1.0; 
  		elseif msLen <= 2 then
  			orderDropoffMinuteText.xScale = 0.8;
  			orderDropoffMinuteText.yScale = 0.8; 
  		elseif msLen <= 3 then
  			orderDropoffMinuteText.xScale = 0.7;
  			orderDropoffMinuteText.yScale = 0.7;
  		elseif msLen <= 4 then
  			orderDropoffMinuteText.xScale = 0.6;
  			orderDropoffMinuteText.yScale = 0.6;
  		else
  			orderDropoffMinuteText.xScale = 0.5;
  			orderDropoffMinuteText.yScale = 0.5;
  		end
  		
  		orderDropoffMinuteBox:setFillColor(boxColor[1],boxColor[2],boxColor[3]);
  	end
  	
  	orderDropoffMinuteIcon = display.newImageRect("media/images/icons/streetview.png",orderDropoffMinuteBox.width*0.85,orderDropoffMinuteBox.height*0.85);
  	orderDropoffMinuteIcon:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	orderDropoffMinuteIcon.anchorX = orderDropoffMinuteBox.anchorX;
  	orderDropoffMinuteIcon.anchorY = orderDropoffMinuteBox.anchorY;
  	orderDropoffMinuteIcon.x = orderDropoffMinuteBox.x;
  	orderDropoffMinuteIcon.y = orderDropoffMinuteBox.y;
  	orderDropoffMinuteIcon.alpha = 0.0;
  	
  	roadmapGroup:insert(orderTimelineRect);
  	roadmapGroup:insert(orderPickupMinuteBox);
  	roadmapGroup:insert(orderPickupMinuteText);
  	roadmapGroup:insert(orderPickupMinuteIcon);
  	roadmapGroup:insert(orderDropoffMinuteBox);
  	roadmapGroup:insert(orderDropoffMinuteText);
  	roadmapGroup:insert(orderDropoffMinuteIcon);
  	
  	-- Pickup Info Objects
  	pickupTimeText = textmaker.newText("Unknown",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
  	pickupTimeText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	pickupTimeText.anchorX = 1.0;
  	pickupTimeText.anchorY = 0.0;
  	pickupTimeText.x = containerWidth - 4;
  	pickupTimeText.y = orderPickupMinuteBox.y - orderPickupMinuteBox.height;
  	pickupTimeText.updateTime = function (date)
  		if date ~= nil then
  			local timeString = "Unknown";
  			if date.hour > 12 then
  				timeString = string.format("%02d",(date.hour-12))..":"..string.format("%02d",date.min).." PM";
  			else
  				timeString = string.format("%02d",date.hour)..":"..string.format("%02d",date.min).." AM";
  			end
  			
  			pickupTimeText.text = timeString;
  		end
  	end
  	
  	pickupDetailsGroup = display.newGroup();
  	
  	roadmapGroup:insert(pickupTimeText);
  	roadmapGroup:insert(pickupDetailsGroup);
  	
  	pickupButtonsGroup = display.newGroup();
  	
  	local pickupDirectionsButtonBox = display.newRoundedRect( 0, 0, 48, 48, navButtonCorner );
  	pickupDirectionsButtonBox:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
  	pickupDirectionsButtonBox.anchorX = pickupTimeText.anchorX;
  	pickupDirectionsButtonBox.anchorY = pickupTimeText.anchorY;
  	pickupDirectionsButtonBox.x = pickupTimeText.x;
  	pickupDirectionsButtonBox.y = 0;
  	
  	local pickupDirectionsButtonIcon = display.newImageRect("media/images/icons/location.png",36,36);
  	pickupDirectionsButtonIcon:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	pickupDirectionsButtonIcon.anchorX = 0.5;
  	pickupDirectionsButtonIcon.anchorY = 0.5;
  	pickupDirectionsButtonIcon.x = pickupDirectionsButtonBox.x - pickupDirectionsButtonBox.width*0.5;
  	pickupDirectionsButtonIcon.y = pickupDirectionsButtonBox.y + pickupDirectionsButtonBox.height*0.5;
  	
  	local function onPickupDirections(event)
  		if panelEnabled == true and actionEnabled == true then
			if ( "began" == event.phase) then
				pickupDirectionsButtonBox:setFillColor(navButtonActiveColor[1],navButtonActiveColor[2],navButtonActiveColor[3]);
			elseif ( "ended" == event.phase ) then
				pickupDirectionsButtonBox:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
				logger.log("Pickup Directions Pressed!");
				analytics.logEvent("details_pickup_directions_tap");
				
				local orderDescriptor = receivedData["order"];
				local orderRestaurant = orderDescriptor["restaurant"];
				
				local function onAlertReply( event )
					if ( event.action == "clicked" ) then
						local i = event.index
						if ( i == 1 ) then
							-- Do nothing
						elseif ( i == 2 ) then
							analytics.logEvent("details_pickup_directions_confirmed");
							local externalURL = nil;
							
							if orderRestaurant ~= nil then
								local tpLat = orderRestaurant["lat"];
								local tpLng = orderRestaurant["lng"];
							
								if device.platform == "ios" then
									externalURL = "waze://?ll="..tostring(tpLat)..","..tostring(tpLng).."&navigate=yes";
								elseif device.platform == "android" then
									externalURL = "waze://?ll="..tostring(tpLat)..","..tostring(tpLng).."&navigate=yes";
								else
									logger.log("Pickup Directions requested - platform="..tostring(device.platform).." not supported");
								end
						
								if externalURL ~= nil then
									system.openURL( externalURL );
								end
							else
								logger.log("Can't find restaurant...");
							end
						end
					end
				end
				
				local alert = native.showAlert( "Pickup Directions", "Do you need directions to "..tostring(orderRestaurant["name"]).."? Please remember to install Waze App to use the navigation", { "No", "Yes" }, onAlertReply );
			end
		end
  	end
  	
  	local pickupDirectionsButtonAction = widget.newButton {
		width = pickupDirectionsButtonBox.width,
		height = pickupDirectionsButtonBox.height,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onPickupDirections
	};
	pickupDirectionsButtonAction.anchorX = pickupDirectionsButtonIcon.anchorX;
  	pickupDirectionsButtonAction.anchorY = pickupDirectionsButtonIcon.anchorY;
  	pickupDirectionsButtonAction.x = pickupDirectionsButtonIcon.x;
  	pickupDirectionsButtonAction.y = pickupDirectionsButtonIcon.y;
  	
  	pickupButtonsGroup:insert(pickupDirectionsButtonBox);
  	pickupButtonsGroup:insert(pickupDirectionsButtonIcon);
  	pickupButtonsGroup:insert(pickupDirectionsButtonAction);
  	
  	local pickupPhoneButtonBox = display.newRoundedRect( 0, 0, 48, 48, navButtonCorner );
  	pickupPhoneButtonBox:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
  	pickupPhoneButtonBox.anchorX = pickupDirectionsButtonBox.anchorX;
  	pickupPhoneButtonBox.anchorY = pickupDirectionsButtonBox.anchorY;
  	pickupPhoneButtonBox.x = pickupDirectionsButtonBox.x - pickupDirectionsButtonBox.width - (containerWidth - pickupDirectionsButtonBox.x)*2;
  	pickupPhoneButtonBox.y = pickupDirectionsButtonBox.y;
  	
  	local pickupPhoneButtonIcon = display.newImageRect("media/images/icons/phone.png",36,36);
  	pickupPhoneButtonIcon:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	pickupPhoneButtonIcon.anchorX = 0.5;
  	pickupPhoneButtonIcon.anchorY = 0.5;
  	pickupPhoneButtonIcon.x = pickupPhoneButtonBox.x - pickupPhoneButtonBox.width*0.5;
  	pickupPhoneButtonIcon.y = pickupPhoneButtonBox.y + pickupPhoneButtonBox.height*0.5;
  	
  	local function onPickupPhone(event)
  		if panelEnabled == true and actionEnabled == true then
			if ( "began" == event.phase) then
				pickupPhoneButtonBox:setFillColor(navButtonActiveColor[1],navButtonActiveColor[2],navButtonActiveColor[3]);
			elseif ( "ended" == event.phase ) then
				pickupPhoneButtonBox:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
				logger.log("Pickup Phone Pressed!");
				analytics.logEvent("details_pickup_phone_tap");
				
				local orderDescriptor = receivedData["order"];
				local orderRestaurant = orderDescriptor["restaurant"];
				local restaurantPhoneNumber = orderRestaurant["phone"];
				
				if restaurantPhoneNumber ~= nil then
					restaurantPhoneNumber = "" .. string.gsub( restaurantPhoneNumber, "%(", "" );
					restaurantPhoneNumber = "" .. string.gsub( restaurantPhoneNumber, "%)", "-" );
					restaurantPhoneNumber = "" .. string.gsub( restaurantPhoneNumber, " ", "" );
				
					local function onAlertReply( event )
						if ( event.action == "clicked" ) then
							local i = event.index
							if ( i == 1 ) then
								-- Do nothing
							elseif ( i == 2 ) then
								logger.log("Restaurant Call requested to "..tostring(restaurantPhoneNumber));
								analytics.logEvent("details_pickup_phone_confirmed");
								system.openURL( "tel:"..tostring(restaurantPhoneNumber) )
							end
						end
					end
				
					local alert = native.showAlert( "Call Restaurant", "Do you want to call "..tostring(orderRestaurant["name"]).." at "..tostring(restaurantPhoneNumber).." ?", { "No", "Yes" }, onAlertReply );
				end
			end
		end
  	end
  	
  	local pickupPhoneButtonAction = widget.newButton {
		width = pickupPhoneButtonBox.width,
		height = pickupPhoneButtonBox.height,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onPickupPhone
	};
	pickupPhoneButtonAction.anchorX = pickupPhoneButtonIcon.anchorX;
  	pickupPhoneButtonAction.anchorY = pickupPhoneButtonIcon.anchorY;
  	pickupPhoneButtonAction.x = pickupPhoneButtonIcon.x;
  	pickupPhoneButtonAction.y = pickupPhoneButtonIcon.y;
  	
  	pickupButtonsGroup:insert(pickupPhoneButtonBox);
  	pickupButtonsGroup:insert(pickupPhoneButtonIcon);
  	pickupButtonsGroup:insert(pickupPhoneButtonAction);
  	
  	pickupButtonsGroup.y = pickupTimeText.y + pickupTimeText.height + pickupDetailsGroup.height;
  	roadmapGroup:insert(pickupButtonsGroup);
  	
  	-- Dropoff Info Objects
  	dropoffTimeText = textmaker.newText("Unknown",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
  	dropoffTimeText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
  	dropoffTimeText.anchorX = 0.0;
  	dropoffTimeText.anchorY = 0.0;
  	dropoffTimeText.x = orderDropoffMinuteBox.x + orderDropoffMinuteBox.width;
  	dropoffTimeText.y = orderDropoffMinuteBox.y - orderDropoffMinuteBox.height*2;
  	dropoffTimeText.updateTime = function (date)
  		if date ~= nil then
  			local timeString = "Unknown";
  			if date.hour > 12 then
  				timeString = string.format("%02d",(date.hour-12))..":"..string.format("%02d",date.min).." PM";
  			else
  				timeString = string.format("%02d",date.hour)..":"..string.format("%02d",date.min).." AM";
  			end
  			
  			dropoffTimeText.text = timeString;
  		end
  	end
  	
  	dropoffDetailsGroup = display.newGroup();
  	
  	roadmapGroup:insert(dropoffTimeText);
  	roadmapGroup:insert(dropoffDetailsGroup);
  	
  	dropoffButtonsGroup = display.newGroup();
  	
  	local dropoffPhoneButtonBox = display.newRoundedRect( 0, 0, 48, 48, navButtonCorner );
  	dropoffPhoneButtonBox:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
  	dropoffPhoneButtonBox.anchorX = dropoffTimeText.anchorX;
  	dropoffPhoneButtonBox.anchorY = dropoffTimeText.anchorY;
  	dropoffPhoneButtonBox.x = dropoffTimeText.x;
  	dropoffPhoneButtonBox.y = 0;
  	
  	local dropoffPhoneButtonIcon = display.newImageRect("media/images/icons/phone.png",36,36);
  	dropoffPhoneButtonIcon:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	dropoffPhoneButtonIcon.anchorX = 0.5;
  	dropoffPhoneButtonIcon.anchorY = 0.5;
  	dropoffPhoneButtonIcon.x = dropoffPhoneButtonBox.x + dropoffPhoneButtonBox.width*0.5;
  	dropoffPhoneButtonIcon.y = dropoffPhoneButtonBox.y + dropoffPhoneButtonBox.height*0.5;
  	
  	local function onDropoffPhone(event)
  		if panelEnabled == true and actionEnabled == true then
			if ( "began" == event.phase) then
				dropoffPhoneButtonBox:setFillColor(navButtonActiveColor[1],navButtonActiveColor[2],navButtonActiveColor[3]);
			elseif ( "ended" == event.phase ) then
				dropoffPhoneButtonBox:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
				logger.log("Dropoff Phone Pressed!");
				analytics.logEvent("details_dropoff_phone_tap");
				
				local orderDescriptor = receivedData["order"];
				local orderCustomer = orderDescriptor["customer"];
				local customerPhoneNumber = orderCustomer["phone"];
				
				if customerPhoneNumber ~= nil then
					customerPhoneNumber = "" .. string.gsub( customerPhoneNumber, "%(", "" );
					customerPhoneNumber = "" .. string.gsub( customerPhoneNumber, "%)", "-" );
					customerPhoneNumber = "" .. string.gsub( customerPhoneNumber, " ", "" );
				
					local function onAlertReply( event )
						if ( event.action == "clicked" ) then
							local i = event.index
							if ( i == 1 ) then
								-- Do nothing
							elseif ( i == 2 ) then
								logger.log("Dropoff Call requested to "..tostring(customerPhoneNumber));
								analytics.logEvent("details_dropoff_phone_confirmed");
								system.openURL( "tel:"..tostring(customerPhoneNumber) )
							end
						end
					end
				
					local alert = native.showAlert( "Call Customer", "Do you want to call "..tostring(orderCustomer["name"]).." at "..tostring(customerPhoneNumber).." ?", { "No", "Yes" }, onAlertReply );
				end
			end
		end
  	end
  	
  	local dropoffPhoneButtonAction = widget.newButton {
		width = dropoffPhoneButtonBox.width,
		height = dropoffPhoneButtonBox.height,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onDropoffPhone
	};
	dropoffPhoneButtonAction.anchorX = dropoffPhoneButtonIcon.anchorX;
  	dropoffPhoneButtonAction.anchorY = dropoffPhoneButtonIcon.anchorY;
  	dropoffPhoneButtonAction.x = dropoffPhoneButtonIcon.x;
  	dropoffPhoneButtonAction.y = dropoffPhoneButtonIcon.y;
  	
  	dropoffButtonsGroup:insert(dropoffPhoneButtonBox);
  	dropoffButtonsGroup:insert(dropoffPhoneButtonIcon);
  	dropoffButtonsGroup:insert(dropoffPhoneButtonAction);
  	
  	local dropoffDirectionsButtonBox = display.newRoundedRect( 0, 0, 48, 48, navButtonCorner );
  	dropoffDirectionsButtonBox:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
  	dropoffDirectionsButtonBox.anchorX = dropoffPhoneButtonBox.anchorX;
  	dropoffDirectionsButtonBox.anchorY = dropoffPhoneButtonBox.anchorY;
  	dropoffDirectionsButtonBox.x = dropoffPhoneButtonBox.x + dropoffPhoneButtonBox.width + (containerWidth - pickupDirectionsButtonBox.x)*2;
  	dropoffDirectionsButtonBox.y = dropoffPhoneButtonBox.y;
  	
  	local dropoffDirectionsButtonIcon = display.newImageRect("media/images/icons/location.png",36,36);
  	dropoffDirectionsButtonIcon:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	dropoffDirectionsButtonIcon.anchorX = 0.5;
  	dropoffDirectionsButtonIcon.anchorY = 0.5;
  	dropoffDirectionsButtonIcon.x = dropoffDirectionsButtonBox.x + dropoffDirectionsButtonBox.width*0.5;
  	dropoffDirectionsButtonIcon.y = dropoffDirectionsButtonBox.y + dropoffDirectionsButtonBox.height*0.5;
  	
  	local function onDropoffDirections(event)
  		if panelEnabled == true and actionEnabled == true then
			if ( "began" == event.phase) then
				dropoffDirectionsButtonBox:setFillColor(navButtonActiveColor[1],navButtonActiveColor[2],navButtonActiveColor[3]);
			elseif ( "ended" == event.phase ) then
				dropoffDirectionsButtonBox:setFillColor(navButtonOverColor[1],navButtonOverColor[2],navButtonOverColor[3]);
				logger.log("Dropoff Directions Pressed!");
				analytics.logEvent("details_dropoff_directions_tap");
				
				local orderDescriptor = receivedData["order"];
				local orderCustomer = orderDescriptor["customer"];
				
				local function onAlertReply( event )
					if ( event.action == "clicked" ) then
						local i = event.index
						if ( i == 1 ) then
							-- Do nothing
						elseif ( i == 2 ) then
							analytics.logEvent("details_dropoff_directions_confirmed");
							local externalURL = nil;
							
							if orderDescriptor ~= nil then
								local orderDropoffAddress = orderDescriptor["address"];
								
								if orderDropoffAddress ~= nil then
									local tpLat = orderDropoffAddress["lat"];
									local tpLng = orderDropoffAddress["lng"];
								
									if device.platform == "ios" then
										externalURL = "waze://?ll="..tostring(tpLat)..","..tostring(tpLng).."&navigate=yes";
									elseif device.platform == "android" then
										externalURL = "waze://?ll="..tostring(tpLat)..","..tostring(tpLng).."&navigate=yes";
									else
										logger.log("Dropoff Directions requested - platform="..tostring(device.platform).." not supported");
									end
							
									if externalURL ~= nil then
										system.openURL( externalURL );
									end
								else
									logger.log("Can't find address...");
								end
							end
						end
					end
				end
				
				local alert = native.showAlert( "Dropoff Directions", "Do you need directions to "..tostring(orderCustomer["name"]).." address? Please remember to install Waze App to use the navigation", { "No", "Yes" }, onAlertReply );
			end
		end
  	end
  	
  	local dropoffDirectionsButtonAction = widget.newButton {
		width = dropoffDirectionsButtonBox.width,
		height = dropoffDirectionsButtonBox.height,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onDropoffDirections
	};
	dropoffDirectionsButtonAction.anchorX = dropoffDirectionsButtonIcon.anchorX;
  	dropoffDirectionsButtonAction.anchorY = dropoffDirectionsButtonIcon.anchorY;
  	dropoffDirectionsButtonAction.x = dropoffDirectionsButtonIcon.x;
  	dropoffDirectionsButtonAction.y = dropoffDirectionsButtonIcon.y;
  	
  	dropoffButtonsGroup:insert(dropoffDirectionsButtonBox);
  	dropoffButtonsGroup:insert(dropoffDirectionsButtonIcon);
  	dropoffButtonsGroup:insert(dropoffDirectionsButtonAction);
  	
  	dropoffButtonsGroup.y = dropoffTimeText.y + dropoffTimeText.height + dropoffDetailsGroup.height; 
  	roadmapGroup:insert(dropoffButtonsGroup);
  	
  	scrollView:insert(roadmapGroup);
  	
  	-- Notes
  	itemsGroup = display.newGroup();
  	feesGroup = display.newGroup();
	discountGroup = display.newGroup();
	paymentGroup = display.newGroup();
	totalGroup = display.newGroup();
	
  	scrollView:insert(itemsGroup);
  	scrollView:insert(feesGroup);
  	scrollView:insert(discountGroup);
  	scrollView:insert(paymentGroup);
  	scrollView:insert(totalGroup);
  	
  	-- Spacers
  	--[[
  	roadmapSpacerTop = display.newRect(0,0,containerWidth, 4);
  	roadmapSpacerTop.anchorX = 0.5;
  	roadmapSpacerTop.anchorY = 0.5;
  	roadmapSpacerTop.alpha = 0.1;
  	roadmapSpacerTop.x = _CX;
  	roadmapSpacerTop.y = orderTypeText.y + orderTypeText.height + 8;
  	--]]
  	
  	roadmapSpacerBottom = display.newRect(0,0,containerWidth, 4);
  	roadmapSpacerBottom.anchorX = 0.5;
  	roadmapSpacerBottom.anchorY = 0.5;
  	roadmapSpacerBottom.alpha = 0.1;
  	roadmapSpacerBottom.x = _CX
  	roadmapSpacerBottom.y = dropoffButtonsGroup.y + dropoffButtonsGroup.height + 28;
  	
  	notesSpacerBottom = display.newRect(0,0,containerWidth, 4);
  	notesSpacerBottom.anchorX = roadmapSpacerBottom.anchorX;
  	notesSpacerBottom.anchorY = roadmapSpacerBottom.anchorY;
  	notesSpacerBottom.alpha = roadmapSpacerBottom.alpha;
  	notesSpacerBottom.x = roadmapSpacerBottom.x;
  	notesSpacerBottom.y = dropoffPhoneButtonBox.y + dropoffPhoneButtonBox.height + 200;
  	
  	checkPartialLine = display.newRect(0,0,containerWidth, 1);
  	checkPartialLine.anchorX = notesSpacerBottom.anchorX;
  	checkPartialLine.anchorY = notesSpacerBottom.anchorY;
  	checkPartialLine.alpha = notesSpacerBottom.alpha;
  	checkPartialLine.x = notesSpacerBottom.x;
  	checkPartialLine.y = _H*0.75 + 4;
  	
  	checkDiscountLine = display.newRect(0,0,containerWidth, 1);
  	checkDiscountLine.anchorX = checkPartialLine.anchorX;
  	checkDiscountLine.anchorY = checkPartialLine.anchorY;
  	checkDiscountLine.alpha = checkPartialLine.alpha;
  	checkDiscountLine.x = checkPartialLine.x;
  	checkDiscountLine.y = _H*0.75 + 4;
  	
  	paymentTypeLine = display.newRect(0,0,containerWidth, 1);
  	paymentTypeLine.anchorX = checkDiscountLine.anchorX;
  	paymentTypeLine.anchorY = checkDiscountLine.anchorY;
  	paymentTypeLine.alpha = checkDiscountLine.alpha;
  	paymentTypeLine.x = checkDiscountLine.x;
  	paymentTypeLine.y = _H*0.75 + 4;
  	
  	totalLine = display.newRect(0,0,containerWidth, 1);
  	totalLine.anchorX = paymentTypeLine.anchorX;
  	totalLine.anchorY = paymentTypeLine.anchorY;
  	totalLine.alpha = paymentTypeLine.alpha;
  	totalLine.x = paymentTypeLine.x;
  	totalLine.y = _H*0.75 + 4;
  	
  	finalSpacerBottom = display.newRect(0,0,containerWidth, 4);
  	finalSpacerBottom.anchorX = totalLine.anchorX;
  	finalSpacerBottom.anchorY = totalLine.anchorY;
  	finalSpacerBottom.alpha = 0.0;
  	finalSpacerBottom.x = totalLine.x;
  	finalSpacerBottom.y = totalLine.y + totalLine.height*0.5 + 50;
  	
  	-- scrollView:insert(roadmapSpacerTop);
  	scrollView:insert(roadmapSpacerBottom);
  	scrollView:insert(notesSpacerBottom);
  	scrollView:insert(checkPartialLine);
  	scrollView:insert(checkDiscountLine);
  	scrollView:insert(paymentTypeLine);
  	scrollView:insert(totalLine);
  	scrollView:insert(finalSpacerBottom);
	
	GUI:insert(orderMainGroup);
  	GUI:insert(topGradient);
  	GUI:insert(bottomGradient);
  	
  	GUI:insert(loader);
  	GUI:insert(backButtonGroup);
  	GUI:insert(actionButtonGroup);
  	
  	-- Functions BEGIN
  	local function getOrderStatusDescriptor(orderDescriptor)
  		if orderDescriptor ~= nil then
  			local status = orderDescriptor["order_status_id"];
  			local orderTimeline = orderDescriptor["timeline"];
  			
  			local infoSentAt = nil;
  			local orderPlacedAt = nil;
  			local driverAcceptedAt = nil;
  			local completedAt = nil;
  			local pickupWillArriveAt = nil;
  			local pickupWillLeaveAt = nil;
  			local dropoffWillArriveAt = nil;
  			local dropoffWillLeaveAt = nil;
  			local pickupDidArriveAt = nil;
  			local pickupDidLeaveAt = nil;
  			local dropoffDidArriveAt = nil;
  			local dropoffDidLeaveAt = nil;
  			
  			if orderTimeline ~= nil then
  				infoSentAt = orderTimeline["sent"];
  				driverAcceptedAt = orderTimeline["confirmed"];
  				completedAt = orderTimeline["completed"];
  				orderPlacedAt = orderTimeline["placed"];
  				
  				pickupWillArriveAt = orderTimeline["pickup"]["in"]["estimated"];
  				pickupWillLeaveAt = orderTimeline["pickup"]["out"]["estimated"];
  				dropoffWillArriveAt = orderTimeline["dropoff"]["in"]["estimated"];
  				dropoffWillLeaveAt = orderTimeline["dropoff"]["out"]["estimated"];
  				
  				pickupDidArriveAt = orderTimeline["pickup"]["in"]["actual"];
  				pickupDidLeaveAt = orderTimeline["pickup"]["out"]["actual"];
  				dropoffDidArriveAt = orderTimeline["dropoff"]["in"]["actual"];
  				dropoffDidLeaveAt = orderTimeline["dropoff"]["out"]["actual"];
  			end
			
			
			local orderStatusColor = nil;
			local orderStatusIcon = nil;
			local orderStatusText = nil;
			
			local orderNextStatusCode = nil;
			local orderNextStatusText = nil;
			local orderNextStatusColor = nil;
			
			if status > 0 then
				if completedAt ~= nil and completedAt > 0 then
					orderStatusText = "Delivered";
					orderStatusIcon = "media/images/icons/target.png";
					orderStatusColor = parameters.GRAPHICS.ORDERS.COLORS["delivered"];
				elseif dropoffDidLeaveAt ~= nil and dropoffDidLeaveAt > 0 then
					orderStatusText = "At Dropoff";
					orderStatusIcon = "media/images/icons/home.png";
					orderStatusColor = parameters.GRAPHICS.ORDERS.COLORS["atdropoff"];
					
					orderNextStatusCode = "delivered";
					orderNextStatusText = "Delivered";
					orderNextStatusColor = parameters.GRAPHICS.ORDERS.ACTIONS.COLORS["delivered"];
				elseif dropoffDidArriveAt ~= nil and dropoffDidArriveAt > 0 then
					orderStatusText = "At Dropoff";
					orderStatusIcon = "media/images/icons/home.png";
					orderStatusColor = parameters.GRAPHICS.ORDERS.COLORS["atdropoff"];
					
					orderNextStatusCode = "delivered";
					orderNextStatusText = "Delivered";
					orderNextStatusColor = parameters.GRAPHICS.ORDERS.ACTIONS.COLORS["delivered"];
				elseif pickupDidLeaveAt ~= nil and pickupDidLeaveAt > 0 then
					orderStatusText = "Driving";
					orderStatusColor = parameters.GRAPHICS.ORDERS.COLORS["enroute"];
					orderStatusIcon = "media/images/icons/truck.png";
						
					orderNextStatusCode = "atdropoff";
					orderNextStatusText = "At Dropoff";
					orderNextStatusColor = parameters.GRAPHICS.ORDERS.ACTIONS.COLORS["delivered"];
				elseif pickupDidArriveAt ~= nil and pickupDidArriveAt > 0 then
					orderStatusText = "At Restaurant";
					orderStatusIcon = "media/images/icons/restaurant.png";
					orderStatusColor = parameters.GRAPHICS.ORDERS.COLORS["placed"];
						
					orderNextStatusCode = "enroute";
					orderNextStatusText = "En Route";
					orderNextStatusColor = parameters.GRAPHICS.ORDERS.ACTIONS.COLORS["enroute"];
				elseif driverAcceptedAt ~= nil and driverAcceptedAt > 0 then
					orderStatusText = "Confirmed";
					orderStatusIcon = "media/images/icons/calendar.png";
					orderStatusColor = parameters.GRAPHICS.ORDERS.COLORS["placed"];
						
					orderNextStatusCode = "atrestaurant";
					orderNextStatusText = "At Restaurant";
					orderNextStatusColor = parameters.GRAPHICS.ORDERS.ACTIONS.COLORS["atrestaurant"];
				elseif infoSentAt ~= nil and infoSentAt > 0 then
					orderStatusText = "Open";
					orderStatusColor = parameters.GRAPHICS.ORDERS.COLORS["init"];
					orderStatusIcon = "media/images/icons/clock.png";
					
					orderNextStatusCode = "confirmed";
					orderNextStatusText = "Accept";
					orderNextStatusColor = parameters.GRAPHICS.ORDERS.ACTIONS.COLORS["confirm"];
				end
			end
  		
  			if orderStatusColor ~= nil and orderStatusIcon ~= nil and orderStatusText ~= nil then
  				local result = {};
  				result.color = orderStatusColor;
  				result.icon = orderStatusIcon;
  				result.text = orderStatusText;
  				
  				if orderNextStatusCode ~= nil and orderNextStatusColor ~= nil and orderNextStatusText ~= nil then
					local nextStatus = {};
					nextStatus.code = orderNextStatusCode;
					nextStatus.color = orderNextStatusColor;
					nextStatus.text = orderNextStatusText;
				
					result.nextStatus = nextStatus;
				end
  				
  				return result;
			end
  		end
  	end
  	
  	local function formatOrder()
  		local utcDate = os.date( "!*t" );
		local utcTime = tonumber(os.time(utcDate));
		local epochTime = tonumber(os.time{year=1970, month=1, day=1, hour=0});
		local nowTime = (utcTime - epochTime);
		local localDate = os.date( "*t" );
		local localTime = tonumber(os.time(localDate));
		
		-- local driverDelay = (orderTargetArriveAt - nowTime);
  	
  		local orderDescriptor = receivedData["order"];
  		local orderId = orderDescriptor["order_id"];
  		local orderType = 0; -- asap
  		if orderDescriptor["delivery_type"] == "target" then
  			orderType = 1; -- target
  		end
  		local orderPoNumber = orderDescriptor["po_number"];
		
		local orderRestaurant = orderDescriptor["restaurant"];
		local orderCustomer = orderDescriptor["customer"];
		local orderDropoffAddress = orderDescriptor["address"];
		
		local orderTimeline = orderDescriptor["timeline"];
  			
		local infoSentAt = nil;
		local driverAcceptedAt = nil;
		local orderPlacedAt = nil;
		local completedAt = nil;
		local pickupWillArriveAt = nil;
		local pickupWillLeaveAt = nil;
		local dropoffWillArriveAt = nil;
		local dropoffWillLeaveAt = nil;
		local pickupDidArriveAt = nil;
		local pickupDidLeaveAt = nil;
		local dropoffDidArriveAt = nil;
		local dropoffDidLeaveAt = nil;
		
		if orderTimeline ~= nil then
			infoSentAt = orderTimeline["sent"];
			driverAcceptedAt = orderTimeline["confirm"];
			completedAt = orderTimeline["completed"];
			orderPlacedAt = orderTimeline["placed"];
			
			pickupWillArriveAt = orderTimeline["pickup"]["in"]["estimated"];
			pickupWillLeaveAt = orderTimeline["pickup"]["out"]["estimated"];
			dropoffWillArriveAt = orderTimeline["dropoff"]["in"]["estimated"];
			dropoffWillLeaveAt = orderTimeline["dropoff"]["out"]["estimated"];
			
			pickupDidArriveAt = orderTimeline["pickup"]["in"]["actual"];
			pickupDidLeaveAt = orderTimeline["pickup"]["out"]["actual"];
			dropoffDidArriveAt = orderTimeline["dropoff"]["in"]["actual"];
			dropoffDidLeaveAt = orderTimeline["dropoff"]["out"]["actual"];
		end
  		
  		if pickupWillArriveAt ~= nil then
			local pickupDelayMinutes = math.floor((pickupWillArriveAt - nowTime)/60);
			local pickupDate = os.date( "*t", (localTime + (pickupWillArriveAt - nowTime)) );
			pickupTimeText.updateTime(pickupDate);
			orderPickupMinuteText.updateMinutes(pickupDelayMinutes);
		end
		
		if dropoffWillArriveAt ~= nil then
			local dropoffDelayMinutes = math.floor((dropoffWillArriveAt - nowTime)/60);
			local dropoffDate = os.date( "*t", (localTime + (dropoffWillArriveAt - nowTime)) );
			dropoffTimeText.updateTime(dropoffDate);
			orderDropoffMinuteText.updateMinutes(dropoffDelayMinutes);
		end
		
		if dropoffDidArriveAt ~= nil then
			orderNextEventCounter.alpha = 0.0;
		else
			orderNextEventCounter.alpha = 1.0;
		end
		
  		if orderPoNumber ~= nil and string.len(orderPoNumber) > 0 then
  			orderPoNumberText.text = "["..tostring(orderPoNumber).."]";
  			orderPoNumberText.alpha = 1.0;
  			-- orderTypeText.y = orderPoNumberText.y + orderPoNumberText.height;
  			-- roadmapGroup.y = 0;
  		else
  			orderPoNumberText.text = "";
  			orderPoNumberText.alpha = 0.0;
  			-- orderTypeText.y = orderPoNumberText.y + orderPoNumberText.height;
  			-- roadmapGroup.y = -orderPoNumberText.height;
  		end
  		
  		-- roadmapSpacerTop.y = orderTypeText.y + orderTypeText.height + 8;
		
		while pickupDetailsGroup.numChildren > 0 do
			local child = pickupDetailsGroup[1];
			if child ~= nil then
				child:removeSelf();
			end
		end
		
		-- Pickup description
		local pDataOffset = pickupTimeText.y + pickupTimeText.height*0.85;
		
		local pickupNameText = textmaker.newText("Unknown",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.2);
		pickupNameText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		pickupNameText.anchorX = pickupTimeText.anchorX;
		pickupNameText.anchorY = pickupTimeText.anchorY;
		pickupNameText.x = pickupTimeText.x;
		pickupNameText.y = pDataOffset;
		pickupNameText.setContents = function (text)
			if text ~= nil and string.len(text) > 0 then
				local limit = 23;
				if string.len(text) > limit then
					pickupNameText.text = string.sub(text, 0, (limit-3) ) .. "...";
				else
					pickupNameText.text = text;
				end
			end
		end
		pickupNameText.setContents(orderRestaurant["name"]);
		pickupDetailsGroup:insert(pickupNameText);
		pDataOffset = pDataOffset + pickupNameText.height*0.85;
		
		local pickupAddressAText = textmaker.newText("Unknown",0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
		pickupAddressAText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		pickupAddressAText.anchorX = pickupTimeText.anchorX;
		pickupAddressAText.anchorY = pickupTimeText.anchorY;
		pickupAddressAText.x = pickupTimeText.x;
		pickupAddressAText.y = pDataOffset;
		pickupAddressAText.setContents = function (text)
			if text ~= nil and string.len(text) > 0 then
				local limit = 27;
				if string.len(text) > limit then
					pickupAddressAText.text = string.sub(text, 0, (limit-3) ) .. "...";
				else
					pickupAddressAText.text = text;
				end
			end
		end
		pickupAddressAText.setContents(orderRestaurant["address"]);
		pickupDetailsGroup:insert(pickupAddressAText);
		pDataOffset = pDataOffset + pickupAddressAText.height*0.85;
		
		local pickupAddressBText = textmaker.newText("Unknown",0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
		pickupAddressBText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		pickupAddressBText.anchorX = pickupTimeText.anchorX;
		pickupAddressBText.anchorY = pickupTimeText.anchorY;
		pickupAddressBText.x = pickupTimeText.x;
		pickupAddressBText.y = pDataOffset;
		pickupAddressBText.setContents = function (text)
			if text ~= nil and string.len(text) > 0 then
				local limit = 27;
				if string.len(text) > limit then
					pickupAddressBText.text = string.sub(text, 0, (limit-3) ) .. "...";
				else
					pickupAddressBText.text = text;
				end
			end
		end
		pickupAddressBText.setContents(orderRestaurant["city"]..", "..orderRestaurant["state"].." "..tostring(orderRestaurant["zip"]));
		pickupDetailsGroup:insert(pickupAddressBText);
		pDataOffset = pDataOffset + pickupAddressBText.height*0.85;
	
		local pickupPhoneNumberText = textmaker.newText("Unknown",0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
		pickupPhoneNumberText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		pickupPhoneNumberText.anchorX = pickupTimeText.anchorX;
		pickupPhoneNumberText.anchorY = pickupTimeText.anchorY;
		pickupPhoneNumberText.x = pickupTimeText.x;
		pickupPhoneNumberText.y = pDataOffset;
		pickupPhoneNumberText.setNumber = function (text)
			if text ~= nil and string.len(text) > 0 then
				pickupPhoneNumberText.text = text;
			end
		end
		pickupPhoneNumberText.setNumber(orderRestaurant["phone"]);
		pickupDetailsGroup:insert(pickupPhoneNumberText);
		pDataOffset = pDataOffset + pickupPhoneNumberText.height*0.85;
		
		if orderRestaurant["notes"] ~= nil and string.len(orderRestaurant["notes"]) > 0 then
			pDataOffset = pDataOffset + 6;
			
			local restaurantNotes = orderRestaurant["notes"];
			
			local pickupNoteLineText = textmaker.newText(restaurantNotes,0,0,{"roboto-thin-italic"}, parameters.GRAPHICS.FONT_BASE_SIZE*0.75, containerWidth - dropoffTimeText.x, 0, "right");
			pickupNoteLineText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			pickupNoteLineText.anchorX = pickupTimeText.anchorX;
			pickupNoteLineText.anchorY = pickupTimeText.anchorY;
			pickupNoteLineText.x = pickupTimeText.x;
			pickupNoteLineText.y = pDataOffset;
			pickupDetailsGroup:insert(pickupNoteLineText);
			pDataOffset = pDataOffset + pickupNoteLineText.height;
		end
		
		pickupButtonsGroup.y = pickupTimeText.y + pickupTimeText.height + pickupDetailsGroup.height +4;
		
		while dropoffDetailsGroup.numChildren > 0 do
			local child = dropoffDetailsGroup[1];
			if child ~= nil then
				child:removeSelf();
			end
		end
		
		-- Dropoff description
		local dDataOffset = dropoffTimeText.y + dropoffTimeText.height*0.85;
		
		local dropoffNameText = textmaker.newText("Unknown",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.2);
		dropoffNameText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		dropoffNameText.anchorX = dropoffTimeText.anchorX;
		dropoffNameText.anchorY = dropoffTimeText.anchorY;
		dropoffNameText.x = dropoffTimeText.x;
		dropoffNameText.y = dDataOffset;
		dropoffNameText.setContents = function (text)
			if text ~= nil and string.len(text) > 0 then
				local limit = 23;
				if string.len(text) > limit then
					dropoffNameText.text = string.sub(text, 0, limit-3 ) .. "...";
				else
					dropoffNameText.text = text;
				end
			end
		end
		dropoffNameText.setContents(orderCustomer["name"]);
		dropoffDetailsGroup:insert(dropoffNameText);
		dDataOffset = dDataOffset + dropoffNameText.height*0.85;
		
		local dropoffAddressAText = textmaker.newText("Unknown",0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
		dropoffAddressAText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		dropoffAddressAText.anchorX = dropoffTimeText.anchorX;
		dropoffAddressAText.anchorY = dropoffTimeText.anchorY;
		dropoffAddressAText.x = dropoffTimeText.x;
		dropoffAddressAText.y = dDataOffset;
		dropoffAddressAText.setContents = function (text)
			if text ~= nil and string.len(text) > 0 then
				local limit = 27;
				if string.len(text) > limit then
					dropoffAddressAText.text = string.sub(text, 0, (limit-3) ) .. "...";
				else
					dropoffAddressAText.text = text;
				end
			end
		end
		dropoffAddressAText.setContents(orderDropoffAddress["address"]);
		dropoffDetailsGroup:insert(dropoffAddressAText);
		dDataOffset = dDataOffset + dropoffAddressAText.height*0.85;
		
		if orderDropoffAddress["alternative_address"] ~= nil then
			local dropoffAddressAdditionalText = textmaker.newText("Unknown",0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
			dropoffAddressAdditionalText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			dropoffAddressAdditionalText.anchorX = dropoffTimeText.anchorX;
			dropoffAddressAdditionalText.anchorY = dropoffTimeText.anchorY;
			dropoffAddressAdditionalText.x = dropoffTimeText.x;
			dropoffAddressAdditionalText.y = dDataOffset;
			dropoffAddressAdditionalText.setContents = function (text)
				if text ~= nil and string.len(text) > 0 then
					local limit = 27;
					if string.len(text) > limit then
						dropoffAddressAdditionalText.text = string.sub(text, 0, (limit-3) ) .. "...";
					else
						dropoffAddressAdditionalText.text = text;
					end
				end
			end
			dropoffAddressAdditionalText.setContents(orderDropoffAddress["alternative_address"]);
			dropoffDetailsGroup:insert(dropoffAddressAdditionalText);
			dDataOffset = dDataOffset + dropoffAddressAdditionalText.height*0.85;
		end
		
		local dropoffAddressBText = textmaker.newText("Unknown",0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
		dropoffAddressBText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		dropoffAddressBText.anchorX = dropoffTimeText.anchorX;
		dropoffAddressBText.anchorY = dropoffTimeText.anchorY;
		dropoffAddressBText.x = dropoffTimeText.x;
		dropoffAddressBText.y = dDataOffset;
		dropoffAddressBText.setContents = function (text)
			if text ~= nil and string.len(text) > 0 then
				local limit = 27;
				if string.len(text) > limit then
					dropoffAddressBText.text = string.sub(text, 0, (limit-3) ) .. "...";
				else
					dropoffAddressBText.text = text;
				end
			end
		end
		dropoffAddressBText.setContents(orderDropoffAddress["city"]..", "..orderDropoffAddress["state"].." "..tostring(orderDropoffAddress["zip"]));
		dropoffDetailsGroup:insert(dropoffAddressBText);
		dDataOffset = dDataOffset + dropoffAddressBText.height*0.85;
	
		local dropoffPhoneNumberText = textmaker.newText("Unknown",0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
		dropoffPhoneNumberText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		dropoffPhoneNumberText.anchorX = dropoffTimeText.anchorX;
		dropoffPhoneNumberText.anchorY = dropoffTimeText.anchorY;
		dropoffPhoneNumberText.x = dropoffTimeText.x;
		dropoffPhoneNumberText.y = dDataOffset;
		dropoffPhoneNumberText.setNumber = function (text)
			if text ~= nil and string.len(text) > 0 then
				dropoffPhoneNumberText.text = text;
			end
		end
		dropoffPhoneNumberText.setNumber(orderCustomer["phone"]);
		dropoffDetailsGroup:insert(dropoffPhoneNumberText);
		dDataOffset = dDataOffset + dropoffPhoneNumberText.height*0.85;
		
		if orderDropoffAddress["notes"] ~= nil and string.len(orderDropoffAddress["notes"]) > 0 then
			dDataOffset = dDataOffset + 6;
			
			local addressNotes = orderDropoffAddress["notes"];
			
			local addressNoteLineText = textmaker.newText(addressNotes,0,0,{"roboto-thin-italic"}, parameters.GRAPHICS.FONT_BASE_SIZE*0.75, (containerWidth - dropoffTimeText.x - 4), 0, "left");
			addressNoteLineText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			addressNoteLineText.anchorX = dropoffTimeText.anchorX;
			addressNoteLineText.anchorY = dropoffTimeText.anchorY;
			addressNoteLineText.x = dropoffTimeText.x;
			addressNoteLineText.y = dDataOffset;
			dropoffDetailsGroup:insert(addressNoteLineText);
			dDataOffset = dDataOffset + addressNoteLineText.height;
		end
		
		if orderCustomer["notes"] ~= nil and string.len(orderCustomer["notes"]) > 0 then
			dDataOffset = dDataOffset + 6;
			
			local customerNotes = orderCustomer["notes"];
			
			local customerNoteLineText = textmaker.newText(customerNotes,0,0,{"roboto-thin-italic"}, parameters.GRAPHICS.FONT_BASE_SIZE*0.75, (containerWidth - dropoffTimeText.x - 4), 0, "left");
			customerNoteLineText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			customerNoteLineText.anchorX = dropoffTimeText.anchorX;
			customerNoteLineText.anchorY = dropoffTimeText.anchorY;
			customerNoteLineText.x = dropoffTimeText.x;
			customerNoteLineText.y = dDataOffset;
			dropoffDetailsGroup:insert(customerNoteLineText);
			dDataOffset = dDataOffset + customerNoteLineText.height;
		end
		
		dropoffButtonsGroup.y = dropoffTimeText.y + dropoffTimeText.height + dropoffDetailsGroup.height + 4; 
  		
  		local orderStatusDescriptor = getOrderStatusDescriptor(orderDescriptor);
  		
  		-- Check summary
  		local orderItems = orderDescriptor["items"];
  		local orderFees = orderDescriptor["fees"];
  		local orderAdjustments = orderDescriptor["adjustments"];
  		local orderPayments = orderDescriptor["payments"];
  		local orderTotal = orderDescriptor["total"];
  		
		local fontSize = parameters.GRAPHICS.FONT_BASE_SIZE*0.85;
		
		local yOffset = math.max((dropoffButtonsGroup.y + dropoffButtonsGroup.height + 28),(orderDropoffMinuteBox.y + orderDropoffMinuteBox.height));
		
		roadmapSpacerBottom.y = yOffset;
		yOffset = yOffset + 12;
		
		while itemsGroup.numChildren > 0 do
			local child = itemsGroup[1];
			if child ~= nil then
				child:removeSelf();
			end
		end
		
		-- Add order notes if exist
		if orderDescriptor["notes"] ~= nil then
			local orderNotes = orderDescriptor["notes"];
			
			local notesHeaderText = textmaker.newText("Notes:",0,0,{"roboto-bold"}, fontSize*1.25);
			notesHeaderText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			notesHeaderText.anchorX = 0.0;
			notesHeaderText.anchorY = 0.0;
			notesHeaderText.x = 4;
			notesHeaderText.y = yOffset;
			itemsGroup:insert(notesHeaderText);
			yOffset = yOffset + notesHeaderText.height;
			
			local orderNoteLineText = textmaker.newText(orderNotes,0,0,{"roboto-thin-italic"}, parameters.GRAPHICS.FONT_BASE_SIZE*0.75,containerWidth-8,0,"left");
			orderNoteLineText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			orderNoteLineText.anchorX = 0.0;
			orderNoteLineText.anchorY = 0.0;
			orderNoteLineText.x = 4;
			orderNoteLineText.y = yOffset;
			itemsGroup:insert(orderNoteLineText);
			yOffset = yOffset + orderNoteLineText.height + 12;
			
			--[[
			while string.len(orderNotes) > 54 do
				local notesLine = string.sub( orderNotes, 0, 54 );
				local remaining = string.sub( orderNotes, 55 );
				
				orderNotes = remaining;
				
				local orderNoteLineText = textmaker.newText(notesLine,0,0,{"roboto-thin-italic"}, parameters.GRAPHICS.FONT_BASE_SIZE*0.75);
				orderNoteLineText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
				orderNoteLineText.anchorX = 0.0;
				orderNoteLineText.anchorY = 0.0;
				orderNoteLineText.x = 4;
				orderNoteLineText.y = yOffset;
				itemsGroup:insert(orderNoteLineText);
				yOffset = yOffset + orderNoteLineText.height*0.85;
			end
			
			local orderNoteLineText = textmaker.newText(orderNotes,0,0,{"roboto-thin-italic"}, parameters.GRAPHICS.FONT_BASE_SIZE*0.75);
			orderNoteLineText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			orderNoteLineText.anchorX = 0.0;
			orderNoteLineText.anchorY = 0.0;
			orderNoteLineText.x = 4;
			orderNoteLineText.y = yOffset;
			itemsGroup:insert(orderNoteLineText);
			yOffset = yOffset + orderNoteLineText.height*0.85;
			
			yOffset = yOffset + 12;
			--]]
		end
		
		if orderItems ~= nil then
			local orderMenus = orderItems["menus"];
			local orderStandaloneItems = orderItems["items"];
			
			if orderMenus ~= nil then
				for menuNumber=1, #orderMenus do
					local orderMenu = orderMenus[menuNumber];
					
					local orderMenuName = orderMenu["name"];
					local orderMenuItems = orderMenu["items"];
					
					logger.log("Creating MENU: "..tostring(orderMenuName));
					
					if string.len(orderMenuName) > 30 then
						orderMenuName = string.sub(orderMenuName, 0, (30-3) ) .. "...";
					end
					
					local menuNameText = textmaker.newText(tostring(orderMenuName),0,0,{"roboto-bold"}, fontSize*1.25);
					menuNameText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
					menuNameText.anchorX = 0.0;
					menuNameText.anchorY = 0.0;
					menuNameText.x = 4;
					menuNameText.y = yOffset;
					itemsGroup:insert(menuNameText);
					yOffset = yOffset + fontSize*1.5 + 4;
					
					if orderMenuItems ~= nil then
						for itemNumber=1, #orderMenuItems do
							local orderMenuItem = orderMenuItems[itemNumber];
							local omiName = orderMenuItem["name"];
							local omiPrice = orderMenuItem["price"];
							local omiQuantity = orderMenuItem["quantity"];
							local omiOptions = orderMenuItem["options"];
							local omiLabel = orderMenuItem["label"];
							local omiSpecialInstructions = orderMenuItem["special_instructions"];
						
							local menuItemLine = display.newRect(0,0,containerWidth, 1);
							menuItemLine.anchorX = notesSpacerBottom.anchorX;
							menuItemLine.anchorY = notesSpacerBottom.anchorY;
							menuItemLine.alpha = notesSpacerBottom.alpha;
							menuItemLine.x = notesSpacerBottom.x;
							menuItemLine.y = yOffset;
							itemsGroup:insert(menuItemLine);
							yOffset = yOffset + 2;
							
							local omiHeader = omiName;
							if string.len(omiHeader) > 32 then
								omiHeader = string.sub(omiHeader, 0, (32-3) ) .. "...";
							end
							
							
							if omiLabel ~= nil then
								if string.len(omiLabel) > 45 then
									omiLabel = string.sub(omiLabel, 0, (45-3) ) .. "...";
								end
								
								local omiLabelText = textmaker.newText("["..tostring(omiLabel).."]",0,0,{"roboto-bold-italic"}, fontSize);
								omiLabelText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
								omiLabelText.anchorX = 0.0;
								omiLabelText.anchorY = 0.0;
								omiLabelText.x = 4;
								omiLabelText.y = yOffset;
								itemsGroup:insert(omiLabelText);
								
								yOffset = yOffset + omiLabelText.height;
							end
							
							local omiNameText = textmaker.newText(tostring(omiQuantity).."x "..tostring(omiHeader),0,0,{"roboto-bold"}, fontSize);
							omiNameText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
							omiNameText.anchorX = 0.0;
							omiNameText.anchorY = 0.0;
							omiNameText.x = 4;
							omiNameText.y = yOffset;
							itemsGroup:insert(omiNameText);
							
							if omiQuantity ~= nil and omiQuantity > 0 then
								local omiPriceText = textmaker.newText("$"..string.format("%0.2f",omiPrice),0,0,{"roboto-regular"}, fontSize);
								omiPriceText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
								omiPriceText.anchorX = 1.0;
								omiPriceText.anchorY = 0.0;
								omiPriceText.x = containerWidth - 4;
								omiPriceText.y = yOffset;
								itemsGroup:insert(omiPriceText);
							end
							
							yOffset = yOffset + fontSize*1.25;
							
							if omiSpecialInstructions ~= nil then
								--[[if string.len(omiSpecialInstructions) > 50 then
									omiSpecialInstructions = string.sub(omiSpecialInstructions, 0, (50-3) ) .. "...";
								end--]]
								omiSpecialInstructions = "\"" .. omiSpecialInstructions .. "\""
							
								oaSpecialInstructionsText = textmaker.newText(tostring(omiSpecialInstructions),0,0,{"roboto-light-italic"}, fontSize*0.85,containerWidth-8,0,"left");
								oaSpecialInstructionsText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
								oaSpecialInstructionsText.anchorX = 0.0;
								oaSpecialInstructionsText.anchorY = 0.0;
								oaSpecialInstructionsText.x = 4;
								oaSpecialInstructionsText.y = yOffset;
								itemsGroup:insert(oaSpecialInstructionsText);
								
								yOffset = yOffset + oaSpecialInstructionsText.height + 4;
							end
							
							if omiOptions ~= nil then
								for oaNumber=1, #omiOptions do
									local oa = omiOptions[oaNumber];
									local oaDesc = oa["desc"];
									local oaQuantity = oa["quantity"];
									local oaPrice = oa["price"];
									local oaSuboptions = oa["options"];
									
									if string.len(oaDesc) > 38 then
										oaDesc = string.sub(oaDesc, 0, (38-3) ) .. "...";
									end
									
									local oaDescText = nil;
									oaDescText = textmaker.newText("   L_ "..tostring(oaQuantity).."x "..tostring(oaDesc),0,0,{"roboto-thin"}, fontSize*0.85);
									oaDescText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
									oaDescText.anchorX = 0.0;
									oaDescText.anchorY = 0.0;
									oaDescText.x = 4;
									oaDescText.y = yOffset;
									itemsGroup:insert(oaDescText);
									
									if oaPrice ~= nil and oaPrice > 0.0 and oaQuantity ~= nil and oaQuantity > 0 then
										local oaPriceText = textmaker.newText("$"..string.format("%0.2f",(oaPrice*oaQuantity)),0,0,{"roboto-thin"}, fontSize*0.85);
										oaPriceText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
										oaPriceText.anchorX = 1.0;
										oaPriceText.anchorY = 0.0;
										oaPriceText.x = containerWidth - 4;
										oaPriceText.y = yOffset;
										itemsGroup:insert(oaPriceText);
									end
			
									yOffset = yOffset + fontSize*1.25;
									
									if oaSuboptions ~= nil then
										for obNumber=1, #oaSuboptions do
											local ob = oaSuboptions[obNumber];
											local obDesc = ob["desc"];
											local obSuboptions = ob["options"];
											
											if string.len(obDesc) > 36 then
												obDesc = string.sub(obDesc, 0, (36-3) ) .. "...";
											end
									
											local obDescText = textmaker.newText("         L_ "..tostring(obDesc),0,0,{"roboto-thin"}, fontSize*0.85);
											obDescText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
											obDescText.anchorX = 0.0;
											obDescText.anchorY = 0.0;
											obDescText.x = 4;
											obDescText.y = yOffset;
			
											itemsGroup:insert(obDescText);
											yOffset = yOffset + fontSize*1.25;
											
											if obSuboptions ~= nil then
												for ocNumber=1, #obSuboptions do
													local oc = obSuboptions[ocNumber];
													local ocDesc = oc["desc"];
													local ocSuboptions = oc["options"];
													
													if string.len(ocDesc) > 34 then
														ocDesc = string.sub(ocDesc, 0, (34-3) ) .. "...";
													end
									
													local ocDescText = textmaker.newText("               L_ "..tostring(ocDesc),0,0,{"roboto-thin"}, fontSize*0.85);
													ocDescText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
													ocDescText.anchorX = 0.0;
													ocDescText.anchorY = 0.0;
													ocDescText.x = 4;
													ocDescText.y = yOffset;
			
													itemsGroup:insert(ocDescText);
													yOffset = yOffset + fontSize*1.25;
													
													if ocSuboptions ~= nil then
														for odNumber=1, #ocSuboptions do
															local od = ocSuboptions[odNumber];
															local odDesc = od["desc"];
															local odSuboptions = od["options"];
															
															if string.len(odDesc) > 32 then
																odDesc = string.sub(odDesc, 0, (32-3) ) .. "...";
															end
									
															local odDescText = textmaker.newText("                     L_ "..tostring(odDesc),0,0,{"roboto-thin"}, fontSize*0.85);
															odDescText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
															odDescText.anchorX = 0.0;
															odDescText.anchorY = 0.0;
															odDescText.x = 4;
															odDescText.y = yOffset;
			
															itemsGroup:insert(odDescText);
															yOffset = yOffset + fontSize*1.25;
															
															if odSuboptions ~= nil then
																for oeNumber=1, #odSuboptions do
																	local oe = odSuboptions[oeNumber];
																	local oeDesc = oe["desc"];
																	local oeSuboptions = oe["options"];
																	
																	if string.len(oeDesc) > 30 then
																		oeDesc = string.sub(oeDesc, 0, (30-3) ) .. "...";
																	end
									
																	local oeDescText = textmaker.newText("                           L_ "..tostring(oeDesc),0,0,{"roboto-thin"}, fontSize*0.85);
																	oeDescText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
																	oeDescText.anchorX = 0.0;
																	oeDescText.anchorY = 0.0;
																	oeDescText.x = 4;
																	oeDescText.y = yOffset;
			
																	itemsGroup:insert(oeDescText);
																	yOffset = yOffset + fontSize*1.25;
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						
							-- between items
							yOffset = yOffset + 4;
						end
					end
					
					-- between menus
					yOffset = yOffset + 12;
				end
			end
		end
		yOffset = yOffset + 4;
		notesSpacerBottom.y = yOffset;
		yOffset = yOffset + 4;
		
		if orderFees ~= nil then
			while feesGroup.numChildren > 0 do
				local child = feesGroup[1];
				if child ~= nil then
					child:removeSelf();
				end
			end
    
			for i=1, #orderFees do
				local orderFee = orderFees[i];
				local orderFeeName = tostring(orderFee["name"]);
				
				logger.log(orderFeeName..": "..string.format("%0.2f",orderFee["amount"]));
				
				if string.len(orderFeeName) > 26 then
					orderFeeName = string.sub(orderFeeName, 0, (26-3) ) .. "...";
				end
			
				local feeText = textmaker.newText(orderFeeName..": $"..string.format("%0.2f",orderFee["amount"]),0,0,{"roboto-regular"}, fontSize);
				feeText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
				feeText.anchorX = 1.0;
				feeText.anchorY = 0.0;
				feeText.x = _W - 4;
				feeText.y = yOffset;
			
				feesGroup:insert(feeText);
				yOffset = yOffset + fontSize*1.25;
			end
		end
		yOffset = yOffset + 4;
		checkPartialLine.y = yOffset;
		
		if orderAdjustments ~= nil then
			while discountGroup.numChildren > 0 do
				local child = discountGroup[1];
				if child ~= nil then
					child:removeSelf();
				end
			end
			
			for i=1, #orderAdjustments do
				local orderAdjustment = orderAdjustments[i];
				local orderAdjustmentName = tostring(orderAdjustment["name"]);
				
				logger.log(orderAdjustmentName..": "..string.format("%0.2f",orderAdjustment["amount"]));
			
				if string.len(orderAdjustmentName) > 26 then
					orderAdjustmentName = string.sub(orderAdjustmentName, 0, (26-3) ) .. "...";
				end
			
				local adjustmentText = textmaker.newText(orderAdjustmentName..": $"..string.format("%0.2f",orderAdjustment["amount"]),0,0,{"roboto-regular"}, fontSize);
				adjustmentText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
				adjustmentText.anchorX = 1.0;
				adjustmentText.anchorY = 0.0;
				adjustmentText.x = _W - 4;
				adjustmentText.y = yOffset;
			
				discountGroup:insert(adjustmentText);
				yOffset = yOffset + fontSize*1.25;
			end
		end
		yOffset = yOffset + 4;
		checkDiscountLine.y = yOffset;
		
		if orderPayments ~= nil then
			while paymentGroup.numChildren > 0 do
				local child = paymentGroup[1];
				if child ~= nil then
					child:removeSelf();
				end
			end
			
			for i=1, #orderPayments do
				local orderPayment = orderPayments[i];
				local orderPaymentName = tostring(orderPayment["name"]);
				
				logger.log(orderPaymentName..": "..string.format("%0.2f",orderPayment["amount"]));
				
				if string.len(orderPaymentName) > 26 then
					orderPaymentName = string.sub(orderPaymentName, 0, (26-3) ) .. "...";
				end
			
				local paymentText = textmaker.newText(orderPaymentName..": $"..string.format("%0.2f",orderPayment["amount"]),0,0,{"roboto-regular"}, fontSize);
				paymentText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
				paymentText.anchorX = 1.0;
				paymentText.anchorY = 0.0;
				paymentText.x = _W - 4;
				paymentText.y = yOffset;
			
				paymentGroup:insert(paymentText);
				yOffset = yOffset + fontSize*1.25;
			end
		end
		yOffset = yOffset + 4;
		paymentTypeLine.y = yOffset;
		
		if orderTotal ~= nil then
			while totalGroup.numChildren > 0 do
				local child = totalGroup[1];
				if child ~= nil then
					child:removeSelf();
				end
			end
			
			logger.log("TOTAL: "..string.format("%0.2f",orderTotal));
			
			local totalFontSize = fontSize*1.25;
			local totalText = textmaker.newText("Total: $"..string.format("%0.2f",orderTotal),0,0,{"roboto-bold"}, totalFontSize);
			totalText:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			totalText.anchorX = 1.0;
			totalText.anchorY = 0.0;
			totalText.x = _W - 4;
			totalText.y = yOffset;
			
			totalGroup:insert(totalText);
			yOffset = yOffset + totalFontSize*1.25;
		end
		yOffset = yOffset + 4;
		totalLine.y = yOffset;
		
		finalSpacerBottom.y = totalLine.y + totalLine.height*0.5 + 50;
		
		scrollView:setScrollHeight(finalSpacerBottom.y + finalSpacerBottom.height);
  		
  		-- Drawing
  		--[[
  		subtotalText.updateAmount(math.random()*150);
		deliveryFeeText.updateAmount(math.random()*150);
		gratuityText.updateAmount(math.random()*150);
		serviceFeeText.updateAmount(math.random()*150);
		taxText.updateAmount(math.random()*150);
		adjustmentText.updateAmount(math.random()*150);
		couponText.updateAmount(math.random()*150);
		paymentTypeText.updateAmount(math.random()*150);
		totalText.updateAmount(math.random()*150);
		--]]
  		
  		if orderType == 0 then
  			backgroundOrderTargetTypeIcon.alpha = 0.0;
  			backgroundOrderASAPTypeIcon.alpha = 0.05;
  			-- orderTypeTargetIcon.alpha = 0.0;
  			-- orderTypeASAPIcon.alpha = 1.0;
  			orderTypeText.text = "ASAP";
  		else
  			backgroundOrderTargetTypeIcon.alpha = 0.05;
  			backgroundOrderASAPTypeIcon.alpha = 0.0;
  			-- orderTypeTargetIcon.alpha = 1.0;
  			-- orderTypeASAPIcon.alpha = 0.0;
  			orderTypeText.text = "TARGET";
  		end
  		
  		if orderStatusDescriptor ~= nil then
  			local orderNumberContents = tostring(orderId);
  		
  			orderNumberText.text = orderNumberContents;
			orderCurrentStatusText.text = orderStatusDescriptor.text;
			orderCurrentStatusText:setFillColor(math.min(1,orderStatusDescriptor.color[1]*1.25),math.min(1,orderStatusDescriptor.color[2]*1.25),math.min(1,orderStatusDescriptor.color[3]*1.25));
  			orderPoNumberText.x = orderNumberText.x + orderNumberText.width + 4;
  		
  			-- If next action is enabled for current status
  			if orderStatusDescriptor.nextStatus ~= nil then
  				nextStatusCode = orderStatusDescriptor.nextStatus["code"];
  				local nextOrderStatusColor = orderStatusDescriptor.nextStatus["color"];
				local nextOrderStatusName = orderStatusDescriptor.nextStatus["text"];
				
				actionButtonOverColor = nextOrderStatusColor;
				actionButtonActiveColor = {math.min(1.0,actionButtonOverColor[1]*1.25),math.min(1.0,actionButtonOverColor[2]*1.25),math.min(1.0,actionButtonOverColor[3]*1.25)};
		
				actionButtonBg:setFillColor(nextOrderStatusColor[1],nextOrderStatusColor[2],nextOrderStatusColor[3]);
				actionButtonText.text = nextOrderStatusName;
  				
  				actionButtonGroup.alpha = 1.0;
  				actionEnabled = true;
  			else
  				actionButtonGroup.alpha = 0.0;
  				actionEnabled = false;
  				nextStatusCode = nil;
  			end
  		else
  			logger.log("orderStatusDescriptor is nil");
  		end
		
		scrollView:scrollToPosition{ y = 0, time = 0 }
		
		if pickupDidArriveAt ~= nil and pickupDidArriveAt > 0 then
			orderPickupMinuteBox:setFillColor(0.0,1.0,0.0);
			orderPickupMinuteIcon.alpha = 1.0;
			orderPickupMinuteText.alpha = 0.0;
		else
			orderPickupMinuteBox:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			orderPickupMinuteIcon.alpha = 0.0;
			orderPickupMinuteText.alpha = 1.0;
		end
		
		if pickupDidLeaveAt ~= nil and pickupDidLeaveAt > 0 then
			orderTimelineRect:setFillColor(0.0,1.0,0.0);
		else
			orderTimelineRect:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
		end
		
		if dropoffDidArriveAt ~= nil and dropoffDidArriveAt > 0 then
			orderDropoffMinuteBox:setFillColor(0.0,1.0,0.0);
			orderDropoffMinuteIcon.alpha = 1.0;
			orderDropoffMinuteText.alpha = 0.0;
		else
			orderDropoffMinuteBox:setFillColor(mainTextColor[1],mainTextColor[2],mainTextColor[3]);
			orderDropoffMinuteIcon.alpha = 0.0;
			orderDropoffMinuteText.alpha = 1.0;
		end
		
		if completedAt ~= nil and completedAt > 0 then
			bottomGradient.y = backButtonBg.y - backButtonBg.height - (containerHeight - backButtonBg.y);
		else
			bottomGradient.y = actionButtonBg.y - actionButtonBg.height - (containerHeight - backButtonBg.y);
		end
		scrollView.height = containerHeight - topGradient.y - (containerHeight - bottomGradient.y) + bottomGradient.height - 2;
  	end
  	
  	local loopCounter = 0; -- temp
  	local onLoaderRepeat = function (event)
	  	if receivedData ~= nil then
	  		formatOrder();
	  		
	  		loader.stop();
  			loopCounter = 0;
	  	elseif loopCounter > 100 then
	  		-- TODO
	  		-- probably stucked
	  	end
	  	
	  	loopCounter = loopCounter+1;
	end
  	loader.initialize({onRepeat=onLoaderRepeat});
  	
  	local lastMainLoopUpdate = system.getTimer();
  	local onMainLoop = function (event)
  		if event ~= nil and event.time ~= nil and receivedData ~= nil then
  			if event.time > lastMainLoopUpdate + 500 then
  				local utcDate = os.date( "!*t" );
				local utcTime = tonumber(os.time(utcDate));
				local epochTime = tonumber(os.time{year=1970, month=1, day=1, hour=0});
				local nowTime = (utcTime - epochTime);
				local localDate = os.date( "*t" );
				local localTime = tonumber(os.time(localDate));
		
				-- local driverDelay = (orderTargetArriveAt - nowTime);
	
				local orderDescriptor = receivedData["order"];
				local orderId = orderDescriptor["order_id"];
				local orderStatus = menunu.getStatusName(orderDescriptor["order_status_id"]);
				
				local orderTimeline = orderDescriptor["timeline"];
  			
				local infoSentAt = nil;
				local driverAcceptedAt = nil;
				local completedAt = nil;
				local pickupWillArriveAt = nil;
				local pickupWillLeaveAt = nil;
				local dropoffWillArriveAt = nil;
				local dropoffWillLeaveAt = nil;
		
				if orderTimeline ~= nil then
					infoSentAt = orderTimeline["sent"];
					driverAcceptedAt = orderTimeline["confirm"];
					completedAt = orderTimeline["completed"];
			
					pickupWillArriveAt = orderTimeline["pickup"]["in"]["estimated"];
					pickupWillLeaveAt = orderTimeline["pickup"]["out"]["estimated"];
					dropoffWillArriveAt = orderTimeline["dropoff"]["in"]["estimated"];
					dropoffWillLeaveAt = orderTimeline["dropoff"]["out"]["estimated"];
					
					pickupDidArriveAt = orderTimeline["pickup"]["in"]["actual"];
					pickupDidLeaveAt = orderTimeline["pickup"]["out"]["actual"];
					dropoffDidArriveAt = orderTimeline["dropoff"]["in"]["actual"];
					dropoffDidLeaveAt = orderTimeline["dropoff"]["out"]["actual"];
				end
				
				if pickupWillArriveAt ~= nil and pickupDidArriveAt == nil then
					local pickupDelaySeconds = math.floor(pickupWillArriveAt - nowTime);
					
					local pickupDelayMinutes = math.floor(pickupDelaySeconds/60);
					orderPickupMinuteText.updateMinutes(pickupDelayMinutes);
				end
				
				if dropoffWillArriveAt ~= nil and dropoffDidArriveAt == nil then
					local dropoffDelaySeconds = math.floor(dropoffWillArriveAt - nowTime);
					orderNextEventCounter.updateCounter(dropoffDelaySeconds);
					
					local dropoffDelayMinutes = math.floor(dropoffDelaySeconds/60);
					orderDropoffMinuteText.updateMinutes(dropoffDelayMinutes);
				end
  			
  				lastMainLoopUpdate = event.time;
  			end
  		end
  	end
  	
  	Container.setOrderData = function (oData)
  		if oData ~= nil and oData["info_code"] ~= nil then
			orderData = oData;
			receivedData = null;
			nextStatusCode = null;
		
			logger.log("Requesting infoCode: "..oData["info_code"]);
		
			local function orderReceivedCB(response)
				receivedData = response["data"];
			end
		
			loader.start();
			menunu.getOrderDetails(oData["info_code"],orderReceivedCB);
  		end
  	end
  	
  	Container.setCallback = function (cbFunction)
  		navigationCallback = cbFunction;
  	end
  	
  	Container.enablePanel = function (flag)
  		panelEnabled = flag;
  		actionEnabled = false;
  		actionButtonGroup.alpha = 0.0;
  		
  		if flag == true then
  			Runtime:addEventListener("enterFrame", onMainLoop);
  		else
  			loader.stop();
  			actionButtonGroup.alpha = 0.0;
  			Runtime:removeEventListener("enterFrame", onMainLoop);
  		end
  	end
  	
  	-- Functions END
  	
  	return Container;
end

return M;