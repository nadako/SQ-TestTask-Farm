package myfarm.common.cell
{
/**
 * Representation of a single cell in the cell map.
 *
 * Currently it only contains its coordinates and
 * a "free" attribute.
 */
public class Cell
{
    private var _x:uint;
    private var _y:uint;

    public var free:Boolean = true;

    public function Cell(x:uint, y:uint)
    {
        _x = x;
        _y = y;
    }

    public function get x():uint
    {
        return _x;
    }

    public function get y():uint
    {
        return _y;
    }
}
}
