import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls
//import QtMultimedia
import QtQml 2.0

import qmlstorage 1.0

Window {
    width: 1250
    height: 950
    visible: true
    title: "Snake 1.6.1 debug    Apple update "


    /* This is my version of famous snake game
        Update list:
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

            BUG DETECTTED: change directeon through double change of dir var
        v 1.4.3
            removed change directeon trough double change of dir var
            added arrow controls
        v 1.5.0
            added users system
            added maxPoints saving when die

        v. 1.5.1
            fixed bug with score overwrite when snake dies on account with better max score

        v. 1.6.0 "apples update"
            added 3 new apples:
            - golden apple (+3 points, random lifetime, spawn 35% chanse)
            - time apple (decreases time K by 2 (ignoring first 1k), random lifetime, spawn 20% chanse)
            - wall apple (double random lifetime, spawn 25% chanse, kills snake)
            - fixed speed formula (now 1 + 0.12*eated (apples ang gapples))
         v. 1.6.1
            - fixed strange speed up bug
            ->current version

            known bug: apples overlay!


        PLAN add matrix animation, add userfield console commands (like see top, delete, ...)

    */
    //======= vars
    property int time: 1000 //ms
    property int timeFreezeMS: 10000; //ms
    property int timeInc: 0
    property double timeIncMod: 0.12
    property int timeFreezed: 0 //ms

    property int points: 0
    property int maxPoints: 0
    property string username: "none"
    property bool isPlayng: false

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
        text: "Stats: score - " + points + " / " + maxPoints + " - max score; eated - "+timeInc+"\n dir - "
              + snake.direction + ", length - " + snake.tail.length + ", time K - " + (1000 / time).toFixed(2)+ ", freeze remaining  - "+timeFreezed+" ms"
        font.pointSize: 14
        color: "black"
    }
    Text {
        id: playerText
        x: 650
        y: 50
        text: "Current user: " + username
        font.pointSize: 14
        color: "black"
    }

    Field {
        id: field
        focus: true
        x: 100
        y: 100
        pxWidth: 40

        Snake {
            id: snake
            pxWidth: parent.pxWidth
            maxLength: Math.floor(field.fieldSz.x * field.fieldSz.y * 0.16)
        }

        Item{
            id: fruits
            Fruit {
                id: apple
                pxWidth: field.pxWidth
                price: 1

                property var event: (function() {
                    snake.growth()
                    timeInc++;
                    if (timeFreezed <= 0)
                        time = 1000 / (1 + (timeIncMod * timeInc))
                    else
                        time = 1000 / (1 + (timeIncMod * timeInc) * 0.5)

                    respawn(field.fieldSz, snake.checkOnfree)
                    if (!gapple.alive)
                        gapple.respawn(field.fieldSz, snake.checkOnfree)
                    if (!time_apple.alive)
                        time_apple.respawn(field.fieldSz, snake.checkOnfree)
                    if (!wall_apple.alive)
                        wall_apple.respawn(field.fieldSz, snake.checkOnfree)
                    //fruits.reset(field.fieldSz, snake.checkOnfree)
                })
            }
            Fruit {
                id: gapple
                color: "gold"
                pxWidth: field.pxWidth
                price: 3
                maxLifetime: (field.fieldSz.x + field.fieldSz.y)
                spawnChanse: 35//35

                property var event: (function() {
                    timeInc++;
                    if (timeFreezed <= 0)
                        time = 1000 / (1 + (timeIncMod * timeInc))
                    else
                        time = 1000 / (1 + (timeIncMod * timeInc) * 0.5)

                    respawn(field.fieldSz, snake.checkOnfree)
                })
            }

            Fruit {
                id: time_apple
                color: "violet"
                pxWidth: field.pxWidth
                price: 0
                maxLifetime: (field.fieldSz.x + field.fieldSz.y)
                spawnChanse: 20//35

                property var event: (function() {
                    timeFreezed = timeFreezeMS//ms
                    field.resetOverlay(true, color)

                    time = 1000 / (1 + (timeIncMod * timeInc)*0.5)

                    respawn(field.fieldSz, snake.checkOnfree)
                })
            }

            Fruit {
                id: wall_apple
                color: "black"
                radius: 0
                pxWidth: field.pxWidth
                price: 0
                maxLifetime: (field.fieldSz.x + field.fieldSz.y) * 2
                spawnChanse: 25//15

                property var event: (function() {
                    killGame("bumped in the wall")
                })
            }


            function update() {
                apple.update()
                gapple.update()
                time_apple.update()
                wall_apple.update()
            }

            function checkOnCollision() {
                var get =  {"price": 0};

                if (apple.isCollided(snake.tail[0], get))
                    apple.event()
                if (gapple.isCollided(snake.tail[0], get))
                    gapple.event()
                if (time_apple.isCollided(snake.tail[0], get))
                    time_apple.event()
                if (wall_apple.isCollided(snake.tail[0], get))
                    wall_apple.event()

                update()

                points+=get.price
            }

            function clear() {
                apple.alive = false
                gapple.alive = false
                time_apple.alive = false
                wall_apple.alive = false
            }

            function reset(fieldSz, checkOnfree) {
                apple.respawn(fieldSz, checkOnfree)
                gapple.respawn(fieldSz, checkOnfree)
                time_apple.respawn(fieldSz, checkOnfree)
                wall_apple.respawn(fieldSz, checkOnfree)
            }
        }

        function resetOverlay(enable, color = "violet"){
            overlay.color = color
            if (enable)
                overlay.opacity = 0.15
            overlay.visible = enable
        }
        function animateOverlay(running){
            overlayAnimation.running = running;
        }
        Rectangle {
            id: overlay
            width: parent.pxWidth * parent.fieldSz.x
            height: parent.pxWidth * parent.fieldSz.y
            color: "violet"
            opacity: 0.15
            visible: false

            SequentialAnimation {
                id: overlayAnimation

                        NumberAnimation{ target: overlay ;  properties: "opacity"; from: 0.15; to: 0.03; duration: timeFreezeMS/30}
                        NumberAnimation { target: overlay;  properties: "opacity"; from: 0.03; to: 0.15; duration: timeFreezeMS/30}
                        onStopped: {
                            if (timeFreezed <= 0)
                                stop()
                            console.log("overlayAnimation onStopped ", timeFreezed)
                        }
            }
        }
        //controls
        Keys.onPressed: {
            if (timer.running === true) {
                if ((event.key === Qt.Key_W || event.key === Qt.Key_Up) && snake.direction != "d")
                    snake.tempDirection = "u"
                if ((event.key === Qt.Key_A || event.key === Qt.Key_Left) && snake.direction != "r")
                    snake.tempDirection = "l"
                if ((event.key === Qt.Key_S || event.key === Qt.Key_Down) && snake.direction != "u")
                    snake.tempDirection = "d"
                if ((event.key === Qt.Key_D || event.key === Qt.Key_Right) && snake.direction != "l")
                    snake.tempDirection = "r"
            }
            if (event.key === Qt.Key_P) {
                if (isPlayng) {
                    if (timer.running === true) {
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
                    killGame("")

                    snake.reset(field.fieldSz)
                    fruits.reset(field.fieldSz, snake.checkOnfree)

                    isPlayng = true
                    status.color = "green"
                    status.text = "Status: playing... "

                    timer.start()
                }
            }
        }
    }

    Text {
        id: status
        x: 100
        y: 100 + 600
        text: "Status: None  ( press G to start )"
        font.pointSize: 20
        color: "gray"

    }

    Timer {
        id: timer
        interval: time
        running: false
        repeat: true
        onTriggered: {
            snake.reDraw()
            event()
        }
    }

    function event() {
        fruits.checkOnCollision()

        if (timeFreezed > 0) {
            timeFreezed -= time;
            if (timeFreezed <= 0){
                time = 1000 / (1 + (timeIncMod * timeInc))
                field.animateOverlay(false);
                field.resetOverlay(false);
                timeFreezed = 0
            } else if (timeFreezed < timeFreezeMS/30*7)
                field.animateOverlay(true);
        }
        //console.log("timeFreezed ",timeFreezed)

        if (snake.isCollided(field.fieldSz)) {
            killGame("bumped in the wall")
        } else if (snake.isSelfCollided())
            killGame("bumped in itself")
    }

    function killGame(str) {
        if (str !== "") {
            status.color = "red"
            status.text = "Status: GAME OVER with score " + points
                    + ", because snake " + str + ", ( press G to restart )"

        } else {
            status.text = "Status: None  ( press G to start )"
            status.color = "gray"
        }
        field.animateOverlay(false);
        field.resetOverlay(false);

        snake.clear()
        fruits.clear()
        /// reset time
        timer.stop()
        isPlayng = false
        time = 1000
        timeFreezed = 0
        timeInc = 0

        //save points
        if (maxPoints < points) {
            maxPoints = points

            //log it
            if (username !== "none") {
                var res = [points.toString()]

                //console.log("lll ", res)
                console.log("save? ",storage.write(username, res), " data ",res)
            }
        }
        points = 0
    }
    //filesys
    TextInput {
        id: userField
        font.pixelSize: 23
        x: 650
        y: 70
        width: 300
        height: 25
        maximumLength: 15
        onActiveFocusChanged: {
            temptext.visible = !temptext.visible;
            if (temptext.visible) {
                if (length >= 3) {
                    username = userField.text;

                    console.log("trying to load data...")

                    //reads data here (cr file)
                    if (read()) {
                        temptext.text = "loaded succesfully!"
                        temptext.color = "green"
                    } else {
                        temptext.text = "failed to load data! Creating new user..."
                        temptext.color = "red"
                    }
                }

                text = ""
            }
        }
        onEditingFinished: {
            field.focus = true;
        }

        Text {
            id: temptext
            text: "write username here (Enter to complete)"
            width: parent.width
            height: parent.height
            font.pixelSize: parent.font.pixelSize
        }
    }

    function read(){
        var isSucceed;
        var data = storage.read(username, isSucceed)
        if (data[0] === undefined || typeof(data[0]) == "undefined" || !data[0] ){
            maxPoints = 0
            isSucceed = false
        } else {
            maxPoints = data[0]
            isSucceed = true
        }

        console.log("isSucceed ",isSucceed," data ",data, " username ",username)
        return isSucceed;
    }

    QmlStorage {
        id: storage
        extension: ".rcd"
        path: "data"
    }
}
