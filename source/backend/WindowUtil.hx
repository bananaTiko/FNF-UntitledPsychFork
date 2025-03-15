package backend;

import flixel.util.FlxSignal.FlxTypedSignal;

using StringTools;

/**
 * Utilities for Windows Users
*/
#if (cpp && windows)
@:cppFileCode('
#include <iostream>
#include <windows.h>
#include <psapi.h>
')
#end
@:keep class WindowUtil
{

/**
   * Turns off that annoying "Report to Microsoft" dialog that pops up when the game crashes.
   */
public static function disableCrashHandler():Void
    {
    #if (cpp && windows)
    untyped __cpp__('SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX);');
    #else
    // Do nothing.
    #end
    }

    /**
     * Runs ShellExecute from shell32.
     */
    public static function shellExecute(?operation:String, ?file:String, ?parameters:String, ?directory:String):Void
    {
    #if (cpp && windows)
    untyped __cpp__('static HMODULE hShell32 = LoadLibraryW(L"shell32.dll");');
    untyped __cpp__('static const auto pShellExecuteW = (decltype(ShellExecuteW)*)GetProcAddress(hShell32, "ShellExecuteW");');
    untyped __cpp__('pShellExecuteW(NULL, operation.__WCStr(), file.__WCStr(), parameters.__WCStr(), directory.__WCStr(), SW_SHOWDEFAULT);');
    #else
    // Do nothing.
    #end
    }


    @:keep public static function setWindowIcon(pahty:String)
    {
    #if windows
    backend.api.WinAPI.setWindowIcon(pahty);
    #else
    trace("WINDOWS ONLY");
    #end
    }

    @:keep public static function enableVisualStyles()
    {
    #if windows
    backend.api.WinAPI.enableVisualStyles();
    #else
    trace("WINDOWS ONLY");
    #end
    }

    @:keep public static function allocConsole()
    {
    #if windows
    backend.api.WinAPI.allocConsole();
    #else
    trace("WINDOWS ONLY");
    #end
    }

    @:keep public static function clearScreen()
    {
    #if windows
    backend.api.WinAPI.clearScreen();
    #else
    trace("WINDOWS ONLY");
    #end
    }
}