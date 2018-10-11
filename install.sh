#!/bin/bash

# installs Melodeer development environment

if [ "$EUID" -ne 0 ]
	then echo "Please run as root (sudo ./install.sh)."
	exit
fi

UNAMEOUT="$(uname -s)"

case "${UNAMEOUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

if [ ! -d "install" ]
then
	mkdir install
fi

ZIPEXT=".zip"

OPENALOUT="OpenAL"
OPENALURL="https://github.com/kcat/openal-soft/archive/master.zip"

if [ "$MACHINE" = "Mac" ]
then

	if [ ! -f "/usr/bin/brew" ] && [ ! -f "/usr/local/bin/brew" ]
	then
		echo "(!) Homebrew not installed. Please install Homebrew and try again."
		exit
	fi

	OPENALBREWCHECK="$(brew ls --versions openal-soft)"

	if [ "$OPENALBREWCHECK" = "" ]
	then
		brew install openal-soft
	else
		echo "OpenAL is already installed."
	fi

else
	OPENALLIBRES="$(ls /usr/lib | grep -i openal)"
	OPENALLOCLIBRES="$(ls /usr/local/lib | grep -i openal)"

	if [ "$OPENALLIBRES" = "" ] && [ "$OPENALLOCLIBRES" = "" ]
	then
		echo "Attempting to install OpenAL."

		if [ ! -f "/usr/bin/cmake" ] && [ ! -f "/usr/local/bin/cmake" ]
		then
			echo "(!) Please install cmake."
			exit
		fi

		if [ ! -f "/usr/bin/make" ] && [ ! -f "/usr/local/bin/make" ]
		then
			echo "(!) Please install make."
			exit
		fi	

		if [ -d "$(pwd)/install/openal-soft-master" ]
		then
			rm -rf "$(pwd)/install/openal-soft-master"
		fi

		if [ ! -f "$(pwd)/$OPENALOUT" ]
		then
			wget -O "$OPENALOUT$ZIPEXT" "$OPENALURL"
		fi
	
		unzip "$OPENALOUT$ZIPEXT" -d "$(pwd)/install/"

		(cd "$(pwd)/install/openal-soft-master/build"; cmake .. && make && make install)

	else
		echo "OpenAL is already installed."
	fi
fi

FLACOUT="FLAC"
FLACURL="https://github.com/xiph/flac/archive/master.zip"
FLACLIBRES="$(ls /usr/lib | grep -i flac)"
FLACLOCLIBRES="$(ls /usr/local/lib | grep -i flac)"

if [ "$FLACLIBRES" = "" ] && [ "$FLACLOCLIBRES" = "" ] && [ ! -d "/usr/local/include/FLAC" ]
then

	echo "Attempting to install FLAC."

	if [ ! -f "/usr/bin/autoconf" ] && [ ! -f "/usr/local/bin/autoconf" ]
	then
		echo "(!) Please install autoconf."
		exit
	fi

	if [ ! -f "/usr/bin/automake" ] && [ ! -f "/usr/local/bin/automake" ]
	then
		echo "(!) Please install automake."
		exit
	fi

	if [ ! -f "/usr/bin/libtool" ] && [ ! -f "/usr/local/bin/libtool" ]
	then
		echo "(!) Please install libtool-bin."
		exit
	fi

	if [ ! -f "/usr/bin/make" ] && [ ! -f "/usr/local/bin/make" ]
	then
		echo "(!) Please install make."
		exit
	fi

	if [ -d "$(pwd)/install/flac-master" ]
	then
		rm -rf "$(pwd)/install/flac-master"
	fi
	
	if [ ! -f "$(pwd)/$FLACOUT" ]
	then
		if [ "$MACHINE" = "Mac" ]
		then
			curl -o "$FLACOUT$ZIPEXT" "$FLACURL"
		else
			wget -O "$FLACOUT$ZIPEXT" "$FLACURL"
		fi
	fi

	unzip "$FLACOUT$ZIPEXT" -d "$(pwd)/install/"

	(cd "install/flac-master"; ./autogen.sh && ./configure && make && make install)

else
	echo "FLAC is already installed."
fi

TARGZEXT=".tar.bz"
MPG123OUT="MPG123"
MPG123URL="https://downloads.sourceforge.net/project/mpg123/mpg123/1.25.10/mpg123-1.25.10.tar.bz2"
MPG123LIBRES="$(ls /usr/lib | grep -i mpg123)"
MPG123LOCLIBRES="$(ls /usr/local/lib | grep -i mpg123)"

if [ "$MPG123LIBRES" = "" ] && [ "$MPG123LOCLIBRES" = "" ] && [ ! -f "/usr/local/include/mpg123.h" ]
then

	echo "Attempting to install mpg123."

	if [ ! -f "/usr/bin/make" ] && [ ! -f "/usr/local/bin/make" ]
	then
		echo "(!) Please install make."
		exit
	fi

	if [ -d "$(pwd)/install/mpg123-1.25.10" ]
	then
		rm -rf "$(pwd)/install/mpg123-1.25.10"
	fi

	if [ ! -f "$(pwd)/$MPG123OUT" ]
	then
		if [ "$MACHINE" = "Mac" ]
		then
			curl -o "$MPG123OUT$TARGZEXT" "$MPG123URL"
		else
			wget -O "$MPG123OUT$TARGZEXT" "$MPG123URL"
		fi
	fi

	tar xvf "$MPG123OUT$TARGZEXT" -C "$(pwd)/install/"

	(cd "install/mpg123-1.25.10"; ./configure && make && make install)
else
	echo "mpg123 is already installed."
fi

if [ -d "install" ]
then
	rm -rf "install"
fi

if [ -f "$OPENALOUT$ZIPEXT" ]
then
	rm "$OPENALOUT$ZIPEXT"
fi

if [ -f "$FLACOUT$ZIPEXT" ] 
then
	rm "$FLACOUT$ZIPEXT"
fi

if [ -f "$MPG123OUT$TARGZEXT" ]
then
	rm "$MPG123OUT$TARGZEXT"
fi

exit
