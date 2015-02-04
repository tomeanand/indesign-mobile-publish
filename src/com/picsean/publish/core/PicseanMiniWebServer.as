package com.picsean.publish.core
{
	import com.picsean.publish.utils.Configuration;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import org.osmf.logging.Log;

	public class PicseanMiniWebServer
	{

		private var serverSocket:ServerSocket;
		private var mimeTypes:Object = new Object();
		private var webroot : File;
		
		public function PicseanMiniWebServer()
		{
			
		}
		
		public function startServer(serverPath : String):void	{
			mimeTypes[".css"]   = "text/css";
			mimeTypes[".gif"]   = "image/gif";
			mimeTypes[".htm"]   = "text/html";
			mimeTypes[".html"]  = "text/html";
			mimeTypes[".ico"]   = "image/x-icon";
			mimeTypes[".jpg"]   = "image/jpeg";
			mimeTypes[".js"]    = "application/x-javascript";
			mimeTypes[".png"]   = "image/png";
		
			webroot = new File(serverPath);
			listen();
		}
		
		private function listen():void
		{
			try
			{
				serverSocket = new ServerSocket();
				serverSocket.addEventListener(Event.CONNECT, socketConnectHandler);
				serverSocket.bind(8050);
				serverSocket.listen();
			}
			catch (error:Error)
			{
				Log.getLogger(Configuration.PICSAEN_LOG).info("Port 8050 may be in use. Enter another port number and try again."+ error.message);
			}
		}
		
		private function socketConnectHandler(event:ServerSocketConnectEvent):void
		{
			var socket:Socket = event.socket;
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		private function socketDataHandler(event:ProgressEvent):void
		{
			try
			{
				var socket:Socket = event.target as Socket;
				var bytes:ByteArray = new ByteArray();
				socket.readBytes(bytes);
				var request:String = "" + bytes;
				Log.getLogger(Configuration.PICSAEN_LOG).info(request);
				var filePath:String = request.substring(4, request.indexOf("HTTP/") - 1);
				var file:File = new File(webroot.url + filePath);
				if (file.exists && !file.isDirectory)
				{
					var stream:FileStream = new FileStream();
					stream.open( file, FileMode.READ );
					var content:ByteArray = new ByteArray();
					stream.readBytes(content);
					stream.close();
					socket.writeUTFBytes("HTTP/1.1 200 OK\n");
					socket.writeUTFBytes("Content-Type: " + getMimeType(filePath) + "\n\n");
					socket.writeBytes(content);
				}
				else
				{
					socket.writeUTFBytes("HTTP/1.1 404 Not Found\n");
					socket.writeUTFBytes("Content-Type: text/html\n\n");
					socket.writeUTFBytes("<html><body><h2>Page Not Found</h2></body></html>");
				}
				socket.flush();
				socket.close();
			}
			catch (error:Error)
			{
				Log.getLogger(Configuration.PICSAEN_LOG).info(error.message);
			}
		}
		
		private function getMimeType(path:String):String
		{
			var mimeType:String;
			var index:int = path.lastIndexOf(".");
			if (index > -1)
			{
				mimeType = mimeTypes[path.substring(index)];
			}
			return mimeType == null ? "text/html" : mimeType; // default to text/html for unknown mime types
		}		
		
	}
}