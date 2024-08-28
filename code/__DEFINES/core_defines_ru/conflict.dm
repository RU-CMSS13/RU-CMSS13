#define REAL_CLIENTS length(GLOB.clients) - length(GLOB.que_clients)

#define AMMO_IGNORE_XENO_IFF (1<<23)

///TTS preference is disbaled entirely, no sound will be played.
#define TTS_SOUND_OFF "Disabled"
///TTS preference is enabled, and will give full text-to-speech.
#define TTS_SOUND_ENABLED "Enabled"
///TTS preference is set to only play blips of a sound, rather than speech.
#define TTS_SOUND_BLIPS "Blips Only"
