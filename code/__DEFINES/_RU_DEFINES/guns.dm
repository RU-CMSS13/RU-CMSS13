//Gun mounted flags
#define GUN_MOUNTING				(1<<0)
#define GUN_ONLY_MOUNTING			(1<<1)
#define GUN_MOUNTED					(1<<2)

#define GUN_CATEGORY_MOUNTED 6

//0 - null, 1 - small (can install in 1,2,3 class MD), 2 - medium, 3 - big (likely artilery and ltb)
#define GUN_MOUNT_SMALL 1
#define GUN_MOUNT_MEDIUM 2
#define GUN_MOUNT_BIG 3

DEFINE_BITFIELD(flags_mounted_gun_features, list(
	"MOUNTING" = GUN_MOUNTING,
	"GUN_ONLY_MOUNTING" = GUN_ONLY_MOUNTING,
	"MOUNTED" = GUN_MOUNTED,
))
