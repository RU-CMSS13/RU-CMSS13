//Gun mounted flags
#define GUN_MOUNTING				(1<<0)
#define GUN_ONLY_MOUNTING			(1<<1)
#define GUN_MOUNTED					(1<<2)

#define GUN_CATEGORY_MOUNTED 6

#define GUN_MOUNT_NO 0
#define GUN_MOUNT_SMALL 1
#define GUN_MOUNT_MEDIUM 2
#define GUN_MOUNT_BIG 3
#define GUN_MOUNT_MECHA 4

DEFINE_BITFIELD(flags_mounted_gun_features, list(
	"MOUNTING" = GUN_MOUNTING,
	"GUN_ONLY_MOUNTING" = GUN_ONLY_MOUNTING,
	"MOUNTED" = GUN_MOUNTED,
))
