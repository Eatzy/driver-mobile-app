local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local OneSignal = require ("app.lib.onesignal")

local ordersTabGen = require("app.modules.ordersgen")
local chatTabGen = require("app.modules.chatgen")
local directionsTabGen = require("app.modules.directionsgen")
local settingsTabGen = require("app.modules.settingsgen")

local bottombarGenerator = require ( "app.modules.bottombar" )

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

-- Display objects
local loader;

-- Controllers
local navigationController = {};

local requesting = false;

local ordersTab;
local chatTab;
local directionsTab;
local settingsTab;

local ordersButtonPress = function( event )
	logger.log("ORDERS BUTTON PRESSED!");
	
	if requesting ~= true then
		loader.start();
		
		local onOrders = function (response)
			if response["error"] == true then
    			loader.stop();
    			native.showAlert( "Error getting orders", tostring(response["message"]), { "OK" } );
    		else
    			local data = response["data"];
    			loader.stop();
				
				if data["orders"] ~= nil then
					local orders = data["orders"];
					local ordersCount = 0;
					for k,v in pairs(orders) do
						 ordersCount = ordersCount + 1;
					end
				
					if ordersCount > 0 then
						-- Change scene
						local composer = require( "composer" );
						composer.gotoScene("app.modules.ordergen");
					else
						native.showAlert( "Orders", "No orders assigned", { "OK" } );
					end
				else
					native.showAlert( "Orders", "No orders assigned", { "OK" } );
				end
    		end
    		
    		requesting = false;
		end
		
		menunu.getDriverOrders(onOrders);
		
		requesting = true;
	end
end

function scene:create( event )
  	local group = self.view;
  	
  	local loaderBuilder = require( "app.lib.loader" );
  	loader = loaderBuilder.newLoader();
  	loader.initialize();
  	
  	local appConfiguration = storage.getConfiguration();
  	
  	local driverDetails = appConfiguration["driver"];
  	local driverBusinessDetails = driverDetails["business"];

  	local Background = display.newGroup();
  	local Foreground = display.newGroup();
  	local GUI = display.newGroup();

  	group:insert(Background);
  	group:insert(Foreground);
  	group:insert(GUI);

  	local backgroundBox = display.newRect(0,0,_W,_H);
  	backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background"][1],parameters.GRAPHICS.COLORS["background"][2],parameters.GRAPHICS.COLORS["background"][3]);
  	backgroundBox.anchorX = 0.5;
  	backgroundBox.anchorY = 0.5;
  	backgroundBox.x = _CX;
  	backgroundBox.y = _CY;
  	Background:insert(backgroundBox);
	
	local tabBar;
  	
  	navigationController.goToOrders = function (event)
  		ordersTab.alpha = 1.0;
		chatTab.alpha = 0.0;
		directionsTab.alpha = 0.0;
		settingsTab.alpha = 0.0;

		tabBar.setSelected(1);
		tabBar.setNotifications(1,0);
		
		ordersTab.onEnable();
		chatTab.onDisable();
		directionsTab.onDisable();
		settingsTab.onDisable();
		
		backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_orders"][1],parameters.GRAPHICS.COLORS["background_orders"][2],parameters.GRAPHICS.COLORS["background_orders"][3]);
  	end
  	navigationController.goToChat = function (event)
  		ordersTab.alpha = 0.0;
		chatTab.alpha = 1.0;
		directionsTab.alpha = 0.0;
		settingsTab.alpha = 0.0;
		
		tabBar.setSelected(2);
		tabBar.setNotifications(2,0);
		
		ordersTab.onDisable();
		chatTab.onEnable();
		directionsTab.onDisable();
		settingsTab.onDisable();
		
		backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_chat"][1],parameters.GRAPHICS.COLORS["background_chat"][2],parameters.GRAPHICS.COLORS["background_chat"][3]);
  	end
  	navigationController.goToDirections = function (event)
  		ordersTab.alpha = 0.0;
		chatTab.alpha = 0.0;
		directionsTab.alpha = 1.0;
		settingsTab.alpha = 0.0;
		
		tabBar.setSelected(3);
		tabBar.setNotifications(3,0);
		
		ordersTab.onDisable();
		chatTab.onDisable();
		directionsTab.onEnable();
		settingsTab.onDisable();
		
		backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_directions"][1],parameters.GRAPHICS.COLORS["background_directions"][2],parameters.GRAPHICS.COLORS["background_directions"][3]);
  	end
  	navigationController.goToSettings = function (event)
  		ordersTab.alpha = 0.0;
		chatTab.alpha = 0.0;
		directionsTab.alpha = 0.0;
		settingsTab.alpha = 1.0;
		
		tabBar.setSelected(4);
		tabBar.setNotifications(4,0);
		
		ordersTab.onDisable();
		chatTab.onDisable();
		directionsTab.onDisable();
		settingsTab.onEnable();
		
		backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_settings"][1],parameters.GRAPHICS.COLORS["background_settings"][2],parameters.GRAPHICS.COLORS["background_settings"][3]);
  	end
	
	local bbParams = {};
	bbParams.width = _W;
	bbParams.height = 52;
	
	bbParams.notifications = {};
	bbParams.notifications["color"] = parameters.GRAPHICS.COLORS["eatzydriver_colorscheme_01"];
	
	bbParams.buttons = {};
	
	local buttonWidth = 36;
	local buttonHeight = buttonWidth;
	local defaultButtonColor = parameters.GRAPHICS.COLORS["main_text"];
	local defaultButtonAlpha = 1.0;
	local overButtonColor = parameters.GRAPHICS.COLORS["eatzydriver_colorscheme_05"];
	local overButtonAlpha = 1.0;
	local onButtonPress = nil;
	local onButtonRelease = function (e)
		if e ~= nil and e.target ~= nil and e.target.buttonNumber ~= nil then
			local buttonNumber = e.target.buttonNumber;
			tabBar.setSelected(buttonNumber);
			if buttonNumber == 1 then
				analytics.logEvent("bbbtn_orders_tap");
				navigationController.goToOrders();
			elseif buttonNumber == 2 then
				analytics.logEvent("bbbtn_chat_tap");
				navigationController.goToChat();
			elseif buttonNumber == 3 then
				analytics.logEvent("bbbtn_directions_tap");
				navigationController.goToDirections();
			elseif buttonNumber == 4 then
				analytics.logEvent("bbbtn_settings_tap");
				navigationController.goToSettings();
			end
		end
	end
	
	local ordersButton = {};
	ordersButton["default"] = {};
	ordersButton["default"]["image"] = "media/images/icons/clock.png";
	ordersButton["over"] = {};
	ordersButton["over"]["image"] = "media/images/icons/clock.png";
	bbParams.buttons[#bbParams.buttons+1] = ordersButton;
	
	local chatButton = {};
	chatButton["default"] = {};
	chatButton["default"]["image"] = "media/images/icons/comments.png";
	chatButton["over"] = {};
	chatButton["over"]["image"] = "media/images/icons/comments.png";
	bbParams.buttons[#bbParams.buttons+1] = chatButton;
	
	local directionsButton = {};
	directionsButton["default"] = {};
	directionsButton["default"]["image"] = "media/images/icons/compass.png";
	directionsButton["over"] = {};
	directionsButton["over"]["image"] = "media/images/icons/compass.png";
	bbParams.buttons[#bbParams.buttons+1] = directionsButton;
	
	local settingsButton = {};
	settingsButton["default"] = {};
	settingsButton["default"]["image"] = "media/images/icons/gears.png";
	settingsButton["over"] = {};
	settingsButton["over"]["image"] = "media/images/icons/gears.png";
	bbParams.buttons[#bbParams.buttons+1] = settingsButton;
	
	for i=1, #bbParams.buttons do
		local buttonDesc = bbParams.buttons[i];
		buttonDesc["default"]["width"] = buttonWidth;
		buttonDesc["default"]["height"] = buttonHeight;
		buttonDesc["default"]["color"] = defaultButtonColor;
		buttonDesc["default"]["alpha"] = defaultButtonAlpha;
		buttonDesc["over"]["width"] = buttonWidth;
		buttonDesc["over"]["height"] = buttonHeight;
		buttonDesc["over"]["color"] = overButtonColor;
		buttonDesc["over"]["alpha"] = overButtonAlpha;
		buttonDesc["onPress"] = onButtonPress;
		buttonDesc["onRelease"] = onButtonRelease;
	end
	
	tabBar = bottombarGenerator.newBar(bbParams);
  	tabBar.x = _CX;
  	tabBar.y = _H;
  	GUI:insert(tabBar);
  	
  	-- Create modules
  	local tabParams = {};
  	tabParams["width"] = _W;
  	tabParams["height"] = _H - tabBar.height;
  	tabParams["loader"] = loader;
  	tabParams["notifications"] = {};
  	tabParams["notifications"]["set"] = tabBar.setNotifications;
  	tabParams["notifications"]["get"] = tabBar.getNotifications;
  	tabParams["navigation"] = {};
  	tabParams["navigation"]["hide"] = tabBar.hide;
  	tabParams["navigation"]["show"] = tabBar.show;
  	
  	ordersTab = ordersTabGen.newTab(tabParams);
	chatTab = chatTabGen.newTab(tabParams);
	directionsTab = directionsTabGen.newTab(tabParams);
	settingsTab = settingsTabGen.newTab(tabParams);
	
	ordersTab.alpha = 0.0;
	chatTab.alpha = 0.0;
	directionsTab.alpha = 0.0;
	settingsTab.alpha = 0.0;
	
	Foreground:insert(ordersTab);
	Foreground:insert(chatTab);
	Foreground:insert(directionsTab);
	Foreground:insert(settingsTab);
  	
  	GUI:insert(loader);
end

function scene:show( event )
    local phase = event.phase;

    if ( phase == "will" ) then
    	-- Load tracking
		gpshelper.init();
    	
		-- On load for all modules
		ordersTab.onLoad();
		chatTab.onLoad();
		directionsTab.onLoad();
		settingsTab.onLoad();
	
    	menunu.setDriverClockedIn(true);
    	navigationController.goToOrders();
    elseif ( phase == "did" ) then
		OneSignal.enableRegistration(true);
    end
end

function scene:hide( event )
  	local phase = event.phase;

    if ( phase == "will" ) then
        -- On unload for all modules
		ordersTab.onUnload();
		chatTab.onUnload();
		directionsTab.onUnload();
		settingsTab.onUnload();
    elseif ( phase == "did" ) then
    	-- Unload tracking
		gpshelper.destroy();
    end
end

function scene:destroy( event )
-- TODO
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene