@tool
extends Resource
class_name ControllerSettings

enum Devices {
	LUNA,
	OUYA,
	PS3,
	PS4,
	PS5,
	STADIA,
	STEAM,
	SWITCH,
	JOYCON,
	XBOX360,
	XBOXONE,
	XBOXSERIES,
	STEAM_DECK
}

## General addon settings
@export_subgroup("General")

## Controller type to fallback to if automatic
## controller detection fails
@export var joypad_fallback : Devices = Devices.XBOX360

## Controller deadzone for triggering an icon remap when input
## is analogic (movement sticks or triggers)
@export_range(0.0, 1.0) var joypad_deadzone : float = 0.5

## Allow mouse movement to trigger an icon remap
@export var allow_mouse_remap : bool = true

## Minimum mouse "instantaneous" movement for
## triggering an icon remap
@export_range(0, 10000) var mouse_min_movement : int = 200

## Settings related to advanced custom assets usage and remapping
@export_subgroup("Custom assets")

## Custom asset lookup folder for custom icons
@export_dir var custom_asset_dir : String = ""

## Custom generic joystick mapper script
@export var custom_mapper : Script

## Custom icon file extension
@export var custom_file_extension : String = ""

## Custom settings related to any text rendering required on prompts
@export_subgroup("Text Rendering")

## Custom LabelSettings. If unset, uses engine default settings.
@export var custom_label_settings : LabelSettings
