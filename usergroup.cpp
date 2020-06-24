#include "usergroup.h"
#include <QCoreApplication>
#include <QMessageBox>

UserGroup::UserGroup(QObject *parent) : QObject(parent)
{

}

bool UserGroup::pkexec(const QStringList& command, const QByteArray& stdinData)
{
    Q_ASSERT(!command.isEmpty());
    QProcess process;
    qDebug() << command;
    qDebug() << stdinData;
    QStringList args;
    args << QStringLiteral("--disable-internal-agent")
            //        << QStringLiteral("lxqt-admin-user-helper")
         << command;
    process.setReadChannelMode(QProcess::SeparateChannels);
    process.setStandardInputFile("stdin.file");
    process.start(QStringLiteral("pkexec"), args);
    if(!stdinData.isEmpty()) {
        process.waitForStarted();
        process.write(stdinData);
        process.waitForBytesWritten();
        process.closeWriteChannel();
    }
    process.waitForFinished(-1);
    QByteArray pkexec_error = process.readAllStandardError();
    qDebug() << "pkexec_error: " << pkexec_error;
    const bool succeeded = process.exitCode() == 0;
    if (!succeeded)
    {
        QMessageBox * msg = new QMessageBox{QMessageBox::Critical, tr("lxqt-admin-user")
                , tr("<strong>Action (%1) failed:</strong><br/><pre>%2</pre>").arg(command[0], QString::fromUtf8(pkexec_error))};
    msg->setAttribute(Qt::WA_DeleteOnClose, true);
    msg->show();
}
QByteArray res = process.readAllStandardOutput();
qDebug() << "res: " << res;
return succeeded;
}

QString UserGroup::whoAmI()
{
    QProcess process(this);
    process.setProgram("whoami");
    process.start();
    while (process.state() != QProcess::NotRunning)
        QCoreApplication::processEvents();
    QString str = QString(process.readAll());
    return  str.trimmed();
}

int UserGroup::getUID(QString userName)
{
    QProcess process(this);
    process.setProgram("id");
    QStringList args = QStringList{"-u"};
    args.append(userName);
    process.setArguments(args);
    process.start();
    while (process.state() != QProcess::NotRunning)
        QCoreApplication::processEvents();
    QString str = QString(process.readAll());
    qDebug() <<  str.trimmed();
    return 0;
}

QJsonArray UserGroup::getUsers()
{
    QProcess process;
    process.start("cat", QStringList("/etc/passwd"));
    process.waitForStarted(-1);
    while (process.state() != QProcess::NotRunning)
        QCoreApplication::processEvents();
    process.waitForFinished();
    QByteArray errorBytes = process.readAllStandardError();
    if(process.exitStatus() != QProcess::NormalExit){
        qDebug() << "process.readAllStandardError: " << errorBytes;
    }
    QString output = QString(process.readAll());
    QStringList l;
    l = output.split("\n");
    l.removeAll("");
    int len = l.length();
    QJsonArray jArr;
    for (int i=0; i<len; i++) {
        QStringList us = l[i].split(":");
        user sUser = {us[0], us[2].toInt(), us[3].toInt(), us[4], us[5], us[4]};
        if (sUser.UID >= 1000){
            QJsonObject jObj;
            jObj["username"] = sUser.username;
            jObj["UID"] = sUser.UID;
            jObj["GID"] = sUser.GID;
            jObj["userInfo"] = sUser.userInfo;
            jObj["homeDirectory"] = sUser.homeDirectory;
            jObj["command"] = sUser.command;
            jArr.append(jObj);
        }
    }
    return  jArr;
}

QStringList UserGroup::getGroups(QString username)
{qDebug()<< username;
    QProcess process(this);
    QStringList args;
    args << username;
    process.setArguments(args);
    process.start("groups", args);
    while (process.state() != QProcess::NotRunning)
        QCoreApplication::processEvents();
    QString str = QString(process.readAll()).trimmed();
    QStringList grs = str.split(" ");
    grs.removeAt(0);
    grs.removeAt(0);
    return  grs;
}

QStringList UserGroup::getAllGroups()
{
    QProcess process(this);
    process.setProgram("cat");
    QStringList args = QStringList{"/etc/group"};
    process.setArguments(args);
    process.start();
    while (process.state() != QProcess::NotRunning)
        QCoreApplication::processEvents();
    QString str = QString(process.readAll()).trimmed();
    QStringList list = str.split("\n");
    for (int i = 0; i < list.length(); i++){
        list[i] = list[i].split(":").first();
    }
    return list;
}

int UserGroup::updateUserGroups(QString user, QStringList groups)
{
    qDebug() << "updateUserGroups() user, groups: " << user << groups;
    QProcess process(this);
    process.setProgram("pkexec");
    QStringList args = QStringList{"usermod", /*"-a",*/ "-G"};
    QString grps = groups.join(",");
    args.append(grps);
    args.append(user.toUtf8());
    qDebug() << "args" << args;
    process.setArguments(args);
    process.start();
    bool success = process.waitForStarted();
    if (!success)
    {
//            qDebug("waitForStarted() error: %s", process.errorString().toUtf8().constData());
        qDebug() << "waitForStarted() error: " << QString::fromUtf8(process.readAllStandardError().constData());
        return -1;
    }
    while (process.state() != QProcess::NotRunning)
        QCoreApplication::processEvents();
    QString str = QString(process.readAll()).trimmed();
    qDebug() << "updateUserGroups: " << str;
    /*success = */process.waitForFinished();
    if (process.exitStatus() != 0)
    {
        qDebug("exitStatus errorStr: %s", process.errorString().toUtf8().constData());
        qDebug() << "process AllStandardError: " << QString::fromUtf8(process.readAllStandardError().constData());
        return -2;
    }

    //    QStringList list = str.split("\n");
    return 0;
}
