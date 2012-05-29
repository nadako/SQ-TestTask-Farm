package myfarm.common
{
/**
 * Something that has a method to cleanup itself
 * when it's not needed (somewhat like destructor).
 */
public interface IDisposable
{
    /**
     * Dispose any resources acquired, clean up
     * any collections, etc., making the object
     * free to throw away.
     */
    function dispose():void;
}
}
