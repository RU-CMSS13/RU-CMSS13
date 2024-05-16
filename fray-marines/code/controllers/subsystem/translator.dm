
/**
 * Если человек будет писать по-русски транслитом, то в данном случае предлагаю отрывать ему ебасос за такой перформанс
 * Никакого асинка, если что-то отвалится, то соси хуй
 */
GLOBAL_DATUM_INIT(russian_regex, /regex, regex("\[А-Яа-я\\-\]+", "i"))

SUBSYSTEM_DEF(translator)
	name   = "Translator"
	init_order = SS_INIT_TRANSLATOR
	priority   = SS_PRIORITY_TRANSLATOR
	flags = SS_NO_FIRE

	var/enabled = TRUE
	var/api_url = "http://localhost:6644/translate"
	var/api_key = ""

	var/list/cached_translations = list()

/datum/controller/subsystem/translator/stat_entry(msg)
	msg = "EN:[enabled ? "TRUE" : "FALSE"]|CT:[cached_translations.len]"
	return ..()

/datum/controller/subsystem/translator/Initialize(timeofday)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/translator/proc/translate(msg, ru_to_en = TRUE, append_source = TRUE, span_class = "unconscious", keep_html = FALSE)
	if(!enabled || (findtext(msg, GLOB.russian_regex) && !ru_to_en))
		return msg

	// не тыкаем апи по 1000000 раз в секунду
	if(LAZYISIN(msg, cached_translations))
		return cached_translations[msg]

	var/list/headers = list()
	var/list/body = list("q" = msg, "source" = (ru_to_en ? "ru" : "en"), "target" = (ru_to_en ? "en" : "ru"), "format" = keep_html ? "html" : "text", "api_key" = api_key)
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, api_url, json_encode(body), headers)
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		stack_trace(response.error)
		// если пиздец, то возвращаем сообщение
		return msg

	// дай боже апи не высрало говно
	var/translated_text = json_decode(response.body)?["translatedText"]
	LAZYADDASSOC(cached_translations, msg, translated_text)
	return "[translated_text][append_source ? " <i class='[span_class]'>([msg])</i>" : ""]"
