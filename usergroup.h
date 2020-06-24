#ifndef USERGROUP_H
#define USERGROUP_H

#include <QObject>
#include <QProcess>
#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>

class UserGroup : public QObject
{
    Q_OBJECT
public:
    typedef struct{
        QString username;
        int UID;
        int GID;
        QString userInfo;
        QString homeDirectory;
        QString command;
    } user;

    explicit UserGroup(QObject *parent = nullptr);
    bool pkexec(const QStringList& command, const QByteArray& stdinData);
    QString whoAmI();
    int getUID(QString userName);
    Q_INVOKABLE QJsonArray getUsers();
    Q_INVOKABLE QStringList getGroups(QString username);
    Q_INVOKABLE QStringList getAllGroups();
    Q_INVOKABLE int updateUserGroups(QString user, QStringList groups);

signals:

};

#endif // USERGROUP_H
