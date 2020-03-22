local M = {};

local lastMessageId = 0;

local sampleTexts = {};
sampleTexts[#sampleTexts+1] = "Lorem ipsum dolor sit amet, consectetur adipisicing elit.";
sampleTexts[#sampleTexts+1] = "Eligendi non quis exercitationem culpa nesciunt nihil aut nostrum explicabo reprehenderit. Voluptatum ducimus voluptates voluptas?";
sampleTexts[#sampleTexts+1] = "Zril fuisset deseruisse an sea.";
sampleTexts[#sampleTexts+1] = "OK!";
sampleTexts[#sampleTexts+1] = "I don't think so";
sampleTexts[#sampleTexts+1] = "Number is +01 (325) 657-3282";

local sampleSender = {};
sampleSender[#sampleSender+1] = "Eatzy Server";
sampleSender[#sampleSender+1] = "Brian Braido";
sampleSender[#sampleSender+1] = "Doug Wrightsman";
sampleSender[#sampleSender+1] = "Aaron Justi";
sampleSender[#sampleSender+1] = "Ron DeVille";
sampleSender[#sampleSender+1] = "Leah Humble";
sampleSender[#sampleSender+1] = "Bill Francione";
sampleSender[#sampleSender+1] = "Greg Trombley";
sampleSender[#sampleSender+1] = "Todd Drain";
sampleSender[#sampleSender+1] = "Troy Harris";
sampleSender[#sampleSender+1] = "Igor Stasevich";
sampleSender[#sampleSender+1] = "John Smith";
sampleSender[#sampleSender+1] = "Graph Test";
sampleSender[#sampleSender+1] = "Jason Statham";
sampleSender[#sampleSender+1] = "Adam Smith";
sampleSender[#sampleSender+1] = "Jane Jones";
sampleSender[#sampleSender+1] = "Aaron Justi";
sampleSender[#sampleSender+1] = "Pam Evans";
sampleSender[#sampleSender+1] = "Kenan Hopkins";
sampleSender[#sampleSender+1] = "Alex DeNoyelles";
sampleSender[#sampleSender+1] = "Walter DeNoyelles";
sampleSender[#sampleSender+1] = "Jeff Tice";
sampleSender[#sampleSender+1] = "Jesus DeLeon";
sampleSender[#sampleSender+1] = "Mark Pizzolatto";
sampleSender[#sampleSender+1] = "Kirk Messinger";
sampleSender[#sampleSender+1] = "Jeff Mayers";

M.generateMessage = function ()
	local message = {};
	
	lastMessageId = lastMessageId + 1;
	
	message.id = math.random(100);
	message.text = sampleTexts[math.random(#sampleTexts)];
	message.sender = sampleSender[math.random(#sampleSender)];
	
	if math.random(100) > 50 then
		message.source = "remote";
	else
		message.source = "local";
	end
	
	local randomMinute = math.random(60) - 1;
	local randomHour = math.random(24) - 1;
	local randomDay = math.random(28);
	local randomMonth = math.random(12);
	local randomYear = math.random(2010,2020)
	local randomTimestamp = os.time{year=randomYear, month=randomMonth, day=randomDay, hour=randomHour, minute=randomMinute};
	
	message.timestamp = randomTimestamp;
	
	return message;
end

return M;