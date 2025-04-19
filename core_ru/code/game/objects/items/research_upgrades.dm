/obj/item/research_upgrades/credits/small
	name =	"Research Market (Credits)"
	credit_value = 4

/obj/item/research_upgrades/credits/small/Initialize(mapload, ...)
	. = ..()
	credit_value = rand(4, 5)
	desc = "Research disk containing all the bits of data the analyzer could salvage, insert this into a research computer in order to sell the data and acquire [credit_value] points."
