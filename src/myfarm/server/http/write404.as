package myfarm.server.http
{
import flash.net.Socket;

/**
 * Little utility function to write a very simple 404 response
 * to a socket.
 *
 * @param socket Socket to write 404 page to
 */
public function write404(socket:Socket):void
{
    socket.writeUTFBytes("HTTP/1.1 404 Not Found\n");
    socket.writeUTFBytes("Content-Type: text/html\n\n");
    socket.writeUTFBytes("<html><body>Not Found</body></html>");
}
}
