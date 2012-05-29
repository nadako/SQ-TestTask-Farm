package myfarm.client.view
{
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;

import myfarm.client.model.resource.IResourceManager;
import myfarm.client.model.resource.ResourceEvent;
import myfarm.common.IDisposable;
import myfarm.common.vo.PlantType;

/**
 * Sprite using for placing new plants (this is added to the placing layer of the view)
 */
public class PlantPlacingSprite extends Sprite implements IDisposable
{
    private var _plantType:PlantType;
    private var resourceManager:IResourceManager;

    public function PlantPlacingSprite(plantType:PlantType, resourceManager:IResourceManager)
    {
        _plantType = plantType;
        this.resourceManager = resourceManager;
        alpha = 0.5;

        // get graphics for first growth stage
        var graphicsURL:String = plantType.getStageGraphicPath(1);
        if (resourceManager.hasResource(graphicsURL))
        {
            setGraphics();
        }
        else
        {
            resourceManager.addEventListener(resourceManager.constructCompleteEventName(graphicsURL), onLoadComplete);
            resourceManager.load(graphicsURL);
        }

    }

    private function setGraphics():void
    {
        var resource:Bitmap = resourceManager.getResource(_plantType.getStageGraphicPath(1)) as Bitmap;
        var bitmap:Bitmap = new Bitmap(resource.bitmapData);
        var anchor:Point = _plantType.graphicAnchors[0];
        bitmap.x = -anchor.x;
        bitmap.y = -anchor.y;
        addChild(bitmap);
    }

    private function onLoadComplete(event:ResourceEvent):void
    {
        resourceManager.removeEventListener(event.type, onLoadComplete);
        setGraphics();
    }

    public function get plantType():PlantType
    {
        return _plantType;
    }

    public function dispose():void
    {
        var graphicsURL:String = plantType.getStageGraphicPath(1);
        resourceManager.removeEventListener(resourceManager.constructCompleteEventName(graphicsURL), onLoadComplete);
    }
}
}
