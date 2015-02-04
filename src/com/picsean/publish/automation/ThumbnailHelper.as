package com.picsean.publish.automation
{
	import com.picsean.publish.model.PublishModel;
	import com.picsean.publish.utils.Configuration;
	
	import flash.filesystem.File;
	
	import org.osmf.logging.Log;

	public class ThumbnailHelper
	{
		private var _model : PublishModel = PublishModel.getInstance();
		
		private var thumblist : Array;
		
		public function ThumbnailHelper()
		{
			
		}
		
		public function initialise(path:String, list:Array):void	{
			thumblist = new Array();
			var seprator : String = File.separator;
			var pathName : String;
			var s_large:File,s_small:File;
			var t_large:File,t_small:File;
			var device:Object;
			var deviceFolder : String = "";
			for(var i:Number = 0; i<list.length; i++)	{
				
				device = _model.allDeviceInfo.itemFor(list[i]);
				deviceFolder = (device.label == Configuration.DEVICE_IPAD_RETINA ? Configuration.IPAD_RETINA_LITERAL_PUBLISH : device.folder);
				
				pathName = path + deviceFolder + seprator+ "p"+ seprator + "a00"+ seprator;
				s_large = new File(pathName + "p01.jpg");
				s_small = new File(pathName + "p01_t.jpg");
				try	{
					if(s_large.exists)	{
						t_large = new File( path + deviceFolder + seprator+ "thumbnail_latest.jpg");
						s_large.copyTo(t_large, true)
					}
				}
				catch(error:Error)	{
					Log.getLogger(Configuration.PICSAEN_LOG).error(( deviceFolder + seprator)+"thumbnail_latest.jpg not copied")
				}
				
				try	{
					if(s_small.exists)	{
						t_small = new File( path + deviceFolder + seprator+ "thumbnail.jpg");
						s_small.copyTo(t_small, true)
					}
				}
				catch(error:Error)	{
					Log.getLogger(Configuration.PICSAEN_LOG).error(( deviceFolder + seprator) +"thumbnail.jpg not copied")
				}
				
				
				
				
				
				

			}
		}
	}
}