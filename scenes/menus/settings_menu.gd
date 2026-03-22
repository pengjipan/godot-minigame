extends Control
## Settings menu with language selection
class_name SettingsMenu

func _ready() -> void:
	# Apply translations
	$CenterContainer/VBoxContainer/Title.text = tr("SETTINGS_TITLE")
	$CenterContainer/VBoxContainer/LanguageLabel.text = tr("SETTINGS_LANGUAGE")
	$CenterContainer/VBoxContainer/LanguageButtons/ChineseButton.text = tr("SETTINGS_CHINESE")
	$CenterContainer/VBoxContainer/LanguageButtons/EnglishButton.text = tr("SETTINGS_ENGLISH")
	$CenterContainer/VBoxContainer/BackButton.text = tr("SETTINGS_BACK")

	# Highlight current language
	_update_language_buttons()

func _update_language_buttons() -> void:
	var current_locale = TranslationServer.get_locale()
	var chinese_btn = $CenterContainer/VBoxContainer/LanguageButtons/ChineseButton
	var english_btn = $CenterContainer/VBoxContainer/LanguageButtons/EnglishButton

	if current_locale.begins_with("zh"):
		chinese_btn.modulate = Color(1, 1, 0.5)  # 高亮中文
		english_btn.modulate = Color(1, 1, 1)
	else:
		chinese_btn.modulate = Color(1, 1, 1)
		english_btn.modulate = Color(1, 1, 0.5)  # 高亮英文

func _on_chinese_pressed() -> void:
	print("[SettingsMenu] 切换到中文")
	LocalizationManager.set_language("zh_CN")
	_refresh_ui()

func _on_english_pressed() -> void:
	print("[SettingsMenu] Switch to English")
	LocalizationManager.set_language("en")
	_refresh_ui()

func _refresh_ui() -> void:
	# 重新应用所有翻译
	$CenterContainer/VBoxContainer/Title.text = tr("SETTINGS_TITLE")
	$CenterContainer/VBoxContainer/LanguageLabel.text = tr("SETTINGS_LANGUAGE")
	$CenterContainer/VBoxContainer/LanguageButtons/ChineseButton.text = tr("SETTINGS_CHINESE")
	$CenterContainer/VBoxContainer/LanguageButtons/EnglishButton.text = tr("SETTINGS_ENGLISH")
	$CenterContainer/VBoxContainer/BackButton.text = tr("SETTINGS_BACK")
	_update_language_buttons()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
