package com.picsean.publish.utils
{
	public class Configuration
	{
		public static const DEVICE_INFO : Array = 
			[
				{label:'Select Device', 	pHeight:0, 		pWidth:0,		sRatio:0, folder:""},
				{label:DEVICE_IPAD, 		pHeight:1024, 	pWidth:768,		sRatio:2, folder:""},
				{label:DEVICE_IPAD_RETINA, 	pHeight:2048, 	pWidth:1536,	sRatio:2, folder:IPAD_RETINA_LITERAL},// changed the ration to 2,prevously it was 1;
				/*{label:DEVICE_IPAD_MINI, 	pHeight:1024, 	pWidth:768,		sRatio:1},
				{label:DEVICE_IPHONE, 		pHeight:480, 	pWidth:320,		sRatio:1},*/
				{label:DEVICE_IPHONE_4, 	pHeight:960, 	pWidth:640,		sRatio:2, folder:IPHONE_LITERAL},
				{label:DEVICE_IPHONE_5, 	pHeight:1136, 	pWidth:640,		sRatio:2, folder:IPHONE_5_LITERAL},
				{label:DEVICE_ANDRIOD_10, 	pHeight:1280, 	pWidth:800,		sRatio:2, folder:TAB_10_LITERAL},
				{label:DEVICE_ANDRIOD_07, 	pHeight:1024, 	pWidth:600,		sRatio:2, folder:TAB_7_LITERAL},
				{label:DEVICE_ANDRIOD_05, 	pHeight:640, 	pWidth:400,		sRatio:2, folder:TAB_5_LITERAL}

			];
		
		public static const ANDROID_PHONE_INFO : Array = [
				{label:DEVICE_ANDRIOD_PHONE_1080, 	pHeight:1920, 	pWidth:1080,		sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_PHONE_1080},
				{label:DEVICE_ANDRIOD_PHONE_720, 	pHeight:1280, 	pWidth:720,			sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_PHONE_720},
				{label:DEVICE_ANDRIOD_PHONE_540, 	pHeight:960, 	pWidth:540,			sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_PHONE_540},
				{label:DEVICE_ANDRIOD_PHONE_480, 	pHeight:854, 	pWidth:480,			sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_PHONE_480},
				{label:DEVICE_ANDRIOD_PHONE_480800, 	pHeight:800, 	pWidth:480,		sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_PHONE_480800},
				{label:DEVICE_ANDRIOD_PHONE_768, 	pHeight:1280, 	pWidth:768,			sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_PHONE_768},
				{label:DEVICE_ANDRIOD_PHONE_320, 	pHeight:480, 	pWidth:320,			sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_PHONE_320},
		];
		
		public static const ANDROID_TABLET_INFO : Array = [
				{label:DEVICE_ANDRIOD_TAB_800, 		pHeight:1280, 	pWidth:800,			sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_TAB_800},
				{label:DEVICE_ANDRIOD_TAB_1200, 	pHeight:1920, 	pWidth:1200,		sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_TAB_1200},
				{label:DEVICE_ANDRIOD_TAB_600, 		pHeight:1024, 	pWidth:600,			sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_TAB_600},
				{label:DEVICE_ANDRIOD_TAB_1600, 	pHeight:1600, 	pWidth:1600,		sRatio:1, folder: LITERAL_DEVICE_ANDRIOD_TAB_1600}
		];
		

		public static const SPECIAL_PRINT : String = "_print";
		
		public static const DEVICE_IPAD : String = "iPad";
		public static const DEVICE_IPAD_RETINA : String = "iPad Retina";
		public static const DEVICE_IPAD_MINI : String = "iPad Mini";
		public static const DEVICE_IPHONE_4 : String = "iPhone 4";
		public static const DEVICE_IPHONE_5 : String = "iPhone 5";
		
		public static const DEVICE_ANDRIOD_10 :String = "10inch Tablet";
		public static const DEVICE_ANDRIOD_07 :String = "7inch Tablet";
		public static const DEVICE_ANDRIOD_05 :String = "5inch Tablet";
		/**
		 * New devices from CMS
		 * 
		 * */
		public static const DEVICE_ANDRIOD_PHONE_1080 :String = "android_p_1080";
		public static const DEVICE_ANDRIOD_PHONE_720 :String = "android_p_720";
		public static const DEVICE_ANDRIOD_PHONE_540 :String = "android_p_540";
		public static const DEVICE_ANDRIOD_PHONE_480 :String = "android_p_480";
		public static const DEVICE_ANDRIOD_PHONE_480800 :String = "android_p_480800";
		public static const DEVICE_ANDRIOD_PHONE_768 :String = "android_p_768";
		public static const DEVICE_ANDRIOD_PHONE_320 :String = "android_p_320";

		public static const DEVICE_ANDRIOD_TAB_800 :String = "android_t_800";
		public static const DEVICE_ANDRIOD_TAB_1200 :String = "android_t_1200";
		public static const DEVICE_ANDRIOD_TAB_600 :String = "android_t_600";
		public static const DEVICE_ANDRIOD_TAB_1600 :String = "android_t_1600";
		
		

		public static const IPAD_RETINA_LITERAL_PUBLISH : String = "_retina";
		public static const IPAD_RETINA_LITERAL : String = "";
		public static const IPHONE_LITERAL : String = "_iphone";
		public static const IPHONE_5_LITERAL : String = "_iphone5";
		public static const TAB_7_LITERAL : String = "_nexus7";
		public static const TAB_10_LITERAL : String = "_tab101";
		public static const TAB_5_LITERAL : String = "_nexus5";
		
		/**
		 * New devices from CMS
		 * 
		 * */
		public static const LITERAL_DEVICE_ANDRIOD_PHONE_1080 :String = "_android_p_1080";
		public static const LITERAL_DEVICE_ANDRIOD_PHONE_720 :String = "_android_p_720";
		public static const LITERAL_DEVICE_ANDRIOD_PHONE_540 :String = "_android_p_540";
		public static const LITERAL_DEVICE_ANDRIOD_PHONE_480 :String = "_android_p_480";
		public static const LITERAL_DEVICE_ANDRIOD_PHONE_480800 :String = "_android_p_480800";
		public static const LITERAL_DEVICE_ANDRIOD_PHONE_768 :String = "_android_p_768";
		public static const LITERAL_DEVICE_ANDRIOD_PHONE_320 :String = "_android_p_320";
		
		public static const LITERAL_DEVICE_ANDRIOD_TAB_800 :String = "_android_t_800";
		public static const LITERAL_DEVICE_ANDRIOD_TAB_1200 :String = "_android_t_1200";
		public static const LITERAL_DEVICE_ANDRIOD_TAB_600 :String = "_android_t_600";
		public static const LITERAL_DEVICE_ANDRIOD_TAB_1600 :String = "_android_t_1600";		
		
		
		
		public static const SELECT_ALL :String = "Select All";
		public static const ANDROID_PHONES :String = "Android Phones";
		public static const ANDROID_TABLETS :String = "Android Tablets";
		
		// possible folders user may select while publishing
		public static const PUBLISH_SELECTABLE_FOLDERS : Array = [
			IPHONE_LITERAL, IPHONE_5_LITERAL,TAB_7_LITERAL,TAB_10_LITERAL,TAB_5_LITERAL,
			LITERAL_DEVICE_ANDRIOD_PHONE_1080,
			LITERAL_DEVICE_ANDRIOD_PHONE_720,
			LITERAL_DEVICE_ANDRIOD_PHONE_540,
			LITERAL_DEVICE_ANDRIOD_PHONE_480,
			LITERAL_DEVICE_ANDRIOD_PHONE_480800,
			LITERAL_DEVICE_ANDRIOD_PHONE_768,
			LITERAL_DEVICE_ANDRIOD_PHONE_320,
			LITERAL_DEVICE_ANDRIOD_TAB_800,
			LITERAL_DEVICE_ANDRIOD_TAB_1200,
			LITERAL_DEVICE_ANDRIOD_TAB_600,
			LITERAL_DEVICE_ANDRIOD_TAB_1600
			];
		
		
			
		public static const PANO_IMAGE_SPLIT_SIZE :Number = 300;
		public static const PANO_IMAGE_NAME :String = "panoclip";
		
		public static const PICSAEN_LOG : String = "PicseanPublish";
		public static const STANDERD_PPI:int=72;
		public static const INDD : String = ".idml";//".indd";

		public static const LABEL:String = "properties";
		public static const ORIENTATION:String ='orientation';
		//http://192.168.1.4/pubplus/images/3_demos/99_version_two/31_november2013/p/a00/p03/scroll-1/slide-6.png
		public static const PICSEAN_SERVER_URL: String ='http://picsean.com/pubplus/images'; //"http://192.168.1.4/pubplus/images/3_demos/99_version_two/31_november2013/";//'http://picsean.com/pubplus/images/';
		
		public static const MAIN : String = "main";
		
		// all types must be added to F_LIST as well
		public static const TYPE_BASE : String = "base";
		public static const TYPE_DRAWCLOSE : String = "drawclose";
		public static const TYPE_DRAW : String = "draw";
		public static const TYPE_SLIDESHOW : String = "slideshow";
		public static const TYPE_SCROLL : String = "scroll";
		public static const TYPE_PANORAMA : String = "panorama";
		public static const TYPE_ANIMBTN : String = "animatedbutton";
		public static const TYPE_IMAGEHYPERLINK :String = 'imageHyperLink';
		public static const TYPE_VIDEO:String = '$video'
		public static const TYPE_AUDIO:String ='$audio';
		public static const TYPE_WEBVIEW:String = 'WebOverScreen';
		public static const TYPE_ANIMATEDIMAGE:String ='anim_image';
		public static const TYPE_ZOOMABLEIMAGE:String ='zoomableImage';
		public static const TYPE_SCALE:String = 'scale';
		public static const TYPE_VIDEOTRIGGER:String = '$videotrigger';
		public static const TYPE_SCRUBBEREFFECT:String = 'scrubberEffect';

		public static const TYPE_TIMERJSON :String = 'timerJson';
		/* TYPE_DRAW_MULTI_TIMER is used for adding timerJson and multidraw features to draw.*/
		public static const TYPE_DRAW_MULTI_TIMER :String = 'drawmultitimer';
		public static const TYPE_MULTIPLEDRAW :String = "multipledraw";
		public static const TYPE_PANORAMA_EVENT : String = "panoevent";
		public static const TYPE_FLIPIMAGE :String = 'flipImage';

		public static const TYPE_TRIGGERABLEPANO:String = "triggerablepano";
		public static const G_TRIGGERABLEPANO_TRIGGER_OPEN : String = "trigger-open";
		public static const G_TRIGGERABLEPANO_TRIGGER_CLOSE : String = "trigger-close";

		public static const G_SLIDES : String = "slides";
		public static const G_CONTENT : String = "contents";
		public static const G_TRIGGER : String = "trigger";
		public static const G_NESTED :String = "nested";
		
		public static const TYPE_DRAGIMAGE:String = 'dragimage';
		
		public static const TYPE_JUMP:String = 'jump';
		
		public static const TYPE_CAMERA:String = 'camera';

		
		public static const TYPE_ACCELEROMETERTRIGGER : String = 'accelerometertrigger';
		
		public static const TYPE_RELATIVE_PANORAMA : String = 'relativePano';
		public static const TYPE_RELATIVE_PANORAMA_NEW : String = 'RelativepanoNew';
		
		public static const TYPE_MASK : String = 'mask';
		
		public static const TYPE_SLIDESHOW_TRIGGER:String = "slideshowtrigger";
		public static const TYPE_RELATIVE_DRAW :String = "relativeDraw";
		public static const TYPE_RELATIVE_IMAGE :String = "relativeImage";
		public static const TYPE_VIDEO_FEATURE :String = "video";
		public static const TYPE_AUDIO_FEATURE :String = "audio";
		public static const TYPE_RELATIVE_DRAG:String = "relativeDragImage";
		
		public static const TYPE_R_PANORAMA :String ="rpanorama"
		public static const TYPE_FLIP_BOOK :String ="flipbook"
		
		public static const TYPE_PANO :String = "pano"


		public static const F_LIST : Array = [ MAIN, TYPE_DRAWCLOSE, TYPE_DRAW, TYPE_SLIDESHOW, TYPE_SCROLL, TYPE_PANORAMA, TYPE_ANIMBTN,
												TYPE_IMAGEHYPERLINK, TYPE_VIDEO, TYPE_AUDIO, TYPE_WEBVIEW ,
												TYPE_SCALE,TYPE_ZOOMABLEIMAGE,TYPE_VIDEOTRIGGER,TYPE_SCRUBBEREFFECT,
												TYPE_TIMERJSON,TYPE_TRIGGERABLEPANO,TYPE_DRAGIMAGE,TYPE_JUMP,TYPE_CAMERA,TYPE_PANORAMA_EVENT, TYPE_ACCELEROMETERTRIGGER,
												TYPE_RELATIVE_PANORAMA,TYPE_MASK,TYPE_DRAW_MULTI_TIMER,TYPE_FLIPIMAGE,TYPE_RELATIVE_DRAW,TYPE_RELATIVE_IMAGE,TYPE_RELATIVE_DRAG,TYPE_VIDEO_FEATURE,TYPE_PANO,TYPE_RELATIVE_PANORAMA_NEW,TYPE_R_PANORAMA,TYPE_AUDIO_FEATURE,
												TYPE_FLIP_BOOK];

												



		//
		public static const TYPE_AUTO_PANORAMA : String ='AutoPanaroma';
		public static const PRPTY_SPEED :String = 'acclerationspeed';
		public static const PRPTY_SVALUE :String = 'scrollingValue';
		public static const PRPTY_SDIRECTION :String = 'scrollingDirection';
		
		
		public static const F_NESTED_LIST : Array = [ TYPE_SLIDESHOW,TYPE_PANORAMA,TYPE_ANIMBTN, TYPE_DRAWCLOSE, TYPE_DRAW, TYPE_SCROLL,TYPE_CAMERA,TYPE_PANO,TYPE_R_PANORAMA,TYPE_FLIP_BOOK ];

		
		public static function isNested(type:String):Boolean	{
			type = type.split("-")[0];
			//supporting all features
			//return (F_NESTED_LIST.toString().indexOf(type) >= 0 ? true : false); // Bug id @234
			return (F_LIST.toString().indexOf(type) >= 0 ? true : false); // Bug id @234
		}
		
		public static function getFeatureType(type:String):String	{
			type = type.split("-")[0];
			var returnType:String = TYPE_BASE;
			for(var i:Number = 0; i<F_LIST.length; i++)	{
				if(type == F_LIST[i])	{
					returnType = F_LIST[i];
					break;
				}
			}
			return returnType;
		}
		

		
		[Embed (source='assets/images/publish_splash.png')]
		public static const SPLASH_LOGO:Class;
		
	}
}
