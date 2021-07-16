import QtQuick 2.6

Rectangle {
    id: field

    property int pxWidth: 40
    property point fieldSz: Qt.point(20, 15)

    property color borderColor: "black";
    property color fieldColor: "gray";

    /*Component.onCompleted: {
        repa.model =  fieldSz.x * fieldSz.y;
    }*/

    //graphics
    Repeater {
        id: repa
        model: fieldSz.x * fieldSz.y
        Rectangle {
            x: pxWidth * (index % fieldSz.x)
            y: pxWidth * Math.floor(index / fieldSz.x)
            width: pxWidth
            height: pxWidth
            color: ((index < fieldSz.x) || (index >= fieldSz.x * (fieldSz.y - 1)) ||
                    (index % fieldSz.x == 0) || (index % fieldSz.x == fieldSz.x - 1)) ?
                       borderColor : fieldColor;
        }
    }
}
