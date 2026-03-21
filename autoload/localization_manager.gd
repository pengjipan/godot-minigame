extends Node
## Manages game localization and language settings

func _ready() -> void:
	# Get system locale
	var system_locale = OS.get_locale()
	print("System locale detected: ", system_locale)

	# Set default language based on system locale
	if system_locale.begins_with("zh"):
		# Chinese language variants (zh_CN, zh_TW, zh_HK, etc.)
		TranslationServer.set_locale("zh_CN")
	else:
		# Default to English
		TranslationServer.set_locale("en")

	print("Game language set to: ", TranslationServer.get_locale())

## Change language manually
func set_language(locale: String) -> void:
	TranslationServer.set_locale(locale)
	# Save preference
	SaveManager.save_setting("language", locale)

## Get current language
func get_current_language() -> String:
	return TranslationServer.get_locale()

## Get available languages
func get_available_languages() -> Array[String]:
	return ["en", "zh_CN"]
