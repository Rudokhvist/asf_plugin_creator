#!/bin/bash
#
###############################################################################

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$HOME/bin
export PATH

################################################################################

_PROGN_=`basename $0`

_INSTDIR_=`dirname $0`
[[ $_INSTDIR_ = . ]] && _INSTDIR_=`pwd`

################################################################################

if [ $# -lt 1 -o "$1" = "-h" -o "$1" = "-?" -o "$1" = "--help" ]; then
   printf "\nUsage:   $_PROGN_ plugin_name [ssh|https]\n\n"
   exit 1
else
   plugin_name="$1"
fi

if [[ -e $plugin_name ]]; then
   printf "\nERROR:   Folder or file '$plugin_name' already exists.\n\n"
   exit 1
fi

if ( ! git version >/dev/null 2>/dev/null ); then
   printf "\nERROR:   Git binary was not found. Please install it or make sure it's in your PATH.\n\n"
   exit 1
fi

if ( ! 7z >/dev/null 2>/dev/null ); then
   printf "\nERROR:   7z binary was not found. Please install it or make sure it's in your PATH.\n\n"
   exit 1
fi

echo "##"
echo "## Creating plugin '$plugin_name'"
echo "##"

mkdir $plugin_name
cd $plugin_name

echo -e "\n## Git init"
git init

echo -e "\n## Git submodule add"
git submodule add https://github.com/JustArchiNET/ArchiSteamFarm.git

echo -e "\n## Git submodule update"
git submodule foreach "git fetch origin; git checkout $(git rev-list --tags --max-count=1);"

echo -e "\n## Git add and commit"
git add -A
git commit -m "add ASF as submodule"

echo -e "\n## Dotnet new classlib"
dotnet new classlib -f net5.0 -n $plugin_name

echo -e "\n## Dotnet add package"
dotnet add $plugin_name/$plugin_name.csproj package System.Composition.AttributedModel -v "*"

echo -e "\n## Dotnet add reference"
dotnet add $plugin_name/$plugin_name.csproj reference ArchiSteamFarm/ArchiSteamFarm/ArchiSteamFarm.csproj

echo -e "\n## Dotnet new sln"
dotnet new sln -n $plugin_name

echo -e "\n## Dotnet sln add plugin"
dotnet sln add $plugin_name

echo -e "\n## Dotnet sln add ArchiSteamFarm"
dotnet sln add ArchiSteamFarm/ArchiSteamFarm/ArchiSteamFarm.csproj --in-root

echo -e "\n## Copy some files"
cp ../build.* .
cp ../.gitignore .

## replace of 'net5.0' with 'net5.0;net48' & 'TargetFramework' with 'TargetFrameworks'.
## because linux implementation of dotnet is shit and does not works correctly - it's commented by default
## uncomment section below if you want to target NETF version of ASF anyway (it will include some hacks to workaround dotnet limitations)
#sed -i 's|net5.0|net5.0;net48|' $plugin_name/$plugin_name.csproj
#sed -i 's|TargetFramework|TargetFrameworks|g' $plugin_name/$plugin_name.csproj
#sed -i 's|#build_netf=1|build_netf=1|g' build.sh

echo -e "\n## Git add and commit"
git add -A
git commit -m "add initial commit"

if ( ! git config --global user.name >/dev/null ); then
   printf "\nERROR:   Git user was not set. Please set git user with"
   printf "\n           git config --global user.name 'Your name here'"
   printf "\n         Make sure it's the same as your Github username!\n\n"
   exit 1
else
   gituser=$(git config --global user.name)
fi

if [ "$2" = "https" ]; then
   plugin_url="https://github.com/$gituser/$plugin_name.git"
else
   plugin_url="git@github.com:$gituser/$plugin_name.git"
fi

echo $plugin_url

if ( ! git ls-remote $plugin_url ); then
   printf "\nERROR:   Github repository '$1' was not found. Did you forgot to create it?"
   printf "\n         Repository must be empty (no README.md etc)!\n\n"
   exit 1
else
  echo -e "\n## Git remote add origin"
  git remote add origin $plugin_url

  echo -e "\n## Git push"
  git push -u origin master
fi

echo ""
echo "##"
echo "## Plugin repo created"
echo "##"

echo -e "\nThings to consider next:"
echo -e "- Add AssemblyVersion and Autors to plugin project"
echo -e "- Add actual code!"
