import QtQuick 2.0

Item {
    id: snake

    property string direction: "u"; property string tempDirection: "u"
    property var tail: []

    property int pxWidth: 40
    property int length: 2
    property int maxLength: 10


    Repeater {
        id: bodyDrawer //drawes body
        model: maxLength
        Rectangle {
            id: body
            width: pxWidth
            height: pxWidth
            radius: ((index > 0) ? pxWidth/4 : pxWidth/6)
            color: (tail[index] !== undefined) ? ((index > 0) ? "lightgreen" : "green") : "transparent"
        }
    }

    function reset(fieldSz){
        direction = 'u'
        tempDirection = 'u'
        length = 2;
        var sx = randomPoint(fieldSz.x);
        var sy = randomPoint(fieldSz.y);
        tail = [ Qt.point(sx,sy), Qt.point(sx,sy)]

        bodyDrawer.itemAt(0).color = "green"
        bodyDrawer.itemAt(0).x = tail[0].x * pxWidth
        bodyDrawer.itemAt(0).y = tail[0].y * pxWidth
    }
    function clear(){
        for (var i = 0; i < maxLength; i++) {
            bodyDrawer.itemAt(i).color = "transparent"
        }
    }


    function reDraw() {
        direction = tempDirection
        moveBody()

        switch (direction) {
        case "u":
            //move up
            tail[0].y--
            break
        case "d":
            //move down
            tail[0].y++
            break
        case "l":
            //move left
            tail[0].x--
            break
        case "r":
            //move right
            tail[0].x++
            break
        default:
            //if err
            break
        }
        bodyDrawer.itemAt(0).x = tail[0].x * pxWidth
        bodyDrawer.itemAt(0).y = tail[0].y * pxWidth

        //status.color = "green"
        //status.text = "Status: playing... "
    }

    function moveBody() {
        for (var i = length - 1; i > 0; i--) {
                tail[i].x = tail[i - 1].x
                tail[i].y = tail[i - 1].y


            bodyDrawer.itemAt(i).x = tail[i].x * pxWidth
            bodyDrawer.itemAt(i).y = tail[i].y * pxWidth
            bodyDrawer.itemAt(i).color = "lawngreen"
        }
    }

    function growth(){
        if (length < maxLength) { //to snake
            tail[length] = Qt.point(0,0)
            length++
        }
    }

    //collisions
    function checkOnfree(x, y) {
        for (var i = 0; i<length; i++) {
            //check if apple spawned on snake
            if (x === tail[i].x && y === tail[i].y) {
                console.log("cant spawn")
                return false
            }
        }
        return true
    }

    function isCollided(fieldSz) {
        if (tail[0].x < 1 || tail[0].x >= fieldSz.x - 1 || tail[0].y >= fieldSz.y -1 || tail[0].y < 1)
            return true
        return false
    }
    function isSelfCollided() {
        for (var i = 1; i < length; i++) {
            if (tail[0].x  === tail[i].x && tail[0].y  === tail[i].y) {
                return true
            }
        }
        return false
    }
    function randomPoint(max){
        return Math.floor(Math.random() * (max - 2) + 1)
    }
}
