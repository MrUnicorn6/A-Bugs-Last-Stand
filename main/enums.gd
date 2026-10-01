extends Node
##how a tower will decide what target to prioritize and shoot at, 
##it decides between whatever targets are already in its range
enum TargetingType {CLOSEST,##target closest to the tower
	STRONGEST,##highest health
	FIRST,##Furthest along its path, may change in future
	LAST##the least far along its path
	}
##a bullets guidance behavior
enum GuidanceType {
	##when fired will fly to the position its target was
	##when it was fired not updating/leading as it flies
	##and is deleted when it reaches its end
	DUMB,
	##constantly fly to the targets current position
	SMART,
	##similar to DUMB, but instead of being deleted at the point, 
	##uses a timer instead
	BALL}
	
##when a bullet will explode and or be deleted
enum Fuse {
	##hits a target, deals its direct damage to it,triggers its AOE if it has one
	## and then is deleted
	IMPACT,
	##very similar to IMPACT, but checks for targets in a radius, not intended to do 
	##direct damage
	PROXIMITY,POINT,
	##like direct, but ignores all but one specific target, meant for bullets 
	##that fly over many targets to reach a specific target.
	PRECISION,
	##Doesnt explode and is deleted after a set time,  meant for BALL type bullets
	TIMER,
	##explodes after a set time
	TIMER_EXPLOSIVE}
# ^^ not all of these are implementsed
##how a status will be applied when a bullet explodes
enum StatusApplication{
	NONE,
	##applies to its direct target
	DIRECT,
	##applies to targets in a radius
	AOE,
	##applies to targets in a radius, and continues as a 'puddle' for a set time
	AOE_LINGER}
##what a status effect does
enum StatusEffectType{
	## ignores strength value, stuns
	STUN,
	##deals damage over time using strength value
	DOT,
	##multiplies enemy speed using currspeed/strength like 100/2
	SLOW}
enum CanSeeCamo {CAN_SEE_CAMO,CANNOT_SEE_CAMO}

##element, for elemental resistances and bullets
enum ElementalType{NORMAL,FIRE,WATER,EARTH,ELECTRIC}
