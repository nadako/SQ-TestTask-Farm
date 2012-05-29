package myfarm.client.view
{
import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

import myfarm.client.view.iso.IsoObject;

import myfarm.common.IDisposable;
import myfarm.client.IFacade;
import myfarm.client.controller.CommandEvent;
import myfarm.client.model.PlantEvent;
import myfarm.client.model.resource.ResourceEvent;
import myfarm.common.vo.PlantType;
import myfarm.client.view.iso.IsoScene;
import myfarm.client.view.widgets.TextButton;
import myfarm.client.view.widgets.TextButtonMenu;
import myfarm.client.view.widgets.TextButtonMenuEvent;

public class WorldView implements IDisposable
{
    private static const BG_URL:String = "BG.jpg";
    private static const BG_ZERO_POINT:Point = new Point(118, 432);

    private var container:DisplayObjectContainer;
    private var facade:IFacade;

    private var placingSprite:PlantPlacingSprite;
    private var placingLayer:DisplayObjectContainer;
    private var layers:DisplayObjectContainer;
    private var scene:IsoScene;
    private var plantViews:Dictionary = new Dictionary();
    private var growButton:TextButton;
    private var plantMenu:TextButtonMenu;

    public function WorldView(container:DisplayObjectContainer, facade:IFacade)
    {
        this.container = container;
        this.facade = facade;

        layers = new Sprite();

        scene = new IsoScene(new Sprite());
        scene.container.x = BG_ZERO_POINT.x;
        scene.container.y = BG_ZERO_POINT.y;
        layers.addChild(scene.container);

        placingLayer = new Sprite();
        placingLayer.name = "placingLayer";
        layers.addChild(placingLayer);

        container.addChild(new PanningContainer(layers, 760, 650));

        growButton = new TextButton("Grow plants");
        growButton.addEventListener(MouseEvent.CLICK, onGrowButtonClick);
        container.addChild(growButton);

        var plantChoices:Object = {};
        for each (var plantType:PlantType in facade.gameDataManager.getPlantTypes())
            plantChoices[plantType.id] = plantType.name;

        plantMenu = new TextButtonMenu(plantChoices);
        plantMenu.x = growButton.width + 5;
        plantMenu.addEventListener(TextButtonMenuEvent.ITEM_SELECT, onPlantItemSelected);
        container.addChild(plantMenu);

        container.addEventListener(Event.ENTER_FRAME, scene.render);

        facade.eventRelay.addEventListener(PlantEvent.PLANT_ADD, onPlantAdd);
        facade.eventRelay.addEventListener(PlantEvent.PLANT_MOVE, onPlantMove);
        facade.eventRelay.addEventListener(PlantEvent.PLANT_REMOVE, onPlantRemove);
        facade.eventRelay.addEventListener(PlantEvent.PLANT_STAGE_CHANGE, onPlantStageChange);
    }

    public function dispose():void
    {
        for each (var isoObject:IsoObject in scene.isoObjects.concat())
        {
            scene.removeObject(isoObject);
            isoObject.removeEventListener(MouseEvent.CLICK, onPlantViewClick);
            isoObject.dispose();
        }

        container.removeEventListener(Event.ENTER_FRAME, scene.render);
        growButton.removeEventListener(MouseEvent.CLICK, onGrowButtonClick);
        plantMenu.removeEventListener(TextButtonMenuEvent.ITEM_SELECT, onPlantItemSelected);
        plantMenu.dispose();

        facade.eventRelay.removeEventListener(PlantEvent.PLANT_ADD, onPlantAdd);
        facade.eventRelay.removeEventListener(PlantEvent.PLANT_MOVE, onPlantMove);
        facade.eventRelay.removeEventListener(PlantEvent.PLANT_REMOVE, onPlantRemove);
        facade.eventRelay.removeEventListener(PlantEvent.PLANT_STAGE_CHANGE, onPlantStageChange);
    }

    public function init():void
    {
        initBackground();
    }

    public function initBackground():void
    {
        if (facade.resourceManager.hasResource(BG_URL))
        {
            var bgResource:Bitmap = facade.resourceManager.getResource(BG_URL) as Bitmap;
            layers.addChildAt(new Bitmap(bgResource.bitmapData), 0);
        }
        else
        {
            facade.resourceManager.addEventListener(facade.resourceManager.constructCompleteEventName(BG_URL), onBackgroundLoadComplete);
            facade.resourceManager.load(BG_URL);
        }
    }

    private function onBackgroundLoadComplete(event:ResourceEvent):void
    {
        facade.resourceManager.removeEventListener(facade.resourceManager.constructCompleteEventName(BG_URL), onBackgroundLoadComplete);
        var bgResource:Bitmap = facade.resourceManager.getResource(BG_URL) as Bitmap;
        layers.addChildAt(new Bitmap(bgResource.bitmapData), 0);
    }

    private function onPlantAdd(event:PlantEvent):void
    {
        var view:PlantView = new PlantView(event.plant, facade.resourceManager);
        var coords:Point = scene.cellToIso(event.plant.position);
        view.x = coords.x;
        view.y = coords.y;
        view.addEventListener(MouseEvent.CLICK, onPlantViewClick);
        scene.addObject(view);
        plantViews[event.plant.id] = view;
    }

    private function onPlantMove(event:PlantEvent):void
    {
        trace("Moving view for plant");
    }

    private function onPlantRemove(event:PlantEvent):void
    {
        var view:PlantView = plantViews[event.plant.id] as PlantView;
        scene.removeObject(view);
        view.dispose();
        view.removeEventListener(MouseEvent.CLICK, onPlantViewClick);
    }

    private function onPlantStageChange(event:PlantEvent):void
    {
        var view:PlantView = plantViews[event.plant.id] as PlantView;
        view.updateGraphics();
    }

    private function onGrowButtonClick(event:MouseEvent):void
    {
        facade.eventRelay.dispatchEvent(new CommandEvent(CommandEvent.GROW));
    }

    private function onPlantItemSelected(event:TextButtonMenuEvent):void
    {
        var plantType:PlantType = facade.gameDataManager.getPlantType(event.value);
        var sprite:PlantPlacingSprite = new PlantPlacingSprite(plantType, facade.resourceManager);
        startPlacing(sprite);
    }

    private function startPlacing(sprite:PlantPlacingSprite):void
    {
        placingSprite = sprite;
        placingLayer.addChild(sprite);

        var isoPoint:Point = scene.localToIso(scene.container.globalToLocal(new Point(scene.container.stage.mouseX, scene.container.stage.mouseY)));
        scene.alignToCell(isoPoint);
        var coords:Point = placingLayer.globalToLocal(scene.container.localToGlobal(scene.isoToLocal(isoPoint)));
        placingSprite.x = coords.x;
        placingSprite.y = coords.y;

        // disable iso scene mouse interaction while placing
        scene.container.mouseEnabled = scene.container.mouseChildren = false;

        layers.addEventListener(MouseEvent.MOUSE_MOVE, onPlacingMouseMove);
        layers.addEventListener(MouseEvent.CLICK, onPlacingClick);
    }

    private function onPlacingMouseMove(event:MouseEvent):void
    {
        var isoPoint:Point = scene.localToIso(scene.container.globalToLocal(new Point(event.stageX, event.stageY)));
        scene.alignToCell(isoPoint);
        var coords:Point = placingLayer.globalToLocal(scene.container.localToGlobal(scene.isoToLocal(isoPoint)));
        placingSprite.x = coords.x;
        placingSprite.y = coords.y;
    }

    private function onPlacingClick(event:MouseEvent):void
    {
        var isoCoords:Point = scene.localToIso(scene.container.globalToLocal(new Point(event.stageX, event.stageY)));
        scene.isoToCell(isoCoords, isoCoords);

        var plantType:PlantType = placingSprite.plantType;
        if (facade.gameDataManager.canBePlanted(plantType, isoCoords.x, isoCoords.y))
        {
            // issue PLANT command
            facade.eventRelay.dispatchEvent(new CommandEvent(CommandEvent.PLANT, {
                plantType: plantType.id,
                x: isoCoords.x,
                y: isoCoords.y
            }));

            // remove placing stuff
            layers.removeEventListener(MouseEvent.MOUSE_MOVE, onPlacingMouseMove);
            layers.removeEventListener(MouseEvent.CLICK, onPlacingClick);
            placingLayer.removeChild(placingSprite);
            placingSprite.dispose();
            placingSprite = null;

            // enable scene mouse interaction again
            scene.container.mouseEnabled = scene.container.mouseChildren = true;
        }
    }

    private function onPlantViewClick(event:MouseEvent):void
    {
        var view:PlantView = event.target as PlantView;
        facade.eventRelay.dispatchEvent(new CommandEvent(CommandEvent.GATHER, view.plant));
    }
}
}
