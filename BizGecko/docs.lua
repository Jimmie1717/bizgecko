return {
	["DRW"]={
		[1]={
			["title"]="Write 8 bits:",
			["code"]="00______ YYYY00XX",
			["info"]="Writes the value XX to YYYY+1 consecutive byte-sized addresses, starting with the address ba+______.\n\nTo use po instead of ba, change the codetype from 00 to 10. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[2]={
			["title"]="Write 16 bits:",
			["code"]="02______ YYYYXXXX",
			["info"]="Writes the value XXXX to YYYY+1 consecutive half word-sized addresses, starting with the address ba+______.\n\nTo use po instead of ba, change the codetype from 00 to 10. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[3]={
			["title"]="Write 32 bits:",
			["code"]="04______ XXXXXXXX",
			["info"]="Writes the value XXXXXXXX to the address ba+______.\n\nTo use po instead of ba, change the codetype from 00 to 10. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[4]={
			["title"]="Write String:",
			["code"]="06______ XXXXXXXX\nB1B2B3B4 B5B6....",
			["info"]="Writes each byte (B1, B2, B3, ...) consecutively, starting at address ba+______. XXXXXXXX is the number of bytes to write.\n\nTo use po instead of ba, change the codetype from 06 to 16. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[5]={
			["title"]="Write Slider:",
			["code"]="08______ XXXXXXXX\nTNNNZZZZ VVVVVVVV",
			["info"]="ba+______ = Initial Address\nX = Initial value for the RAM write.\nT = Value Size (0 = byte, 1 = halfword, 2 = word).\nN = Amount of additional addresses to write to (the first is assumed).\nZ = Address Increment; in bytes (How many To skip By).\nV = Value Increment (How much to add to the value after each additional RAM write).\n\nTo use po instead of ba, change the codetype from 08 to 18. For values of ______ >= 0x01000000, add one to the codetype."
		}
	},
	["IFC"]={
		[1]={
			["title"]="If 32 bits equal:",
			["code"]="20______ XXXXXXXX",
			["info"]="Adding 1 to ______ will make this code first apply an Endif. It will still use ______ for address calculation; without the added 1.\n\nIf 32 bits at [ba+______]==XXXXXXXX, then codes are executed (else code execution set to false).\n\nTo use po instead of ba, change the codetype from 20 to 30. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[2]={
			["title"]="If 32 bits not equal:",
			["code"]="22______ XXXXXXXX",
			["info"]="Adding 1 to ______ will make this code first apply an Endif. It will still use ______ for address calculation; without the added 1.\n\nIf 32 bits at [ba+______]!=XXXXXXXX, then codes are executed (else code execution set to false).\n\nTo use po instead of ba, change the codetype from 22 to 32. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[3]={
			["title"]="If 32 bits greater than:",
			["code"]="24______ XXXXXXXX",
			["info"]="Adding 1 to ______ will make this code first apply an Endif. It will still use ______ for address calculation; without the added 1.\n\nIf 32 bits at [ba+______]>XXXXXXXX, then codes are executed (else code execution set to false).\n\nTo use po instead of ba, change the codetype from 24 to 34. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[4]={
			["title"]="If 32 bits less than:",
			["code"]="26______ XXXXXXXX",
			["info"]="Adding 1 to ______ will make this code first apply an Endif. It will still use ______ for address calculation; without the added 1.\n\nIf 32 bits at [ba+______]<XXXXXXXX, then codes are executed (else code execution set to false).\n\nTo use po instead of ba, change the codetype from 26 to 36. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[5]={
			["title"]="If 16 bits equal:",
			["code"]="28______ MMMMXXXX",
			["info"]="Adding 1 to ______ will make this code first apply an Endif. It will still use ______ for address calculation; without the added 1.\n\nIf 16 bits at ([ba+______] and not(MMMM))==XXXX, then codes are executed (else code execution set to false). Note that this is a bitwise and being used.\n\nTo use po instead of ba, change the codetype from 28 to 38. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[6]={
			["title"]="If 16 bits not equal:",
			["code"]="2A______ MMMMXXXX",
			["info"]="Adding 1 to ______ will make this code first apply an Endif. It will still use ______ for address calculation; without the added 1.\n\nIf 16 bits at ([ba+______] and not(MMMM))!=XXXX, then codes are executed (else code execution set to false). Note that this is a bitwise and being used.\n\nTo use po instead of ba, change the codetype from 2A to 3A. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[7]={
			["title"]="If 16 bits greater than:",
			["code"]="2C______ MMMMXXXX",
			["info"]="Adding 1 to ______ will make this code first apply an Endif. It will still use ______ for address calculation; without the added 1.\n\nIf 16 bits at ([ba+______] and not(MMMM))>XXXX, then codes are executed (else code execution set to false). Note that this is a bitwise and being used.\n\nTo use po instead of ba, change the codetype from 2C to 3C. For values of ______ >= 0x01000000, add one to the codetype."
		},
		[8]={
			["title"]="If 16 bits less than:",
			["code"]="2E______ MMMMXXXX",
			["info"]="Adding 1 to ______ will make this code first apply an Endif. It will still use ______ for address calculation; without the added 1.\n\nIf 16 bits at ([ba+______] and not(MMMM))<XXXX, then codes are executed (else code execution set to false). Note that this is a bitwise and being used.\n\nTo use po instead of ba, change the codetype from 2E to 3E. For values of ______ >= 0x01000000, add one to the codetype."
		}
	},
	["UKN"]={
		[1]={
			["title"]=":",
			["code"]="",
			["info"]=""
		}
	}
};