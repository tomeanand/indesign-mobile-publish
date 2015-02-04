package com.picsean.publish.core
{
	import com.adobe.indesign.Group;
	import com.adobe.indesign.PageItem;
	import com.picsean.publish.feature.AccelerometerTrigger;
	import com.picsean.publish.feature.AnimatedButtonFeature;
	import com.picsean.publish.feature.AudioFeature;
	import com.picsean.publish.feature.BaseFeature;
	import com.picsean.publish.feature.CameraFeature;
	import com.picsean.publish.feature.DragImageFeature;
	import com.picsean.publish.feature.DrawFeature;
	import com.picsean.publish.feature.EventfullPanoramaFeature;
	import com.picsean.publish.feature.FlipBookFeature;
	import com.picsean.publish.feature.IFeature;
	import com.picsean.publish.feature.MainFeature;
	import com.picsean.publish.feature.PanoFeature;
	import com.picsean.publish.feature.PanoramaFeature;
	import com.picsean.publish.feature.RelativeDrag;
	import com.picsean.publish.feature.RelativeDraw;
	import com.picsean.publish.feature.RelativeImage;
	import com.picsean.publish.feature.RelativePanorama;
	import com.picsean.publish.feature.RelativePanoramaNew;
	import com.picsean.publish.feature.ScaleFeature;
	import com.picsean.publish.feature.ScrollFeature;
	import com.picsean.publish.feature.SlideShowFeature;
	import com.picsean.publish.feature.TimerJsonFeature;
	import com.picsean.publish.feature.TriggerablePanoramaFeature;
	import com.picsean.publish.feature.VideoFeature;
	import com.picsean.publish.feature.WebOverScreen;
	import com.picsean.publish.utils.Configuration;

	public class FeatureFactory
	{
		public function FeatureFactory()
		{
			
		}
		
		public static function createFeature(group:Group):IFeature	{
			var featureName : String = PageItem(group).name;
			var featureType : String  = Configuration.getFeatureType(featureName);
			switch(featureType)	{
				case Configuration.MAIN : 					return new MainFeature(group); break;
				case Configuration.TYPE_ANIMBTN : 			return new AnimatedButtonFeature(group); break;
				case Configuration.TYPE_AUDIO : 			return new BaseFeature(group); break;
				case Configuration.TYPE_DRAW : 				return new DrawFeature(group); break;
				case Configuration.TYPE_DRAWCLOSE : 		return new DrawFeature(group); break;
				case Configuration.TYPE_IMAGEHYPERLINK : 	return new BaseFeature(group); break;
				case Configuration.TYPE_PANORAMA : 			return new PanoramaFeature(group); break;
				case Configuration.TYPE_SCROLL : 			return new ScrollFeature(group); break;
				case Configuration.TYPE_SLIDESHOW : 		return new SlideShowFeature(group); break;
				case Configuration.TYPE_VIDEO : 			return new BaseFeature(group); break;
				case Configuration.TYPE_WEBVIEW : 			return new WebOverScreen(group); break;
				case Configuration.TYPE_SCALE : 			return new ScaleFeature(group); break;
				case Configuration.TYPE_TIMERJSON :			return new TimerJsonFeature(group); break;
				case Configuration.TYPE_TRIGGERABLEPANO : 	return new TriggerablePanoramaFeature(group); break;
				case Configuration.TYPE_DRAGIMAGE :         return new DragImageFeature(group);break;
				case Configuration.TYPE_JUMP :              return new BaseFeature(group); break;
				case Configuration.TYPE_CAMERA :            return new CameraFeature(group); break;
				case Configuration.TYPE_PANORAMA_EVENT :    return new EventfullPanoramaFeature(group); break;
				case Configuration.TYPE_ACCELEROMETERTRIGGER : return new AccelerometerTrigger(group); break;
				case Configuration.TYPE_RELATIVE_PANORAMA :    return new RelativePanorama(group); break;
				case Configuration.TYPE_MASK :    			   return new DrawFeature(group); break;
				case Configuration.TYPE_RELATIVE_DRAW :        return new RelativeDraw(group) ; break;
				case Configuration.TYPE_RELATIVE_DRAG : 		return new RelativeDrag(group); break;
				case Configuration.TYPE_RELATIVE_IMAGE : 	   return new RelativeImage(group); break;
				case Configuration.TYPE_VIDEO_FEATURE : 	   return new VideoFeature(group); break;
				case Configuration.TYPE_PANO : 	   			return new PanoFeature(group); break;
				case Configuration.TYPE_RELATIVE_PANORAMA_NEW : 	   			return new RelativePanoramaNew(group); break;
				case Configuration.TYPE_R_PANORAMA  : return new PanoFeature(group); break;
				case Configuration.TYPE_AUDIO_FEATURE  : return new AudioFeature(group); break;
				case Configuration.TYPE_FLIP_BOOK  : return new FlipBookFeature(group); break;

			}
			return new BaseFeature(group);
		}
	}
}