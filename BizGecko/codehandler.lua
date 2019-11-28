local codehandler={};
local status=true;
local register={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
local block={{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0},{i=0,r=0}};
local ba=0x00000000;
local po=0x00000000;
local endIf={[0]=0};
local substr=bizstring.substring;
local hex=bizstring.hex;

-- Gecko Codetype Bits
-- 111 1 111 1111111111111111111111111
-- ^   ^ ^   ^
-- |   | |   - Address
-- |   | - Subtype
-- |   - Base/Pointer Address
-- - Maintype

function getCodetype(line)
	return {
		main=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xE0000000),0x1D),
		sub=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0x0E000000),0x19)
	};
end

function getAddressType(line)
	return bit.rshift(bit.band(tonumber(substr(line,0,8),16),0x10000000),0x1C);
end

function getAddress(line)
	return bit.band(tonumber(substr(line,0,8),16),0x01FFFFFF);
end

function setAddress(addressType,address)
	if(addressType==0x0)then
		return address+ba;
	elseif(addressType==0x1)then
		return address+po;
	end
end

-- Codetype Parameters
function get00(line)
	return {
		address=getAddress(line),
		addressType=getAddressType(line),
		count=bit.rshift(bit.band(tonumber(substr(line,9,8),16),0xFFFF0000),0x10),
		value=bit.band(tonumber(substr(line,9,8),16),0x000000FF)
	};
end

function get02(line)
	return {
		address=getAddress(line),
		addressType=getAddressType(line),
		count=bit.rshift(bit.band(tonumber(substr(line,9,8),16),0xFFFF0000),0x10),
		value=bit.band(tonumber(substr(line,9,8),16),0x0000FFFF)
	};
end

function get04(line)
	return {
		address=getAddress(line),
		addressType=getAddressType(line),
		value=tonumber(substr(line,9,8),16)
	};
end

function get06(line)
	return {
		address=getAddress(line),
		addressType=getAddressType(line),
		lines=math.ceil(tonumber(substr(line,9,8),16)/8)
	};
end

function get08(line1, line2)
	return {
		address=getAddress(line1),
		addressType=getAddressType(line1),
		value=tonumber(substr(line1,9,8),16),
		size=bit.rshift(bit.band(tonumber(substr(line2,0,8),16),0xF0000000),0x1C),
		count=bit.rshift(bit.band(tonumber(substr(line2,0,8),16),0x0FFF0000),0x10),
		increment={
			address=bit.band(tonumber(substr(line2,0,8),16),0x0000FFFF),
			value=tonumber(substr(line2,9,8),16)
		}
	};
end

function get20(line)
	return {
		address=getAddress(line),
		addressType=getAddressType(line),
		value=tonumber(substr(line,9,8),16)
	};
end

function get28(line)
	return {
		address=getAddress(line),
		addressType=getAddressType(line),
		mask=bit.rshift(bit.band(tonumber(substr(line,9,8),16),0xFFFF0000),0x10),
		value=bit.band(tonumber(substr(line,9,8),16),0x0000FFFF)
	};
end

function get40(line)
	return {
		addressType=getAddressType(line),
		settings={
			register=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF000),0xC),
			address=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF0000),0x10),
			additonal=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF00000),0x14)
		},
		register=bit.band(tonumber(substr(line,0,8),16),0xF),
		address=tonumber(substr(line,9,8),16)
	};
end

function get60(line,i)
	return {
		type=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF00000),0x14),
		count=bit.band(tonumber(substr(line,0,8),16),0xFFFF),
		block=bit.band(tonumber(substr(line,9,8),16),0xF)
	};
end

function get80(line)
	return {
		addressType=getAddressType(line),
		settings={
			address=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF0000),0x10),
			additonal=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF00000),0x14)
		},
		register=bit.band(tonumber(substr(line,0,8),16),0xF),
		value=tonumber(substr(line,9,8),16)
	};
end

function get82(line)
	return {
		addressType=getAddressType(line),
		settings={
			address=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF0000),0x10),
			size=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF00000),0x14)
		},
		register=bit.band(tonumber(substr(line,0,8),16),0xF),
		address=tonumber(substr(line,9,8),16)
	};
end

function get84(line)
	return {
		addressType=getAddressType(line),
		settings={
			address=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF0000),0x10),
			size=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF00000),0x14)
		},
		count=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xFFF0),0x4),
		register=bit.band(tonumber(substr(line,0,8),16),0xF),
		address=tonumber(substr(line,9,8),16)
	};
end

function get86(line)
	return {
		settings={
			type=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF0000),0x10),
			operation=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF00000),0x14)
		},
		register={
			[1]=bit.band(tonumber(substr(line,0,8),16),0xF),
			[2]=bit.band(tonumber(substr(line,9,8),16),0xF)
		},
		address=tonumber(substr(line,9,8),16)
	};
end

function get8A(line)
	return {
		addressType=getAddressType(line),
		count=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xFFFF00),0x8),
		register={
			[1]=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0xF0),0x4),
			[2]=bit.band(tonumber(substr(line,0,8),16),0xF)
		},
		address=tonumber(substr(line,9,8),16)
	};
end

function getA0(line)
	return {
		address=getAddress(line),
		addressType=getAddressType(line),
		register={
			[1]=bit.rshift(bit.band(tonumber(substr(line,9,8),16),0xF0000000),0x1C),
			[2]=bit.rshift(bit.band(tonumber(substr(line,9,8),16),0x0F000000),0x18)
		},
		mask=bit.band(tonumber(substr(line,9,8),16),0x0000FFFF)
	};
end

function getA8(line)
	return {
		counter=bit.rshift(bit.band(tonumber(substr(line,0,8),16),0x000FFFF0),0x4),
		endIf=bit.band(tonumber(substr(line,0,8),16),0x0000000F),
		mask=bit.rshift(bit.band(tonumber(substr(line,9,8),16),0xFFFF0000),0x10),
		value=bit.band(tonumber(substr(line,9,8),16),0x0000FFFF)
	};
end

function getCC(line)
	return {state=bit.band(tonumber(substr(line,9,8),16),0x0000000F)};
end

function getCE(line)
	return {
		addressType=getAddressType(line),
		endIf=bit.band(tonumber(substr(line,0,8),16),0x0000000F),
		lower=bit.rshift(bit.band(tonumber(substr(line,9,8),16),0xFFFF0000),0x10),
		upper=bit.band(tonumber(substr(line,9,8),16),0x0000FFFF)
	};
end

function getE0(line)
	return {
		base=tonumber(substr(line,9,4),16),
		pointer=tonumber(substr(line,13,4),16)
	};
end

function getE2(line)
	return {
		endElse=tonumber(substr(line,2,1),16),
		endIf=tonumber(substr(line,6,2),16),
		base=tonumber(substr(line,9,4),16),
		pointer=tonumber(substr(line,13,4),16)
	};
end

-- Codetype Functions
function run00(params)
	if(status)then
		params.address=setAddress(params.addressType,params.address);
		for i=0,params.count,1 do
			memory.write_u8(params.address+i,params.value);
		end
	end
end

function run02(params)
	if(status)then
		params.address=setAddress(params.addressType,params.address);
		for i=0,params.count,1 do
			memory.write_u16_be(params.address+(i*2),params.value);
		end
	end
end

function run04(params)
	if(status)then
		params.address=setAddress(params.addressType,params.address);
		memory.write_u32_be(params.address,params.value);
	end
end

function run06(params,lines)
	if(status)then
		params.address=setAddress(params.addressType,params.address);
		local bytes={};
		for i=1,table.getn(lines),1 do
			local m=tonumber(substr(lines[i],0,8),16);
			local n=tonumber(substr(lines[i],9,8),16);
			table.insert(bytes,bit.rshift(bit.band(m,0xFF000000),0x18));
			table.insert(bytes,bit.rshift(bit.band(m,0x00FF0000),0x10));
			table.insert(bytes,bit.rshift(bit.band(m,0x0000FF00),0x08));
			table.insert(bytes,bit.band(m,0x000000FF));
			table.insert(bytes,bit.rshift(bit.band(n,0xFF000000),0x18));
			table.insert(bytes,bit.rshift(bit.band(n,0x00FF0000),0x10));
			table.insert(bytes,bit.rshift(bit.band(n,0x0000FF00),0x08));
			table.insert(bytes,bit.band(n,0x000000FF));
		end
		for i=1,table.getn(bytes),1 do
			memory.write_u8(params.address+(i-1),bytes[i]);
		end
	end
end

function run08(params)
	if(status)then
		params.address=setAddress(params.addressType,params.address);
		for i=0,params.count,1 do
			if(params.size==0x0)then
				memory.write_u8(params.address+(i*params.increment.address),params.value+(i*params.increment.value));
			elseif(params.size==0x1)then
				memory.write_u16_be(params.address+(i*params.increment.address),params.value+(i*params.increment.value));
			elseif(params.size==0x2)then
				memory.write_u32_be(params.address+(i*params.increment.address),params.value+(i*params.increment.value));
			end
		end
	end
end

function run20(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		if(memory.read_u32_be(params.address)==params.value)then
			setEndIf(true);
		else
			status=false;
		end
	end
end

function run22(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		if(memory.read_u32_be(params.address) ~= params.value)then
			setEndIf(true);
		else
			status=false;
		end
	end
end

function run24(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		if(memory.read_u32_be(params.address) > params.value)then
			setEndIf(true);
		else
			status=false;
		end
	end
end

function run26(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		if(memory.read_u32_be(params.address) < params.value)then
			setEndIf(true);
		else
			status=false;
		end
	end
end

function run28(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		if(bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask)) == params.value)then
			setEndIf(true);
		else
			status=false;
		end
	end
end

function run2A(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		if(bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask)) ~= params.value)then
			setEndIf(true);
		else
			status=false;
		end
	end
end

function run2C(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		if(bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask)) > params.value)then
			setEndIf(true);
		else
			status=false;
		end
	end
end

function run2E(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		if(bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask)) < params.value)then
			setEndIf(true);
		else
			status=false;
		end
	end
end

function run40(params)
	if(status)then
		-- Add Register
		if(params.settings.register==0x1)then
			params.address=params.address+register[params.register];
		end
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		end
		-- Set Base
		if(params.settings.additional==0x1)then
			ba=ba+memory.read_u32_be(params.address);
		else
			ba=memory.read_u32_be(params.address);
		end
	end
end

function run42(params)
	if(status)then
		-- Add Register
		if(params.settings.register==0x1)then
			params.address=params.address+register[params.register];
		end
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		end
		-- Set Base
		if(params.settings.additional==0x1)then
			ba=ba+params.address;
		else
			ba=params.address;
		end
	end
end

function run44(params)
	if(status)then
		-- Add Register
		if(params.settings.register==0x1)then
			params.address=params.address+register[params.register];
		end
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		end
		-- Write Base
		memory.write_u32_be(params.address,ba);
	end
end

function run48(params)
	if(status)then
		-- Add Register
		if(params.settings.register==0x1)then
			params.address=params.address+register[params.register];
		end
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		end
		-- Set Pointer
		if(params.settings.additional==0x1)then
			po=po+memory.read_u32_be(params.address);
		else
			po=memory.read_u32_be(params.address);
		end
	end
end

function run4A(params)
	if(status)then
		-- Add Register
		if(params.settings.register==0x1)then
			params.address=params.address+register[params.register];
		end
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		end
		-- Set Pointer
		if(params.settings.additional==0x1)then
			po=po+params.address;
		else
			po=params.address;
		end
	end
end

function run4C(params)
	if(status)then
		-- Add Register
		if(params.settings.register==0x1)then
			params.address=params.address+register[params.register];
		end
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		end
		-- Write Pointer
		memory.write_u32_be(params.address,po);
	end
end

function run80(params)
	if(status)then
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.value=params.value+ba;
			elseif(params.addressType==0x1)then
				params.value=params.value+po;
			end
		end
		-- Set Register
		if(params.settings.additional==0x1)then
			register[params.register]=register[params.register]+params.value;
		else
			register[params.register]=params.value;
		end
	end
end

function run82(params)
	if(status)then
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		end
		-- Set Register
		if(params.settings.size==0x0)then
			register[params.register]=memory.read_u8(params.address);
		elseif(params.settings.size==0x1)then
			register[params.register]=memory.read_u16_be(params.address);
		elseif(params.settings.size==0x2)then
			register[params.register]=memory.read_u32_be(params.address);
		end
	end
end

function run84(params)
	if(status)then
		-- Add Base/Pointer
		if(params.settings.address==0x1)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		end
		local value=0;
		if(params.settings.size==0x0)then
			value=bit.band(register[params.register],0xFF);
			for i=0,params.count,1 do
				memory.write_u8(params.address+i,value);
			end
		elseif(params.settings.size==0x1)then
			value=bit.band(register[params.register],0xFFFF);
			for i=0,params.count,1 do
				memory.write_u16_be(params.address+(i*2),value);
			end
		elseif(params.settings.size==0x2)then
			value=bit.band(register[params.register],0xFFFFFFFF);
			for i=0,params.count,1 do
				memory.write_u32_be(params.address+(i*4),value);
			end
		end
	end
end

function run86(params)
	if(status)then
		if(params.settings.type==0x0)then
			if(params.settings.operation==0x0)then
				register[params.register[1]]=register[params.register[1]]+params.address;
			elseif(params.settings.operation==0x1)then
				register[params.register[1]]=register[params.register[1]]*params.address;
			elseif(params.settings.operation==0x2)then
				register[params.register[1]]=bit.bor(register[params.register[1]],params.address);
			elseif(params.settings.operation==0x3)then
				register[params.register[1]]=bit.band(register[params.register[1]],params.address);
			elseif(params.settings.operation==0x4)then
				register[params.register[1]]=bit.bxor(register[params.register[1]],params.address);
			elseif(params.settings.operation==0x5)then
				register[params.register[1]]=bit.lshift(register[params.register[1]],params.address);
			elseif(params.settings.operation==0x6)then
				register[params.register[1]]=bit.rshift(register[params.register[1]],params.address);
			elseif(params.settings.operation==0x7)then
				register[params.register[1]]=bit.rol(register[params.register[1]],params.address);
			elseif(params.settings.operation==0x8)then
				register[params.register[1]]=bit.arshift(register[params.register[1]],params.address);
			elseif(params.settings.operation==0x9)then
				register[params.register[1]]=float2hex(hex2float(register[params.register[1]])+hex2float(params.address));
			elseif(params.settings.operation==0xA)then
				register[params.register[1]]=float2hex(hex2float(register[params.register[1]])*hex2float(params.address));
			end
		elseif(params.settings.type==0x1)then
			if(params.settings.operation==0x0)then
				memory.write_u32_be(register[params.register[1]],memory.read_u32_be(register[params.register[1]])+params.address);
			elseif(params.settings.operation==0x1)then
				memory.write_u32_be(register[params.register[1]],memory.read_u32_be(register[params.register[1]])*params.address);
			elseif(params.settings.operation==0x2)then
				memory.write_u32_be(register[params.register[1]],bit.bor(memory.read_u32_be(register[params.register[1]]),params.address));
			elseif(params.settings.operation==0x3)then
				memory.write_u32_be(register[params.register[1]],bit.band(memory.read_u32_be(register[params.register[1]]),params.address));
			elseif(params.settings.operation==0x4)then
				memory.write_u32_be(register[params.register[1]],bit.bxor(memory.read_u32_be(register[params.register[1]]),params.address));
			elseif(params.settings.operation==0x5)then
				memory.write_u32_be(register[params.register[1]],bit.lshift(memory.read_u32_be(register[params.register[1]]),params.address));
			elseif(params.settings.operation==0x6)then
				memory.write_u32_be(register[params.register[1]],bit.rshift(memory.read_u32_be(register[params.register[1]]),params.address));
			elseif(params.settings.operation==0x7)then
				memory.write_u32_be(register[params.register[1]],bit.rol(memory.read_u32_be(register[params.register[1]]),params.address));
			elseif(params.settings.operation==0x8)then
				memory.write_u32_be(register[params.register[1]],bit.arshift(memory.read_u32_be(register[params.register[1]]),params.address));
			elseif(params.settings.operation==0x9)then
				memory.writefloat(register[params.register[1]],memory.readfloat(register[params.register[1]])+hex2float(params.address));
			elseif(params.settings.operation==0xA)then
				memory.writefloat(register[params.register[1]],memory.readfloat(register[params.register[1]])*hex2float(params.address));
			end
		elseif(params.settings.type==0x2)then
			if(params.settings.operation==0x0)then
				register[params.register[1]]=register[params.register[1]]+memory.read_u32_be(params.address);
			elseif(params.settings.operation==0x1)then
				register[params.register[1]]=register[params.register[1]]*memory.read_u32_be(params.address);
			elseif(params.settings.operation==0x2)then
				register[params.register[1]]=bit.bor(register[params.register[1]],memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x3)then
				register[params.register[1]]=bit.band(register[params.register[1]],memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x4)then
				register[params.register[1]]=bit.bxor(register[params.register[1]],memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x5)then
				register[params.register[1]]=bit.lshift(register[params.register[1]],memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x6)then
				register[params.register[1]]=bit.rshift(register[params.register[1]],memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x7)then
				register[params.register[1]]=bit.rol(register[params.register[1]],memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x8)then
				register[params.register[1]]=bit.arshift(register[params.register[1]],memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x9)then
				register[params.register[1]]=float2hex(hex2float(register[params.register[1]])+memory.readfloat(params.address));
			elseif(params.settings.operation==0xA)then
				register[params.register[1]]=float2hex(hex2float(register[params.register[1]])*memory.readfloat(params.address));
			end
		elseif(params.settings.type==0x3)then
			if(params.settings.operation==0x0)then
				memory.write_u32_be(register[params.register[1]],memory.read_u32_be(register[params.register[1]])+memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x1)then
				memory.write_u32_be(register[params.register[1]],memory.read_u32_be(register[params.register[1]])*memory.read_u32_be(params.address));
			elseif(params.settings.operation==0x2)then
				memory.write_u32_be(register[params.register[1]],bit.bor(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(params.address)));
			elseif(params.settings.operation==0x3)then
				memory.write_u32_be(register[params.register[1]],bit.band(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(params.address)));
			elseif(params.settings.operation==0x4)then
				memory.write_u32_be(register[params.register[1]],bit.bxor(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(params.address)));
			elseif(params.settings.operation==0x5)then
				memory.write_u32_be(register[params.register[1]],bit.lshift(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(params.address)));
			elseif(params.settings.operation==0x6)then
				memory.write_u32_be(register[params.register[1]],bit.rshift(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(params.address)));
			elseif(params.settings.operation==0x7)then
				memory.write_u32_be(register[params.register[1]],bit.rol(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(params.address)));
			elseif(params.settings.operation==0x8)then
				memory.write_u32_be(register[params.register[1]],bit.arshift(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(params.address)));
			elseif(params.settings.operation==0x9)then
				memory.writefloat(register[params.register[1]],memory.readfloat(register[params.register[1]])+memory.readfloat(params.address));
			elseif(params.settings.operation==0xA)then
				memory.writefloat(register[params.register[1]],memory.readfloat(register[params.register[1]])*memory.readfloat(params.address));
			end
		end
	end
end

function run88(params)
	if(status)then
		if(params.settings.type==0x0)then
			if(params.settings.operation==0x0)then
				register[params.register[1]]=register[params.register[1]]+register[params.register[2]];
			elseif(params.settings.operation==0x1)then
				register[params.register[1]]=register[params.register[1]]*register[params.register[2]];
			elseif(params.settings.operation==0x2)then
				register[params.register[1]]=bit.bor(register[params.register[1]],register[params.register[2]]);
			elseif(params.settings.operation==0x3)then
				register[params.register[1]]=bit.band(register[params.register[1]],register[params.register[2]]);
			elseif(params.settings.operation==0x4)then
				register[params.register[1]]=bit.bxor(register[params.register[1]],register[params.register[2]]);
			elseif(params.settings.operation==0x5)then
				register[params.register[1]]=bit.lshift(register[params.register[1]],register[params.register[2]]);
			elseif(params.settings.operation==0x6)then
				register[params.register[1]]=bit.rshift(register[params.register[1]],register[params.register[2]]);
			elseif(params.settings.operation==0x7)then
				register[params.register[1]]=bit.rol(register[params.register[1]],register[params.register[2]]);
			elseif(params.settings.operation==0x8)then
				register[params.register[1]]=bit.arshift(register[params.register[1]],register[params.register[2]]);
			elseif(params.settings.operation==0x9)then
				register[params.register[1]]=float2hex(hex2float(register[params.register[1]])+hex2float(register[params.register[2]]));
			elseif(params.settings.operation==0xA)then
				register[params.register[1]]=float2hex(hex2float(register[params.register[1]])*hex2float(register[params.register[2]]));
			end
		elseif(params.settings.type==0x1)then
			if(params.settings.operation==0x0)then
				memory.write_u32_be(register[params.register[1]],memory.read_u32_be(register[params.register[1]])+register[params.register[2]]);
			elseif(params.settings.operation==0x1)then
				memory.write_u32_be(register[params.register[1]],memory.read_u32_be(register[params.register[1]])*register[params.register[2]]);
			elseif(params.settings.operation==0x2)then
				memory.write_u32_be(register[params.register[1]],bit.bor(memory.read_u32_be(register[params.register[1]]),register[params.register[2]]));
			elseif(params.settings.operation==0x3)then
				memory.write_u32_be(register[params.register[1]],bit.band(memory.read_u32_be(register[params.register[1]]),register[params.register[2]]));
			elseif(params.settings.operation==0x4)then
				memory.write_u32_be(register[params.register[1]],bit.bxor(memory.read_u32_be(register[params.register[1]]),register[params.register[2]]));
			elseif(params.settings.operation==0x5)then
				memory.write_u32_be(register[params.register[1]],bit.lshift(memory.read_u32_be(register[params.register[1]]),register[params.register[2]]));
			elseif(params.settings.operation==0x6)then
				memory.write_u32_be(register[params.register[1]],bit.rshift(memory.read_u32_be(register[params.register[1]]),register[params.register[2]]));
			elseif(params.settings.operation==0x7)then
				memory.write_u32_be(register[params.register[1]],bit.rol(memory.read_u32_be(register[params.register[1]]),register[params.register[2]]));
			elseif(params.settings.operation==0x8)then
				memory.write_u32_be(register[params.register[1]],bit.arshift(memory.read_u32_be(register[params.register[1]]),register[params.register[2]]));
			elseif(params.settings.operation==0x9)then
				memory.writefloat(register[params.register[1]],memory.readfloat(register[params.register[1]])+hex2float(register[params.register[2]]));
			elseif(params.settings.operation==0xA)then
				memory.writefloat(register[params.register[1]],memory.readfloat(register[params.register[1]])*hex2float(register[params.register[2]]));
			end
		elseif(params.settings.type==0x2)then
			if(params.settings.operation==0x0)then
				register[params.register[1]]=register[params.register[1]]+memory.read_u32_be(register[params.register[2]]);
			elseif(params.settings.operation==0x1)then
				register[params.register[1]]=register[params.register[1]]*memory.read_u32_be(register[params.register[2]]);
			elseif(params.settings.operation==0x2)then
				register[params.register[1]]=bit.bor(register[params.register[1]],memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x3)then
				register[params.register[1]]=bit.band(register[params.register[1]],memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x4)then
				register[params.register[1]]=bit.bxor(register[params.register[1]],memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x5)then
				register[params.register[1]]=bit.lshift(register[params.register[1]],memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x6)then
				register[params.register[1]]=bit.rshift(register[params.register[1]],memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x7)then
				register[params.register[1]]=bit.rol(register[params.register[1]],memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x8)then
				register[params.register[1]]=bit.arshift(register[params.register[1]],memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x9)then
				register[params.register[1]]=float2hex(hex2float(register[params.register[1]])+memory.readfloat(register[params.register[2]]));
			elseif(params.settings.operation==0xA)then
				register[params.register[1]]=float2hex(hex2float(register[params.register[1]])*memory.readfloat(register[params.register[2]]));
			end
		elseif(params.settings.type==0x3)then
			if(params.settings.operation==0x0)then
				memory.write_u32_be(register[params.register[1]],memory.read_u32_be(register[params.register[1]])+memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x1)then
				memory.write_u32_be(register[params.register[1]],memory.read_u32_be(register[params.register[1]])*memory.read_u32_be(register[params.register[2]]));
			elseif(params.settings.operation==0x2)then
				memory.write_u32_be(register[params.register[1]],bit.bor(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(register[params.register[2]])));
			elseif(params.settings.operation==0x3)then
				memory.write_u32_be(register[params.register[1]],bit.band(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(register[params.register[2]])));
			elseif(params.settings.operation==0x4)then
				memory.write_u32_be(register[params.register[1]],bit.bxor(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(register[params.register[2]])));
			elseif(params.settings.operation==0x5)then
				memory.write_u32_be(register[params.register[1]],bit.lshift(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(register[params.register[2]])));
			elseif(params.settings.operation==0x6)then
				memory.write_u32_be(register[params.register[1]],bit.rshift(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(register[params.register[2]])));
			elseif(params.settings.operation==0x7)then
				memory.write_u32_be(register[params.register[1]],bit.rol(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(register[params.register[2]])));
			elseif(params.settings.operation==0x8)then
				memory.write_u32_be(register[params.register[1]],bit.arshift(memory.read_u32_be(register[params.register[1]]),memory.read_u32_be(register[params.register[2]])));
			elseif(params.settings.operation==0x9)then
				memory.writefloat(register[params.register[1]],memory.readfloat(register[params.register[1]])+memory.readfloat(register[params.register[2]]));
			elseif(params.settings.operation==0xA)then
				memory.writefloat(register[params.register[1]],memory.readfloat(register[params.register[1]])*memory.readfloat(register[params.register[1]]));
			end
		end
	end
end

function run8A(params)
	if(status)then
		if(params.register[2]==0xF)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		else
			params.address=params.address+memory.read_u32_be(register[params.register[2]]);
		end
		for i=0,(params.count-1),1 do
			memory.write_u8(params.address+i,memory.read_u8(register[params.register[1]]+i));
		end
	end
end

function run8C(params)
	if(status)then
		if(params.register[1]==0xF)then
			if(params.addressType==0x0)then
				params.address=params.address+ba;
			elseif(params.addressType==0x1)then
				params.address=params.address+po;
			end
		else
			params.address=params.address+memory.read_u32_be(register[params.register[1]]);
		end
		for i=0,(params.count-1),1 do
			memory.write_u8(register[params.register[2]]+i,memory.read_u8(params.address+i));
		end
	end
end

function runA0(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		-- If Register 1 is F.
		if(params.register[1]==0xF and params.register[2]~=0xF)then
			if(bit.band(memory.read_u16_be(register[params.register[2]]),bit.bnot(params.mask))==bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		-- If Register 2 is F.
		elseif(params.register[1]~=0xF and params.register[2]==0xF)then
			if(bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask))==bit.band(memory.read_u16_be(register[params.register[1]]),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		-- If no Register F.
		elseif(params.register[1]~=0xF and params.register[2]~=0xF)then
			if(bit.band(memory.read_u16_be(register[params.register[2]]),bit.bnot(params.mask))==bit.band(memory.read_u16_be(register[params.register[1]]),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		end
	end
end

function runA2(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		-- If Register 1 is F.
		if(params.register[1]==0xF and params.register[2]~=0xF)then
			if(bit.band(memory.read_u16_be(register[params.register[2]]),bit.bnot(params.mask))~=bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		-- If Register 2 is F.
		elseif(params.register[1]~=0xF and params.register[2]==0xF)then
			if(bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask))~=bit.band(memory.read_u16_be(register[params.register[1]]),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		-- If no Register F.
		elseif(params.register[1]~=0xF and params.register[2]~=0xF)then
			if(bit.band(memory.read_u16_be(register[params.register[2]]),bit.bnot(params.mask))~=bit.band(memory.read_u16_be(register[params.register[1]]),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		end
	end
end

function runA4(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		-- If Register 1 is F.
		if(params.register[1]==0xF and params.register[2]~=0xF)then
			if(bit.band(memory.read_u16_be(register[params.register[2]]),bit.bnot(params.mask))>bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		-- If Register 2 is F.
		elseif(params.register[1]~=0xF and params.register[2]==0xF)then
			if(bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask))>bit.band(memory.read_u16_be(register[params.register[1]]),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		-- If no Register F.
		elseif(params.register[1]~=0xF and params.register[2]~=0xF)then
			if(bit.band(memory.read_u16_be(register[params.register[2]]),bit.bnot(params.mask))>bit.band(memory.read_u16_be(register[params.register[1]]),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		end
	end
end

function runA6(params)
	params.address=setAddress(params.addressType,params.address);
	-- if applying an endIf.
	if(params.address%2~=0)then
		setEndIf(false);
		applyEndIf(-1);
		params.address=params.address-1;
		status=endIf[endIf[0]];
	end
	applyEndIf(1);
	setEndIf(false);
	if(status)then
		-- If Register 1 is F.
		if(params.register[1]==0xF and params.register[2]~=0xF)then
			if(bit.band(memory.read_u16_be(register[params.register[2]]),bit.bnot(params.mask))<bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		-- If Register 2 is F.
		elseif(params.register[1]~=0xF and params.register[2]==0xF)then
			if(bit.band(memory.read_u16_be(params.address),bit.bnot(params.mask))<bit.band(memory.read_u16_be(register[params.register[1]]),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		-- If no Register F.
		elseif(params.register[1]~=0xF and params.register[2]~=0xF)then
			if(bit.band(memory.read_u16_be(register[params.register[2]]),bit.bnot(params.mask))<bit.band(memory.read_u16_be(register[params.register[1]]),bit.bnot(params.mask)))then
				setEndIf(true);
			else
				status=false;
			end
		end
	end
end

function runA8(params)
	if(params.endIf==0x1 or params.endIf==0x9)then
		setEndIf(false);
		applyEndIf(-1);
		status=endIf[endIf[0]];
	end
	if(status)then
		params.counter=params.counter+1;
		if(bit.band(params.value,bit.bnot(params.mask))==params.counter)then
			setEndIf(true);
			if(params.endIf==0x1 or params.endIf==0x9)then
				params.counter=0;
			end
		else
			status=false;
		end
	else
		params.counter=0;
	end
	return params.counter;
end

function runAA(params)
	if(params.endIf==0x1 or params.endIf==0x9)then
		setEndIf(false);
		applyEndIf(-1);
		status=endIf[endIf[0]];
	end
	if(status)then
		params.counter=params.counter+1;
		if(bit.band(params.value,bit.bnot(params.mask))~=params.counter)then
			setEndIf(true);
			if(params.endIf==0x1 or params.endIf==0x9)then
				params.counter=0;
			end
		else
			status=false;
		end
	else
		params.counter=0;
	end
	return params.counter;
end

function runAC(params)
	if(params.endIf==0x1 or params.endIf==0x9)then
		setEndIf(false);
		applyEndIf(-1);
		status=endIf[endIf[0]];
	end
	if(status)then
		if(bit.band(params.value,bit.bnot(params.mask))>params.counter)then
			setEndIf(true);
			if(params.endIf==0x1 or params.endIf==0x9)then
				params.counter=0;
			end
		else
			status=false;
		end
	else
		params.counter=0;
	end
	return params.counter;
end

function runAE(params)
	if(params.endIf==0x1 or params.endIf==0x9)then
		setEndIf(false);
		applyEndIf(-1);
		status=endIf[endIf[0]];
	end
	if(status)then
		if(bit.band(params.value,bit.bnot(params.mask))<params.counter)then
			setEndIf(true);
			if(params.endIf==0x1 or params.endIf==0x9)then
				params.counter=0;
			end
		else
			status=false;
		end
	else
		params.counter=0;
	end
	return params.counter;
end

function runCC(params)
	-- Start Fliping Switch
	if(status)then
		if(params.state==0x0)then
			params.state=0x2;
		elseif(params.state==0x1)then
			params.state=0x3;
		end
	-- Finish Flipping Switch
	else
		if(params.state==0x2)then
			params.state=0x1;
		elseif(params.state==0x3)then
			params.state=0x0;
		end
	end
	if(params.state==0x0 or params.state==0x3)then
		status=true;
	end
	return params.state;
end

function runCE(params)
	if(status)then
		if(params.params.endIf==0x1)then
			setEndIf(false);
			applyEndIf(-1);
		end
		if(params.addressType==0x0)then
			if(ba<bit.lshift(params.lower,0x10) or ba>=bit.lshift(params.upper,0x10))then
				status=false;
			end
		elseif(addressType==0x1)then
			if(po<bit.lshift(params.lower,0x10) or po>=bit.lshift(params.upper,0x10))then
				status=false;
			end
		end
	end
end

function runE0(params)
	for i=1,endIf[0],1 do
		applyEndIf(-1);
	end
	endIf[0]=0;
	status=true;
	if(params.base>=0x0000 and params.base<0x8000)then
		ba=bit.lshift(params.base,0x10);
	end
	if(params.pointer>=0x0000 and params.pointer<0x8000)then
		po=bit.lshift(params.pointer,0x10);
	end
end

function runE2(params)
	if(params.endIf>0)then
		for i=1,params.endIf,1 do
			applyEndIf(-1);
			if(endIf[i]==true or endIf[0]==0)then
				status=true;
			end
		end
		if(endIf[0]<0)then
			endIf[0]=0;
			status=true;
		end
	end 
	if(params.endElse==1 and endIf[endIf[0]]==false)then
		status=true;
	end
	if(params.base>=0x0000 and params.base<0x8000)then
		ba=bit.lshift(params.base,0x10);
	end
	if(params.pointer>=0x0000 and params.pointer<0x8000)then
		po=bit.lshift(params.pointer,0x10);
	end
end

function applyEndIf(n)
	endIf[0]=endIf[0]+n;
end

function setEndIf(b)
	endIf[endIf[0]]=b;
end

-- https://stackoverflow.com/questions/18886447/convert-signed-ieee-754-float-to-hexadecimal-representation
function float2hex(n)
    if(n==0.0)then return 0.0; end
    local sign=0;
    if(n<0.0)then
        sign=0x80;
        n=-n;
    end
    local mant,expo=math.frexp(n);
    local hext={};
    if(mant~=mant)then
		hext[#hext+1]=string.char(0xFF,0x88,0x00,0x00);
    elseif(mant==math.huge or expo>0x80)then
        if(sign==0)then
			hext[#hext+1]=string.char(0x7F,0x80,0x00,0x00);
        else
			hext[#hext+1] = string.char(0xFF,0x80,0x00,0x00);
        end
    elseif((mant==0.0 and expo==0) or expo<-0x7E)then
        hext[#hext+1]=string.char(sign,0x00,0x00,0x00);
    else
		expo=expo+0x7E;
		mant=(mant*2.0-1.0)*math.ldexp(0.5,24);
		hext[#hext+1]=string.char(sign+math.floor(expo/0x2),(expo%0x2)*0x80+math.floor(mant/0x10000),math.floor(mant/0x100)%0x100,mant%0x100);
    end
    return tonumber(string.gsub(table.concat(hext),"(.)",function (c) return string.format("%02X%s",string.byte(c),"") end),16);
end

function hex2float(c)
    if(c==0)then return 0.0; end
	local c=string.gsub(string.format("%X",c),"(..)",function (x) return string.char(tonumber(x,16)) end);
	local b1,b2,b3,b4=string.byte(c,1,4);
	local sign=b1>0x7F;
    local expo=(b1%0x80)*0x2+math.floor(b2/0x80);
    local mant=((b2%0x80)*0x100+b3)*0x100+b4
    if sign then
        sign=-1;
    else
        sign=1;
    end
    local n;
    if(mant==0 and expo==0)then
		n=sign*0.0;
    elseif(expo==0xFF)then
        if(mant==0)then
			n=sign*math.huge;
        else
			n=0.0/0.0;
        end
    else
		n=sign*math.ldexp(1.0+mant/0x800000,expo-0x7F);
    end
    return n;
end

-- Determine Codetype then execute.
function codehandler.run(list)
	local skip=1; -- use a variable to skip lines since lua can't change the for loop's control variable???
	for i=1,table.getn(list),1 do
		if(i>=skip)then
			local codetype=getCodetype(list[i]);
			-- print(codetype);
			if(codetype.main==0x0)then
				-- 00: Write Byte
				if(codetype.sub==0x0)then
					run00(get00(list[i]));
				-- 02: Write Word
				elseif(codetype.sub==0x1)then
					run02(get02(list[i]));
				-- 04: Write Double Word
				elseif(codetype.sub==0x2)then
					run04(get04(list[i]));
				-- 06: Write String
				elseif(codetype.sub==0x3)then
					local params=get06(list[i]);
					local lines={};
					for j=1,params.lines,1 do
						-- get the lines with the bytes to write.
						table.insert(lines, list[i+j]);
					end
					run06(params,lines);
					skip=i+params.lines+1; -- skip over the lines of bytes.
				-- 08: Slider
				elseif(codetype.sub==0x4)then
					run08(get08(list[i],list[i+1]));
					skip=i+2; -- skip over the second line of parameters.
				end
			elseif(codetype.main==0x1)then
				-- 20: If Equal - Double Word
				if(codetype.sub==0x0)then
					run20(get20(list[i]));
				-- 22: If Not Equal - Double Word
				elseif(codetype.sub==0x1)then
					run22(get20(list[i]));
				-- 24: If Greater Than - Double Word
				elseif(codetype.sub==0x2)then
					run24(get20(list[i]));
				-- 26: If Less Than - Double Word
				elseif(codetype.sub==0x3)then
					run26(get20(list[i]));
				-- 28: If Equal - Word
				elseif(codetype.sub==0x4)then
					run28(get28(list[i]));
				-- 2A: If Not Equal - Word
				elseif(codetype.sub==0x5)then
					run2A(get28(list[i]));
				-- 2C: If Greater Than - Word
				elseif(codetype.sub==0x6)then
					run2C(get28(list[i]));
				-- 2E: If Less Than - Word
				elseif(codetype.sub==0x7)then
					run2E(get28(list[i]));
				end
			elseif(codetype.main==0x2)then
				-- 40: Load into Base address
				if(codetype.sub==0x0)then
					run40(get40(list[i]));
				-- 42: Set Base address
				elseif(codetype.sub==0x1)then
					run42(get40(list[i]));
				-- 44: Store Base address
				elseif(codetype.sub==0x2)then
					run44(get40(list[i]));
				-- 46: Set Base address to next Code
				--elseif(codetype.sub==0x3)then
					-- run46(get40(list[i]));
				-- 48: Load into Pointer addressess
				elseif(codetype.sub==0x4)then
					run48(get40(list[i]));
				-- 4A: Set Pointer address
				elseif(codetype.sub==0x5)then
					run4A(get40(list[i]));
				-- 4C: Store Pointer address
				elseif(codetype.sub==0x6)then
					run4C(get40(list[i]));
				-- 4E: Set Pointer address to next Code
				--elseif(codetype.sub==0x7)then
					-- run4E(get40(list[i]));
				end
			elseif(codetype.main==0x3)then 
				-- 60: Set Repeat
				if(codetype.sub==0x0)then
					run60(get60(list[i],i));
				-- 62: Execute Repeat
				elseif(codetype.sub==0x1)then
					run62(get60(list[i],i));
				-- 64: Return
				elseif(codetype.sub==0x2)then
					run64(get60(list[i],i));
				-- 66: Goto
				elseif(codetype.sub==0x3)then
					run66(get60(list[i],i));
				-- 68: Gosub
				elseif(codetype.sub==0x4)then
					run68(get60(list[i],i));
				end
			elseif(codetype.main==0x4)then
				-- 80: Set Gecko Register
				if(codetype.sub==0x0)then
					run80(get80(list[i]));
				-- 82: Load into Gecko Register
				elseif(codetype.sub==0x1)then
					run82(get82(list[i]));
				-- 84: Store Gecko Register
				elseif(codetype.sub==0x2)then
					run84(get84(list[i]));
				-- 86: Register/Value Operations
				elseif(codetype.sub==0x3)then
					run86(get86(list[i]));
				-- 88: Register/Register Operations
				elseif(codetype.sub==0x4)then
					run88(get86(list[i]));
				-- 8A: Memory Copy 1
				elseif(codetype.sub==0x5)then
					run8A(get8A(list[i]));
				-- 8C: Memory Copy 2
				elseif(codetype.sub==0x6)then
					run8C(get8A(list[i]));
				end
			elseif(codetype.main==0x5)then
				-- A0: Gecko Register If Equal - Word
				if(codetype.sub==0x0)then
					runA0(getA0(list[i]));
				-- A2: Gecko Register If Not Equal - Word
				elseif(codetype.sub==0x1)then
					runA2(getA0(list[i]));
				-- A4: Gecko Register If Greater Than - Word
				elseif(codetype.sub==0x2)then
					runA4(getA0(list[i]));
				-- A6: Gecko Register If Less Than - Word
				elseif(codetype.sub==0x3)then
					runA6(getA0(list[i]));
				-- A8: Counter If Equal - Word
				elseif(codetype.sub==0x4)then
					local params=getA8(list[i]);
					local counter=runA8(params);
					list[i]=string.format("A80%04s%1s %04s%04s",hex(counter),hex(params.endIf),hex(params.mask),hex(params.value));
				-- AA: Counter If Not Equal - Word
				elseif(codetype.sub==0x5)then
					local params=getA8(list[i]);
					local counter=runAA(params);
					list[i]=string.format("AA0%04s%1s %04s%04s",hex(counter),hex(params.endIf),hex(params.mask),hex(params.value));
				-- AC: Counter If Greater Than - Word
				elseif(codetype.sub==0x6)then
					local params=getA8(list[i]);
					local counter=runAC(params);
					list[i]=string.format("AC0%04s%1s %04s%04s",hex(counter),hex(params.endIf),hex(params.mask),hex(params.value));
				-- AE: Counter If Less Than - Word
				elseif(codetype.sub==0x7)then
					local params=getA8(list[i]);
					local counter=runAE(params);
					list[i]=string.format("AE0%04s%1s %04s%04s",hex(counter),hex(params.endIf),hex(params.mask),hex(params.value));
				end
			-- ASM
			elseif(codetype.main==0x6)then
				-- C0: Execute ASM
				--if(codetype.sub==0x0)then
				--	runC0(getC0(list[i]));
				-- C2: Insert ASM
				--elseif(codetype.sub==0x1)then
				--	runC2(getC2(list[i]));
				-- C6: Create Branch
				--elseif(codetype.sub==0x3)then
				--	runC6(getC6(list[i]));
				-- CC: On/Off Switch
				if(codetype.sub==0x6)then
					local state=runCC(getCC(list[i]));
					list[i]=string.format("CC000000 %08s",hex(state));
				-- CE: Address Range Check
				elseif(codetype.sub==0x7)then
					runCE(getCE(list[i]));
				end
			elseif(codetype.main==0x7)then
				-- E0: Full Terminator
				if(codetype.sub==0x0)then
					params=getE0(list[i]);
					runE0(params);
				-- E2: EndIf/Else
				elseif(codetype.sub==0x1)then
					params=getE2(list[i]);
					runE2(params);
				end
			end
		end
	end
	return list;
end

return codehandler;