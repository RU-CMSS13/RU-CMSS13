/datum/admins/proc/getserverlogs()
	set name = "Get ANY-KIND Server Logs"
	set desc = "View/retrieve logfiles."
	set category = "Server"

	if(!check_rights(R_BAN))  return
	
	var/path = usr.client.browse_files_ru("data/logs/")
	if(!path)
		to_chat(src, "Could not find a file.")
		return

	if(usr.client.file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(wrap_file2text(wrap_file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(wrap_file(path))
		if ("Download")
			src << ftp(wrap_file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
	return

/proc/wrap_file(filepath)
	if(IsAdminAdvancedProcCall())
		// Admins shouldnt fuck with this
		to_chat(usr, "<span class='boldannounce'>File load blocked: Advanced ProcCall detected.</span>")
		message_admins("attempted to load files via advanced proc-call")
		return

	return file(filepath)

/client/proc/browse_files_ru(root="data/logs/", max_iterations=10, list/valid_extensions=list(".txt",".log",".htm"))
	var/path = root

	for(var/i=0, i<max_iterations, i++)
		var/list/choices = sortList(flist(path))
		if(path != root)
			choices.Insert(1,"/")
		choices = filter_file_name(choices)

		var/choice = tgui_input_list(usr, "Choose a file to access:", "Download", choices)
		switch(choice)
			if(null)
				return
			if("/")
				path = root
				continue
		path += choice

		if(copytext(path,-1,0) != "/") //didn't choose a directory, no need to iterate again
			break

	var/extension = copytext(path,-4,0)
	if( !fexists(path) || !(extension in valid_extensions) )
		to_chat(src, "<font color='red'>Error: browse_files(): File not found/Invalid file([path]).</font>")
		return

	return path

/proc/wrap_file2text(filepath)
	if(IsAdminAdvancedProcCall())
		// Admins shouldnt fuck with this
		to_chat(usr, "<span class='boldannounce'>File load blocked: Advanced ProcCall detected.</span>")
		message_admins("attempted to load files via advanced proc-call")
		return

	return file2text(filepath)

//Sends resource files to client cache
/client/proc/getFiles()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounce'>Shelleo blocked: Advanced ProcCall detected.</span>")
		message_admins("attempted to call Shelleo via advanced proc-call")
		return

	for(var/file in args)
		src << browse_rsc(file)

//Потом можно будет избавляться от лишней фигни в зависимости от содержимого
/client/proc/filter_file_name(list/listy)
	for(var/file_name in listy)
		if(findtext(file_name, "config_error"))
			listy.Remove(file_name)
	return listy
