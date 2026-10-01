extends RefCounted
##DEAD CODE - DO NOT USE. kept purely as reference, it never runs.
##moved out of res://Gameplay/gameplay_objects_loader.gd where it used to sit
##inside one giant string literal, so it never ran there either.
##these are the old BlankTower / prepareBullet style tower definitions, including
##the old PathOne/PathTwo/PathThree upgrade model where an upgrade carried its
##own cost and desc instead of borrowing them from the target tower config.
"""
static var basic_towers = [
	BlankTower.instantiate().set_this_towers_values(
		'Ant', Enums.TargetingTypes.FIRST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,300,1,5,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			251,Enums.GuidanceTypes.SMART,#bulletspeed
			5,Enums.Fuses.IMPACT, #damage
			0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			null, #status object
			0,#AOE
			getAtlasAreaTexture(TESTING_ATLAS,22,10,64)
		]),
		getAtlasAreaTexture(BUG_ATLAS,2,2,32),
		[#upgrades, should be 2 per tower
			{"range":100,"damage":20,"muzzleVelocity":50,"sprite":getAtlasAreaTexture(BUG_ATLAS,3,2,32),
			"cost":10,"desc":"better dmg, bullet speed and range"},
			{"firerate":0.5,"canseecamo":Enums.CanSeeCamo.CANSEECAMO,"sprite":getAtlasAreaTexture(BUG_ATLAS,4,2,32),
			"cost":10,"desc":"faster firerate and can now see camo"},
			{
				"PathOne":{"Tower":"Fire Ant","cost":20,
					"desc":"Fire Ant, an ant focused on Fire & Fire DOT damage"},
				"PathTwo":{"Tower":"Bullet Ant","cost":20,
					"desc":"Bullet Ant, an ant focused on raw unguided firepower"},
				"PathThree":{"Tower":"Honey Ant","cost":20,
					"desc":"Honey ant, an ant focused on economics and buffing neaby towers "},
			}
			
		]
	),
	BlankTower.instantiate().set_this_towers_values(
		'Beetle', Enums.TargetingTypes.LAST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,200,0.25,10,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			250,Enums.GuidanceTypes.BALL,#bulletspeed
			5,Enums.Fuses.TIMER, #damage
			1, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			null, #status object
			32,#AOE
			getAtlasAreaTexture(BUG_ATLAS,2,9,32)
		]),
		getAtlasAreaTexture(BUG_ATLAS,2,1,32),
		[{"firerate":0.5,"aoeradius":16,"fusevalue":1,"sprite":getAtlasAreaTexture(BUG_ATLAS,3,1,32),
			"cost":10,"desc":"better firerate, ball Radius,and ball distance"},
			{"damage":5,"status":
				{'application':Enums.StatusApplication.DIRECT,
				'effectType':Enums.StatusEffectType.SLOW,
				'strength':2,'duration':3}
				,"sprite":getAtlasAreaTexture(BUG_ATLAS,4,1,32),
			"cost":15,"desc":"better Damage, and slowness effect"},
			{
				"PathOne":{"Tower":"Scarab","cost":20,
					"desc":"blah"},
				"PathTwo":{"Tower":"Dung Beetle","cost":20,
					"desc":"poopy"},
				"PathThree":{"Tower":"Atlas","cost":20,
					"desc":"NOT IMPLEMENTED YET"},
			}
		]
	)
]
static var special_towers = [
	BlankTower.instantiate().set_this_towers_values(
		'Fire Ant', Enums.TargetingTypes.CLOSEST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,300,0.25,10,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			300,Enums.GuidanceTypes.SMART,
			5,Enums.Fuses.IMPACT,
			0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			{'application':Enums.StatusApplication.DIRECT,
			'effectType':Enums.StatusEffectType.DOT,
			'strength':4,'duration':4},
			0,#AOE
			getAtlasAreaTexture(TESTING_ATLAS,22,12,64)
		]),
		getAtlasAreaTexture(BUG_ATLAS,5,2,32),
		[]
	),
	BlankTower.instantiate().set_this_towers_values(
		'Bullet Ant', Enums.TargetingTypes.LAST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,100,1,0,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			300,Enums.GuidanceTypes.DUMB,
			10,Enums.Fuses.TIMER,
			2, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			null,
			0,#AOE
			getAtlasAreaTexture(TESTING_ATLAS,22,12,64)
		]),
		getAtlasAreaTexture(BUG_ATLAS,8,2,32),
		[]
	),
	BlankTower.instantiate().set_this_towers_values(
		'Honey Ant', Enums.TargetingTypes.CLOSEST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,300,0.25,0,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			300,Enums.GuidanceTypes.SMART,
			1,Enums.Fuses.IMPACT,
			2, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			{'application':Enums.StatusApplication.DIRECT,
			'effectType':Enums.StatusEffectType.SLOW,
			'strength':2,'duration':10},
			0,#AOE
			getAtlasAreaTexture(TESTING_ATLAS,22,12,64)
		]),
		getAtlasAreaTexture(BUG_ATLAS,11,2,32),
		[]
	),
	BlankTower.instantiate().set_this_towers_values(
		'Scarab', Enums.TargetingTypes.LAST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,200,0.5,20,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			250,Enums.GuidanceTypes.DUMB,#bulletspeed
			5,Enums.Fuses.POINT, #damage
			1.5, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			{'application':Enums.StatusApplication.AOE,
				'effectType':Enums.StatusEffectType.STUN,
				'strength':1,'duration':3}, #status object
			200,#AOE
			getAtlasAreaTexture(BUG_ATLAS,2,9,32)
		]),
		getAtlasAreaTexture(BUG_ATLAS,5,1,32),
		[]
	),
	BlankTower.instantiate().set_this_towers_values(
		'Dung Beetle', Enums.TargetingTypes.LAST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,200,0.5,20,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			250,Enums.GuidanceTypes.BALL,#bulletspeed
			5,Enums.Fuses.TIMER, #damage
			2, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			{'application':Enums.StatusApplication.AOE,
				'effectType':Enums.StatusEffectType.STUN,
				'strength':1,'duration':2}, #status object
			64,#AOE
			getAtlasAreaTexture(BUG_ATLAS,2,9,32)
		]),
		getAtlasAreaTexture(BUG_ATLAS,8,1,32),
		[]
	),
	BlankTower.instantiate().set_this_towers_values(
		'Atlas', Enums.TargetingTypes.LAST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,200,0.5,20,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			250,Enums.GuidanceTypes.BALL,#bulletspeed
			5,Enums.Fuses.TIMEREXPLOSIVE, #damage
			2, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			{'application':Enums.StatusApplication.AOE,
				'effectType':Enums.StatusEffectType.STUN,
				'strength':2,'duration':3}, #status object
			25,#AOE
			getAtlasAreaTexture(BUG_ATLAS,2,9,32)
		]),
		getAtlasAreaTexture(BUG_ATLAS,11,1,32),
		[]
	)
]
"""
