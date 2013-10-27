module Userspace.GUI.Compositor;

import Userspace.Libs.Graphics;
import System.IO.Directory;
import System.IO.FileStream;

import System.Threading.Thread;
import System.Diagnostics.Process;
import System.Diagnostics.ProcessStartInfo;
import System.Windows.Window;
import System.Collections.Generic.List;
import System.Convert;

static import Userspace.GUI.GraphicsTest;

class Compositor {
private:
	Graphics ctx;
	Graphics selectCtx;
	FileStream requestPipe;
	List!(Window.ProcessWindows) procWins;


public:
	this() {
		ctx            = new Graphics();
		ctx.Width      = 800;
		ctx.Height     = 600;
		ulong size     = ctx.Width * ctx.Height * ctx.Depth;
		ctx.Buffer     = (cast(byte *)0xE0000000)[0 .. size];
		ctx.BackBuffer = new byte[size];

		//selectCtx   = new Graphics(true); todo
		procWins    = new List!(Window.ProcessWindows)();
		requestPipe = Directory.CreatePipe("/dev/compositor");

		/** Mouse hanlder */
		//(new Thread(&MouseHandler)).Start();


		auto startInfo = new ProcessStartInfo();
		startInfo.ThreadEntry = &Userspace.GUI.GraphicsTest.construct;
		Process.Start(startInfo);

		while (true) {
			ProcessRequest();
			ProcessCommands();
		}
	}


private:
	void ProcessRequest() {
		byte data[24];
		long i;

		while (i != data.length)
			i += requestPipe.Read(data, 0);

		Window.ProcessWindows pwin;
		long[] d         = Convert.ToInt64Array(data);
		pwin.ID          = new Process(d[0]);
		pwin.EventPipe   = new FileStream(d[1]);
		pwin.CommandPipe = new FileStream(d[2]);
		//pwin.windows   = new List!bte;

		pwin.CommandPipe.Write(Convert.ToByteArray([Process.Current.ResID()]), 0);
		procWins.Add(pwin);
	}

	void ProcessCommands() {

	}


	void MouseHandler() {
		auto mousePipe = new FileStream("/dev/mouse");

		while (true) {

		}
	}
}


/* Main class for every program */
class Application {
	public static long Main(string[] args) {
		new Compositor();
		return 0;
	}
}



/** this will be automaticaly compiled to every program */
long construct(ulong* pointer) {
	string[] args = (cast(string *)pointer[0])[0 .. pointer[1]];
	return Application.Main(args);
}