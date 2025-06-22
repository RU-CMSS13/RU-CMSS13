// [RU-CMSS13 ADD]

//Base Instance
/area/prison
	name = "Fiorina Orbital Penitentiary - Main Cellblock"
	ceiling = CEILING_GLASS
	ambience_exterior = AMBIENCE_PRISON
	soundscape_playlist = SCAPE_PL_FIORINA_COMMON
	ceiling_muffle = FALSE
	minimap_color = MINIMAP_AREA_COLONY

//SECURITY
/area/prison/security
	name = "\improper Security Department"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/prison/security/briefing
	name = "\improper Briefing"
	icon_state = "brig"

/area/prison/security/head
	name = "\improper Head of Security's office"
	icon_state = "sec_hos"

/area/prison/security/armory/riot
	name = "\improper Riot Armory"
	icon_state = "armory"

/area/prison/security/armory/lethal
	name = "\improper Lethal Armory"
	icon_state = "Tactical"

/area/prison/security/armory/highsec_monitoring
	name = "\improper High-Security Monitoring Armory"
	icon_state = "security_sub"

/area/prison/security/monitoring
	icon_state = "sec_prison"

/area/prison/security/monitoring/lowsec/ne
	name = "\improper Northeast Low-Security Monitoring"

/area/prison/security/monitoring/lowsec/sw
	name = "\improper Southwest Low-Security Monitoring"

/area/prison/security/monitoring/medsec/south
	name = "\improper Medium-Security Monitoring"
	soundscape_playlist = SCAPE_PL_FIORINA_COMPUTERS_ROOM
	ceiling = CEILING_GLASS

/area/prison/security/monitoring/medsec/central
	name = "\improper Central Medium-Security Monitoring"

/area/prison/security/monitoring/highsec
	name = "\improper High-Security Monitoring"

/area/prison/security/monitoring/maxsec
	name = "\improper Maximum-Security Monitoring"

/area/prison/security/monitoring/maxsec/panopticon
	name = "\improper Panopticon Monitoring"

/area/prison/security/monitoring/protective
	name = "\improper Protective Custody Monitoring"

/area/prison/security/checkpoint
	icon_state = "checkpoint1"

/area/prison/security/checkpoint/medsec
	name = "\improper Medium-Security Checkpoint"

/area/prison/security/checkpoint/highsec/n
	name = "\improper North High-Security Checkpoint"

/area/prison/security/checkpoint/highsec/s
	name = "\improper South High-Security Checkpoint"

/area/prison/security/checkpoint/vip
	name = "\improper VIP Checkpoint"

/area/prison/security/checkpoint/maxsec
	name = "\improper Maximum-Security Checkpoint"

/area/prison/security/checkpoint/highsec_medsec
	name = "\improper High-to-Medium-Security Checkpoint"

/area/prison/security/checkpoint/maxsec_highsec
	name = "\improper Maximum-to-High-Security Checkpoint"

/area/prison/storage
	icon_state = "engine_storage"

/area/prison/storage/medsec
	name = "\improper Medium-Security Storage"

/area/prison/storage/highsec/n
	name = "\improper North High-Security Storage"

/area/prison/storage/highsec/s
	name = "\improper South High-Security Storage"

/area/prison/storage/vip
	name = "\improper VIP Storage"

/area/prison/recreation
	icon_state = "party"

/area/prison/recreation/staff
	name = "\improper Staff Recreation"

/area/prison/recreation/medsec
	name = "\improper Medium-Security Recreation"

/area/prison/recreation/highsec/n
	name = "\improper North High-Security Recreation"

/area/prison/recreation/highsec/s
	name = "\improper South High-Security Recreation"

/area/prison/execution
	name = "\improper Execution"
	icon_state = "dark"

/area/prison/store
	name = "\improper Prison Store"
	icon_state = "bar"

/area/prison/chapel
	name = "\improper Chapel"
	icon_state = "chapel"

/area/prison/holding/holding1
	name = "\improper Holding Cell 1"
	icon_state = "blue-red2"
	minimap_color = MINIMAP_AREA_SEC

/area/prison/holding/holding2
	name = "\improper Holding Cell 2"
	icon_state = "blue-red-d"
	minimap_color = MINIMAP_AREA_SEC

/area/prison/cleaning
	name = "\improper Custodial Supplies"
	icon_state = "janitor"

/area/prison/command/office
	name = "\improper Warden's Office"
	icon_state = "Warden"

/area/prison/command/secretary_office
	name = "\improper Warden's Secretary's Office"
	icon_state = "blue"

/area/prison/command/quarters
	name = "\improper Warden's Quarters"
	icon_state = "party"

/area/prison/toilet
	icon_state = "restrooms"

/area/prison/toilet/canteen
	name = "\improper Canteen Restooms"

/area/prison/toilet/security
	name = "\improper Security Restooms"

// [RU-CMSS13 ADD]

/area/prison/toilet/research
	name = "\improper Research Restooms"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI

// [RU-CMSS13 ADD-END]

/area/prison/toilet/staff
	name = "\improper Staff Restooms"

/area/prison/maintenance
	icon_state = "asmaint"

/area/prison/maintenance/residential

/area/prison/maintenance/residential/nw
	name = "\improper Northwest Civilian Residences Maintenance"

/area/prison/maintenance/residential/ne
	name = "\improper Northeast Civilian Residences Maintenance"

/area/prison/maintenance/residential/sw
	name = "\improper Southwest Civilian Residences Maintenance"

/area/prison/maintenance/residential/se
	name = "\improper Southeast Civilian Residences Maintenance"

/area/prison/maintenance/residential/access/north
	name = "\improper North Civilian Residences Access"

/area/prison/maintenance/residential/access/south
	name = "\improper South Civilian Residences Access"

/area/prison/maintenance/staff_research
	name = "\improper Staff-Research Maintenance"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI
	icon_state = "maint_research_starboard"

/area/prison/maintenance/research_medbay
	name = "\improper Research-Infirmary Maintenance"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI
	icon_state = "maint_research_port"

/area/prison/maintenance/hangar_barracks
	name = "\improper Hangar-Barracks Maintenance"
	soundscape_playlist = SCAPE_PL_FIORINA_COMPUTERS_ROOM
	icon_state = "maint_e_shuttle"
	is_landing_zone = TRUE

/area/prison/canteen
	name = "\improper Canteen"
	icon_state = "cafeteria"

/area/prison/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/prison/laundry
	name = "\improper Laundry"
	icon_state = "bluenew"

/area/prison/library
	name = "\improper Library"
	icon_state = "green"

/area/prison/engineering
	name = "\improper Engineering"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI

/area/prison/engineering/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"

/area/prison/intake
	name = "\improper Intake Processing"
	icon_state = "green"

/area/prison/parole/main
	name = "\improper Parole"
	icon_state = "blue2"

/area/prison/parole/protective_custody
	name = "\improper Protective Custody Parole"
	icon_state = "red2"

/area/prison/visitation
	name = "\improper Visitation"
	icon_state = "yellow"

/area/prison/yard
	name = "\improper Yard"
	icon_state = "thunder"

//HALLWAYS

/area/prison/hallway/entrance
	name = "\improper Entrance Hallway"
	icon_state = "entry"

/area/prison/hallway/central
	name = "\improper Central Ring"
	icon_state = "hallC1"

/area/prison/hallway/central/east
	name = "\improper East Central Ring"

/area/prison/hallway/central/north
	name = "\improper North Central Ring"

/area/prison/hallway/central/south
	name = "\improper South Central Ring"

/area/prison/hallway/central/west
	name = "\improper West Central Ring"

/area/prison/hallway/east
	name = "\improper East Hallway"
	icon_state = "east"

/area/prison/hallway/staff
	name = "\improper Staff Hallway"
	icon_state = "hallS"

/area/prison/hallway/engineering
	name = "\improper Engineering Hallway"
	icon_state = "dk_yellow"
	minimap_color = MINIMAP_AREA_ENGI

//QUARTERS

/area/prison/quarters/staff //In SCI
	name = "\improper Staff Quarters"
	icon_state = "crew_quarters"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI

/area/prison/quarters/research //In SCI
	name = "\improper Research Dorms"
	icon_state = "purple"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI
	minimap_color = MINIMAP_AREA_RESEARCH


/area/prison/quarters/security //In SEC room
	name = "\improper Security Barracks"
	icon_state = "sec_backroom"

//CELLBLOCKS

/area/prison/cellblock/lowsec
	minimap_color = MINIMAP_AREA_CELL_LOW

//Start of Central Cell's ring
/area/prison/cellblock/lowsec/nw
	name = "\improper Northwest Low-Security Cellblock"
	icon_state = "cells_low_nw"

/area/prison/cellblock/lowsec/ne
	name = "\improper Northeast Low-Security Cellblock"
	icon_state = "cells_low_ne"

/area/prison/cellblock/lowsec/sw
	name = "\improper Southwest Low-Security Cellblock"
	icon_state = "cells_low_sw"

/area/prison/cellblock/lowsec/se
	name = "\improper Southeast Low-Security Cellblock"
	icon_state = "cells_low_se"
//End of central ring

//Start of South Cell Blocks
/area/prison/cellblock/mediumsec
	name = "\improper Medium-Security Cellblock"
	icon_state = "cells_med"
	minimap_color = MINIMAP_AREA_CELL_MED

/area/prison/cellblock/mediumsec/north
	name = "\improper Medium-Security Cellblock North"
	icon_state = "cells_med_n"

/area/prison/cellblock/mediumsec/south
	name = "\improper Medium-Security Cellblock South"
	icon_state = "cells_med_s"

/area/prison/cellblock/mediumsec/east
	name = "\improper Medium-Security Cellblock East"
	icon_state = "cells_med_e"

/area/prison/cellblock/mediumsec/west
	name = "\improper Medium-Security Cellblock West"
	icon_state = "cells_med_w"
//End of South Cell Blocks

//Start of West-North Cell Blocks
/area/prison/cellblock/highsec
	minimap_color = MINIMAP_AREA_CELL_HIGH

/area/prison/cellblock/highsec/north/north
	name = "\improper North High-Security Cellblock North"
	icon_state = "cells_high_nn"

/area/prison/cellblock/highsec/north/south
	name = "\improper North High-Security Cellblock South"
	icon_state = "cells_high_ns"
//End of West-North Cell Blocks

//Start of West-South Cell Blocks
/area/prison/cellblock/highsec/south/north
	name = "\improper South High-Security Cellblock North"
	icon_state = "cells_high_sn"

/area/prison/cellblock/highsec/south/south
	name = "\improper South High-Security Cellblock South"
	icon_state = "cells_high_ss"
//End of West-South Cell Blocks

//Start North Cell's Blocks
/area/prison/cellblock/maxsec
	minimap_color = MINIMAP_AREA_CELL_MAX

/area/prison/cellblock/maxsec/north
	name = "\improper Maximum-Security Panopticon Cellblock"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI
	icon_state = "cells_max_n"

/area/prison/cellblock/maxsec/south
	name = "\improper Maximum-Security Suspended Cellblock"
	icon_state = "cells_max_s"
//End North Cell Blocks

//Start VIP Cell blocks
/area/prison/cellblock/vip
	name = "\improper VIP Cells"
	icon_state = "cells_vip"
	minimap_color = MINIMAP_AREA_CELL_VIP

/area/prison/cellblock/protective
	name = "\improper Protective Custody"
	icon_state = "cells_protective"
	minimap_color = MINIMAP_AREA_CELL_VIP
	//End VIP Cell blocks

//DISPSOSAL

/area/prison/disposal
	name = "\improper Disposals"
	icon_state = "disposal"

//MEDBAY

/area/prison/medbay
	name = "\improper Infirmary"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI
	icon_state = "medbay"

/area/prison/medbay/foyer
	name = "\improper Infirmary Foyer"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI
	icon_state = "medbay2"

/area/prison/medbay/surgery
	name = "\improper Operating Theatre"
	icon_state = "medbay3"

/area/prison/medbay/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI


// RESEARCH
/area/prison/research
	name = "\improper Biological Research Department"
	icon_state = "research"
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI

/area/prison/research/RD
	name = "\improper Research Director's office"
	icon_state = "disposal"
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/prison/research/secret
	name = "\improper Classified Research"
	icon_state = "toxlab"
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/prison/research/secret/WYLab
	name = "\improper WY Research Laboratory"
	icon_state = "purple"
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/prison/research/secret/dissection
	name = "\improper Dissection"
	icon_state = "toxmix"
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/prison/research/secret/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/prison/research/secret/bioengineering
	name = "\improper Bioengineering"
	icon_state = "toxmisc"
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/prison/research/secret/containment
	name = "\improper Test Subject Containment"
	icon_state = "xeno_f_store"
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/prison/research/secret/testing
	name = "\improper Biological Testing"
	icon_state = "toxtest"
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS

/area/prison/residential/central
	name = "\improper Civilian Residences Central"
	icon_state = "blue-red2"

/area/prison/residential/north
	name = "\improper Civilian Residences North"
	icon_state = "blue2"

/area/prison/residential/south
	name = "\improper Civilian Residences South"
	icon_state = "red2"

/area/prison/monorail
	icon_state = "purple"

/area/prison/monorail/west
	name = "\improper West Monorail Station"

/area/prison/hangar_storage/main
	name = "\improper Main Hangar Storage"
	soundscape_playlist = SCAPE_PL_FIORINA_MACHINES_ROOM
	icon_state = "quartstorage"

/area/prison/hangar_storage/research/shuttle
	name = "Corporate Shuttle"
	is_landing_zone = FALSE

/area/prison/telecomms
	name = "\improper Telecommunications"
	soundscape_playlist = SCAPE_PL_FIORINA_MACHINES_ROOM
	icon_state = "tcomsatcham"

/area/prison/pirate
	name = "Tramp Freighter \"Rocinante\""
	icon_state = "syndie-ship"
	requires_power = 0

/area/prison/secret
	name = "\improper Secret Room"
	icon_state = "tcomsatcham"

//LZ CODE
//LZ 1

/area/prison/hanger/main
	name = "\improper Main Hanger"
	icon_state = "hangar_alpha"
	is_landing_zone = TRUE
	linked_lz = DROPSHIP_LZ1
	minimap_color = MINIMAP_AREA_LZ

/area/prison/landing/console
	name = "\improper LZ1 'Admin'"
	icon_state = "tcomsatcham"
	requires_power = 0
	linked_lz = DROPSHIP_LZ1
	minimap_color = MINIMAP_AREA_LZ

/area/prison/security/checkpoint/hangar
	name = "\improper Main Hangar Traffic Control"
	soundscape_playlist = SCAPE_PL_FIORINA_COMPUTERS_ROOM
	is_landing_zone = TRUE
	linked_lz = DROPSHIP_LZ1
	minimap_color = MINIMAP_AREA_LZ

/area/prison/monorail/east
	name = "\improper East Monorail Station"
	is_landing_zone = TRUE
	linked_lz = DROPSHIP_LZ1
	minimap_color = MINIMAP_AREA_LZ

//LZ 2

/area/prison/hanger/research
	name = "\improper Research Hanger"
	icon_state = "hangar_beta"
	is_landing_zone = TRUE
	linked_lz = DROPSHIP_LZ2
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI
	minimap_color = MINIMAP_AREA_LZ

/area/prison/landing/console2
	name = "\improper LZ2 'Research'"
	icon_state = "tcomsatcham"
	requires_power = 0
	is_landing_zone = TRUE
	linked_lz = DROPSHIP_LZ2
	soundscape_playlist = SCAPE_PL_FIORINA_NEAR_SCI
	minimap_color = MINIMAP_AREA_LZ

/area/prison/hangar_storage/research
	name = "\improper Research Hangar Storage"
	icon_state = "toxstorage"
	is_landing_zone = TRUE
	linked_lz = DROPSHIP_LZ2
	ambience_exterior = AMBIENCE_PRISON_ALARM
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	minimap_color = MINIMAP_AREA_LZ

// [RU-CMSS13 ADD-END]
