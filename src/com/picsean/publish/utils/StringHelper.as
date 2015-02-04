package com.picsean.publish.utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class StringHelper
	{
		
		public static function replace(str:String, oldSubStr:String, newSubStr:String):String {
			return str.split(oldSubStr).join(newSubStr);
		}
		
		public static function trim(str:String, char:String):String {
			return trimBack(trimFront(str, char), char);
		}
		
		public static function trimFront(str:String, char:String):String {
			char = stringToCharacter(char);
			if (str.charAt(0) == char) {
				str = trimFront(str.substring(1), char);
			}
			return str;
		}
		
		public static function trimBack(str:String, char:String):String {
			char = stringToCharacter(char);
			if (str.charAt(str.length - 1) == char) {
				str = trimBack(str.substring(0, str.length - 1), char);
			}
			return str;
		}
		
		public static function stringToCharacter(str:String):String {
			if (str.length == 1) {
				return str;
			}
			return str.slice(0, 1);
		}
		public static function strToRect(strLoc:String):flash.geom.Rectangle{
			var arrTemp:Array=strLoc.split(",");
			var x:Number=(arrTemp[0].replace("{{","") as Number);
			var y:Number=(arrTemp[0].replace("}","") as Number);
			var width:Number=(arrTemp[0].replace("{","") as Number);
			var height:Number=(arrTemp[0].replace("}}","") as Number);
			return new Rectangle(x,y,x+width,y+height);
		}
		public static function strToPoint(strLoc:String):flash.geom.Point{
			var arrTemp:Array=strLoc.split(",");
			var x:Number=Number(arrTemp[0].replace("{{",""));
			var y:Number=Number(arrTemp[1].replace("}",""));
			return new Point(x,y);
		}
		
		
	}
}