<img src="https://raw.githubusercontent.com/rsubtil/controller_icons/master/icon.png" width=15%>

# Controller Icons

Provides icons for all major controllers and keyboard/mouse actions, with an automatic icon remapping system.

> [!IMPORTANT]
> This is the Godot 4.x version. For the Godot 3.x version, check the [3.x branch](https://github.com/rsubtil/controller_icons/tree/3.x)

## Features

- Parse input actions and assign respective icons for keyboard/mouse and controller

![](screenshots/1.png)

- Automatically detects input between keyboard/mouse and controller and switches icons on-the-fly corresponding to the controller's type

![](screenshots/2.png)

- Handles generic controller paths to support many different button icons

![](screenshots/3.png)

- Ships with default assets for keyboard and mouse, and most popular controllers:
	- Xbox 360
	- Xbox One
	- Xbox Series
	- PlayStation 3
	- PlayStation 4
	- PlayStation 5
	- Nintendo Switch Controller / Joy-Con
	- Steam Controller
	- Steam Deck
	- Amazon Luna
	- Google Stadia
	- OUYA

## Installation

> [!IMPORTANT]
> This is the Godot 4.x version. For the Godot 3.x version, check the [3.x branch](https://github.com/rsubtil/controller_icons/tree/3.x)

> [!NOTE]
> If you're using C#, there are currently some engine bugs affecting the addon's usage. For a C# version of the addon, check out [Jace Varlet's fork instead](https://github.com/jembawls/controller_icons_csharp).
>
> A special thanks to Jace for porting this addon to C#. Please check out [their work](https://linktr.ee/jembawls)!

The minimum Godot version is 4.1.2 (stable).

Download this repository and copy the `addons` folder to your project root directory.

Then activate **Controller Icons** in your project plugins.

## Usage

Check the full [docs](DOCS.md), which has a [Quick-Start guide](DOCS.md#quick-start-guide) to get you up to speed.

## Credits

- Thank you [@adambelis](https://github.com/adambelis) for the redesigned logo!
- Thank you [@el-falso](https://github.com/el-falso) for the port to Godot 4!

## License

The addon is licensed under the MIT license. Full details at [LICENSE](LICENSE).

The controller assets are [Xelu's FREE Controllers & Keyboard PROMPTS](https://thoseawesomeguys.com/prompts/), made by Nicolae (XELU) Berbece and under Creative Commons 0 _(CC0)_. Some extra icons were created and contributed to this addon, also on the same CC0 license:

- [@TacticalLaptopBag](https://github.com/TacticalLaptopBag): Apostrophe, backtick, comma, equals, forward slash and period keys.
- [@DataPlusProgram](https://github.com/DataPlusProgram): Mouse wheel up and down, mouse side buttons up and down.

The icon was designed by [@adambelis](https://github.com/adambelis) ([#5](https://github.com/rsubtil/controller_icons/pull/5)) and is under Create Commons 0 _(CC0)_. It uses the [Godot's logo](https://github.com/godotengine/godot/blob/master/icon.svg) which is under Creative Commons Attribution 4.0 International License _(CC-BY-4.0 International)_