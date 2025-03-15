@echo off
color 0a
cd ../..
echo BUILDING GAME
haxelib run lime test windows -debug -D officialBuild -D message.reporting=pretty -D HXCPP_GC_BIG_BLOCKS -D hscriptPos -D HXCPP_CATCH_SEGV
echo.
echo done.
pause