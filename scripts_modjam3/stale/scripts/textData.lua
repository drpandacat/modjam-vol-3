local this = {}

local TEXT_DATA = {
	["ELECTROCHEMISTRY"] = {
		VOICE_DATA = {
			SFX =SoundEffect.SOUND_PESTILENCE_PUKE_START,
			PITCH = 1,
			VOLUME = .6
		},
		COLOUR_DATA = KColor(1,.2,.2,1),
		["LEVEL_1_INTRODUCTION"] = "Cmon' baby flick on the electrics\nyou know that taste, that feeling\nSEARCH OUT MORE PILLS.",
		["LEVEL_5_INTRODUCTION"] = "You know what...\nMaybe some of the stronger stuff will fix ya.",
		["LEVEL_10_INTRODUCTION"] = "Like father, like son, ata boy!\nNow all we got waiting for us \nis the bottom of the bottle",
		["PICKUP_CONVERSION"] = "Oh WOW, lookie here\nmaybe we don't have to look \nso hard after all.",
		["COLLECTIBLE_CONVERSION"] = "We didn't need that anyway\nTrust me...",
	},
	["INLAND EMPIRE"] = {
		VOICE_DATA = {
			SFX = 910,
			PITCH = .3,
			VOLUME = .7
		},
		COLOUR_DATA = KColor(.8,.5,.8,1),
		["LEVEL_1_INTRODUCTION"] = "from the depths of your mind \nyour inner sactum \nI awaken somthing deep within..",
		["LEVEL_5_INTRODUCTION"] = "or was it always there \nbehind in the piles of thoughts\ntoo infectious for \ndirect contact",
		["LEVEL_10_INTRODUCTION"] = "To the abyss we go together \nand maybe on the edge of oblivion \nyou'll realize you had no other option",
		["SHOP_SPAWN"] = "Sometimes, if you can just close your eyes \nyou could see the friends you wish you had \nthe one grace of being the minotaur",
		["SPAWN_BASEMENT"] = "Your house never had a basement did it? \nit was something you always dreamed about\njust another escape that never came...", 
		["SPAWN_CELLAR"] = "The wood feels more familliar to you\nwallowing in filth with the parasites\nyou don't mind the spiders-\nthey're less scary than people", 
		["SPAWN_BURNING_BASEMENT"] = "The summer the heat was maddening in the box\nyou've dreamt of the box igniting to end it all\nA practice session for hell perhaps..",
		["SPAWN_DOWNPOUR"] = "Sometimes the house would flood in storms\nyour mother could never afford to fix it\nso the damp became your home for the two of you",
		["SPAWN_DROSS"] = "The smell of shit should not feel nostalgic to you\nyou were too young to take care of yourself\nmaybe if you cried a little harder it could drown out their's",
		["SPAWN_CAVES"] = "Mould moss and lichen\nA garden created by the food served rotten\nMaybe the dead could find peace after all",
		["SPAWN_CATACOMBS"] = "Your home have long since become a prison\nVicious guards who hurt you on sight\ncould a toddler understand punishment?",
		["SPAWN_FLOODED_CAVES"] = "The mould could drown in the puddles\nIt could kill them if they went under too long\nto the plants the suffering was the reward",
		["SPAWN_MINES"] = "You need to work to earn your place here\nIf you don't work, then get the fuck out\nAt least.. that's what she said to your Dad",
		["SPAWN_ASHPIT"] = "Several trays litter every room of the house\nButts haven't been thown out for months\nWhoever she was, it was smoked out long ago",
		["SPAWN_DEPTHS"] = "Your counting footsteps aren't you?\nif she saw you, she wouldn't care to understand\nSome people want misery in company",
		["SPAWN_NECROPOLIS"] = "The dead stay here eternal now\nOr do the eternal stay eternal forever?\nsome things should be left forgotten",
		["SPAWN_DANK_DEPTHS"] = "The smell of tobacco is overpowering\nIt used to be stronger but the tar went rotten\nif only the floorboards didn't stick to your feet",
		["SPAWN_MAUSOLEUM"] = "Those of the sacred defy\nTorn of the maker's divide\nBorn from the faith in your mind\nfaith in your mind\nfaith in your mind...\ninto the greater beyond",
		["SPAWN_GEHENNA"] = "You shouldn't have gone looking\nSaw things you couldn't have seen\nDevils born under moonlight when people look away\nEven without the masks",
		["SPAWN_WOMB"] = "Was this the last time \nyour parents were happy?",
		["SPAWN_UTERO"] = "Do you blame yourself?\nDid god dislike your dad playing with you\nIs that why he sent him away?",
		["SPAWN_SCARRED_WOMB"] = "Is god punishing your mom\nfor how she treats you?\nWould removing yourself help that?",
		["SPAWN_CORPSE"] = "Because if you hurt her?\ndoes that mean your going to hell?\nIs there a reason not to anymore?",
		["SPAWN_BLUE_WOMB"] = "Would things be better\nIf you never came to be in the first place?\nwould the world go quiet?",
		["SPAWN_SHEOL"] = "And if you went to hell\n Would the devil look at you in disgust\nor would he take you in instead?",
		["SPAWN_CATHEDRAL"] = "Look at what you could have been.",
		["SPAWN_DARKROOM"] = "You should have been here from the start\nalways just one bad day away\nis today that bad day?",
		["SPAWN_CHEST"] = "Where's his eyes?\nWhere's his smile?\nYou've been gone a very long time",
		["SPAWN_VOID"] = "It was something you always dreamed about\nWould the devil look at you in disgust\nif she saw you, she wouldn't care to understand\nsome things should be left forgotten...\nwallowing in filth with the parasites",
		["SPAWN_HOME"] = "Today I died\nyouI leave all I own to my cat guppy.\nXOXO Isaac"
	}
}

function DiscoCards:getTextData(CardType,Enum)
	-- print(TEXT_DATA[CardType][Enum])
	return TEXT_DATA[CardType][Enum]
end

function DiscoCards:getVoiceData(CardType)
	if CardType == nil or CardType == "" then
		return
	end
	return TEXT_DATA[CardType].VOICE_DATA
end

function DiscoCards:getColour(CardType)
	if CardType == nil or CardType == "" then
		return KColor(0,1,0,1)
	end
	return TEXT_DATA[CardType].COLOUR_DATA
end

return this
