local M = {};

local fonts;
local nativeFonts = native.getFontNames();

M.init = function ()
	fonts = {};
end

M.addFont = function (fontName, args)
	if fontName ~= nil and args ~= nil then
		if fonts[fontName] == nil then
			fonts[fontName] = {};
			fonts[fontName].ios = args.ios;
			fonts[fontName].android = args.android;
		end
	end
end

M.newText = function (text, x, y, fontNames, fontSize, width, height, alignment)
	if fontNames ~= nil and #fontNames > 0 then
		local nativeFont = nil;
		local fontNotFound = false;
		
		for i=1, #fontNames do
			local fontName = fontNames[i];
			local font = nil;
			
			if fonts[fontName] ~= nil then
				if device.platform == "android" then
					font = fonts[fontName].android;
				else
					font = fonts[fontName].ios;
				end
			
				if font ~= nil then
					for fontindex, fontname in ipairs(nativeFonts) do
						if fontname == font then
							nativeFont = fontname;
							break;
						end
					end
				end
				
				local textOptions = {};
				textOptions.text = text;
				textOptions.x = x;
				textOptions.y = y;
				textOptions.font = nativeFont;
				textOptions.fontSize = fontSize;
				if width ~= nil and tonumber(width) > 0 then
					textOptions.width = tonumber(width);
					if alignment ~= nil then
						textOptions.align = alignment;
					end
				end
				if height ~= nil and tonumber(height) > 0 then
					textOptions.height = tonumber(height);
				end
				
				local newText;
				if nativeFont ~= nil then
					newText = display.newText( textOptions );
					if newText == nil then
						textOptions.font = native.systemFont;
						newText = display.newText( textOptions );
					end
				else
					textOptions.font = native.systemFont;
					newText = display.newText( textOptions );
				end
				
				return newText;
			end
		end
	end
end

M.getFontName = function (fontName)
	if fontName ~= nil then
		if fonts[fontName] ~= nil then
			local result = "";
			if device.platform == "android" then
				result = fonts[fontName].android;
			else
				result = fonts[fontName].ios;
			end
			
			local found = false;
			if result ~= nil then
				for fontindex, fontname in ipairs(nativeFonts) do
					if fontname == result then
						found = true;
						break;
					end
				end
			end
			
			if found == true then
				return fontname;
			else
				return native.systemFont;
			end
		end
	end
end

return M;