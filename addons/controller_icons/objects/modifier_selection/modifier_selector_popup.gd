@tool
extends ConfirmationDialog

signal modifier_selected(path: String)

var editor_interface : EditorInterface
var icon : ControllerIconTexture

var current_modifier : ControllerIcons_ModifierButton

@onready var n_selector := $ControllerIconModifierSelector
@onready var n_flair_selection_popup := %FlairSelectionPopup
@onready var n_icon_container := %IconContainer
@onready var n_text_editor_popup := %TextEditorPopup
@onready var n_text_editor := %TextEditor

func populate():
	n_selector.populate(editor_interface)
	if !ControllerIcons.pack_supports_flairs(icon.icon_pack):
		n_flair_selection_popup.queue_free()

func _on_confirmed() -> void:
	modifier_selected.emit(n_selector.get_modifiers())


func _on_flair_selection_popup_about_to_popup() -> void:
	assert(ControllerIcons.pack_supports_flairs(icon.icon_pack))

	if !n_icon_container.is_empty():
		# Already populated; nothing to do
		return

	# Populate with flairs
	var icon_pack := ControllerIcons._load_icon_pack(icon.icon_pack)
	assert(icon_pack)
	var flair_path := icon_pack._get_root_asset_path().path_join("flairs")
	n_icon_container.button_nodes["flairs"] = {}
	n_icon_container.add_meta_icon("flairs", "<empty>")
	for file in DirAccess.get_files_at(flair_path):
		if !file.get_extension() in ["png", "jpg", "jpeg", "svg"]: continue

		var icon_path = "flairs".path_join(file.get_file().get_basename())
		n_icon_container.add_icon("flairs", icon_path, icon_pack._get_folder_name())


func _on_controller_icon_modifier_selector_flair_requested(modifier_button: ControllerIcons_ModifierButton) -> void:
	current_modifier = modifier_button
	n_flair_selection_popup.popup_centered()


func _on_controller_icon_modifier_selector_text_requested(modifier_button: ControllerIcons_ModifierButton) -> void:
	current_modifier = modifier_button
	n_text_editor.text = current_modifier.base_modifier
	n_text_editor_popup.popup_centered()


func _on_about_to_popup() -> void:
	assert(icon)

	n_selector.setup_tokens(icon)


func _on_icon_container_icon_selected(icon: ControllerIcons_IconContainer.ControllerIcons_Icon) -> void:
	if current_modifier:
		current_modifier.set_flair("" if icon.path == "<empty>" else icon.path)
	n_flair_selection_popup.visible = false


func _on_flair_selection_popup_confirmed() -> void:
	_on_icon_container_icon_selected(n_icon_container._last_pressed_icon)


func _on_text_editor_popup_confirmed() -> void:
	if current_modifier:
		current_modifier.set_icon_text(n_text_editor.text)
	n_text_editor_popup.visible = false


func _on_text_editor_text_changed(new_text: String) -> void:
	n_text_editor_popup.get_ok_button().disabled = new_text.is_empty()


func _on_text_editor_text_submitted(new_text: String) -> void:
	if not new_text.is_empty():
		_on_text_editor_popup_confirmed()


func _on_text_editor_popup_about_to_popup() -> void:
	_on_text_editor_text_changed(n_text_editor.text)
