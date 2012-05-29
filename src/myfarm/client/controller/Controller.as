package myfarm.client.controller
{
import myfarm.client.IFacade;
import myfarm.common.IDisposable;
import myfarm.common.vo.Plant;

/**
 * Application logic controller
 *
 * Listens application event relay for CommandEvent events,
 * representing commands from other parts of the system (mainly
 * view) and does actual work.
 */
public class Controller implements IDisposable
{
    private var facade:IFacade;

    public function Controller(facade:IFacade)
    {
        this.facade = facade;
        facade.eventRelay.addEventListener(CommandEvent.INIT, onInitCommand);
        facade.eventRelay.addEventListener(CommandEvent.PLANT, onPlantCommand);
        facade.eventRelay.addEventListener(CommandEvent.GROW, onGrowCommand);
        facade.eventRelay.addEventListener(CommandEvent.GATHER, onGatherCommand);
    }

    public function dispose():void
    {
        facade.eventRelay.removeEventListener(CommandEvent.INIT, onInitCommand);
        facade.eventRelay.removeEventListener(CommandEvent.PLANT, onPlantCommand);
        facade.eventRelay.removeEventListener(CommandEvent.GROW, onGrowCommand);
        facade.eventRelay.removeEventListener(CommandEvent.GATHER, onGatherCommand);
    }

    private function onInitCommand(event:CommandEvent):void
    {
        facade.server.request("init");
    }

    private function onPlantCommand(event:CommandEvent):void
    {
        facade.server.request("plant", {
            type:event.data.plantType,
            x:event.data.x,
            y:event.data.y
        });
    }

    private function onGrowCommand(event:CommandEvent):void
    {
        facade.server.request("growPlants");
    }

    private function onGatherCommand(event:CommandEvent):void
    {
        var plant:Plant = event.data as Plant;
        if (plant.stage >= plant.type.numStages)
            facade.server.request("gather", {plantId:plant.id});
    }
}
}
