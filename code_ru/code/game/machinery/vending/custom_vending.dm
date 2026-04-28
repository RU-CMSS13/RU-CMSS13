/obj/structure/machinery/vending/walkman/Initialize()
    . = ..()

    var/static/list/new_products = list(
        /obj/item/device/cassette_tape/milkline = 5,
        /obj/item/device/cassette_tape/puma = 5,
        /obj/item/device/cassette_tape/duck = 5
    )
    for (var/item in new_products)
        var/amount = new_products[item]

        if (products && products[item])
            products[item] += amount
        else
            products[item] = amount

    var/static/list/new_prices = list(
        /obj/item/device/cassette_tape/milkline = 5,
        /obj/item/device/cassette_tape/puma = 5,
        /obj/item/device/cassette_tape/duck = 5
    )
    for (var/item in new_prices)
        var/price = new_prices[item]

        if (!prices || !prices[item])
            prices[item] = price

    if(!GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/milkline])
        GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/milkline] = NO_GARB_OVERRIDE
    if(!GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/puma])
        GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/puma] = NO_GARB_OVERRIDE
    if(!GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/duck])
        GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/duck] = NO_GARB_OVERRIDE
