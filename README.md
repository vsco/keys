# Support Notice 11/03/2017

Be aware that the new releases of Lightroom have broken Keys functionality.

# Keys

Keys was originally distributed by Visual Supply Company in order to
give users a speed boost when editing images in Adobe Photoshop Lightroom.
In August 2015, it was discontinued as a product for purchase, and is now
open source and available for free download.

Before downloading Keys, remove any pre-existing versions of VSCO Keys.

## License

Keys is released under the GPLv2 (or any later version). See full license
in [LICENSE](LICENSE).

## Installing

Go to the Releases page, and download the `.zip` file for the [latest release](https://github.com/cajames/keys/releases/latest).
Unzip the downloaded file and double-click the installer. Follow the prompts and it will be installed.

**On Mac**
After installing, please be sure to add the `VSCOKeys.app` to have accessibility privileges.
```
System Preferences -> Security & Privacy -> Privacy -> Accessibility.
// Add VSCOKeys.app to that list
```

## Contributing

How to build Keys installers for OS X and Windows:

Instructions below are for use on a OS X machine.

Prerequisite: Download Bitrock InstallBuilder
(http://installbuilder.bitrock.com/download.html)

1. Put appropriate application files in correct folders to build installer. (This setting may be change in Tools/VSCOKeys.xml)
    - For OS X app generated from Xcode, VSCOKeys.app, place .app file in `Build/` directory
    - For Windows app generated from Visual Studio, `VSCOKeys.exe`, place `.exe` file in `Build/VSCOKeys/` directory
2. Open Terminal and run `Tools/BuildInstallerOnOSX.sh`, both OS X and Windows installer will be built
3. Installers can be found in `Build/`, zip files and they are ready to distribute

For setting on installer, such as build directory and naming of installers, changes can be made to `Tools/VSCOKeys.xml`.

## Creating your own Layout file

1. Open the [`sampleLayout.keysjson`](Layout/sampleLayout.keysjson) file in a text editor of your choice (you may edit this file directly or create a new file with the extension `.keysjson`) to create your own layout.
2. To find the correct values for input, please use the [`Layout/keymap.json`](Layout/keymap.json) and [`Layout/toolkitlistlr4.json`](Layout/toolkitlistlr4.json) for reference. Change the `key` value and the name of the adjustment in `adj` (e.g. `Saturation`). Use `keymap.json` to find the imtxcode that maps to the desired key on your keyboard. Refer to `toolkitlistlr4.json` for the adjustment names and values.

        Layout/sampleLayout.keysjson Example:
            Line 10 sets `Q` to the preset "C - Fuji 160C from Film 01"
            Line 11 sets `W` to decrease saturation by 1
            Line 12 sets `E` to increase saturation by 1
            Line 13 sets Ctrl + `W` to decrease exposure by 1
            Line 14 sets Ctrl + `E` to increase exposure by 1

3. Change the `uuid` line and the `name` line to what you prefer.
4. Save the file.
5. Launch Lightroom with VSCO Keys 2.0 enabled.
6. Double click the saved file to load the file into VSCO Keys 2.0. (make a backup of file if you want to update later)
7. Click on the VSCO Keys 2.0 Icon to change the layout.
