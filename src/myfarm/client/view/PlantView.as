package myfarm.client.view
{
import com.mosesSupposes.bitmap.InteractivePNG;

import flash.display.Bitmap;
import flash.geom.Point;

import myfarm.common.IDisposable;
import myfarm.client.model.resource.IResourceManager;
import myfarm.client.model.resource.ResourceEvent;
import myfarm.common.vo.Plant;
import myfarm.client.view.iso.IsoObject;

/**
 * Isometric view of a plant
 */
public class PlantView extends IsoObject implements IDisposable
{
    private var graphicsContainer:InteractivePNG;
    private var _plant:Plant;
    private var resourceManager:IResourceManager;

    public function PlantView(plant:Plant, resourceManager:IResourceManager)
    {
        this.resourceManager = resourceManager;

        _plant = plant;

        graphicsContainer = new InteractivePNG();
        graphicsContainer.mouseChildren = false;
        super(graphicsContainer);

        updateGraphics();
    }

    public function get plant():Plant
    {
        return _plant;
    }

    public function updateGraphics():void
    {
        var graphicsURL:String = plant.type.getStageGraphicPath(plant.stage);
        if (resourceManager.hasResource(graphicsURL))
        {
            setGraphics();
        }
        else
        {
            // we listen on generic LOAD_COMPLETE event because plant growth stage
            // can change while we're loading the resource
            resourceManager.addEventListener(ResourceEvent.LOAD_COMPLETE, onResourceLoaded);
            resourceManager.load(graphicsURL);
        }
    }

    private function setGraphics():void
    {
        var graphicsURL:String = plant.type.getStageGraphicPath(plant.stage);
        var plantResource:Bitmap = resourceManager.getResource(graphicsURL) as Bitmap;
        var bitmap:Bitmap = new Bitmap(plantResource.bitmapData);
        var anchor:Point = plant.type.graphicAnchors[plant.stage - 1];
        bitmap.x = -anchor.x;
        bitmap.y = -anchor.y;
        graphicsContainer.removeChildren();
        graphicsContainer.addChild(bitmap);
    }

    private function onResourceLoaded(event:ResourceEvent):void
    {
        if (event.url == resourceManager.baseURL + plant.type.getStageGraphicPath(plant.stage))
        {
            resourceManager.removeEventListener(ResourceEvent.LOAD_COMPLETE, onResourceLoaded);
            setGraphics();
        }
    }

    override public function dispose():void
    {
        resourceManager.removeEventListener(ResourceEvent.LOAD_COMPLETE, onResourceLoaded);
        super.dispose();
    }
}
}
