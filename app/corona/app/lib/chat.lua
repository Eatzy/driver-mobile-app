local M = {};

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local widget = require( "widget" )

local messageDescriptors = {};
local lastMessageTimestamp = nil;

M.newChat = function (options)

	if options == nil then
		return nil;
	end
	
	if options.width == nil or options.height == nil then
		return nil;
	end
	
	local chatWidth = tonumber(options.width);
	local chatHeight = tonumber(options.height);
	local chatInnerBorder = 5;
	if options.innerborder ~= nil then
		chatInnerBorder = tonumber(options.innerborder);
	end
	local chatMaxBubbleSenderNameLength = 16;
	
	local chatManager = {};
	chatManager.yOffset = 0;
	
	local chatContainer = widget.newScrollView {
		left = 0,
		top = 0,
		width = chatWidth,
		height = chatHeight,
		hideBackground = true,
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = chatManager.scrollListener;
	}
	
	-- FUNCTIONS BEGIN
	
	chatManager.scrollListener = function (event)
		logger.log("On chatManager.scrollListener");
	end
	
	chatManager.createBubble = function (options)
		if options == nil then
			return nil;
		end
		
		if options.text == nil then
			return nil;
		end
		
		if options.source == nil then
			return nil;
		end
		
		if options.timestamp == nil then
			return nil;
		end
		
		local internalBorder = chatInnerBorder;
		
		local alignment = "left";
		local timestampAlignment = "right";
		local anchorX = 0.0;
		local senderName = nil;
		local bgColor = parameters.GRAPHICS.COLORS["bubble_remote_bg"];
		local textPadding = -internalBorder/2;
		if options.source == "local" then
			alignment = "right";
			timestampAlignment = "left";
			anchorX = 1.0;
			bgColor = parameters.GRAPHICS.COLORS["bubble_local_bg"];
			senderName = parameters.GRAPHICS.TEXT["you"];
		else
			textPadding = internalBorder/2;
			senderName = options.sender;
			if senderName == nil then
				senderName = "Unknown";
			end
		end
		
		local messageTimestamp = os.date("*t", options.timestamp);
		
		-- local messageDateString = string.format("%02d/%02d/%02d",messageTimestamp.day,messageTimestamp.month,(messageTimestamp.year%100));
		local messageDateString = string.format("%02d/%02d",messageTimestamp.month,messageTimestamp.day);
		local messageTimeString = string.format("%02d:%02d",messageTimestamp.hour,messageTimestamp.min);
		local messageTimestampText = messageDateString.." "..messageTimeString;
		
		if string.len(senderName) > chatMaxBubbleSenderNameLength then
			local senderAbbrName = string.sub( senderName, 0, chatMaxBubbleSenderNameLength );
			senderAbbrName = senderAbbrName .. "...";
			senderName = senderAbbrName;
		end
	
		local bubbleBlock = display.newGroup();
	
		local bubbleBlockWidth = chatWidth*0.825;
	
		local chatBubbleText = textmaker.newText(options.text,0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_MESSAGE_BUBBLE_SIZE, bubbleBlockWidth, 0, alignment);
		chatBubbleText:setFillColor(parameters.GRAPHICS.COLORS["bubble_text"][1],parameters.GRAPHICS.COLORS["bubble_text"][2],parameters.GRAPHICS.COLORS["bubble_text"][3]);
		chatBubbleText.anchorX = anchorX;
		chatBubbleText.anchorY = 1.0;
		chatBubbleText.x = textPadding;
		chatBubbleText.y = -internalBorder/2;
		
		local chatBubbleSenderText = textmaker.newText(senderName,0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_MESSAGE_BUBBLE_SIZE, bubbleBlockWidth, 0, alignment);
		chatBubbleSenderText:setFillColor(parameters.GRAPHICS.COLORS["bubble_sender"][1],parameters.GRAPHICS.COLORS["bubble_sender"][2],parameters.GRAPHICS.COLORS["bubble_sender"][3]);
		chatBubbleSenderText.anchorX = anchorX;
		chatBubbleSenderText.anchorY = 1.0;
		chatBubbleSenderText.x = textPadding;
		chatBubbleSenderText.y = -chatBubbleText.height - internalBorder/2;
		
		local chatBubbleTimestampText = textmaker.newText(messageTimestampText,0,0,{"roboto-black"}, parameters.GRAPHICS.FONT_MESSAGE_BUBBLE_SIZE*0.85, bubbleBlockWidth, 0, timestampAlignment);
		chatBubbleTimestampText:setFillColor(parameters.GRAPHICS.COLORS["bubble_timestamp"][1],parameters.GRAPHICS.COLORS["bubble_timestamp"][2],parameters.GRAPHICS.COLORS["bubble_timestamp"][3]);
		chatBubbleTimestampText.anchorX = 0.0 + math.abs( anchorX - 1.0 );
		chatBubbleTimestampText.anchorY = 1.0;
		if options.source == "local" then
			chatBubbleTimestampText.x = - chatBubbleText.width + textPadding;
		else
			chatBubbleTimestampText.x = chatBubbleText.width - textPadding;
		end
		chatBubbleTimestampText.y = chatBubbleSenderText.y;
		
		local chatBubbleBgHeight = chatBubbleText.height+chatBubbleSenderText.height+internalBorder*2;
		local chatBubbleBg = display.newRoundedRect( 0, 0, chatBubbleText.width+internalBorder, chatBubbleBgHeight, 6 );
		chatBubbleBg.strokeWidth = 0;
		chatBubbleBg:setStrokeColor( 0, 0, 0 );
		chatBubbleBg:setFillColor( bgColor[1], bgColor[2], bgColor[3] );
		chatBubbleBg.anchorX = chatBubbleText.anchorX;
		chatBubbleBg.anchorY = chatBubbleText.anchorY;
		chatBubbleBg.x = 0;
		chatBubbleBg.y = 0;
		
		bubbleBlock:insert(chatBubbleBg);
		bubbleBlock:insert(chatBubbleText);
		bubbleBlock:insert(chatBubbleSenderText);
		bubbleBlock:insert(chatBubbleTimestampText);
	
		return bubbleBlock;
	end
	
	chatManager.addMessage = function (message)
		if message == nil then
			return nil;
		end
		
		if message.id == nil or message.timestamp == nil or message.body == nil or message.source == nil then
			return nil;
		end
		local messageId = tonumber(message.id);
		local messageTimestamp = tonumber(message.timestamp);
		
		if lastMessageTimestamp ~= nil then
			if messageTimestamp < lastMessageTimestamp then
				logger.log("Message "..tostring(messageId)..": received too late, ts="..tostring(messageTimestamp)..", current="..tostring(lastMessageTimestamp));
				return nil;
			else
				lastMessageTimestamp = messageTimestamp;
			end
		else
			lastMessageTimestamp = messageTimestamp;
		end
		
		if messageId <= 0 then
			logger.log("Message ID is "..tostring(messageId));
			return nil;
		end
		
		logger.log("MessageID is "..tostring(messageId));
		
		-- Store message in memory
		if messageDescriptors[messageId] ~= nil then
			logger.log("Message already exists");
			return nil;
		end
		
		local chatOptions = {};
		chatOptions.text = tostring(message.body);
		chatOptions.source = tostring(message.source);
		chatOptions.timestamp = tonumber(message.timestamp);
		if message.sender ~= nil then
			chatOptions.sender = tostring(message.sender);
		end
		
		local chatBubble = chatManager.createBubble(chatOptions);
		
		if chatBubble == nil then
			logger.log("Can't create chat bubble");
			return nil;
		end
		
		chatManager.yOffset = chatManager.yOffset + chatBubble.height + 6;
		
		-- chatBubble.anchorX = 0.0;
		-- chatBubble.anchorY = 1.0;
		if message.source == "remote" then
			chatBubble.x = chatInnerBorder;
		else
			chatBubble.x = chatWidth - chatInnerBorder;
		end
		chatBubble.y = chatManager.yOffset;
		chatBubble.messageId = messageId;
		
		chatContainer:insert(messageId, chatBubble);
		messageDescriptors[messageId] = chatBubble;
		
		logger.log("chatManager.yOffset AFTER: "..tostring(chatManager.yOffset));
		
		chatContainer:scrollToPosition{y=math.min(0, (chatHeight-chatManager.yOffset)), time = 200, onComplete = nil}
		
		return true;
	end
	
	chatManager.reset = function ()
		logger.log("Reset chat container");
		
		-- Remove all bubbles
		logger.log("chatContainer.numChildren is "..tostring(chatContainer.numChildren));
		
		for messageId, messageBubble in pairs(messageDescriptors) do
			chatContainer:remove(messageBubble);
			messageBubble:removeSelf();
		end
		
		chatManager.yOffset = chatHeight;
		chatContainer:scrollToPosition{y=math.min(0, (chatHeight-chatManager.yOffset)), time = 1, onComplete = nil}
		
		messageDescriptors = {};
		lastMessageTimestamp = nil;
	end
	
	-- FUNCTIONS END
	
	-- Public functions
	chatContainer.addMessage = chatManager.addMessage;
	chatContainer.reset = chatManager.reset;
	
	return chatContainer;
end

return M;