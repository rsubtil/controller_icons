@tool
extends Resource
class_name ControllerSettings

enum Devices {
	NONE = -1,
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

enum MouseProfiles {
	MOUSE, ## Mouse buttons use the regular mouse icons.
	TRACKPAD, ## Mouse buttons use (macOS) trackpad gesture icons.
	AUTO ## Trackpad on macOS by default, switching live based on the input received.
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

## Icon profile for mouse input. [code]Trackpad[/code] shows trackpad
## gesture icons (e.g. left button as a one finger click).
## [code]Auto[/code] starts as [code]Trackpad[/code] on macOS and
## [code]Mouse[/code] elsewhere, then switches when trackpad gestures
## or mouse-only buttons (middle, wheel, side buttons) are used.
@export var mouse_profile : MouseProfiles = MouseProfiles.MOUSE

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
