package myfarm.tests
{
import flash.data.EncryptedLocalStore;
import flash.utils.ByteArray;

import myfarm.server.Application;

import org.flexunit.asserts.assertEquals;

public class ServerApplicationTests
{
    private function setTestGameData(xml:XML):void
    {
        var bytes:ByteArray = new ByteArray();
        bytes.writeUTF(xml.toXMLString());
        EncryptedLocalStore.setItem("gameData", bytes);
    }

    [Before(order=1)]
    [After]
    public function resetELS():void
    {
        EncryptedLocalStore.reset();
    }

    [Test]
    public function testCreation():void
    {
        var app:Application = new Application();
        assertEquals(app.gameData, <field size_x="60" size_y="60"></field>);
    }

    [Test]
    public function testPlant():void
    {
        var app:Application = new Application();

        app.plant("clover", 0, 0);
        assertEquals(app.gameData, <field size_x="60" size_y="60"><clover id="1" x="0" y="0" stage="1"/></field>);

        app.plant("sunflower", 10, 10);
        assertEquals(app.gameData, <field size_x="60" size_y="60">
            <clover id="1" x="0" y="0" stage="1"/>
            <sunflower id="2" x="10" y="10" stage="1"/>
        </field>);
    }

    [Test(expects="myfarm.server.ApplicationError")]
    public function testUnknownPlant():void
    {
        var app:Application = new Application();
        app.plant("wtf", 0, 0);
    }

    [Test(expects="myfarm.server.ApplicationError")]
    public function testOccupied():void
    {
        var app:Application = new Application();
        app.plant("clover", 0, 0);
        app.plant("clover", 1, 1);
    }

    [Test(expects="myfarm.server.ApplicationError")]
    public function testOutOfBounds():void
    {
        var app:Application = new Application();
        app.plant("clover", 58, 0);
    }


    [Test]
    public function testGather():void
    {
        setTestGameData(<field size_x="60" size_y="60"><clover id="1" x="0" y="0" stage="5"/></field>)
        var app:Application = new Application();
        app.gather(1);
        assertEquals(app.gameData, <field size_x="60" size_y="60"></field>);
    }

    [Test(expects="myfarm.server.ApplicationError")]
    public function testGatherUnknown():void
    {
        var app:Application = new Application();
        app.gather(1);
    }

    [Test(expects="myfarm.server.ApplicationError")]
    public function testGatherNotReady():void
    {
        setTestGameData(<field size_x="60" size_y="60"><clover id="1" x="0" y="0" stage="4"/></field>);
        var app:Application = new Application();
        app.gather(1);
    }


    [Test]
    public function testGrowPlants():void
    {
        setTestGameData(<field size_x="60" size_y="60">
            <clover id="1" x="0" y="0" stage="1"/>
            <clover id="2" x="5" y="0" stage="4"/>
            <clover id="3" x="10" y="0" stage="5"/>
        </field>);

        var app:Application = new Application();
        app.growPlants();

        assertEquals(app.gameData, <field size_x="60" size_y="60">
            <clover id="1" x="0" y="0" stage="2"/>
            <clover id="2" x="5" y="0" stage="5"/>
            <clover id="3" x="10" y="0" stage="5"/>
        </field>);

        app.growPlants();
        assertEquals(app.gameData, <field size_x="60" size_y="60">
            <clover id="1" x="0" y="0" stage="3"/>
            <clover id="2" x="5" y="0" stage="5"/>
            <clover id="3" x="10" y="0" stage="5"/>
        </field>);
    }

}
}
