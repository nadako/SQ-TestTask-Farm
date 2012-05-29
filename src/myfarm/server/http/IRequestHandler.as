package myfarm.server.http
{
import flash.net.Socket;

/**
 * Interface for any HTTP request handlers
 */
public interface IRequestHandler
{
    /**
     * Handle request and write data to socket.
     *
     * @param request - string containing full request body
     * @param socket - socket connection to write to, you don't
     * need to flush or close it.
     */
    function handleRequest(path:String, socket:Socket):void;
}
}
