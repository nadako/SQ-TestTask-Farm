package myfarm.server
{
/**
 * Exception that are thrown by application methods to be converted
 * to proper error response by application request handler.
 */
internal class ApplicationError extends Error
{
    public function ApplicationError(message:* = "", id:* = 0)
    {
        super(message, id);
    }

    public function toXML():XML
    {
        return new XML("<error id='" + errorID + "'>" + message + "</error>");
    }
}
}
