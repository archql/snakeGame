#include "qmlstorage.h"

QmlStorage::QmlStorage(QObject *parent) : QObject(parent)
{
    qInfo()<<"QmlStorage: loaded!";
}

QVariantList QmlStorage::read(QString filename, bool isSucceeded)  //isSucceeded -- it should return error code
{
    qInfo()<<"QmlStorage: trying to read a file...";

    QDir dir = QDir::currentPath(); //open dir (trying to create it)
    if (!dir.exists(path))
       dir.mkpath(path);

    qInfo()<<QDir::currentPath() + "/"+ path + "/" + filename + extension;

    QFile file(QDir::currentPath() + "/"+ path + "/" + filename + extension);
    QVariantList res = QVariantList();

    if (!file.open(QIODevice::ReadOnly))
    {
        qWarning()<<"QmlStorage: cant open a file";
        return res; //cant open file
    }

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        res.append(line);
    }
    file.close();

    qInfo()<<"QmlStorage: file readed succesfully";
    return res;
}
bool QmlStorage::write(QString filename, const QVariantList &data)
{
    qInfo()<<"QmlStorage: trying to write to a file...";

    QDir dir = QDir::currentPath(); //open dir (trying to create it)
    if (!dir.exists(path))
       dir.mkpath(path);

    QFile file(QDir::currentPath() + "/"+ path + "/" + filename + extension);

    qInfo()<<QDir::currentPath() + "/"+ path + "/" + filename + extension;

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning()<<"QmlStorage: cant open a file";
        return false; //cant open file
    }

    QTextStream wr(&file); //(write to file)
    for (QVariant line : data)
        wr<<line.toString();
    file.close();

    qInfo()<<"QmlStorage: file writted succesfully";
    return true;
}
