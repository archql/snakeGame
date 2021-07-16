import QtQuick 2.0

Rectangle {
    // its fruit
    id: fruit
    x: cords.x * pxWidth
    y: cords.y * pxWidth
    width: pxWidth
    height: pxWidth
    radius: pxWidth/2
    color: "red"

    property int price: 3
    property int lifetime: -1
    property int maxLifetime: -1

    property point cords: Qt.point(3,5)
    property int size: 1
    property int pxWidth: 40

    property bool alive: false
    visible: alive
    property int spawnChanse: 100

    function respawn(fieldSize, checkOnFree) {
        if ((randomPoint(100) < spawnChanse)) {
            cords.x = randomPoint(fieldSize.x)
            cords.y = randomPoint(fieldSize.y)

            while (!checkOnFree(cords.x, cords.y))
                respawn(fieldSize, checkOnFree)

            alive = true
            if (maxLifetime != -1)
                lifetime = maxLifetime - randomPoint(maxLifetime/ 3)
        } else
            alive = false
    }

    function isCollided (snakeHead, properties) {
        if (alive && snakeHead.x === cords.x && snakeHead.y === cords.y) {
            console.log("Collided!")

            properties.price+= price;
            console.log(properties.price)

            return true
        }
        return false
    }

    function update() {
        if (alive && lifetime > 0) {
            lifetime--
            if (lifetime == 0)
                alive = false
        }
    }

    function randomPoint(max){
        return Math.floor(Math.random() * (max - 2) + 1)
    }
}
