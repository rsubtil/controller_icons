# Controller Icons - Documentation

## Contents

- [Quick-start guide](#quick-start-guide)
	- [Input action](#input-action)
	- [Generic joypad path](#generic-joypad-path)
	- [Specific path](#specific-path)
- [Reacting to input change](#reacting-to-input-change)
- [Settings](#settings)
- [Adding/removing controller iconss](#addingremoving-controller-icons)
- [Changing controller mapper](#changing-controller-mapper)
- [TTS support](#tts-support)
- [Porting addon versions](#porting-addon-versions)
	- [v2.x.x to v3.0.0](#v2xx-to-v300)
	- [v1.x.x to v2.0.0](#v1xx-to-v200)
- [Generic path lookup](#generic-path-lookup)


# Quick-start guide

Controller Icons provides a new Texture2D resource, `ControllerIconTexture`, which displays the correct icon for the current input device. This can be used in any node that accepts a Texture2D, such as `TextureRect`, `Button`, `Sprite2D/3D`, `RichTextLabel`, etc...

> [!TIP]
> The `demo` folder contains some scenes showcasing and explaining how to use the addon as well.

> [!WARNING]
> The existing objects before version 3.0.0 (`ControllerButton`, `ControllerTextureRect`, `ControllerSprite2D`, `ControllerSprite3D`) should no longer be used as they are deprecated, and will be removed in a future version. For help in porting your project, refer to [Porting addon versions](#porting-addon-versions).

![](screenshots/docs/controller_icon_texture_new.png)

The following properties are available:
- `Path`: Specify the controller lookup path
- `Show Mode`: Set the input type this icon will appear on. When set to `Keyboard/Mouse` or `Controller`, the object will hide when the opposite input method is used.
- `Force Type`: When set to other than `None`, forces the displayed icon to be either `Keyboard/Mouse` or `Controller`. Only relevant for input actions, other types of lookup paths are not affected by this.
- `Custom Label Settings`: When text rendering is needed for multi-icon prompts, the texture uses the addon's settings by default. If you want to override for this particular icon, you can specify it here.

![](screenshots/docs/path.png)

The `Path` is the most relevant property, as it specifies what icons to show. It can be one of three major categories, detailed below. You can use the builtin tool for picking paths, or write it manually as well.

![](screenshots/docs/path_selector_tool.png)

> [!NOTE]
> If you add/remove/change input actions on the editor, you will need to reload the addon so it can update the input map and show the appropriate mappings in the editor view again. This is not needed in the launched project though.
>
> However, if you change input actions at runtime, you must call `refresh` on the `ControllerIcons` singleton to update all existing icons with the new actions:
>
> ```gdscript
> ControllerIcons.refresh()
> ```

## Input action

You can specify the exact name of an existing input action in your project. This is the recommended approach, as you can easily change the controls and have the icons remap automatically between keyboard/mouse and controller.

![](screenshots/docs/input_action_ui.png)

![](screenshots/docs/input_action.gif)

## Generic joypad path

If you want to only use controller icons, you can use a generic mapping, which automatically changes to the correct icons depending on the connected controller type.

![](screenshots/docs/joypad_path_ui.png)

![](screenshots/docs/joypad_path.gif)

> [!NOTE]
> The list of generic paths available, as well as to which icons they map per controller, can be checked at [Generic path lookup](#generic-path-lookup).

## Specific path

You can also directly use the icons by specifying their path. This lets you use more custom icons which can't be accessed from generic scenarios:

![](screenshots/docs/specific_path_ui.png)

![](screenshots/docs/specific_path.png)

To know which paths exist, check the `assets` folder from this addon. The path to use is the path to an image file, minus the base path and extension. So for example, to use `res://addons/controller_icons/assets/switch/controllers_separate.png`, the path is `switch/controllers_separate`

# Reacting to input change

The `ControllerIcons` singleton has an `input_type_changed` signal available so you can detect when the type of input device changes:

```gdscript
func my_func():
	...
	ControllerIcons.input_type_changed.connect(_on_input_type_changed)

func _on_input_type_changed(input_type):
	match input_type:
		ControllerIcons.InputType.KEYBOARD_MOUSE:
			# Input changed to keyboard/mouse
			...
		ControllerIcons.InputType.CONTROLLER:
			# Input changed to a controller
			...

```
# Settings

There is a settings resource file at `res://addons/controller_icons/settings.tres` which you can open and modify to tweak the addon's behavior:

![](screenshots/docs/settings.png)

- **General**
	- `Joypad Fallback`: To what default controller type fallback to if automatic controller type detection fails.
	- `Joypad Deadzone`: Controller's deadzone for analogue inputs when detecting input device changes.
	- `Allow Mouse Remap`: If set, consider mouse movement when detecting input device changes.
	- `Mouse Min Movement`: Minimum "instantaneous" mouse speed in pixels to be considered for an input device change
- **Custom Assets**
	- `Custom Asset Dir`: Directory with custom controller icons to use. Refer to [Adding/removing controller icons](#addingremoving-controller-icons) for more instructions on how to do this.
	- `Custom Mapper`: Custom generic path mapper script to use. Refer to [Changing controller mapper](#changing-controller-mapper) for more instructions on how to do this.
	- `Custom Icon Extension`: Custom icon file extension to use. If empty, the addon defaults to `png`. Must be the extension portion only, without the preceding dot.
- **Text Rendering**
	- `Custom Label Settings`: Custom `LabelSettings` to use for text rendering on multi-icon prompts. Will be used by all icons by default, but can also be overridden on a per-icon basis.

# Adding/removing controller icons

To remove controller icons you don't want to use, delete those files/folders from `res://addons/controller_icons/assets`. You might need to create a custom mapper in order to prevent the addon from trying to use deleted icons. For more information, refer to [Changing controller mapper](#changing-controller-mapper).

To add or change controller icons, while you can do it directly in the `assets` folder, you can intead set a custom folder for different assets. When set, the addon will look for icons in that folder first, and if not found, fallback to the default assets folder. Do to this, set the `Custom Asset Dir` field from [Settings](#settings) to your custom icons folder. It needs to have a similar structure to the addon's assets folder.

# Changing controller mapper

The default mapper script maps generic joypad paths to a lot of popular controllers available. However, you may need to override how this mapping process works.

You can do so by creating a script which extends `ControllerMapper`:

```gdscript
extends ControllerMapper

func _convert_joypad_path(path: String, fallback: int) -> String:
	var controller_name = Input.get_joy_name(0)
	# Support for the new hot Playstation 42 controller
	if "PlayStation 42 Controller" in controller_name:
		return path.replace("joypad/", "playstation42/")
	# else return default mapping
	return super._convert_joypad_path(path, fallback)
```

The only function that's mandatory is `_convert_joypad_path`. This supplies a [generic joypad `path`](#generic-joypad-path), which you then need to convert to a [specific path](#specific-path) for the desired controller assets. Check out the the default implementation at `res://addons/controller_icons/Mapper.gd` to see how the default mapping is done.

`fallback` is the fallback device type if automatic detection fails. There's not much need to use this if you're writing a custom mapper, but it is needed for the default mapping process.

If you do not wish to fully replace the original mapper, you can still fallback to the default mapper by calling the parent's method (`return super._convert_joypad_path(path, fallback)`)

# TTS support

Text-to-speech (TTS) is supported by the addon. To fetch a TTS representation of a given icon, you can call the texture's `get_tts_string()` method:

```gdscript
var tts_text = texture.get_tts_string()
```

This TTS text takes into consideration the currently displayed icon, and will thus be different if the icon is from keyboard/mouse or controller. It also takes into consideration the controller type, and will thus use native button names (e.g. `A` for Xbox, `Cross` for PlayStation, etc).

You can also request to convert an icon path directly throuh the `ControllerIcons` singleton:

```gdscript
func _ready():
	# Input Action - Will switch based on active keyboard/mouse or controller
	var tts_text = ControllerIcons.parse_path_to_tts("attack")

	# Generic Joypad Path - Will switch based on active controller
	var tts_text = ControllerIcons.parse_path_to_tts("joypad/a")

	# Specific Path
	var tts_text = ControllerIcons.parse_path_to_tts("xbox360/a")
	var ttx_text = ControllerIcons.parse_path_to_tts("key/z")
```

# Porting addon versions

This section details porting instructions between breaking changes of the addon. If you're updating multiple versions, you should start at your current version, and work your way up to the latest version.

## v2.x.x to v3.0.0

Version 3.0.0 represents a very large breaking change due to an internal refactor of the addon. The most impactful change is that the existing objects before version 3.0.0 (`ControllerButton`, `ControllerTextureRect`, `ControllerSprite2D`, `ControllerSprite3D`) should no longer be used as they are deprecated, and will be removed in a future version.

![](screenshots/docs/deprecated_nodes.png)
![](screenshots/docs/deprecated_nodes_warning.png)

To update these objects, remove their script, and assign a new `ControllerIconTexture` to it. The given warning also gives more specific instructions on what do to for each particular object.

Beyond that, the remaining properties and behavior remain largely the same. However, there are still some minor changes of note:

- The `show_only` property was renamed to `show_mode`. If you access this property directly in your code, you'll need to update it.
- The `show_mode` and `force_type` properties now use enums (`ShowMode` and `ForceType` respectively), instead of `int` values. If you access these properties directly in your code, you'll need to update them.
- The `max_width` property, only available in `ControllerTextureRect`, was removed. Use the related properties like `expand_mode` and `custom_minimum_size` instead.

## v1.x.x to v2.0.0

- The `ControllerSetting.Devices` enum had some dangling values removed, which changed the order of a few existing keys. If you rely on these values, you'll need to update your code:
	- The `VITA`, `WII` and `WIIU` values were removed. These were not used anywhere in the addon, so you shouldn't be affected by this.
	- The preceding enum keys had their values changed by this: `XBOX360`, `XBOXONE`, `XBOXSERIES` and `STEAM_DECK` enum values have changed. If you use these values directly in your code, you'll need to update them.
	- The default settings file (`settings.tres`) will need to be updated, as the `Joypad Fallback` setting depends on this.
- Some Nintendo Switch asset filenames were renamed. If you use these assets directly in your project, you'll may need to re-add them:
	- `switch/lb.png` -> `switch/l.png`
	- `switch/rb.png` -> `switch/r.png`
	- `switch/lt.png` -> `switch/zl.png`
	- `switch/rt.png` -> `switch/zr.png`

# Generic path lookup

Below is a table of the existing generic joypad paths, as well as to what icons they map for each controller type shipped.

If you want to populate the missing entries, feel free to open a PR!

### Buttons

| Generic path         | Godot joypad index | Xbox 360                                                      | Xbox One                                                      | Xbox Series                                                      | PlayStation 3                                             | PlayStation 4                                             | PlayStation 5                                             | Nintendo Switch Controller                                | Nintendo Switch Joy-Con                               | Steam Controller                                                 | Steam Deck                                                      | Amazon Luna                                                | Google Stadia                                             | OUYA                                                    |
|----------------------|--------------------|---------------------------------------------------------------|---------------------------------------------------------------|------------------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-------------------------------------------------------|------------------------------------------------------------------|-----------------------------------------------------------------|------------------------------------------------------------|-----------------------------------------------------------|---------------------------------------------------------|
| joypad/a             | 0                  | ![](addons/controller_icons/assets/xbox360/a.png)             | ![](addons/controller_icons/assets/xboxone/a.png)             | ![](addons/controller_icons/assets/xboxseries/a.png)             | ![](addons/controller_icons/assets/ps3/cross.png)         | ![](addons/controller_icons/assets/ps4/cross.png)         | ![](addons/controller_icons/assets/ps5/cross.png)         | ![](addons/controller_icons/assets/switch/b.png)          | ![](addons/controller_icons/assets/switch/b.png)      | ![](addons/controller_icons/assets/steam/a.png)                  | ![](addons/controller_icons/assets/steamdeck/a.png)             | ![](addons/controller_icons/assets/luna/a.png)             | ![](addons/controller_icons/assets/stadia/a.png)          | ![](addons/controller_icons/assets/ouya/o.png)          |
| joypad/b             | 1                  | ![](addons/controller_icons/assets/xbox360/b.png)             | ![](addons/controller_icons/assets/xboxone/b.png)             | ![](addons/controller_icons/assets/xboxseries/b.png)             | ![](addons/controller_icons/assets/ps3/circle.png)        | ![](addons/controller_icons/assets/ps4/circle.png)        | ![](addons/controller_icons/assets/ps5/circle.png)        | ![](addons/controller_icons/assets/switch/a.png)          | ![](addons/controller_icons/assets/switch/a.png)      | ![](addons/controller_icons/assets/steam/b.png)                  | ![](addons/controller_icons/assets/steamdeck/b.png)             | ![](addons/controller_icons/assets/luna/b.png)             | ![](addons/controller_icons/assets/stadia/b.png)          | ![](addons/controller_icons/assets/ouya/a.png)          |
| joypad/x             | 2                  | ![](addons/controller_icons/assets/xbox360/x.png)             | ![](addons/controller_icons/assets/xboxone/x.png)             | ![](addons/controller_icons/assets/xboxseries/x.png)             | ![](addons/controller_icons/assets/ps3/square.png)        | ![](addons/controller_icons/assets/ps4/square.png)        | ![](addons/controller_icons/assets/ps5/square.png)        | ![](addons/controller_icons/assets/switch/y.png)          | ![](addons/controller_icons/assets/switch/y.png)      | ![](addons/controller_icons/assets/steam/x.png)                  | ![](addons/controller_icons/assets/steamdeck/x.png)             | ![](addons/controller_icons/assets/luna/x.png)             | ![](addons/controller_icons/assets/stadia/x.png)          | ![](addons/controller_icons/assets/ouya/u.png)          |
| joypad/y             | 3                  | ![](addons/controller_icons/assets/xbox360/y.png)             | ![](addons/controller_icons/assets/xboxone/y.png)             | ![](addons/controller_icons/assets/xboxseries/y.png)             | ![](addons/controller_icons/assets/ps3/triangle.png)      | ![](addons/controller_icons/assets/ps4/triangle.png)      | ![](addons/controller_icons/assets/ps5/triangle.png)      | ![](addons/controller_icons/assets/switch/x.png)          | ![](addons/controller_icons/assets/switch/x.png)      | ![](addons/controller_icons/assets/steam/y.png)                  | ![](addons/controller_icons/assets/steamdeck/y.png)             | ![](addons/controller_icons/assets/luna/y.png)             | ![](addons/controller_icons/assets/stadia/y.png)          | ![](addons/controller_icons/assets/ouya/y.png)          |
| joypad/lb            | 4                  | ![](addons/controller_icons/assets/xbox360/lb.png)            | ![](addons/controller_icons/assets/xboxone/lb.png)            | ![](addons/controller_icons/assets/xboxseries/lb.png)            | ![](addons/controller_icons/assets/ps3/l1.png)            | ![](addons/controller_icons/assets/ps4/l1.png)            | ![](addons/controller_icons/assets/ps5/l1.png)            | ![](addons/controller_icons/assets/switch/l.png)          | ![](addons/controller_icons/assets/switch/l.png)      | ![](addons/controller_icons/assets/steam/lb.png)                 | ![](addons/controller_icons/assets/steamdeck/l1.png)            | ![](addons/controller_icons/assets/luna/lb.png)            | ![](addons/controller_icons/assets/stadia/l1.png)         | ![](addons/controller_icons/assets/ouya/l1.png)         |
| joypad/rb            | 5                  | ![](addons/controller_icons/assets/xbox360/rb.png)            | ![](addons/controller_icons/assets/xboxone/rb.png)            | ![](addons/controller_icons/assets/xboxseries/rb.png)            | ![](addons/controller_icons/assets/ps3/r1.png)            | ![](addons/controller_icons/assets/ps4/r1.png)            | ![](addons/controller_icons/assets/ps5/r1.png)            | ![](addons/controller_icons/assets/switch/r.png)          | ![](addons/controller_icons/assets/switch/r.png)      | ![](addons/controller_icons/assets/steam/rb.png)                 | ![](addons/controller_icons/assets/steamdeck/r1.png)            | ![](addons/controller_icons/assets/luna/rb.png)            | ![](addons/controller_icons/assets/stadia/r1.png)         | ![](addons/controller_icons/assets/ouya/r1.png)         |
| joypad/lt            | 6                  | ![](addons/controller_icons/assets/xbox360/lt.png)            | ![](addons/controller_icons/assets/xboxone/lt.png)            | ![](addons/controller_icons/assets/xboxseries/lt.png)            | ![](addons/controller_icons/assets/ps3/l2.png)            | ![](addons/controller_icons/assets/ps4/l2.png)            | ![](addons/controller_icons/assets/ps5/l2.png)            | ![](addons/controller_icons/assets/switch/zl.png)         | ![](addons/controller_icons/assets/switch/zl.png)     | ![](addons/controller_icons/assets/steam/lt.png)                 | ![](addons/controller_icons/assets/steamdeck/l2.png)            | ![](addons/controller_icons/assets/luna/lt.png)            | ![](addons/controller_icons/assets/stadia/l2.png)         | ![](addons/controller_icons/assets/ouya/l2.png)         |
| joypad/rt            | 7                  | ![](addons/controller_icons/assets/xbox360/rt.png)            | ![](addons/controller_icons/assets/xboxone/rt.png)            | ![](addons/controller_icons/assets/xboxseries/rt.png)            | ![](addons/controller_icons/assets/ps3/r2.png)            | ![](addons/controller_icons/assets/ps4/r2.png)            | ![](addons/controller_icons/assets/ps5/r2.png)            | ![](addons/controller_icons/assets/switch/zr.png)         | ![](addons/controller_icons/assets/switch/zr.png)     | ![](addons/controller_icons/assets/steam/rt.png)                 | ![](addons/controller_icons/assets/steamdeck/r2.png)            | ![](addons/controller_icons/assets/luna/rt.png)            | ![](addons/controller_icons/assets/stadia/r2.png)         | ![](addons/controller_icons/assets/ouya/r2.png)         |
| joypad/l_stick_click | 8                  | ![](addons/controller_icons/assets/xbox360/l_stick_click.png) | ![](addons/controller_icons/assets/xboxone/l_stick_click.png) | ![](addons/controller_icons/assets/xboxseries/l_stick_click.png) | ![](addons/controller_icons/assets/ps3/l_stick_click.png) | ![](addons/controller_icons/assets/ps4/l_stick_click.png) | ![](addons/controller_icons/assets/ps5/l_stick_click.png) | N/A                                                       | N/A                                                   | N/A                                                              | ![](addons/controller_icons/assets/steamdeck/l_stick_click.png) | ![](addons/controller_icons/assets/luna/l_stick_click.png) | N/A                                                       | N/A                                                     |
| joypad/r_stick_click | 9                  | ![](addons/controller_icons/assets/xbox360/r_stick_click.png) | ![](addons/controller_icons/assets/xboxone/r_stick_click.png) | ![](addons/controller_icons/assets/xboxseries/r_stick_click.png) | ![](addons/controller_icons/assets/ps3/r_stick_click.png) | ![](addons/controller_icons/assets/ps4/r_stick_click.png) | ![](addons/controller_icons/assets/ps5/r_stick_click.png) | N/A                                                       | N/A                                                   | ![](addons/controller_icons/assets/steam/right_track_center.png) | ![](addons/controller_icons/assets/steamdeck/r_stick_click.png) | ![](addons/controller_icons/assets/luna/r_stick_click.png) | N/A                                                       | N/A                                                     |
| joypad/select        | 10                 | ![](addons/controller_icons/assets/xbox360/back.png)          | ![](addons/controller_icons/assets/xboxone/view.png)          | ![](addons/controller_icons/assets/xboxseries/view.png)          | ![](addons/controller_icons/assets/ps3/select.png)        | ![](addons/controller_icons/assets/ps4/share.png)         | ![](addons/controller_icons/assets/ps5/share.png)         | ![](addons/controller_icons/assets/switch/minus.png)      | ![](addons/controller_icons/assets/switch/minus.png)  | ![](addons/controller_icons/assets/steam/back.png)               | ![](addons/controller_icons/assets/steamdeck/square.png)        | ![](addons/controller_icons/assets/luna/circle.png)        | ![](addons/controller_icons/assets/stadia/dots.png)       | N/A                                                     |
| joypad/start         | 11                 | ![](addons/controller_icons/assets/xbox360/start.png)         | ![](addons/controller_icons/assets/xboxone/menu.png)          | ![](addons/controller_icons/assets/xboxseries/menu.png)          | ![](addons/controller_icons/assets/ps3/start.png)         | ![](addons/controller_icons/assets/ps4/options.png)       | ![](addons/controller_icons/assets/ps5/options.png)       | ![](addons/controller_icons/assets/switch/plus.png)       | ![](addons/controller_icons/assets/switch/plus.png)   | ![](addons/controller_icons/assets/steam/start.png)              | ![](addons/controller_icons/assets/steamdeck/menu.png)          | ![](addons/controller_icons/assets/luna/menu.png)          | ![](addons/controller_icons/assets/stadia/menu.png)       | ![](addons/controller_icons/assets/ouya/menu.png)       |
| joypad/dpad          | N/A                | ![](addons/controller_icons/assets/xbox360/dpad.png)          | ![](addons/controller_icons/assets/xboxone/dpad.png)          | ![](addons/controller_icons/assets/xboxseries/dpad.png)          | ![](addons/controller_icons/assets/ps3/dpad.png)          | ![](addons/controller_icons/assets/ps4/dpad.png)          | ![](addons/controller_icons/assets/ps5/dpad.png)          | ![](addons/controller_icons/assets/switch/dpad.png)       | ![](addons/controller_icons/assets/switch/dpad.png)   | ![](addons/controller_icons/assets/steam/left_track.png)         | ![](addons/controller_icons/assets/steamdeck/dpad.png)          | ![](addons/controller_icons/assets/luna/dpad.png)          | ![](addons/controller_icons/assets/stadia/dpad.png)       | ![](addons/controller_icons/assets/ouya/dpad.png)       |
| joypad/dpad_up       | 12                 | ![](addons/controller_icons/assets/xbox360/dpad_up.png)       | ![](addons/controller_icons/assets/xboxone/dpad_up.png)       | ![](addons/controller_icons/assets/xboxseries/dpad_up.png)       | ![](addons/controller_icons/assets/ps3/dpad_up.png)       | ![](addons/controller_icons/assets/ps4/dpad_up.png)       | ![](addons/controller_icons/assets/ps5/dpad_up.png)       | ![](addons/controller_icons/assets/switch/dpad_up.png)    | ![](addons/controller_icons/assets/switch/up.png)     | ![](addons/controller_icons/assets/steam/left_track_up.png)      | ![](addons/controller_icons/assets/steamdeck/dpad_up.png)       | ![](addons/controller_icons/assets/luna/dpad_up.png)       | ![](addons/controller_icons/assets/stadia/dpad_up.png)    | ![](addons/controller_icons/assets/ouya/dpad_up.png)    |
| joypad/dpad_down     | 13                 | ![](addons/controller_icons/assets/xbox360/dpad_down.png)     | ![](addons/controller_icons/assets/xboxone/dpad_down.png)     | ![](addons/controller_icons/assets/xboxseries/dpad_down.png)     | ![](addons/controller_icons/assets/ps3/dpad_down.png)     | ![](addons/controller_icons/assets/ps4/dpad_down.png)     | ![](addons/controller_icons/assets/ps5/dpad_down.png)     | ![](addons/controller_icons/assets/switch/dpad_down.png)  | ![](addons/controller_icons/assets/switch/down.png)   | ![](addons/controller_icons/assets/steam/left_track_down.png)    | ![](addons/controller_icons/assets/steamdeck/dpad_down.png)     | ![](addons/controller_icons/assets/luna/dpad_down.png)     | ![](addons/controller_icons/assets/stadia/dpad_down.png)  | ![](addons/controller_icons/assets/ouya/dpad_down.png)  |
| joypad/dpad_left     | 14                 | ![](addons/controller_icons/assets/xbox360/dpad_left.png)     | ![](addons/controller_icons/assets/xboxone/dpad_left.png)     | ![](addons/controller_icons/assets/xboxseries/dpad_left.png)     | ![](addons/controller_icons/assets/ps3/dpad_left.png)     | ![](addons/controller_icons/assets/ps4/dpad_left.png)     | ![](addons/controller_icons/assets/ps5/dpad_left.png)     | ![](addons/controller_icons/assets/switch/dpad_left.png)  | ![](addons/controller_icons/assets/switch/left.png)   | ![](addons/controller_icons/assets/steam/left_track_left.png)    | ![](addons/controller_icons/assets/steamdeck/dpad_left.png)     | ![](addons/controller_icons/assets/luna/dpad_left.png)     | ![](addons/controller_icons/assets/stadia/dpad_left.png)  | ![](addons/controller_icons/assets/ouya/dpad_left.png)  |
| joypad/dpad_right    | 15                 | ![](addons/controller_icons/assets/xbox360/dpad_right.png)    | ![](addons/controller_icons/assets/xboxone/dpad_right.png)    | ![](addons/controller_icons/assets/xboxseries/dpad_right.png)    | ![](addons/controller_icons/assets/ps3/dpad_right.png)    | ![](addons/controller_icons/assets/ps4/dpad_right.png)    | ![](addons/controller_icons/assets/ps5/dpad_right.png)    | ![](addons/controller_icons/assets/switch/dpad_right.png) | ![](addons/controller_icons/assets/switch/right.png)  | ![](addons/controller_icons/assets/steam/left_track_right.png)   | ![](addons/controller_icons/assets/steamdeck/dpad_right.png)    | ![](addons/controller_icons/assets/luna/dpad_right.png)    | ![](addons/controller_icons/assets/stadia/dpad_right.png) | ![](addons/controller_icons/assets/ouya/dpad_right.png) |
| joypad/home          | 16                 | N/A                                                           | N/A                                                           | N/A                                                              | N/A                                                       | N/A                                                       | N/A                                                       | ![](addons/controller_icons/assets/switch/home.png)       | ![](addons/controller_icons/assets/switch/home.png)   | ![](addons/controller_icons/assets/steam/system.png)             | ![](addons/controller_icons/assets/steamdeck/steam.png)         | N/A                                                        | ![](addons/controller_icons/assets/stadia/assistant.png)  | N/A                                                     |
| joypad/share         | 17                 | N/A                                                           | N/A                                                           | ![](addons/controller_icons/assets/xboxseries/share.png)         | N/A                                                       | N/A                                                       | ![](addons/controller_icons/assets/ps5/microphone.png)    | ![](addons/controller_icons/assets/switch/square.png)     | ![](addons/controller_icons/assets/switch/square.png) | N/A                                                              | ![](addons/controller_icons/assets/steamdeck/dots.png)          | ![](addons/controller_icons/assets/luna/microphone.png)    | ![](addons/controller_icons/assets/stadia/select.png)     | N/A                                                     |

### Axis

| Generic path   | Godot joypad axis | Xbox 360                                                | Xbox One                                                | Xbox Series                                                | PlayStation 3                                       | PlayStation 4                                       | PlayStation 5                                       | Nintendo Switch Controller                             | Nintendo Switch Joy-Con                                | Steam Controller                                          | Steam Deck                                                | Amazon Luna                                          | Google Stadia                                          | Ouya                                                 |
|----------------|-------------------|---------------------------------------------------------|---------------------------------------------------------|------------------------------------------------------------|-----------------------------------------------------|-----------------------------------------------------|-----------------------------------------------------|--------------------------------------------------------|--------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|------------------------------------------------------|--------------------------------------------------------|------------------------------------------------------|
| joypad/l_stick | 0, 1              | ![](addons/controller_icons/assets/xbox360/l_stick.png) | ![](addons/controller_icons/assets/xboxone/l_stick.png) | ![](addons/controller_icons/assets/xboxseries/l_stick.png) | ![](addons/controller_icons/assets/ps3/l_stick.png) | ![](addons/controller_icons/assets/ps4/l_stick.png) | ![](addons/controller_icons/assets/ps5/l_stick.png) | ![](addons/controller_icons/assets/switch/l_stick.png) | ![](addons/controller_icons/assets/switch/l_stick.png) | ![](addons/controller_icons/assets/steam/stick.png)       | ![](addons/controller_icons/assets/steamdeck/l_stick.png) | ![](addons/controller_icons/assets/luna/l_stick.png) | ![](addons/controller_icons/assets/stadia/l_stick.png) | ![](addons/controller_icons/assets/ouya/l_stick.png) |
| joypad/r_stick | 2, 3              | ![](addons/controller_icons/assets/xbox360/r_stick.png) | ![](addons/controller_icons/assets/xboxone/r_stick.png) | ![](addons/controller_icons/assets/xboxseries/r_stick.png) | ![](addons/controller_icons/assets/ps3/r_stick.png) | ![](addons/controller_icons/assets/ps4/r_stick.png) | ![](addons/controller_icons/assets/ps5/r_stick.png) | ![](addons/controller_icons/assets/switch/r_stick.png) | ![](addons/controller_icons/assets/switch/r_stick.png) | ![](addons/controller_icons/assets/steam/right_track.png) | ![](addons/controller_icons/assets/steamdeck/r_stick.png) | ![](addons/controller_icons/assets/luna/r_stick.png) | ![](addons/controller_icons/assets/stadia/r_stick.png) | ![](addons/controller_icons/assets/ouya/r_stick.png) |
| joypad/lt      | 6                 | ![](addons/controller_icons/assets/xbox360/lt.png)      | ![](addons/controller_icons/assets/xboxone/lt.png)      | ![](addons/controller_icons/assets/xboxseries/lt.png)      | ![](addons/controller_icons/assets/ps3/l2.png)      | ![](addons/controller_icons/assets/ps4/l2.png)      | ![](addons/controller_icons/assets/ps5/l2.png)      | ![](addons/controller_icons/assets/switch/zl.png)      | ![](addons/controller_icons/assets/switch/zl.png)      | ![](addons/controller_icons/assets/steam/lt.png)          | ![](addons/controller_icons/assets/steamdeck/l2.png)      | ![](addons/controller_icons/assets/luna/lt.png)      | ![](addons/controller_icons/assets/stadia/l2.png)      | ![](addons/controller_icons/assets/ouya/l2.png)      |
| joypad/rt      | 7                 | ![](addons/controller_icons/assets/xbox360/rt.png)      | ![](addons/controller_icons/assets/xboxone/rt.png)      | ![](addons/controller_icons/assets/xboxseries/rt.png)      | ![](addons/controller_icons/assets/ps3/r2.png)      | ![](addons/controller_icons/assets/ps4/r2.png)      | ![](addons/controller_icons/assets/ps5/r2.png)      | ![](addons/controller_icons/assets/switch/zl.png)      | ![](addons/controller_icons/assets/switch/zr.png)      | ![](addons/controller_icons/assets/steam/rt.png)          | ![](addons/controller_icons/assets/steamdeck/r2.png)      | ![](addons/controller_icons/assets/luna/rt.png)      | ![](addons/controller_icons/assets/stadia/r2.png)      | ![](addons/controller_icons/assets/ouya/r2.png)      |
