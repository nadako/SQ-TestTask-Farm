package myfarm.server
{
import com.junkbyte.console.Cc;

import flash.display.Sprite;
import flash.filesystem.File;

import myfarm.server.http.Server;
import myfarm.server.http.StaticFileHandler;

/**
 * Server entry point, creates log display for
 * any output, creates the game application and
 * starts the HTTP server for handling incoming
 * requests.
 */
public class Main extends Sprite
{
    private var application:Application;
    private var server:Server;

    public function Main()
    {
        Cc.startOnStage(this);

        application = new Application();

        server = new Server(8080);
        server.addHandler("/static", new StaticFileHandler(File.applicationDirectory.resolvePath("static")));
        server.addHandler("/", new ApplicationHandler(application));
        server.start();
    }
}
}
