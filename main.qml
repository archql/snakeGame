import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtMultimedia 5.8
import QtQml 2.0

Window {
    width: 1250
    height: 950
    visible: true
    title: "Snake 1.4.2 Final      (removed direction changing while pausing, fixed apple spawning and so on)"


    /*Update list:
        v 1.0.0
            created field
            created keyboard snake control (WASD)
        v 1.1.0
            max snake length was increased from 1 to 12
            field size was decreased to 15
            added black borders to field
            added points
        v 1.2.0
            added death from wall
            added text labels
            snake was colored
            max snake length was increased from 12 to 21
            added time decreasing
            +bugfixes
        v 1.3.0
            max snake length was increased from 21 to 35
            added death from bumping snake in itself
            text labels was colored + added new stats panel
            added pause (P) and restart (G) buttons
            added max score
            +bugfixes
        v 1.4.0
            removed direction changing while pausing
            fixed apple spawning
            you can clear game without starting a new one
            +bugfixes
        v 1.4.2
            removed possibility to move back
            fixed speed formula (now 1 + 0.12*score)
            ->current version
    */
    property int x0: 8
    property int y0: 8
    property var xX: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property var yY: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property int aX: Math.random() * 13 + 1
    property int aY: Math.random() * 13 + 1
    property int time: 1000
    property int length: 1
    property int points: 0
    property int maxPoints: 0
    property string direction: "u"
    property bool isPlayng: false

    Item {
        focus: true
        Keys.onPressed: {
            if (timer.running == true) {
                if (event.key === Qt.Key_W && direction != "d") {
                    direction = "u"
                }
                if (event.key === Qt.Key_A && direction != "r") {
                    direction = "l"
                }
                if (event.key === Qt.Key_S && direction != "u") {
                    direction = "d"
                }
                if (event.key === Qt.Key_D && direction != "l") {
                    direction = "r"
                }
            }
            if (event.key === Qt.Key_P) {
                if (isPlayng) {
                    if (timer.running == true) {
                        timer.running = false
                        status.color = "dodgerblue"
                        status.text = "Status: game paused...( press P to continue )"
                    } else {
                        status.color = "green"
                        status.text = "Status: playing... "
                        timer.running = true
                    }
                }
            }
            if (event.key === Qt.Key_G) {
                if (isPlayng) {
                    killGame("")
                } else {
                    isPlayng = true
                    x0 = 8
                    y0 = 8
                    head.x = 100 + x0 * 50
                    head.y = 100 + y0 * 50
                    direction = "u"
                    head.color = "green"
                    timer.start()
                }
            }
        }
    }

    Text {
        x: 350
        id: txt
        text: "Snake Game"
        font.family: "Helvetica"
        font.pointSize: 30
        font.bold: true
        color: "forestgreen"
    }
    Text {
        x: 100
        y: 50
        text: "Stats: score - " + points + " / " + maxPoints + " - max score;\n dir - "
              + direction + ", length - " + length + ", time K - " + (1000 / time)
        font.pointSize: 15
        color: "black"
    }
    Text {
        id: status
        x: 100
        y: 100 + 750
        text: "Status: NaN  ( press G to start )"
        font.pointSize: 20
        color: "gray"
    }

    Grid {
        // its field
        x: 100
        y: 100
        columns: 1
        Repeater {
            model: 15
            Row {
                id: line
                x: 0
                Repeater {
                    model: 15
                    Rectangle {
                        id: r1
                        width: 50
                        height: 50
                        x: index * 50
                        color: (r1.x == 0 || r1.x == 14 * 50 || line.y == 0
                                || line.y == 14 * 50) ? "black" : "darkgrey"
                    }
                }
                y: index * 50
            }
        }
    }

    Rectangle {
        // its head
        id: head
        width: 50
        height: 50
        radius: 17
        x: 100 + x0 * 50
        y: 100 + y0 * 50
        color: "green"
    }

    Repeater {
        id: bodyDrawer //drawes body
        model: 35
        Rectangle {
            id: body
            width: 50
            height: 50
            radius: 20
            x: 100
            y: 100
            color: (xX[index] > 0) ? "lightgreen" : "black"
        }
    }

    Rectangle {
        // its fruit
        id: fruit
        x: 100 + aX * 50
        y: 100 + aY * 50
        width: 50
        height: 50
        radius: 25
        color: "red"
    }

    Timer {
        id: timer
        interval: time
        running: false
        repeat: true
        onTriggered: {
            reDraw()
            event()
        }
    }

    function reDraw() {
        moveBody()
        switch (direction) {
        case "u":
            //move up
            y0--
            break
        case "d":
            //move down
            y0++
            break
        case "l":
            //move left
            x0--
            break
        case "r":
            //move right
            x0++
            break
        default:
            //if err
            break
        }
        head.x = 100 + x0 * 50
        head.y = 100 + y0 * 50
        status.color = "green"
        status.text = "Status: playing... "
    }

    function event() {
        if (x0 == aX && y0 == aY) {
            //fruit have eated
            points++
            aX = Math.random() * 13 + 1
            aY = Math.random() * 13 + 1
            checkOnfree() //check if apple spawned on snake & repeat it if it needed
            if (length < 35) {
                length++
            }
            time = 1000 / (1 + 0.12 * points)
        }
        if (x0 < 1 || x0 > 13 || y0 > 13 || y0 < 1) {
            head.color = "black"
            killGame("bumped in the wall")
            //bumped in the wall
        }
        for (var i = 0; i < length; i++) {
            if (x0 === xX[i] && y0 === yY[i]) {
                killGame("bumped in itself")
            }
            //bumped in itself
        }
    }

    function checkOnfree() {
        for (var i = 0; i < length; i++) {
            //check if apple spawned on snake
            if ((aX === xX[i] && aY === yY[i]) || (x0 === aX && y0 === aY)) {
                aX = Math.random() * 13 + 1
                aY = Math.random() * 13 + 1
                console.log("Apple respawn!")
                checkOnfree()
            }
        } //repeat it if it need
    }

    function moveBody() {
        for (var i = length - 1; i != -1; i--) {
            if (i == 0) {
                xX[0] = x0
                yY[0] = y0
            } else {
                xX[i] = xX[i - 1]
                yY[i] = yY[i - 1]
            }
            bodyDrawer.itemAt(i).x = xX[i] * 50 + 100
            bodyDrawer.itemAt(i).y = yY[i] * 50 + 100
            bodyDrawer.itemAt(i).color = "lawngreen"
        }
    }

    function killGame(str) {
        if (str !== "") {
            status.color = "red"
            status.text = "Status: GAME OVER with score " + points
                    + ", because snake " + str + ", ( press G to restart )"
        } else {
            status.text = "Status: NaN  ( press G to start )"
            status.color = "gray"
        }
        ///
        timer.stop()
        time = 1000
        direction = ""
        aX = Math.random() * 13 + 1
        aY = Math.random() * 13 + 1
        console.log("Apple respawn!")
        checkOnfree()
        head.x = 100
        head.y = 100
        isPlayng = false
        length = 1
        if (maxPoints < points) {
            maxPoints = points
        }
        points = 0
        for (var i = 0; i < 35; i++) {
            bodyDrawer.itemAt(i).x = 0 + 100
            bodyDrawer.itemAt(i).y = 0 + 100
            bodyDrawer.itemAt(i).color = "black"
        }
    }
}
