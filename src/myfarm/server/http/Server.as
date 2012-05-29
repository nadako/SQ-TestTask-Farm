package myfarm.server.http
{
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.ServerSocketConnectEvent;
import flash.net.ServerSocket;
import flash.net.Socket;
import flash.utils.ByteArray;

/**
 * Simple HTTP server that listens on given port and
 * trying to handle GET requests, choosing handlers
 * by prefix.
 */
public class Server
{
    private var port:uint;
    private var serverSocket:ServerSocket;
    private var handlers:Vector.<HandlerRecord>;

    /**
     * Create a server instance
     *
     * @param port - port to listen to
     */
    public function Server(port:uint)
    {
        this.port = port;
        handlers = new Vector.<HandlerRecord>();
        serverSocket = new ServerSocket();
        serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onServerSocketConnect);
    }

    /**
     * Add a request handler for given path prefix.
     *
     * Note that handlers are checked in the order they were
     * added, so if you want more specific prefixes to be handled
     * with different handlers, add it before others.
     *
     * @param prefix path prefix
     * @param handler handler object
     */
    public function addHandler(prefix:String, handler:IRequestHandler):void
    {
        if (prefix in handlers)
            throw new Error("Handler already present for prefix " + prefix);
        handlers.push(new HandlerRecord(prefix, handler));
    }

    /**
     * Bind to a port and start listening for incoming requests
     */
    public function start():void
    {
        serverSocket.bind(port);
        serverSocket.listen();
    }

    /**
     * Called when new incoming connection opened
     */
    private function onServerSocketConnect(event:ServerSocketConnectEvent):void
    {
        event.socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
        event.socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
        event.socket.addEventListener(Event.CLOSE, onSocketError);
    }

    /**
     * Called when data is received from incoming connection
     */
    private function onSocketData(event:ProgressEvent):void
    {
        var socket:Socket = event.target as Socket;

        // read the whole request body, though we're only interested in path
        var bytes:ByteArray = new ByteArray();
        socket.readBytes(bytes);
        var request:String = bytes.toString();
        var path:String = request.substring(4, request.indexOf("HTTP/") - 1); // FIXME: this is ugly

        // loop through available handlers and if prefix matches
        // pass the request to the handler and break the loop
        var handled:Boolean = false;
        for each (var record:HandlerRecord in handlers)
        {
            if (path.indexOf(record.prefix) == 0)
            {
                path = path.substring(record.prefix.length);
                record.handler.handleRequest(path, socket);
                handled = true;
                break;
            }
        }

        // if it wasnt handled, just return 404 page
        if (!handled)
            write404(socket);

        socket.flush();
        socket.close();
        disposeSocket(socket)
    }

    /**
     * Called on any error or if remote closed the connection.
     */
    private function onSocketError(event:Event):void
    {
        var socket:Socket = event.target as Socket;
        try
        {
            socket.close();
        }
        catch (error:Error)
        {
            // we dont care if it's already closed
        }
        disposeSocket(socket);
    }

    /**
     * Remove any event listeners from the socket
     */
    private function disposeSocket(socket:Socket):void
    {
        socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
        socket.removeEventListener(IOErrorEvent.IO_ERROR, onSocketError);
    }
}
}
import myfarm.server.http.IRequestHandler;

/**
 * Just an utility structure to hold information about request handlers.
 */
internal class HandlerRecord
{
    public var prefix:String;
    public var handler:IRequestHandler;

    public function HandlerRecord(prefix:String, handler:IRequestHandler)
    {
        this.prefix = prefix;
        this.handler = handler;
    }
}
