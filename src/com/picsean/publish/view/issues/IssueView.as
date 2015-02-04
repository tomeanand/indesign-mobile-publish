package com.picsean.publish.view.issues
{
	import com.picsean.publish.core.PicseanMiniWebServer;
	import com.picsean.publish.core.RESTServiceController;
	import com.picsean.publish.download.DownloadOperation;
	import com.picsean.publish.events.EventIssues;
	import com.picsean.publish.events.EventRestService;
	import com.picsean.publish.model.vo.IssueRawVO;
	import com.picsean.publish.utils.Constants;
	import com.picsean.publish.utils.CookieHelper;
	import com.picsean.publish.view.WorkspaceFolderView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.core.IFlexDisplayObject;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	public class IssueView extends VBox
	{
		public var service:RESTServiceController;
		public var isDeploy : Boolean = false;
		
		[Bindable]public var magazineList : Object;
		[Bindable]public var editionList : Array;
		[Bindable]public var issueList : Array;
		
		private var userInfo : Object;
		private var magid : String;
		private var editionId : String;
		
		protected var issueVO:IssueRawVO;
		protected var downloadOperation : DownloadOperation;
		protected var webserver : PicseanMiniWebServer;
		
		[Bindable]protected var workspceFolder:String = "";
		[Bindable]protected var logtxt : String = "";
			
		
		public function IssueView()
		{
			super();
		}
		
		public function intialiseUI(service:RESTServiceController):void	{
			this.downloadOperation = new DownloadOperation();
			this.webserver = new PicseanMiniWebServer();
			
			workspceFolder = CookieHelper.getInstance().getWorkspace();
			
			this.service = service;
			service.addEventListener(EventRestService.EVENT_REST_RESPONSE, onRestEventHandler);
			
			userInfo = CookieHelper.getInstance().getUserInfo();
			if(userInfo != "")	{
				showMagazines();
			}
			if(workspceFolder != "")	{
				this.webserver.startServer(workspceFolder);
			}
			
		}
		
		public function showMagazines():void	{
			userInfo = CookieHelper.getInstance().getUserInfo();
			service.getMagazines(userInfo.pubid);
		}
		protected function onMagazineChangeHandler(event:ListEvent):void	{
			this.magid = event.target.selectedItem.id;
			service.getEditions(userInfo.pubid, magid);
		}
		protected function onTileClickHandler(event:ListEvent):void	{
			var editionid:String = event.currentTarget.selectedItem.editionid;
			editionId = editionid;
			service.getIssues(userInfo.pubid, this.magid, editionid);
		}
		protected function downloadAllFiles(event:MouseEvent):void	{
			var usr:Object = CookieHelper.getInstance().getUserInfo();
			if(CookieHelper.getInstance().getWorkspace() != "")	{
				downloadOperation.initOperation( this.issueVO );
				trace("HELOO WORKSPCE");
			}
			else if(usr.workspace != "")	{
				trace("HELOO USERINFO");
				downloadOperation.initOperation( this.issueVO );
			}
		}
		protected function directorySettingHandler(event:MouseEvent):void	{
			showFolderSetup();
		}
		
		protected function logout(event:MouseEvent):void	{
			CookieHelper.getInstance().addUserInfo("");
			this.dispatchEvent(new EventIssues(EventIssues.EVENT_LOGOUT,""));
		}
		protected function uploadToS3Handler(event:MouseEvent):void	{
			if(CookieHelper.getInstance().getWorkspace() != "")	{
				this.logtxt = this.issueVO.toString();
				this.dispatchEvent(new EventIssues(EventIssues.EVENT_S3_PUSH,this.issueVO));
			}
			
		}
		protected function autoDeployHandler(event:MouseEvent):void	{
			isDeploy = true;// setting it to true / will call once the printing is over. // shows alert from publishmain.mxml / user interation seeked
			this.dispatchEvent(new EventIssues(EventIssues.EVENT_PUBLISH_ISSUE,this.issueVO));
		}
		protected function syncAllFiles(event:MouseEvent):void	{
			var usr:Object = CookieHelper.getInstance().getUserInfo();
			this.logtxt = "";
			this.logtxt += "\n--Workspace ---"+ (CookieHelper.getInstance().getWorkspace());
			this.logtxt += "\n--Username  ---"+ (usr.user_name);
			this.logtxt += "\n--Email     ---"+ (usr.email);
			this.logtxt += "\n--Id User   ---"+ (usr.id_user);
			this.logtxt += "\n--Asset path---"+ (usr.assets_folder_path);
			this.logtxt += "\n--Workspace 1--"+ (usr.workspace);
		}
		private function showFolderSetup():void	{
			var dirWindow : IFlexDisplayObject = PopUpManager.createPopUp(this,WorkspaceFolderView,true);
			dirWindow.addEventListener(EventIssues.EVENT_SET_WORKSPACE,onWorkspaceHandler);
			PopUpManager.centerPopUp(dirWindow);				
		}
		public function autoPublish():void	{
			//var path:String = String(userInfo.assets_folder_path);
		//	path = path.replace(/\//g, '||');
			//service.autoPublish(userInfo.pubid, this.magid, this.editionId,path);
		}
		public function autoDeploy(devices:String):void	{
			isDeploy = false; // setting back to false after the call triggered
			service.autoDeploy(userInfo.pubid, this.magid, this.editionId, devices);
		}
		
		private function onRestEventHandler(event:EventRestService):void	{
			if(event.data.status == "success" )	{
				switch(event.action)	{
					case Constants.MAGS:
						magazineList = new Object();
						magazineList = event.data.data;
						var firstItem:Object = (magazineList[0]);
						this.magid = firstItem.id;
						service.getEditions(userInfo.pubid, firstItem.id);
					break;
					case Constants.EDITION :
						editionList = new Array();
						editionList = event.data.result as Array;
						editionList.reverse();
					break;
					case Constants.ISSUE :
						issueList = new Array();
						issueList = event.data.list as Array;
						issueVO = new IssueRawVO( event.data );
					break;
				}
			}
			else	{
				//do nothin
			}
		}
		
		private function onWorkspaceHandler(event:EventIssues):void	{
			this.webserver.startServer(event.data);
		}
		
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * */
		protected function listLabel(value:Object):String	{
			return value.path.toString().substring(value.path.toString().lastIndexOf(File.separator)+1);
		}
	}
}