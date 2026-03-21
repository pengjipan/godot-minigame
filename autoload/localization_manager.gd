extends Node
## Manages game localization and language settings

func _ready() -> void:
	# Get system locale
	var system_locale = OS.get_locale()
	print("[LocalizationManager] System locale detected: ", system_locale)

	# Print available translations
	var translations = TranslationServer.get_loaded_locales()
	print("[LocalizationManager] Available translations: ", translations)

	# Set default language based on system locale
	var target_locale = "en"
	if system_locale.begins_with("zh"):
		# Chinese language variants (zh_CN, zh_TW, zh_HK, etc.)
		target_locale = "zh_CN"

	TranslationServer.set_locale(target_locale)
	print("[LocalizationManager] Game language set to: ", TranslationServer.get_locale())

	# Test translation
	var test = tr("GAME_TITLE")
	print("[LocalizationManager] Test translation of 'GAME_TITLE': ", test)

## Change language manually
func set_language(locale: String) -> void:
	TranslationServer.set_locale(locale)
	print("[LocalizationManager] Language changed to: ", locale)
	# Save preference
	SaveManager.save_setting("language", locale)

## Get current language
func get_current_language() -> String:
	return TranslationServer.get_locale()

## Get available languages
func get_available_languages() -> Array[String]:
	return ["en", "zh_CN"]
