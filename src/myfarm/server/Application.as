package myfarm.server
{
import com.junkbyte.console.ConsoleChannel;

import flash.data.EncryptedLocalStore;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import myfarm.common.cell.CellMap;
import myfarm.common.vo.PlantType;
import myfarm.server.util.IdGenerator;

/**
 * The actual game application. Handles game data
 * and provides methods to manipulate it.
 */
public class Application
{
    private static const log:ConsoleChannel = new ConsoleChannel("app");

    private static const GAME_DATA_ITEM:String = "gameData"; // The name of ELS item to store game data

    private var _gameData:XML;
    private var plantIdGenerator:IdGenerator;
    private var plantTypes:Dictionary; // dictionary of PlantType objects (plant definitions)
    private var cellMap:CellMap; // 2D area map with cells marked as free or not

    public function Application()
    {
        log.debug("Initializing application");

        createPlantTypes();
        plantIdGenerator = new IdGenerator("nextPlantId");

        // Load game data from ELS or create an empty field if it's not present.
        var bytes:ByteArray = EncryptedLocalStore.getItem(GAME_DATA_ITEM);
        if (bytes != null)
            _gameData = new XML(bytes.readUTF());
        else
            _gameData = <field size_x="60" size_y="60"></field>
        initGame();
    }

    /**
     * Load plant definitions (just include them from static file for now).
     */
    private function createPlantTypes():void
    {
        plantTypes = new Dictionary();
        include "../PLANT_TYPES.as";
    }

    /**
     * Initialize internal structures after game data loading.
     */
    private function initGame():void
    {
        // Initialize cell map...
        cellMap = new CellMap(_gameData.@size_y, _gameData.@size_x);

        // and mark areas occupied by plants
        var rect:Rectangle = new Rectangle();
        var plantType:PlantType;
        for each (var plantData:XML in _gameData.children())
        {
            plantType = plantTypes[plantData.name()];
            rect.x = plantData.@x;
            rect.y = plantData.@y;
            rect.width = plantType.size.x;
            rect.height = plantType.size.y;
            cellMap.setAreaFree(rect, false);
        }
    }

    /**
     * Dump current game data to ELS.
     */
    private function saveGameData():void
    {
        log.debug("Saving game data");
        var bytes:ByteArray = new ByteArray();
        bytes.writeUTF(_gameData.toXMLString());
        EncryptedLocalStore.setItem(GAME_DATA_ITEM, bytes);
    }

    /**
     * Add a new plant. Throw an ApplicationError if plant couldn't be added
     * for whatever reason.
     *
     * @param type name of the plant type (should be defined in plantTypes dictionary)
     * @param x X coordinate for new plant
     * @param y Y coordinate for new plant
     */
    public function plant(type:String, x:uint, y:uint):void
    {
        log.debug("Planting", type, x, y);

        if (!(type in plantTypes))
            throw new ApplicationError("Unknown plant type: " + type)

        var plantType:PlantType = plantTypes[type];
        var area:Rectangle = new Rectangle(x, y,  plantType.size.x,  plantType.size.y);
        if (!(cellMap.isAreaInBounds(area) && cellMap.isAreaFree(area)))
            throw new ApplicationError("Area is not free for plant " + type + ": x=" + x + ", y=" + y + ", size=" + plantType.size);

        // mark cells as occupied
        cellMap.setAreaFree(area, false);

        // add a node to game data XML
        var plantData:XML = new XML("<" + type + " id='" + plantIdGenerator.getNextId() + "' x='" + x + "' y='" + y + "' stage='1' />");
        _gameData.appendChild(plantData);
        saveGameData();
    }

    /**
     * Gather specified plant. Throw ApplicationError if
     * given plantId is invalid or plant is not ready to be gathered.
     *
     * @param plantId ID of a plant to gather.
     */
    public function gather(plantId:uint):void
    {
        log.debug("Gathering", plantId);

        var children:XMLList = _gameData.children().(@id == plantId);
        if (!children.length())
            throw new ApplicationError("Unknown plant ID: " + plantId);

        var plantData:XML = children[0];
        var plantType:PlantType = plantTypes[plantData.name()];

        if (plantData.@stage < plantType.numStages)
            throw new ApplicationError("Plant with ID " + plantId + " is not ready for gathering (" + plantData.@stage + "/" + plantType.numStages + ")");

        // mark cells as free
        cellMap.setAreaFree(new Rectangle(plantData.@x, plantData.@y, plantType.size.x, plantType.size.y), true);

        // delete plant node from game data XML
        delete children[0];

        saveGameData();
    }

    /**
     * Grow all plants by 1 stage. Plants that are already fully grown
     * are not affected by this.
     */
    public function growPlants():void
    {
        log.debug("Growing plants");
        var plantType:PlantType;
        for each (var plantData:XML in _gameData.children())
        {
            plantType = plantTypes[plantData.name()];
            if (plantData.@stage < plantType.numStages)
                plantData.@stage++;
        }
        saveGameData();
    }

    /**
     * Return current game data XML.
     */
    public function get gameData():XML
    {
        return _gameData;
    }
}
}
