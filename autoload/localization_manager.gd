extends Node
## Manages game localization and language settings

func _ready() -> void:
	# Print available translations
	var translations = TranslationServer.get_loaded_locales()
	print("[LocalizationManager] Available translations: ", translations)

	# 优先使用保存的语言设置
	var saved_language = SaveManager.get_setting("language", "")
	var target_locale = "en"

	if saved_language != "":
		# 用户之前手动选择了语言
		target_locale = saved_language
		print("[LocalizationManager] 使用保存的语言设置: ", target_locale)
	else:
		# 使用系统语言
		var system_locale = OS.get_locale()
		print("[LocalizationManager] System locale detected: ", system_locale)

		if system_locale.begins_with("zh"):
			target_locale = "zh_CN"
		print("[LocalizationManager] 根据系统语言设置为: ", target_locale)

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
