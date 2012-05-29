package myfarm.server
{
import com.junkbyte.console.ConsoleChannel;

import flash.net.Socket;
import flash.net.URLVariables;

import myfarm.server.http.IRequestHandler;
import myfarm.server.http.write404;

/**
 * Request handler for actual game, parses request variables
 * and calls methods on given Application object, sending
 * updated game data back. In case of error, instead of
 * game data, the error XML is sent.
 */
public class ApplicationHandler implements IRequestHandler
{
    private static const log:ConsoleChannel = new ConsoleChannel("appHandler");

    private var methodHandlers:Object;
    private var app:Application;

    /**
     * Create application request handler
     *
     * @param app The actual application object to work with
     */
    public function ApplicationHandler(app:Application)
    {
        this.app = app;
        methodHandlers = {
            "init":init,
            "plant":plant,
            "growPlants":growPlants,
            "gather":gather
        };
    }

    /**
     * Init request handler. Just send current game data back.
     *
     * @param params unused (no params required for initialization)
     */
    private function init(params:Object):void
    {
        log.debug("Processing init request");
        // do nothing, just return current game data
    }

    /**
     * Plant request handler. Try to add a plant to the game.
     *
     * @param params (type, x, y)
     */
    private function plant(params:Object):void
    {
        log.debug("Processing plant request", params);
        checkRequired(params, "type", "x", "y");
        app.plant(params["type"], uint(params["x"]), uint(params["y"]));
    }

    /**
     * Grow all plants request handler.
     *
     * @param params unused (no params required)
     */
    private function growPlants(params:Object):void
    {
        log.debug("Processing growPlants request", params);
        app.growPlants();
    }

    /**
     * Gather request handler. Try to gather request.
     *
     * @param params (plantId)
     */
    private function gather(params:Object):void
    {
        log.debug("Processing gather request", params);
        checkRequired(params, "plantId");
        app.gather(uint(params["plantId"]));
    }

    /**
     * Process incoming request, where the method name is the
     * actual path and its parameters are the query string.
     *
     * If a handler for the method is not found, 404 is returned.
     *
     * @param path path to handle
     * @param socket socket to write response data to
     */
    public function handleRequest(path:String, socket:Socket):void
    {
        log.debug("Handling request", path);
        var parts:Array = path.split("?", 2);
        var query:String;
        if (parts.length > 1)
        {
            path = parts[0];
            query = parts[1];
        }

        var method:String = path;
        if (method.indexOf("/") == 0)
            method = method.slice(1);

        var vars:URLVariables = new URLVariables(query);

        log.debug("Method:", method, ", params:", JSON.stringify(vars));

        if (!(method in methodHandlers))
        {
            log.debug("Method " + method + " not found, sending 404");
            write404(socket);
        }
        else
        {
            try
            {
                methodHandlers[method](vars);
                writeXML(socket, app.gameData);
            }
            catch (error:ApplicationError)
            {
                writeXML(socket, error.toXML());
            }
        }
    }

    /**
     * Check that given params object has all the required fields.
     *
     * @param params the params object parsed from query string
     * @param arguments sequence of parameter names
     */
    private function checkRequired(params:Object, ...arguments):void
    {
        for each (var argument:String in arguments)
        {
            if (!(argument in params))
                throw new ApplicationError("Required parameter is not present: " + argument, 1);
        }
    }

    /**
     * Write an XML object as a HTTP response.
     *
     * @param socket socket to write data to
     * @param xml XML object to send
     */
    private function writeXML(socket:Socket, xml:XML):void
    {
        socket.writeUTFBytes("HTTP/1.1 200 OK\n");
        socket.writeUTFBytes("Content-Type: application/xml\n\n");
        socket.writeUTFBytes(xml.toXMLString());
    }
}
}

