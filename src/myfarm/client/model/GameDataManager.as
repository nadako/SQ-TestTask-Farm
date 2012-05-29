package myfarm.client.model
{
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import myfarm.common.IDisposable;
import myfarm.client.IFacade;
import myfarm.client.model.server.ServerEvent;
import myfarm.common.cell.CellMap;
import myfarm.common.vo.Plant;
import myfarm.common.vo.PlantType;

/**
 * Manager for actual game data. Does all the fancy stuff
 * with plants and field map.
 */
public class GameDataManager implements IDisposable
{
    private var plantTypes:Dictionary = new Dictionary();
    private var plants:Dictionary = new Dictionary();
    private var facade:IFacade;
    private var cellMap:CellMap;

    /**
     * Create data manager. It will listen to ServerEvent.GAME_DATA
     * event and process any incoming data from the server.
     *
     * @param facade application facade
     */
    public function GameDataManager(facade:IFacade)
    {
        this.facade = facade;
        facade.eventRelay.addEventListener(ServerEvent.GAME_DATA, onGameData);
        createPlantTypes();
    }

    /**
     * Clean up everything
     */
    public function dispose():void
    {
        plantTypes = null;
        plants = null;
        facade.eventRelay.removeEventListener(ServerEvent.GAME_DATA, onGameData);
        facade = null;
    }

    private function createPlantTypes():void
    {
        // Just include static definitions for now.
        include "../../PLANT_TYPES.as";
    }

    /**
     * Called when server dispatches game data update.
     */
    private function onGameData(event:ServerEvent):void
    {
        mergeData(event.data);
    }

    /**
     * Process incoming XML data and update game
     * data model accordingly. This will effectively
     * initialize cell map, as well as create, modify
     * and remove plants from the game.
     *
     * @param data XML data from the server
     */
    public function mergeData(data:XML):void
    {
        // If we don't have a cell map initialized, do it now
        // TODO: dispatch some event like INITIALIZED so we
        // can remove any preloaders and show actual field display.
        if (!cellMap)
            cellMap = new CellMap(data.@size_y, data.@size_x);

        var plantIds:Dictionary = new Dictionary(); // temporary storage for plant ids that are present in supplied XML
        var plantId:uint;
        for each (var plantData:XML in data.children())
        {
            plantId = plantData.@id;
            plantIds[plantId] = true; // add this plant to the existing plant IDs collection

            if (plantId in plants)
            // if it's already in our plants collection, call for update
                changePlant(plantData);
            else
            // otherwise add new plant
                addPlant(plantData);
        }

        // check if any plants were removed, using the temporary dictionary we created earlier in this function
        for (var p:String in plants)
        {
            plantId = uint(p);
            if (!(plantId in plantIds))
                removePlant(plantId);
        }
    }

    /**
     * Called when new plant data is found in incoming XML.
     * Dispatches PlantEvent.PLANT_ADD to application event relay.
     *
     * @param plantData plant-related XML node
     */
    private function addPlant(plantData:XML):void
    {
        // create plant object and add it to plants collection
        var plantType:PlantType = plantTypes[plantData.name()];
        var plant:Plant = new Plant(plantType);
        plant.id = plantData.@id;
        plant.position = new Point(plantData.@x, plantData.@y);
        plant.stage = plantData.@stage;
        plants[plant.id] = plant;

        // mark cells as occupied
        cellMap.setAreaFree(new Rectangle(plant.position.x, plant.position.y, plantType.size.x, plantType.size.y), false);

        // dispatch global event about plant adding
        facade.eventRelay.dispatchEvent(new PlantEvent(PlantEvent.PLANT_ADD, plant));
    }

    /**
     * Called when existing plant data found in incoming XML.
     * May dispatch PlantEvent.PLANT_MOVE or/and PlantEvent.PLANT_STAGE_CHANGE
     * to application event relay if these parameters change.
     *
     * @param plantData plant-related XML node
     */
    private function changePlant(plantData:XML):void
    {
        var plant:Plant = plants[uint(plantData.@id)];
        var position:Point = new Point(plantData.@x, plantData.@y);

        // if position is changed, update cell map, set new plant position
        // and dispatch PlantEvent.PLANT_MOVE
        if (!position.equals(plant.position))
        {
            // mark old area as free
            cellMap.setAreaFree(new Rectangle(plant.position.x, plant.position.y, plant.type.size.x, plant.type.size.y), true);

            // mark new area as occupied
            cellMap.setAreaFree(new Rectangle(position.x, position.y, plant.type.size.x, plant.type.size.y), false);

            plant.position = position;

            facade.eventRelay.dispatchEvent(new PlantEvent(PlantEvent.PLANT_MOVE, plant));
        }

        // also, if growth stage changed, set new stage and dispatch PlantEvent.PLANT_STAGE_CHANGE
        if (plant.stage != plantData.@stage)
        {
            plant.stage = plantData.@stage;
            facade.eventRelay.dispatchEvent(new PlantEvent(PlantEvent.PLANT_STAGE_CHANGE, plant));
        }
    }

    /**
     * Called when existing plant is not found in incoming XML
     * Removes plant from game model and dispatches PlantEvent.PLANT_REMOVE.
     *
     * @param plantId ID of removed plant
     */
    private function removePlant(plantId:uint):void
    {
        var plant:Plant = plants[plantId];
        // mark area as non occupied
        cellMap.setAreaFree(new Rectangle(plant.position.x, plant.position.y, plant.type.size.x, plant.type.size.y), true);

        // remove from plants collection
        delete plants[plantId];

        facade.eventRelay.dispatchEvent(new PlantEvent(PlantEvent.PLANT_REMOVE, plant));
    }

    /**
     * Return plant type by given string ID
     *
     * @param id ID of the plant type
     * @return actual plant type object
     */
    public function getPlantType(id:String):PlantType
    {
        return plantTypes[id] as PlantType;
    }

    public function getPlantTypes():Dictionary
    {
        return plantTypes;
    }

    /**
     * Returns whether given plant type can be planted at given coordinates.
     * This is useful for client-side checking if a plant can be added.
     *
     * @param plantType a plant type to add
     * @param x X field coordinate
     * @param y Y field coordinate
     * @return true if plant is in bounds and every cell in needed area is free
     */
    public function canBePlanted(plantType:PlantType, x:Number, y:Number):Boolean
    {
        var rect:Rectangle = new Rectangle(x, y, plantType.size.x, plantType.size.y);
        return cellMap.isAreaInBounds(rect) && cellMap.isAreaFree(rect);
    }
}
}
