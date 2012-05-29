package myfarm.common.cell
{
import flash.geom.Rectangle;

/**
 * A cell map that stores a 2D array of cells
 * (relatively) efficient and provides handy
 * methods to check if any cell is occupied or not.
 */
public class CellMap
{
    private var cells:Vector.<Cell>;
    private var _numRows:uint;
    private var _numCols:uint;

    /**
     * Create new cell map. Note that the CellMap
     * currently can't be resized.
     *
     * @param numRows number of rows
     * @param numCols number of columns
     */
    public function CellMap(numRows:uint, numCols:uint)
    {
        _numRows = numRows;
        _numCols = numCols;
        cells = new Vector.<Cell>(numRows * numCols);
        for (var y:uint = 0; y < numRows; y++)
        {
            for (var x:uint = 0; x < numCols; x++)
            {
                cells[y * numCols + x] = new Cell(x, y);
            }
        }
    }

    public function get numRows():uint
    {
        return _numRows;
    }

    public function get numCols():uint
    {
        return _numCols;
    }

    public function getCell(x:uint, y:uint):Cell
    {
        return cells[y * _numCols + x];
    }

    public function isCellFree(x:uint, y:uint):Boolean
    {
        return getCell(x, y).free;
    }

    public function setCellFree(x:uint, y:uint, value:Boolean):void
    {
        getCell(x, y).free = value;
    }

    /**
     * Check if given area is in bounds of this cell map.
     *
     * @param area area to check
     * @return true if it is in bounds, false otherwise
     */
    public function isAreaInBounds(area:Rectangle):Boolean
    {
        return (area.x >= 0 && area.y >= 0 && area.right <= _numCols && area.bottom <= _numRows);
    }

    /**
     * Check if given area consists of free cells.
     *
     * @param area area to check
     * @return true if every single cell in given area is free, false otherwise
     */
    public function isAreaFree(area:Rectangle):Boolean
    {
        if (!isAreaInBounds(area))
            return true;
        for (var x:uint = area.x; x < area.right; x++)
        {
            for (var y:uint = area.y; y < area.bottom; y++)
            {
                if (!isCellFree(x, y))
                    return false;
            }
        }
        return true;
    }

    /**
     * Mark area as free or occupied. This effectively marks every
     * cell in area.
     *
     * @param area are to mark
     * @param value if true, marking as free, otherwise marking as occupied
     */
    public function setAreaFree(area:Rectangle, value:Boolean):void
    {
        if (!isAreaInBounds(area))
            throw new ArgumentError("Given area is not in bounds of the cell map");
        for (var x:uint = area.x; x < area.right; x++)
        {
            for (var y:uint = area.y; y < area.bottom; y++)
            {
                setCellFree(x, y, value);
            }
        }
    }
}
}
