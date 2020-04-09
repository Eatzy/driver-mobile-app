local M = {};

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local widget = require( "widget" )
local detailsGen = require("app.modules.detailsgen")

M.newTab = function (params)
  	local containerEnabled = false;
  	local containerLoaded = false;
  	
	local containerWidth = _W;
	local containerHeight = _H;
	local externalLoader = nil;
	local notificationsGw = nil;
	local navigationGW = nil;
  	
  	local onDetailsAnimation = false;
  	
  	local currentRuns = {};
	
	if params ~= nil then
		if params["width"] ~= nil then containerWidth = params["width"]; end
		if params["height"] ~= nil then containerHeight = params["height"]; end
		if params["loader"] ~= nil then externalLoader = params["loader"]; end
		if params["notifications"] ~= nil then notificationsGw = params["notifications"]; end
		if params["navigation"] ~= nil then navigationGW = params["navigation"]; end
	end
	
	-- model variables
	local orderFuncs = {};
	
	local runsReceived = {};
	
	local ordersRequestPeriod = 10000; -- in milliseconds
	local isRequestingOrders = false;
	local orderRequestTimer = nil;
	
	local Container = display.newGroup();
	
	local Background = display.newGroup();
  	local Foreground = display.newGroup();
  	local GUI = display.newGroup();
  	
  	Container:insert(Background);
  	Container:insert(Foreground);
  	Container:insert(GUI);
  	
  	local loaderParams = {};
  	loaderParams["width"] = containerWidth;
	loaderParams["height"] = containerHeight;
	loaderParams["text"] = parameters.GRAPHICS.TEXT["loading_orders"];
	loaderParams["bgcolor"] = parameters.GRAPHICS.COLORS["background_orders"];
  	local loaderBuilder = require( "app.lib.loader" );
  	local loader = loaderBuilder.newLoader(loaderParams);
  	loader.initialize();

  	local backgroundBox = display.newRect(0,0,containerWidth,containerHeight);
  	backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	backgroundBox.anchorX = 0.5;
  	backgroundBox.anchorY = 0.0;
  	backgroundBox.x = _CX;
  	backgroundBox.y = 0;
  	Background:insert(backgroundBox);
  	
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
		
		if toRefresh == true and onDetailsAnimation ~= true then
			logger.log("Refreshing orders list");
			loader.start();
  			
			if orderRequestTimer ~= nil then
				timer.cancel(orderRequestTimer);
				orderRequestTimer = nil;
			end
			orderRequestTimer = timer.performWithDelay( ordersRequestPeriod, orderFuncs.requestOrders, -1 );
			orderFuncs.requestOrders();
		end

		return true
  	end
  	
  	local scrollView = widget.newScrollView {
		left = 0,
		top = 0,
		width = containerWidth,
		height = containerHeight,
		hideBackground = true,
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollViewListener
	}
	Foreground:insert( scrollView );
	
	local bottomGradient = display.newImageRect("media/images/icons/gradient.png",_W,16);
  	bottomGradient:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	bottomGradient.anchorX = 0.5;
  	bottomGradient.anchorY = 1.0;
  	bottomGradient.x = _CX;
  	bottomGradient.y = containerHeight;
  	
  	Foreground:insert( bottomGradient );
  	
  	local tabNameText = textmaker.newText("This is the order tab",0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
  	tabNameText:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	tabNameText.anchorX = 0.5;
  	tabNameText.anchorY = 0.5;
  	tabNameText.x = _CX;
  	tabNameText.y = containerHeight*0.1;
  	scrollView:insert(tabNameText);
  	
	local ordersContainer = display.newGroup();
  	scrollView:insert(ordersContainer);
  	
  	-- Details block
  	local detailsPageParams = {};
  	detailsPageParams["width"] = _W;
  	detailsPageParams["height"] = _H;
  	
  	local detailsGroup = detailsGen.newPage(detailsPageParams);
  	detailsGroup.alpha = 0.0;
  	detailsGroup.x = _W;
  	
  	Foreground:insert( detailsGroup );
  	
  	GUI:insert(loader);
  	
  	-- FUNCTIONS BEGIN
  	local function buildOrderBlock (blockNumber, orderData, onDetailsListener, onDirectionsListener)
		local orderId = orderData["id"];
		local orderInfoCode = orderData["info_code"];
		local orderStatus = orderData["status"];
		local orderEventName = orderData["type"];
		local orderRestaurant = orderData["restaurant"];
		local orderAddress = orderData["address"];
		local orderCustomer = orderData["customer"];
		local orderType = orderData["delivery"];
		
		--[[local orderTargetArriveAt = orderData["target_arrive_at"];
		local orderTargetPickupAt = orderData["target_pickup_at"];
		local orderAcceptedAt = orderData["driver_confirmed_at"];
		local orderAtRestaurantAt = orderData["arrived_rest_at"];
		local orderPickedUpAt = orderData["picked_up_at"];
		local orderAtDropoffAt = orderData["arrived_cust_at"];--]]
		
		local orderEstimatedTime = orderData["estimated"];
		local orderActualTime = orderData["actual"];
		
		local orderStatusName = nil;
		
		local targetTimeForType = nil;
		if orderType == nil then
			logger.log("orderType not found");
			return nil;
		else
			--[[
			if orderEventName == 'pickup' then
				if orderTargetPickupAt ~= nil then
					targetTimeForType = tonumber(orderTargetPickupAt);
				else
					logger.log("orderTargetPickupAt not found for pickup block");
					return nil;
				end
			elseif orderEventName == 'dropoff' then
				if orderTargetArriveAt ~= nil then
					targetTimeForType = tonumber(orderTargetArriveAt);
				else
					logger.log("orderTargetArriveAt not found for dropoff block");
					return nil;
				end
			else
				logger.log("orderType unknown: "..tostring(orderType));
				return nil;
			end
			--]]
			if orderEstimatedTime ~= nil then
				targetTimeForType = tonumber(orderEstimatedTime);
			else
				logger.log("orderEstimatedTime not found for dropoff block");
				return nil;
			end
		end
		
		if orderStatus ~= nil then
			orderStatusName = menunu.getStatusName(orderStatus);
			if orderStatusName == "completed" then
				logger.log(orderInfoCode..": "..orderStatusName.." -> ignoring block");
				return nil;
			end
		end
		
		if orderInfoCode ~= nil and orderStatus ~= nil then
			local orderBlock = display.newGroup();
			
			-- Block variables
			local blockBorder = 4;
			local blockWidth = containerWidth - blockBorder*2;
			local blockHeight = 100;
			local blockAngleRadius = 16;
			
			orderBlock.infoCode = orderInfoCode;
			orderBlock.orderData = orderData;
			
			local orderColor = parameters.GRAPHICS.COLORS["eatzydriver_colorscheme_05"];
			
			local orderTargetOrderNumberText = tostring(orderId);
			local orderTargetNameText = "Unknown";
			
			-- Format dropoff address
			local orderTargetAddressTextA = "";
			local orderTargetAddressTextB = "";
			if orderAddress["address"] ~= nil then
				orderTargetAddressTextA = orderTargetAddressTextA .. tostring(orderAddress["address"]);
			end
			if orderAddress["alternative_address"] ~= nil then
				orderTargetAddressTextA = orderTargetAddressTextA .. ", " .. tostring(orderAddress["alternative_address"]);
			end
			if orderAddress["city"] ~= nil then
				orderTargetAddressTextB = orderTargetAddressTextB .. tostring(orderAddress["city"]);
			end
			if orderAddress["state"] ~= nil then
				orderTargetAddressTextB = orderTargetAddressTextB .. ", " .. tostring(orderAddress["state"]);
			end
			if orderAddress["zip"] ~= nil then
				orderTargetAddressTextB = orderTargetAddressTextB .. " " .. tostring(orderAddress["zip"]);
			end
			
			-- Format pickup address
			local orderRestaurantAddressTextA = "";
			local orderRestaurantAddressTextB = "";
			if orderRestaurant["address"] ~= nil then
				orderRestaurantAddressTextA = orderRestaurantAddressTextA .. tostring(orderRestaurant["address"]);
			end
			if orderAddress["city"] ~= nil then
				orderRestaurantAddressTextB = orderRestaurantAddressTextB .. tostring(orderRestaurant["city"]);
			end
			if orderRestaurant["state"] ~= nil then
				orderRestaurantAddressTextB = orderRestaurantAddressTextB .. ", " .. tostring(orderRestaurant["state"]);
			end
			if orderRestaurant["zip"] ~= nil then
				orderRestaurantAddressTextB = orderRestaurantAddressTextB .. " " .. tostring(orderRestaurant["zip"]);
			end
			
			local orderStatusIcon = "media/images/icons/target.png";
			local orderTargetIcon = "media/images/icons/restaurant.png";
			local orderTargetColor = parameters.GRAPHICS.COLORS["eatzydriver_colorscheme_05"];
			local orderTargetIconColor = parameters.GRAPHICS.COLORS["main_text"];
			local orderTargetTextColor = parameters.GRAPHICS.COLORS["main_text"];
			
			if orderEventName == "pickup" then
				orderTargetNameText = tostring(orderRestaurant['name']);
				orderColor = parameters.GRAPHICS.COLORS["eatzydriver_colorscheme_05"];
				orderTargetIcon = "media/images/icons/restaurant.png";
				
				orderTargetAddressTextA = orderRestaurantAddressTextA;
				orderTargetAddressTextB = orderRestaurantAddressTextB;
			elseif orderEventName == "dropoff" then
				orderTargetNameText = tostring(orderCustomer['first_name']) .. " " .. tostring(orderCustomer['last_name']);
				orderColor = parameters.GRAPHICS.COLORS["eatzydriver_colorscheme_01"];
				orderTargetIcon = "media/images/icons/home.png";
			end
			
			-- TESTING BEGIN
			-- orderTargetNameText = "WwAaBbCcFfLlEePpQqMmXxTtZzHhUu6600QqKk";
			-- orderTargetAddressTextA = "WwAaBbCcFfLlEePpQqMmXxTtZzHhUu6600QqKk";
			-- orderTargetAddressTextB = "WwAaBbCcFfLlEePpQqMmXxTtZzHhUu6600QqKk";
			-- TESTING END
			
			local orderTargetNameSizeLimit = 23;
			if orderTargetNameText ~= nil then
				if string.len(orderTargetNameText) > orderTargetNameSizeLimit then
					orderTargetNameText = string.sub(orderTargetNameText, 0, orderTargetNameSizeLimit ) .. "...";
				end
			end
			
			local orderTargetAddressTextASizeLimit = 26;
			if orderTargetAddressTextA ~= nil then
				if string.len(orderTargetAddressTextA) > orderTargetAddressTextASizeLimit then
					orderTargetAddressTextA = string.sub(orderTargetAddressTextA, 0, orderTargetAddressTextASizeLimit ) .. "...";
				end
			end
			
			local orderTargetAddressTextBSizeLimit = 24;
			if orderTargetAddressTextB ~= nil then
				if string.len(orderTargetAddressTextB) > orderTargetAddressTextBSizeLimit then
					orderTargetAddressTextB = string.sub(orderTargetAddressTextB, 0, orderTargetAddressTextBSizeLimit ) .. "...";
				end
			end
			
			if orderStatus ~= nil then
				orderStatus = tonumber(orderStatus);
				if orderStatus > 0 then
					if orderStatus == 1 then -- open
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["init"];
						orderStatusIcon = "media/images/icons/clock.png";
					elseif orderStatus == 2 then -- finalized-manual
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["assign"];
						orderStatusIcon = "media/images/icons/clock.png";
					elseif orderStatus == 3 then -- finalized-auto
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["assign"];
						orderStatusIcon = "media/images/icons/clock.png";
					elseif orderStatus == 4 then -- faxed
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["placing"];
						orderStatusIcon = "media/images/icons/clock.png";
					elseif orderStatus == 5 then -- confirmed
						if orderAtRestaurantAt ~= nil and orderAtRestaurantAt > 0 then
							orderStatusIcon = "media/images/icons/restaurant.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placed"];
						elseif orderAcceptedAt ~= nil and orderAcceptedAt > 0 then
							orderStatusIcon = "media/images/icons/calendar.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placed"];
						else
							orderStatusIcon = "media/images/icons/clock.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placing"];
						end
					elseif orderStatus == 6 then -- cooking
						if orderAtRestaurantAt ~= nil and orderAtRestaurantAt > 0 then
							orderStatusIcon = "media/images/icons/restaurant.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placed"];
						elseif orderAcceptedAt ~= nil and orderAcceptedAt > 0 then
							orderStatusIcon = "media/images/icons/calendar.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placed"];
						else
							orderStatusIcon = "media/images/icons/clock.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placing"];
						end
					elseif orderStatus == 7 then -- checking
						if orderAtRestaurantAt ~= nil and orderAtRestaurantAt > 0 then
							orderStatusIcon = "media/images/icons/restaurant.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placed"];
						elseif orderAcceptedAt ~= nil and orderAcceptedAt > 0 then
							orderStatusIcon = "media/images/icons/calendar.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placed"];
						else
							orderStatusIcon = "media/images/icons/clock.png";
							orderColor = parameters.GRAPHICS.ORDERS.COLORS["placing"];
						end
					elseif orderStatus == 8 then -- driving
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["enroute"];
						orderStatusIcon = "media/images/icons/truck.png";
						if orderAtDropoffAt ~= nil and orderAtDropoffAt > 0 then
							orderStatusIcon = "media/images/icons/home.png";
						end
					elseif orderStatus == 9 then -- dropping-off
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["enroute"];
						orderStatusIcon = "media/images/icons/truck.png";
						if orderAtDropoffAt ~= nil and orderAtDropoffAt > 0 then
							orderStatusIcon = "media/images/icons/home.png";
						end
					elseif orderStatus == 10 then -- completed
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["delivered"];
						orderStatusIcon = "media/images/icons/target.png";
					elseif orderStatus == 11 then -- canceled
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["init"];
						orderStatusIcon = "media/images/icons/remove.png";
					elseif orderStatus == 12 then -- saved
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["init"];
						orderStatusIcon = "media/images/icons/target.png";
					elseif orderStatus == 13 then -- autosaved
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["init"];
						orderStatusIcon = "media/images/icons/target.png";
					elseif orderStatus == 14 then -- redelivery
						orderColor = parameters.GRAPHICS.ORDERS.COLORS["init"];
						orderStatusIcon = "media/images/icons/refresh.png";
					else
						logger.log("Order Status Unknown: "..tostring(orderStatus));
					end
				end
			end
			
			local orderBlockBG = display.newRoundedRect(0,0,blockWidth,blockHeight,8);
			orderBlockBG:setFillColor(orderColor[1],orderColor[2],orderColor[3]);
			orderBlockBG.anchorX = 0.5;
			orderBlockBG.anchorY = 0.0;
			orderBlockBG.x = 0;
			orderBlockBG.y = 0;
			orderBlock:insert(orderBlockBG);
			
			local bciSize = 28;
			local bciBorder = bciSize*1.2;
			
			local blockCodeDeliveryIcon = display.newImageRect(orderTargetIcon,orderBlockBG.height*0.9,orderBlockBG.height*0.9);
			blockCodeDeliveryIcon:setFillColor(orderTargetIconColor[1],orderTargetIconColor[2],orderTargetIconColor[3]);
			blockCodeDeliveryIcon.anchorX = 1.0;
			blockCodeDeliveryIcon.anchorY = 1.0;
			blockCodeDeliveryIcon.x = orderBlockBG.width*0.5 - 4;
			blockCodeDeliveryIcon.y = orderBlockBG.height - 4;
			blockCodeDeliveryIcon.alpha = 0.2;
			orderBlock:insert(blockCodeDeliveryIcon);
			
			local blockCodeIcon = display.newImageRect(orderStatusIcon,bciSize,bciSize);
			blockCodeIcon:setFillColor(orderTargetIconColor[1],orderTargetIconColor[2],orderTargetIconColor[3]);
			blockCodeIcon.anchorX = 0.0;
			blockCodeIcon.anchorY = 0.0;
			blockCodeIcon.x = -orderBlockBG.width*0.5 + 4;
			blockCodeIcon.y = 4;
			blockCodeIcon.alpha = 1.0;
			orderBlock:insert(blockCodeIcon);
			
			local blockCodeOrderNumberText = textmaker.newText(orderTargetOrderNumberText,0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
			blockCodeOrderNumberText:setFillColor(orderTargetTextColor[1],orderTargetTextColor[2],orderTargetTextColor[3]);
			blockCodeOrderNumberText.anchorX = 0.0;
			blockCodeOrderNumberText.anchorY = 0.5;
			blockCodeOrderNumberText.x = -orderBlockBG.width*0.5 + bciBorder;
			blockCodeOrderNumberText.y = blockCodeIcon.y + blockCodeIcon.height*0.5;
			orderBlock:insert(blockCodeOrderNumberText);
			
			local blockCodeNameText = textmaker.newText(orderTargetNameText,0,0,{"roboto-black"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.2);
			blockCodeNameText:setFillColor(orderTargetTextColor[1],orderTargetTextColor[2],orderTargetTextColor[3]);
			blockCodeNameText.anchorX = 0.0;
			blockCodeNameText.anchorY = 0.0;
			blockCodeNameText.x = blockCodeIcon.x;
			blockCodeNameText.y = blockCodeIcon.y + blockCodeIcon.height*0.9;
			orderBlock:insert(blockCodeNameText);
			
			local blockCodeAddressTextA = textmaker.newText(orderTargetAddressTextA,0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE*0.9);
			blockCodeAddressTextA:setFillColor(orderTargetTextColor[1],orderTargetTextColor[2],orderTargetTextColor[3]);
			blockCodeAddressTextA.anchorX = 0.0;
			blockCodeAddressTextA.anchorY = 0.0;
			blockCodeAddressTextA.x = blockCodeNameText.x;
			blockCodeAddressTextA.y = blockCodeNameText.y + blockCodeNameText.height;
			orderBlock:insert(blockCodeAddressTextA);
			
			local blockCodeAddressTextB = textmaker.newText(orderTargetAddressTextB,0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE*0.9);
			blockCodeAddressTextB:setFillColor(orderTargetTextColor[1],orderTargetTextColor[2],orderTargetTextColor[3]);
			blockCodeAddressTextB.anchorX = 0.0;
			blockCodeAddressTextB.anchorY = 0.0;
			blockCodeAddressTextB.x = blockCodeAddressTextA.x;
			blockCodeAddressTextB.y = blockCodeAddressTextA.y + blockCodeAddressTextA.height*0.8;
			orderBlock:insert(blockCodeAddressTextB);
			
			local blockCodeCountdownText = textmaker.newText("00:00:00",0,0,{"roboto-black"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
			blockCodeCountdownText:setFillColor(orderTargetTextColor[1],orderTargetTextColor[2],orderTargetTextColor[3]);
			blockCodeCountdownText.anchorX = 1.0;
			blockCodeCountdownText.anchorY = 0.5;
			blockCodeCountdownText.x = orderBlockBG.width*0.5 - 4;
			blockCodeCountdownText.y = blockCodeOrderNumberText.y;
			orderBlock:insert(blockCodeCountdownText);
			
			-- Countdown block
			local function updateCountdown(event)
				local utcDate = os.date( "!*t" );
				local utcTime = tonumber(os.time(utcDate));
				local epochTime = tonumber(os.time{year=1970, month=1, day=1, hour=0});
	
				local nowTime = (utcTime - epochTime);
				local driverDelay = (targetTimeForType - nowTime);
				
				local isLate = false;
				local countdownColor = parameters.GRAPHICS.COLORS["countdown_good"];
				if driverDelay <= parameters.DRIVERS.LATE_TIME_COUNTER then
					isLate = true;
					driverDelay = -driverDelay;
					countdownColor = parameters.GRAPHICS.COLORS["countdown_late"];
				elseif driverDelay <= parameters.DRIVERS.WARNING_TIME_COUNTER then -- almost late
					countdownColor = parameters.GRAPHICS.COLORS["countdown_warning"];
				end
				
				local countdownString = "";
				
				local min = math.floor(driverDelay/60);
				local sec = driverDelay - min*60;
				if min > 999 then
					min = 999;
					sec = 59;
				end
				
				--[[
				local residual = driverDelay;
				local days = math.floor(residual/(60*60*24));
				residual = residual - (days*60*60*24);
				local hours = math.floor(residual/(60*60));
				
				residual = residual - (hours*60*60);
				local minutes = math.min(59, math.floor(residual/60));
				residual = residual - (minutes*60);
			
				local seconds = residual;
				
				local nowDate = os.date("*t");
				if days > 0 then
					countdownString = string.format("%01d:%02d:%02d:%02d",days,hours,minutes,seconds);
				else
					countdownString = string.format("%02d:%02d:%02d",hours,minutes,seconds);
				end
				--]]
				
				-- countdownString = string.format("%d:%02d",min,sec);
				countdownString = string.format("%d",min);
				if isLate == true then
					countdownString = "+" .. countdownString;
				end
				
				if blockCodeCountdownText.setTextColor ~= nil then
					blockCodeCountdownText:setTextColor(countdownColor[1],countdownColor[2],countdownColor[3]);
				end
				blockCodeCountdownText.text = countdownString;
			end
			updateCountdown();
			
			local blockCodeOrderDetailsBtn = nil;
			local blockCodeOrderDirectionsBtn = nil;
			
			blockCodeOrderDetailsBtn = widget.newButton
			{
				width = 32,
				height = 32,
				label = "",
				defaultFile = "media/images/icons/notes.png",
				overFile = "media/images/icons/notes.png",
				onPress = onDetailsListener
			}
			blockCodeOrderDetailsBtn.anchorX = 1.0;
			blockCodeOrderDetailsBtn.anchorY = 1.0;
			blockCodeOrderDetailsBtn.x = blockWidth*0.5 - 4;
			if blockCodeOrderDirectionsBtn ~= nil then
				blockCodeOrderDetailsBtn.y = blockHeight - 44;
			else
				blockCodeOrderDetailsBtn.y = blockHeight - 4;
			end
			blockCodeOrderDetailsBtn.infoCode = orderInfoCode;
			orderBlock:insert(blockCodeOrderDetailsBtn);
			
			local countDowntimer;
			local initialized = false;
			orderBlock.init = function ()
				if initialized ~= true then
					if onDetailsListener ~= nil then
						-- orderBlockBG:addEventListener( "tap", onDetailsListener );
					end
					
					if countDowntimer ~= nil then
						timer.cancel(countDowntimer);
						countDowntimer = nil;
					end
					countDowntimer = timer.performWithDelay( 1000, updateCountdown, -1 );
				
					initialized = true;
				end
			end
			orderBlock.deinit = function ()
				if initialized == true then
					if onDetailsListener ~= nil then
						-- orderBlockBG:removeEventListener( "tap", onDetailsListener );
					end
				
					if countDowntimer ~= nil then
						timer.cancel(countDowntimer);
						countDowntimer = nil;
					end
				
					initialized = false;
				end
			end
			
			return orderBlock;
		else
			return nil;
		end
  	end
  	
  	local function onBlockTouch( event )
  		if event.target ~= nil then
			local infoCode = event.target.infoCode;
			logger.log( "Order block pressed: " .. tostring(infoCode) );
		
			if infoCode ~= nil and onDetailsAnimation ~= true then
				-- Show order details web view
				local blockTransition;
				local function onBTShowed( obj )
					if blockTransition ~= nil then
						transition.cancel(blockTransition);
						blockTransition = nil;
					end
					detailsGroup.enablePanel(true);
					
					logger.log( "Details block In Animation completed" );
				end
				
				local function onBTHidden( obj )
					if blockTransition ~= nil then
						transition.cancel(blockTransition);
						blockTransition = nil;
					end
					detailsGroup.alpha = 0.0;
					onDetailsAnimation = false;
					
					if navigationGW ~= nil then
						if navigationGW["show"] ~= nil then
							local showFunc = navigationGW["show"];
							showFunc();
						end
					end
					
					logger.log( "Details block Out Animation completed" );
				end
				
				-- Hide navigation bar
				if navigationGW ~= nil then
					if navigationGW["hide"] ~= nil then
						local hideFunc = navigationGW["hide"];
						hideFunc();
					end
				end
				
				local function detailsCB(event)
					if event ~= nil then
						if event.phase == "will" then
							detailsGroup.enablePanel(false);
							blockTransition = transition.to( detailsGroup, { time=250, x=_W, transition=easing.outExpo, onComplete=onBTHidden } );
							
							-- Refresh delivery runs
							logger.log("Refreshing orders list");
							loader.start();
			
							if orderRequestTimer ~= nil then
								timer.cancel(orderRequestTimer);
								orderRequestTimer = nil;
							end
							orderRequestTimer = timer.performWithDelay( ordersRequestPeriod, orderFuncs.requestOrders, -1 );
							orderFuncs.requestOrders();
						else
							logger.log("event.phase unknown: "..tostring(event.phase));
						end
					end
				end
				
				detailsGroup.setCallback(detailsCB);
				detailsGroup.setOrderData(currentRuns[infoCode]);
				detailsGroup.alpha = 1.0;
				blockTransition = transition.to( detailsGroup, { time=250, x=0, transition=easing.outExpo, onComplete=onBTShowed } );
			
				onDetailsAnimation = true;
			end
		end
	end
  	
  	local existingOrders = {};
  	orderFuncs.requestOrders = function ( event )
		if isRequestingOrders ~= true then
			isRequestingOrders = true;
			
			local onOrdersReceived = function (response)
				-- Remove all order blocks
				local receivedOrders = {};
				local newOrders = {};
				
				for i=1, #ordersContainer do
					local orderBlock = ordersContainer[i];
					if orderBlock ~= nil and orderBlock.deinit ~= nil then
						orderBlock.deinit();
					end
				end
			
				local orders = nil;
				if response == nil then
					logger.log("Orders Error: nil response");
				elseif response["error"] == true then
					logger.log("Orders Error: "..tostring(response["message"]));
				else
					local data = response["data"];
					if data["runs"] ~= nil then
						orders = data["runs"];
					end
				end
						
				ordersContainer:removeSelf();
				ordersContainer = nil;
						
				ordersContainer = display.newGroup();
				ordersContainer.y = device.safeYOffset;
				
				if orders ~= nil then
					local ordersCount = 0;
						
					for k,v in pairs(orders) do
						ordersCount = ordersCount + 1;
					end
					
					if ordersCount > 0 then
						tabNameText.alpha = 0.0;
						ordersCount = 0;
						local ordersCreated = 0;
						local newRuns = {};
						local newRunsCounter = 0;
						currentRuns = {};
						local menunuRuns = {};
					
						for orderKey, orderData in pairs(orders) do
							ordersCount = ordersCount + 1;
							orderInfoCode = orderData["info_code"];
							
							if orderInfoCode ~= nil then
								local roExists = false;
								for roIdx=1, #receivedOrders do
									if orderInfoCode == receivedOrders[roIdx+1] then
										roExists = true;
										break;
									end
								end
								if roExists ~= true then
									receivedOrders[#receivedOrders+1] = orderInfoCode;
								end
								
								currentRuns[orderInfoCode] = orderData;
								menunuRuns[#menunuRuns+1] = orderData;
							
								local orderBox = buildOrderBlock(ordersCount,orderData,onBlockTouch);
								if orderBox ~= nil then
									orderBox.anchorX = 0.5;
									orderBox.anchorY = 0.0;
									orderBox.x = _CX;
									orderBox.y = 4 + (ordersCount-1)*(orderBox.height+6);
									ordersContainer:insert(orderBox);
								
									orderBox.init();
									ordersCreated = ordersCreated + 1;
								
									local runId = orderData['delivery_event_id'];
									if runId ~= nil then
										runId = tonumber(runId);
									
										newRuns[runId] = true;
										if runsReceived[runId] == nil then
											newRunsCounter = newRunsCounter + 1;
										end
									end
								else
									ordersCount = ordersCount - 1;
								end
							else
								ordersCount = ordersCount - 1;
							end
						end
						runsReceived = newRuns;
					
						-- Update current runs
						menunu.setCurrentRuns(menunuRuns);
						
						if ordersCreated <= 0 then
							tabNameText.text = "No orders assigned";
							tabNameText.alpha = 1.0;
						else
							for roIdx=1, #receivedOrders do
								local receivedOrderInfoCode = receivedOrders[roIdx];
								local oExists = false;
								
								for eoIdx=1, #existingOrders do
									if receivedOrderInfoCode == existingOrders[eoIdx] then
										oExists = true;
										break;
									end
								end
								
								if oExists ~= true then
									newOrders[#newOrders+1] = receivedOrderInfoCode;
								end
							end
						
							if #newOrders > 0 and containerEnabled ~= true then
								if notificationsGw ~= nil then
									local notificationsGwSet = notificationsGw.set;
									local notificationsGwGet = notificationsGw.get;
				
									if notificationsGwSet ~= nil and notificationsGwGet ~= nil then
										local activeNotifications = notificationsGwGet(1);
										if activeNotifications <= 0 then
											notificationsGwSet(1,#newOrders);
										end
									end
								end
							end
						end
					else
						tabNameText.text = "No orders assigned";
						tabNameText.alpha = 1.0;
					end
				else
					tabNameText.text = "No orders assigned";
					tabNameText.alpha = 1.0;
				end
						
				scrollView:insert(ordersContainer);
				scrollView:scrollToPosition{y = 0, time = 200, onComplete = nil}
				
				if loader.started == true then
					loader.stop();
				end
				
				logger.log("Showing orders...");
				isRequestingOrders = false;
				
				existingOrders = receivedOrders;
			end
			
			menunu.getDriverRuns(onOrdersReceived);
		end
	end
  	
  	local enableContainerFunc = function ()
  		if containerEnabled ~= true then
  			logger.log("Starting internal loader");
  			loader.start();
  			
			if orderRequestTimer ~= nil then
				timer.cancel(orderRequestTimer);
				orderRequestTimer = nil;
			end
			orderRequestTimer = timer.performWithDelay( ordersRequestPeriod, orderFuncs.requestOrders, -1 );
			orderFuncs.requestOrders();
  	
			-- TEMP DETAILS SCENE TESTING BEGIN
			--[[
			local triggerTimer = nil;
			local function onBlockTouchTrigger()
				if triggerTimer ~= nil then
					timer.cancel(triggerTimer);
					triggerTimer = nil;
				end
		
				local dummyEvent = {};
				dummyEvent.target = {};
				dummyEvent.target.infoCode = "ABCDEF";
				
				currentRuns[dummyEvent.target.infoCode] = {};
				currentRuns[dummyEvent.target.infoCode]["info_code"] = dummyEvent.target.infoCode;
				
				onBlockTouch(dummyEvent);
			end
			triggerTimer = timer.performWithDelay( 3000, onBlockTouchTrigger );
			--]]
			-- TEMP DETAILS SCENE TESTING END
  			
  			containerEnabled = true;
  		end
  	end
  	
  	local disableContainerFunc = function ()
  		if containerEnabled == true then
  			loader.stop();
  			
			if onDetailsAnimation == true then
				if blockTransition ~= nil then
					transition.cancel(blockTransition);
					blockTransition = nil;
				end
				
				detailsGroup.x = _W;
				detailsGroup.alpha = 0.0;
				onDetailsAnimation = false;
			end
  		
  			containerEnabled = false;
  		end
  	end
  	
  	local loadContainerFunc = function ()
  		if containerLoaded ~= true then
  			if orderRequestTimer ~= nil then
  				timer.cancel(orderRequestTimer);
  				orderRequestTimer = nil;
  			end
  			
  			ordersRequestPeriod = parameters.SERVER.ORDERS_REQUEST_PERIOD;
			local appSetup = storage.getConfiguration();
			if appSetup["configuration"] ~= nil then
				local appConfig = appSetup["configuration"];
				if appConfig["order_period"] ~= nil then
					ordersRequestPeriod = tonumber(appConfig["order_period"]);
				end
			end
		
			ordersRequestPeriod = ordersRequestPeriod * 1000;
			
			if orderRequestTimer ~= nil then
  				timer.cancel(orderRequestTimer);
  				orderRequestTimer = nil;
  			end
  			orderRequestTimer = timer.performWithDelay( ordersRequestPeriod, orderFuncs.requestOrders, -1 );
  			orderFuncs.requestOrders();
  		
  			containerLoaded = true;
  		end
  	end
  	
  	local unloadContainerFunc = function ()
  		if containerLoaded == true then
  			disableContainerFunc();
  			
  			if orderRequestTimer ~= nil then
  				timer.cancel(orderRequestTimer);
  				orderRequestTimer = nil;
  			end
  			
  			for i=1, #ordersContainer do
				local orderBlock = ordersContainer[i];
				if orderBlock ~= nil and orderBlock.deinit ~= nil then
					orderBlock.deinit();
				end
			end
  		
  			containerLoaded = false;
  		end
  	end
  	
  	-- FUNCTIONS END
  	Container.onEnable = enableContainerFunc;
  	Container.onDisable = disableContainerFunc;
  	Container.onLoad = loadContainerFunc;
  	Container.onUnload = unloadContainerFunc;
  	
  	return Container;
end

return M;