/obj/structure/machinery/vending/walkman/New()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(add_custom_tapes)), 1 SECONDS)

/obj/structure/machinery/vending/walkman/proc/add_custom_tapes()
	// Hotline
	if(!(/obj/item/device/cassette_tape/hotline in products))
		products[/obj/item/device/cassette_tape/hotline] = 10
		prices[/obj/item/device/cassette_tape/hotline] = 5
		var/datum/data/vending_product/new_product = new()
		new_product.product_path = /obj/item/device/cassette_tape/hotline
		new_product.amount = 10
		new_product.max_amount = 10
		new_product.price = 5
		new_product.product_name = "Hotline Cassette"
		new_product.display_color = "white"
		product_records += new_product

	// Puma
	if(!(/obj/item/device/cassette_tape/puma in products))
		products[/obj/item/device/cassette_tape/puma] = 10
		prices[/obj/item/device/cassette_tape/puma] = 5
		var/datum/data/vending_product/new_product = new()
		new_product.product_path = /obj/item/device/cassette_tape/puma
		new_product.amount = 10
		new_product.max_amount = 10
		new_product.price = 5
		new_product.product_name = "Puma Cassette"
		new_product.display_color = "white"
		product_records += new_product

	// Duck
	if(!(/obj/item/device/cassette_tape/duck in products))
		products[/obj/item/device/cassette_tape/duck] = 10
		prices[/obj/item/device/cassette_tape/duck] = 5
		var/datum/data/vending_product/new_product = new()
		new_product.product_path = /obj/item/device/cassette_tape/duck
		new_product.amount = 10
		new_product.max_amount = 10
		new_product.price = 5
		new_product.product_name = "Duck Cassette"
		new_product.display_color = "white"
		product_records += new_product
