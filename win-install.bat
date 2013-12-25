@echo off

set OLD_PATH=%PATH%

set _YY_BITS=32
set _YY_ARCH=i686

:do
set YYPREFIX=C:/win-builds-%_YY_BITS%
set PATH=%YYPREFIX%/bin;%OLD_PATH%

echo Initializing yypkg in %YYPREFIX%.
yypkg -init
yypkg -config -setpreds host=%_YY_ARCH%-w64-mingw32
yypkg -config -setpreds target=%_YY_ARCH%-w64-mingw32
sherpa -set-mirror http://win-builds.org/@@VERSION@@/packages/windows_%_YY_BITS%
echo Downloading and installing packages.
sherpa -install all

echo Updating GDK, GTK, Pango and font caches (this may take a while).
gdk-pixbuf-query-loaders --update-cache
gtk-query-immodules-2.0 --update-cache
pango-querymodules --update-cache
fc-cache

copy *.exe "%YYPREFIX%/bin"
copy *.dll "%YYPREFIX%/bin"

if "%_YY_BITS%"=="64" goto done

set _YY_BITS=64
set _YY_ARCH=x86_64
goto do

:done

echo Win-builds has been installed.
echo System settings like PATH haven't been changed; you should now do so.

pause
