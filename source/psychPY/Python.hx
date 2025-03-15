package psychPY;

#if PYTHON_SCRIPTING
using StringTools;
@:include("PythonHandler.cpp")
@:buildXml('<include name="../../../../source/psychPY/PythonBuild.xml" />')
@:unreflective
@:keep
@:native("PythonHandler*")
extern class Python
{
	@:native("doFile")
	public static function doFile(str:String):Void;

	@:native("callNative")
	public static function callNative(strclbk:String):Void;
}
#end