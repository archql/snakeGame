#ifndef QMLSTORAGE_H
#define QMLSTORAGE_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QList>
#include <QDebug>
#include <QQmlListProperty>

/* Qml Storage version 1.1
 *  - support multiline multitype readwrite system
 *  - custom extension def from qml (format: '.ext')
 *  - choose dir from qml           (format: 'filedir/.../filedir')
 *  - console logs status
 *  - 1.1 v update:
 *  - - fixed bug with dir write failure
 */

class QmlStorage : public QObject
{
    Q_OBJECT
public:
    QmlStorage(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList read(QString filename, bool isSucceded);
    Q_INVOKABLE bool write(QString filename, const QVariantList &data);

    Q_PROPERTY(QString extension MEMBER extension);
    Q_PROPERTY(QString path MEMBER path);

private:
    QString extension = ".txt";
    QString path = "";


};

#endif // QMLSTORAGE_H
