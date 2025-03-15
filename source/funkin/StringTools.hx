package funkin;
// I don't know how to use this lmao I just know it's need lmao-bananaTiko

/**
 * A static extension which provides utility functions for Strings.
 */
class StringTools
{
  /**
   * Converts a string to title case. For example, "hello world" becomes "Hello World".
     *
   * @param value The string to convert.
   * @return The converted string.
   */
  public static function toTitleCase(value:String):String
  {
    var words:Array<String> = value.split(' ');
    var result:String = '';
    for (i in 0...words.length)
    {
      var word:String = words[i];
      result += word.charAt(0).toUpperCase() + word.substr(1).toLowerCase();
      if (i < words.length - 1)
      {
        result += ' ';
      }
    }
    return result;
  }
}