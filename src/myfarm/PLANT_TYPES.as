import flash.geom.Point;

import myfarm.common.vo.PlantType;

// clover
var plantType:PlantType = new PlantType();
plantType.id = "clover";
plantType.name = "Clover";
plantType.size = new Point(5, 5);
plantType.numStages = 5;
plantType.graphicAnchors = new <Point>[
    new Point(0, 70),
    new Point(0, 27),
    new Point(0, 32),
    new Point(0, 40),
    new Point(0, 43)
];
plantTypes[plantType.id] = plantType;

// potato
plantType = new PlantType();
plantType.id = "potato";
plantType.name = "Potato";
plantType.size = new Point(5, 5);
plantType.numStages = 5;
plantType.graphicAnchors = new <Point>[
    new Point(0, 26),
    new Point(0, 26),
    new Point(0, 42),
    new Point(0, 44),
    new Point(0, 49)
];
plantTypes[plantType.id] = plantType;

// sunflower
plantType = new PlantType();
plantType.id = "sunflower";
plantType.name = "Sunflower";
plantType.size = new Point(5, 5);
plantType.numStages = 5;
plantType.graphicAnchors = new <Point>[
    new Point(0, 26),
    new Point(0, 44),
    new Point(0, 58),
    new Point(0, 82),
    new Point(0, 99)
];
plantTypes[plantType.id] = plantType;
