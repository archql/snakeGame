#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDateTime>
#include <stdio.h>
#include <QString>
#include <QDebug>

#include <qmlstorage.h>

int main(int argc, char *argv[])
{
    qmlRegisterType<QmlStorage>("qmlstorage",1,0,"QmlStorage");

    QGuiApplication a(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return a.exec();
}
