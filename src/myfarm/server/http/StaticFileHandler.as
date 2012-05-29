package myfarm.server.http
{
import com.junkbyte.console.ConsoleChannel;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.Socket;
import flash.utils.ByteArray;

/**
 * Very simple request handler that can serve image files.
 * Keep in mind that it reads the whole file in memory so it
 * is not very effective, but whatever. :-)
 */
public class StaticFileHandler implements IRequestHandler
{
    private static const log:ConsoleChannel = new ConsoleChannel("static");

    private var directory:File;

    private static const MIME_TYPES:Object = {
        ".gif":"image/gif",
        ".jpg":"image/jpeg",
        ".png":"image/png"
    };

    /**
     * Create a static file handler
     *
     * @param directory a directory where to look for requested files
     */
    public function StaticFileHandler(directory:File)
    {
        this.directory = directory;
    }

    /**
     * Handle file request and serve a file or return 404 if
     * there's no file for specified path.
     *
     * @param path requested path
     * @param socket socket to write output to
     */
    public function handleRequest(path:String, socket:Socket):void
    {
        // paths are always relative to specified directory
        if (path.indexOf("/") == 0)
            path = path.slice(1);

        log.debug("Serving file", path);
        var file:File = directory.resolvePath(path);
        if (file.exists && !file.isDirectory)
        {
            log.debug("Sending", file.nativePath);
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            var content:ByteArray = new ByteArray();
            stream.readBytes(content);
            stream.close();
            socket.writeUTFBytes("HTTP/1.1 200 OK\n");
            socket.writeUTFBytes("Content-Type: " + getMimeType(path) + "\n\n");
            socket.writeBytes(content);
        }
        else
        {
            log.debug("File not found, sending 404");
            write404(socket);
        }
    }

    /**
     * Return mime type based on file extension
     *
     * @param path file path (actually only extension is used)
     * @return mime type string
     */
    private function getMimeType(path:String):String
    {
        var mimeType:String;
        var index:int = path.lastIndexOf(".");
        if (index != -1)
            mimeType = MIME_TYPES[path.substring(index)];
        return mimeType == null ? "text/html" : mimeType;
    }
}
}
