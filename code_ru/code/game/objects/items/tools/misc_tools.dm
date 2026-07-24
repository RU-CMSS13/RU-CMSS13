/obj/item/tool/pen/fountain
	desc = "A lavish testament to the ingenuity of ARMAT's craftsmanship, this fountain pen is a paragon of design and functionality. Detailed with golden accents and intricate mechanics, the pen allows for a swift change between a myriad of ink colors with a simple twist. A product of precision engineering, each mechanism inside the pen is designed to provide a seamless, effortless transition from one color to the next, creating an instrument of luxurious versatility."
	desc_lore = "More than just a tool for writing, ARMAT's fountain pen is a symbol of distinction and authority within the ranks of the United States Colonial Marine Corps (USCM). It is a legacy item, exclusively handed out to the top-tier command personnel, each pen a tribute to the recipient's leadership and dedication.\n \nARMAT, renowned for their weapons technology, took a different approach in crafting this piece. The fountain pen, though seemingly a departure from their usual field, is deeply ingrained with the company's engineering philosophy, embodying precision, functionality, and robustness.\n \nThe golden accents are not mere embellishments; they're an identifier, setting apart these pens and their owners from the rest. The gold is meticulously alloyed with a durable metallic substance, granting it resilience to daily wear and tear. Such resilience is symbolic of the tenacity and perseverance required of USCM command personnel.\n \nEach pen is equipped with an intricate color changing mechanism, allowing the user to switch between various ink colors. This feature, inspired by the advanced targeting systems of ARMAT's weaponry, uses miniaturized actuators and precision-ground components to smoothly transition the ink flow. A simple twist of the pen's body activates the change, rotating the internal ink cartridges into place with mechanical grace, ready for the user's command.\n \nThe ink colors are not chosen arbitrarily. Each represents a different echelon within the USCM, allowing the pen's owner to write in the hue that corresponds with their rank or the rank of the recipient of their written orders. This acts as a silent testament to the authority of their words, as if each stroke of the pen echoes through the halls of USCM authority.\n \nDespite its ornate appearance, the pen is as robust as any ARMAT weapon, reflecting the company's commitment to reliability and durability. The metal components are corrosion-resistant, ensuring the pen's longevity, even under the challenging conditions often faced by USCM high command.\n \nThe fusion of luxury and utility, the blend of gold and metal, is an embodiment of the hard-won elegance of command, of the fusion between power and grace. It's more than a writing instrument - it's an emblem of leadership, an accolade to the dedication and strength of those who bear it. ARMAT's fountain pen stands as a monument to the precision, integrity, and courage embodied by the USCM's highest-ranking officers."
	name = "fountain pen"
	icon_state = "fountain_pen"
	item_state = "fountain_pen"
	matter = list("metal" = 20, "gold" = 10)
	var/static/list/color_list = list("red", "blue", "green", "yellow", "purple", "pink", "brown", "black", "orange") // Can add more colors as required
	var/current_color_index = 1
	var/owner_name


/obj/item/tool/pen/fountain/pickup(mob/user, silent)
	. = ..()
	if(!owner_name)
		RegisterSignal(user, COMSIG_POST_SPAWN_UPDATE, PROC_REF(set_owner), override = TRUE)


/obj/item/tool/pen/fountain/proc/set_owner(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_POST_SPAWN_UPDATE)
	var/mob/living/carbon/human/user = source
	owner_name = user.name


/obj/item/tool/pen/fountain/get_examine_text(mob/user)
	. = ..()
	if(owner_name)
		. += "There's a laser engraving of [owner_name] on it."


/obj/item/tool/pen/fountain/attack_self(mob/living/carbon/human/user)
	if(on)
		current_color_index = (current_color_index % length(color_list)) + 1
		pen_color = color_list[current_color_index]
		balloon_alert(user,"you twist the pen and change the ink color to [pen_color].")
		if(clicky)
			playsound(user.loc, 'sound/items/pen_click_on.ogg', 100, 1, 5)
		update_pen_state()
	else
		..()

