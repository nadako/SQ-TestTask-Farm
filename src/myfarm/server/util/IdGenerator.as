package myfarm.server.util
{
import flash.data.EncryptedLocalStore;
import flash.utils.ByteArray;

/**
 * Simple integer ID generator that stores its counter
 * in EncryptedLocalStorage item with given name.
 */
public class IdGenerator
{
    private var itemName:String;
    private var nextId:uint;

    /**
     * Create ID Generator
     *
     * @param itemName the name of ELS item to use
     */
    public function IdGenerator(itemName:String)
    {
        this.itemName = itemName;

        var bytes:ByteArray = EncryptedLocalStore.getItem(itemName);
        if (bytes != null)
            nextId = bytes.readUnsignedInt();
        else
            nextId = 1;
    }

    /**
     * Return next ID and store the new counter value
     *
     * @return id
     */
    public function getNextId():uint
    {
        var id:uint = nextId++;
        var bytes:ByteArray = new ByteArray();
        bytes.writeUnsignedInt(nextId);
        EncryptedLocalStore.setItem(itemName, bytes);
        return id;
    }
}
}
