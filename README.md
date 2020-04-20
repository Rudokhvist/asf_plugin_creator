# ASF plugin creator
This is a simple .bat script to create empty project for ASF plugin, it's only aim is to save few minutes when creating new plugin.
It also adds to new plugin project `.gitignore` and convenient script to build plugin releases - `build.bat`

If you with to use it - follow those simple steps:
1. Download and install [git](https://git-scm.com/download/win), make sure to add it to PATH variable
2. Download and install [7zip](https://www.7-zip.org/), make sure to add it to PATH variable
3. If you plan to upload your plugin to github - setup your username and email in git with:<br>
`git config --global user.name "Your github name here"`<br>
`git config --global user.email "Email you use on github"`<br>
4. If you plan to upload your plugin to github - make a new repository with the name of your plugin, make sure not **not** include README.me, .gitignore or license
5. Clone this repo with<br>
`git clone https://github.com/Ryzhehvost/asf_plugin_creator.git`<br>
6. Invoke the script with<br>
`createplugin.bat plugin_name`<br>
If you plan to upload your plugin to github - make sure that plugin_name is the same as you used for repository in step 4.
7. Wait until process finished, look out for errors. If everything went smooth your plugin project has to be crated and uploaded to github, now you can open solution in Visual Studio and start creating your plugin.


## build.bat

`build.bat` is a script to easily prepare releases for your plugin, both classic and netf. Syntax is:

`build.bat [ASF_version_to_use]`

If started without arguments it will build plugin for latest asf version (please note, this can be a pre-release!). If `ASF_version_to_use` is specified, it will build for this version. 
Example: `build.bat 4.2.0.1`

