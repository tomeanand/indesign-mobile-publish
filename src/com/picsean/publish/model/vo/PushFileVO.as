package com.picsean.publish.model.vo
{
	public class PushFileVO
	{
		public var id:Number;
		public var name : String;
		public var url : String;
		public var status : Number;
		public var last_pushed : Date;
		
		public function PushFileVO(name:String, uri:String, status:Number, updated:Date)
		{
			this.name =  name;
			this.url = uri;
			this.status = status;
			this.last_pushed = updated;
		}
	}
}