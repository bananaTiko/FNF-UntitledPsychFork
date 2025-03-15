#!/bin/sh
cd ../../
haxelib run lime build cpp -debug -D officialBuild -D message.reporting=pretty -D HXCPP_GC_BIG_BLOCKS -D hscriptPos -D HXCPP_CATCH_SEGV
cd ./export/release/