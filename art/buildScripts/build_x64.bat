@echo off
color 0a
cd ../..
echo BUILDING GAME
haxelib run lime build windows -release -D officialBuild -D message.reporting=pretty -D HXCPP_GC_BIG_BLOCKS -D hscriptPos -D HXCPP_CATCH_SEGV
echo.
echo done.
pause
pwd
explorer.exe export\release\windows\bin