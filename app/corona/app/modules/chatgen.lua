local M = {};

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local widget = require( "widget" )
local chatFactory = require( "app.lib.chat" )
local randomMessage = require( "app.utils.randomessage" )

M.newTab = function (params)
  	
  	local containerEnabled = false;
  	local containerLoaded = false;
  	
	local containerWidth = _W;
	local containerHeight = _H;
	local externalLoader = nil;
	local notificationsGw = nil;
	local navigationGw = nil;
	
	if params ~= nil then
		if params["width"] ~= nil then containerWidth = params["width"]; end
		if params["height"] ~= nil then containerHeight = params["height"]; end
		if params["loader"] ~= nil then externalLoader = params["loader"]; end
		if params["notifications"] ~= nil then notificationsGw = params["notifications"]; end
		if params["navigation"] ~= nil then navigationGW = params["navigation"]; end
	end
	
	local chatFieldBorder = 5;
	
	local chatFunctions = {};
	
	-- model variables
	local isRequestingMessages = false;
	local messagesRequestTimer = nil;
	local messagesRecipientDefaultUserId = nil;
	
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
	loaderParams["bgcolor"] = parameters.GRAPHICS.COLORS["background_chat"];
  	local loaderBuilder = require( "app.lib.loader" );
  	local loader = loaderBuilder.newLoader(loaderParams);
  	loader.initialize();

  	local backgroundBox = display.newRect(0,0,containerWidth,containerHeight);
  	backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_chat"][1],parameters.GRAPHICS.COLORS["background_chat"][2],parameters.GRAPHICS.COLORS["background_chat"][3]);
  	backgroundBox.anchorX = 0.5;
  	backgroundBox.anchorY = 0.0;
  	backgroundBox.x = _CX;
  	backgroundBox.y = 0;
  	Background:insert(backgroundBox);
  	
  	local touchBackgroundListener = function ( event )
		native.setKeyboardFocus( nil );
	end
  	backgroundBox:addEventListener( "touch", touchBackgroundListener );
  	
  	local function onUserChat(event)
  		if ( "began" == event.phase ) then
			-- This is the "keyboard has appeared" event
			-- In some cases you may want to adjust the interface when the keyboard appears.
		elseif ( "ended" == event.phase ) then
			-- This event is called when the user stops editing a field: for example, when they touch a different field
		elseif ( "editing" == event.phase ) then
	
		elseif ( "submitted" == event.phase ) then
			-- This event occurs when the user presses the "return" key (if available) on the onscreen keyboard
			-- Hide keyboard
			native.setKeyboardFocus( nil );
		end
  	end
  	
  	local chatField = nil;
  	
  	--[[
  	chatField = native.newTextField( 0, 0, (containerWidth*0.8 - chatFieldBorder*3), 30 );
	chatField:addEventListener( "userInput", onUserChat );
	chatField.anchorX = 0.0;
	chatField.anchorY = 1.0;
	chatField.x = chatFieldBorder;
	chatField.y = containerHeight - chatFieldBorder;
	GUI:insert(chatField);
	--]]
	
	local sending = false;
	local sendButtonPress = function( event )
		native.setKeyboardFocus( nil );
	
		if sending ~= true then
			if chatField ~= nil then
				local messageText = chatField.text;
				
				if string.len(messageText) > 0 then
					messageText =  utils.trim(messageText);
					
					if string.len(messageText) > 0 then
						
						local utcDate = os.date( "!*t" );
						local utcTime = tonumber(os.time(utcDate));
						
						local messages = {};
						
						local message = {};
						message.subject = parameters.SERVER.DRIVER_MESSAGE_DEFAULT_SUBJECT;
						message.body = messageText;
						message.timestamp = utcTime;
						message.recipient = messagesRecipientDefaultUserId;
						
						messages[#messages+1] = message;
						
						logger.log("SENDING: "..tostring(messageText));
						
						local onPutReceived = function (response)
							logger.log("PUT RESPONSE RECEIVED");
							chatFunctions.requestMessages();
							
							if chatField == nil then
								chatField = native.newTextField( 0, 0, (containerWidth*0.8 - chatFieldBorder*3), 30 );
								chatField:addEventListener( "userInput", onUserChat );
								chatField.anchorX = 0.0;
								chatField.anchorY = 1.0;
								chatField.x = chatFieldBorder;
								chatField.y = containerHeight - chatFieldBorder;
								GUI:insert(chatField);
							end
							
							sending = false;
						end
						
						if chatField ~= nil then
							GUI:remove(chatField);
							chatField:removeSelf();
							chatField = nil;
						end
						
						menunu.sendDriverMessages(messages, onPutReceived);
						sending = true;
					end
				else
					native.showAlert( "Message Error", "Message is empty", { "OK" } );
				end
			else
				native.showAlert( "Message Error", "No message", { "OK" } );
			end
		end
	end
	
	local sendButton = widget.newButton
	{
		width = (containerWidth*0.2 - chatFieldBorder*3),
		height = 30,
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		label = parameters.GRAPHICS.TEXT["send"],
		labelColor =
		{ 
			default = { parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3] },
			over = { 0, 0, 0 }
		},
		font = textmaker.getFontName("roboto-black"),
		fontSize = parameters.GRAPHICS.FONT_BASE_SIZE*1.25,
		onPress = sendButtonPress,
	}
	sendButton.anchorX = 0.5;
  	sendButton.anchorY = 0.5;
  	sendButton.x = containerWidth*0.9 - chatFieldBorder;
  	sendButton.y = containerHeight - chatFieldBorder - 15;
  	GUI:insert(sendButton);
  	
  	local chatOptions = {};
  	chatOptions.width = containerWidth;
  	chatOptions.height = containerHeight - 50;
  	
  	local chatView = chatFactory.newChat(chatOptions);
  	Foreground:insert(chatView);
  	
  	GUI:insert(loader);
  	
  	-- FUNCTIONS BEGIN
  	chatFunctions.requestMessages = function ( event )
		if isRequestingMessages ~= true then
			isRequestingMessages = true;
			
			local onMessagesReceived = function (response)
				local messages = nil;
				
				if response["error"] == true then
					logger.log("Messages Error: "..tostring(response["message"]));
				else
					local data = response["data"];
					if data["messages"] ~= nil then
						messages = data["messages"];
					end
				end
				
				if messages ~= nil then
					local messagesCount = 0;
					for k,v in pairs(messages) do
						messagesCount = messagesCount + 1
					end
					
					if messagesCount > 0 then
						logger.log(tostring(messagesCount).." messages received");
						
						-- Sort messages
						local function orderByTimestamp( a, b )
							return a.timestamp < b.timestamp;
						end
						table.sort(messages,orderByTimestamp);
						
						local toNotify = 0;
						for messageIndex,messageBlock in pairs(messages) do
							if messageBlock ~= nil and messageBlock.id ~= nil then
								local added = chatView.addMessage(messageBlock);
								if added == true and messageBlock.source == "remote" then
									toNotify = toNotify + 1;
								end
							end
						end
						
						if toNotify > 0 and containerEnabled == false then
							-- Notify new messages
							logger.log("Notify "..tostring(toNotify).." new messages...");
							
							if notificationsGw ~= nil then
								local notificationsGwSet = notificationsGw.set;
								local notificationsGwGet = notificationsGw.get;
								
								if notificationsGwSet ~= nil and notificationsGwGet ~= nil then
									local activeNotifications = notificationsGwGet(2);
									if activeNotifications <= 0 then
										notificationsGwSet(2,toNotify);
									end
								end
							end
						end
					else
						logger.log("No messages zero");
					end
				else
					logger.log("No messages nil");
				end
				
				if loader.started == true then
					loader.stop();
				end
				
				isRequestingMessages = false;
				
				-- Reset notifications badge
				if device.platform == "ios" then
					native.setProperty( "applicationIconBadgeNumber", 0 );
				end
			end
			
			menunu.getDriverMessages(onMessagesReceived);
		end
	end
  	
  	local enableContainerFunc = function ()
  		if containerEnabled ~= true then
  			if chatField == nil then
  				chatField = native.newTextField( 0, 0, (containerWidth*0.8 - chatFieldBorder*3), 30 );
				chatField:addEventListener( "userInput", onUserChat );
				chatField.anchorX = 0.0;
				chatField.anchorY = 1.0;
				chatField.x = chatFieldBorder;
				chatField.y = containerHeight - chatFieldBorder;
				GUI:insert(chatField);
  			end
  		
  			containerEnabled = true;
  		end
  	end
  	
  	local disableContainerFunc = function ()
  		logger.log("Disable Container on Chat");
  		if containerEnabled == true then
  			if chatField ~= nil then
  				GUI:remove(chatField);
  				chatField:removeSelf();
  				chatField = nil;
  			end
  		
  			containerEnabled = false;
  		end
  	end
  	
  	local loadContainerFunc = function ()
  		if containerLoaded ~= true then
  			if messagesRequestTimer ~= nil then
  				timer.cancel(messagesRequestTimer);
  				messagesRequestTimer = nil;
  			end
  			
  			local messagesRequestPeriod = parameters.SERVER.MESSAGES_REQUEST_PERIOD;
			local appSetup = storage.getConfiguration();
			if appSetup["configuration"] ~= nil then
				local appConfig = appSetup["configuration"];
				if appConfig["messages_period"] ~= nil then
					messagesRequestPeriod = tonumber(appConfig["messages_period"]);
				end
				if appConfig["recipient_user"] ~= nil then
					messagesRecipientDefaultUserId = tonumber(appConfig["recipient_user"]);
				end
			end
		
			messagesRequestPeriod = messagesRequestPeriod * 1000;
  			
  			messagesRequestTimer = timer.performWithDelay( messagesRequestPeriod, chatFunctions.requestMessages, -1 );
  			chatFunctions.requestMessages();
  		
  			containerLoaded = true;
  		end
  	end
  	
  	local unloadContainerFunc = function ()
  		if containerLoaded == true then
  			disableContainerFunc();
  		
  			if messagesRequestTimer ~= nil then
  				timer.cancel(messagesRequestTimer);
  				messagesRequestTimer = nil;
  			end
  			
  			backgroundBox:removeEventListener( "touch", touchBackgroundListener );
  			
  			if chatField ~= nil then
				GUI:remove(chatField);
				chatField:removeSelf();
				chatField = nil;
			end
			
			if chatView ~= nil then
				chatView.reset();
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