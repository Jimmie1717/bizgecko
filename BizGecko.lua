-- BizGecko: by Jimmie1717
-- GameShark style cheat codes using the Gecko Codes format for BizHawk.
--
-- The Scripts need to be placed in BizHawk's "Lua" directory.
--	BizHawk/Lua/
--		BizGecko.lua			Creates the Form window, compiles the code list and calls the codehandler.
--		BizGecko/
--			codehandler.lua		Loops through the codes list and executes them.
--			cheats.lua			Contains the cheats for game(s) based on ROM ID.
--			docs.lua			Contains the codetype documentation.
--
-- Then load the BizGecko.lua in the Lua Console.
-- If there are codes for the current loaded game in the "cheats.lua" script they will be loaded.

console.clear();

function getROMID()
	local id="";
	for i=0,3,1 do
		id=string.format("%s%s",id,string.char(memory.read_u8(0x3B+i,"ROM")));
	end
	id=id..memory.read_u8(0x3F,"ROM");
	return id;
end

local gecko=require "BizGecko.codehandler";
local cheats=require "BizGecko.cheats";
local docs=require "BizGecko.docs";
local codes=cheats[getROMID()];
local code_list={};

if(codes~=nil)then
	gui.addmessage("BizGecko loaded codes for:");
	gui.addmessage(codes["name"]);
	gui.addmessage("");
else
	gui.addmessage("No codes for this game.");
end

-- Cheats Form
function BizGeckoForm()
	local y=38;
	local height=(table.getn(codes)-1)*19+236;
	local FORM=forms.newform(474,height,"BizGecko");
	local buttons={
		forms.button(FORM,"Add Cheat",addCheatForm,5,(height-64),142,20);
		forms.button(FORM,"Documentation",docsForm,152,(height-64),142,20);
	};
	local game={
		forms.label(FORM,"Game: "..codes["name"],5,3,280,14,false);
		forms.label(FORM,"Cheats: "..table.getn(codes),5,20,145,14,false);
	};
	local cheats_l={};
	local cheats_cb={};
	cheats_active={};
	local code={
		forms.label(FORM,"Code:",304,20,142,14,false);
		forms.label(FORM,"",304,38,142,(height-210),false);
	};
	local note={
		forms.label(FORM,"Notes:",5,(height-179),280,14,false);
		forms.label(FORM,"",5,(height-164),280,150,false);
	};
	for i=1,table.getn(codes),1 do
		-- populate cheat labels table.
		cheats_l[i]=forms.label(FORM, getName(i),21,y,280,19,false);
		-- populate cheat checkboxes table.
		cheats_cb[i]=forms.checkbox(FORM,"",8,y-5);
		-- populate active cheats table. (default to off)
		cheats_active[i]=false;
		-- update when a cheat is turned on/off.
		forms.addclick(cheats_cb[i],function() toggleCheat(cheats_cb[i],code[1],code[2],note[2],i); end);
		y=y+19;
	end
end

-- Turn Cheat on/off
function toggleCheat(checkBox,name,line,note,cheat)
		-- if cheat is turned on.
		if (forms.ischecked(checkBox)==false)then
			forms.settext(note,forms.gettext(note)..getNote(cheat));
			cheats_active[cheat]=true; 
		-- if cheat is turned off.
		else
			forms.settext(note,bizstring.replace(forms.gettext(note),getNote(cheat),""));
			cheats_active[cheat]=false;
		end
		-- Display code that was just turned off or on.
		forms.settext(name,"Code: "..getName(cheat));
		forms.settext(line,"");
		for i = 1,table.getn(codes[cheat]),1 do
			forms.settext(line, string.format("%s%s\n",forms.gettext(line),codes[cheat][i]));
		end
		updateCodeList();
end

-- Add Cheat Form
function addCheatForm()
	local FORM=forms.newform(236,318,"Add Cheat");
	local add_b=forms.button(FORM,"Add Cheat",addCode,4,245,212,30);
	local name_l=forms.label(FORM,"Name:",3,8,40,14,false);
	local code_l=forms.label(FORM,"Code:\n<CCXXXXXX> <YYYYYYYY>",3,28,212,28,false);
	local note_l=forms.label(FORM,"Note:",3,143,212,14,false);
	name_tb=forms.textbox(FORM,"",170,20,null,45,5,false,false);
	code_tb=forms.textbox(FORM,"",210,84,null,5,56,true,false);
	note_tb=forms.textbox(FORM,"",210,84,null,5,157,true,false);
end

-- Add cheats to the "codes" variable created from the "Cheats.lua" file.
-- NOTE: This does not write to the Cheats file.
-- TODO: 
--	Have it write the updated codes table to the "Cheats.lua" file.
--	Check if valid codetype/address/value.
--	Add confirmation that code was added.
function addCode()
	local cheat=table.getn(codes)+1;
	local codeLines=bizstring.split(forms.gettext(code_tb),"\n");
	table.insert(codes,{["name"]=forms.gettext(name_tb),["note"]=forms.gettext(note_tb)});
	for i=0,table.getn(codeLines),1 do
		table.insert(codes[cheat],bizstring.toupper(bizstring.trim(codeLines[i])));
	end
end

-- Display the Documentation.
function docsForm()
	local FORM=forms.newform(316,318,"Documentation");
	local buttons={
		forms.button(FORM,"Direct RAM Writes",function() infoForm("Direct RAM Writes","DRW"); end,5,5,290,20),
		forms.button(FORM,"If Codes",function() infoForm("If Codes","IFC"); end,5,30,290,20)
	};
end

function infoForm(formTitle,key)
	local index=1;
	local FORM=forms.newform(316,318,formTitle);
	local title=forms.label(FORM,docs[key][index]["title"],5,3,280,14,false);
	local code=forms.label(FORM,docs[key][index]["code"],20,20,265,27,false);
	local info=forms.label(FORM,docs[key][index]["info"],20,47,265,200,false);
	local buttons={
		forms.button(FORM,"Next",function() index=updateInfoForm(key,index,1,title,code,info); end,152,254,142,20),
		forms.button(FORM,"Previous",function() index=updateInfoForm(key,index,-1,title,code,info); end,5,254,142,20)
	};
end

function updateInfoForm(key,index,increment,title,code,info)
	index=index+increment;
	if(index<1)then
		index=table.getn(docs[key]);
	elseif(index>table.getn(docs[key]))then
		index=1;
	end
	forms.settext(title,docs[key][index]["title"]);
	forms.settext(code,docs[key][index]["code"]);
	forms.settext(info,docs[key][index]["info"]);
	return index;
end

-- Core Function
-- Determines if code is turned on then checks Codetypes and applies cheats.
function updateCodeList()
	code_list={};
	for i=1,table.getn(cheats_active),1 do
		if (cheats_active[i]==true)then
			-- loop through lines of code.
			for j=1,table.getn(codes[i]),1 do
				table.insert(code_list,codes[i][j]);
			end
		end
	end
end

-- Applies the codes.
function apply()
	if (table.getn(code_list)~=0) then
		code_list=gecko.run(code_list);
	end
end

-- get Functions
function getName(c)
	return codes[c]["name"];
end

function getNote(c)
	return codes[c]["note"];
end

-- set Functions
function setName(c,n)
	codes[c]["name"]=n;
end

function setNote(c,n)
	codes[c]["note"]=n;
end

function setLine(c,l,s)
	codes[c][l]=s;
end


-- Open BizGecko.
BizGeckoForm();
while true do
	if(codes~=nil) then
		apply();
	end
	emu.frameadvance();
end