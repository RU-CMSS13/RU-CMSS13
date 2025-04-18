/client/proc/add_admin_verbs()
	if(!admin_holder)
		return
	if(CLIENT_IS_STAFF(src))
		add_verb(src, GLOB.admin_verbs_default)
	if(CLIENT_HAS_RIGHTS(src, R_MOD))
		add_verb(src, GLOB.admin_verbs_ban)
		add_verb(src, GLOB.admin_verbs_teleport)
	if(CLIENT_HAS_RIGHTS(src, R_EVENT))
		add_verb(src, GLOB.admin_verbs_minor_event)
	if(CLIENT_HAS_RIGHTS(src, R_ADMIN))
		add_verb(src, GLOB.admin_verbs_admin)
		add_verb(src, GLOB.admin_verbs_major_event)
	if(CLIENT_HAS_RIGHTS(src, R_MENTOR))
		add_verb(src, GLOB.mentor_verbs)
	if(CLIENT_HAS_RIGHTS(src, R_BUILDMODE))
		add_verb(src, /client/proc/togglebuildmodeself)
		add_verb(src, /client/proc/screen_alert_menu)
	if(CLIENT_HAS_RIGHTS(src, R_SERVER))
		add_verb(src, GLOB.admin_verbs_server)
	if(CLIENT_HAS_RIGHTS(src, R_DEBUG))
		add_verb(src, GLOB.admin_verbs_debug)
		if(!CONFIG_GET(flag/debugparanoid) || CLIENT_HAS_RIGHTS(src, R_ADMIN))
			add_verb(src, GLOB.admin_verbs_debug_advanced)  // Right now it's just callproc but we can easily add others later on.
	if(CLIENT_HAS_RIGHTS(src, R_POSSESS))
		add_verb(src, GLOB.admin_verbs_possess)
	if(CLIENT_HAS_RIGHTS(src, R_PERMISSIONS))
		add_verb(src, GLOB.admin_verbs_permissions)
	if(CLIENT_HAS_RIGHTS(src, R_COLOR))
		add_verb(src, GLOB.admin_verbs_color)
	if(CLIENT_HAS_RIGHTS(src, R_SOUNDS))
		add_verb(src, GLOB.admin_verbs_sounds)
	if(CLIENT_HAS_RIGHTS(src, R_SPAWN))
		add_verb(src, GLOB.admin_verbs_spawn)
	if(CLIENT_HAS_RIGHTS(src, R_STEALTH))
		add_verb(src, GLOB.admin_verbs_stealth)
	if(check_whitelist_status(WHITELIST_YAUTJA_LEADER))
		add_verb(src, GLOB.clan_verbs)

/client/proc/remove_admin_verbs()
	remove_verb(src, list(
		GLOB.admin_verbs_default,
		/client/proc/togglebuildmodeself,
		/client/proc/screen_alert_menu,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_minor_event,
		GLOB.admin_verbs_major_event,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_debug_advanced,
		GLOB.admin_verbs_possess,
		GLOB.admin_verbs_permissions,
		GLOB.admin_verbs_color,
		GLOB.admin_verbs_sounds,
		GLOB.admin_verbs_spawn,
		GLOB.admin_verbs_teleport,
		GLOB.admin_mob_event_verbs_hideable,
		GLOB.admin_verbs_hideable,
		GLOB.debug_verbs,
		GLOB.admin_verbs_stealth,
	))
