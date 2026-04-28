/obj/structure/machinery/vending/walkman/New()
    . = ..()

    // Сохраняем старый список
    var/list/old_products = products.Copy()
    var/list/old_prices = prices.Copy()

    products = list()
    prices = list()

    var/list/my_products = list(
        /obj/item/device/cassette_tape/milkline = 5,
        /obj/item/device/cassette_tape/puma = 5,
        /obj/item/device/cassette_tape/duck = 5
    )
    for (var/item in my_products)
        products[item] = my_products[item]
        prices[item] = 5   // или свою цену

    for (var/item in old_products)
        if (item in products)
            continue
        products[item] = old_products[item]
        if (old_prices[item])
            prices[item] = old_prices[item]

    GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/milkline] = NO_GARB_OVERRIDE
    GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/puma] = NO_GARB_OVERRIDE
    GLOB.allowed_helmet_items[/obj/item/device/cassette_tape/duck] = NO_GARB_OVERRIDE