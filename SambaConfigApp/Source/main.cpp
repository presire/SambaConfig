#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QSettings>
#include <QIcon>
#include <QMessageBox>
#include <QLocale>
#include <QTranslator>
#include <iostream>
#include <unistd.h>
#include <pwd.h>
#include "ApplicationState.h"
#include "SambaService.h"
#include "Testparm.h"
#include "FirewalldManager.h"
#include "FileSelectDialog.h"
#include "ValidUserManager.h"
#include "SambaModel.h"
#include "SambaConfigReader.h"


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    // Get the name of the user under which it is running.
    // If it is the root user, display a warning.
#ifdef Q_OS_LINUX
    QString RunUser = "";
    uid_t uid = geteuid();
    struct passwd *pw = getpwuid(uid);

    if (pw) RunUser = QString::fromLocal8Bit(pw->pw_name);  // For local encoding of the system

    if(RunUser.compare("root", Qt::CaseSensitive) == 0) {
        auto ret = QMessageBox(QMessageBox::Warning, QMessageBox::tr("Security Risks"),
                               QMessageBox::tr("Running SambaConfig as root can be dangerous.\nPlease be careful."),
                               QMessageBox::Ok | QMessageBox::Cancel, nullptr).exec();
        if(ret == QMessageBox::Cancel) {
            app.quit();
            return 0;
        }
    }
#endif

    app.setOrganizationName("Presire");
    app.setApplicationName("SambaConfig");

    // QTranslator translator;
    // const QStringList uiLanguages = QLocale::system().uiLanguages();
    // for (const QString &locale : uiLanguages) {
    //     const QString baseName = "SambaConfig_" + QLocale(locale).name();
    //     if (translator.load(":/i18n/" + baseName)) {
    //         app.installTranslator(&translator);
    //         break;
    //     }
    // }

    // Select language.
    QTranslator translator;
    auto iLang = ApplicationState::getInstance().getLanguage();
    if (iLang == 1) {
        QString translationsPath = TRANSLATIONS_DIR;
        QString qmFile = QString("SambaConfig_ja_JP.qm");

        //if (translator.load(":/i18n/SambaConfig_ja_JP.qm")) {
        if (translator.load(qmFile, translationsPath)) {
            app.installTranslator(&translator);
        }
        else {
            std::cerr << QString(QTranslator::tr("Failed to load translation file: %1")).arg(QDir(translationsPath).filePath(qmFile)).toStdString() << std::endl;
        }
    }

    // Set SambaConfig's Icon
    app.setWindowIcon(QIcon(":/DesktopIcon/Image/SambaConfig.png"));

    // Set colour mode
    bool bDarkMode = ApplicationState::getInstance().getColorMode();
    if (bDarkMode) QQuickStyle::setStyle("Material");
    else           QQuickStyle::setStyle("Universal");

    // Define QML engine
    QQmlApplicationEngine engine;

    /// Register singleton instances in QML context
    engine.rootContext()->setContextProperty("ApplicationState",  &ApplicationState::getInstance());
    engine.rootContext()->setContextProperty("SambaService",      &SambaService::getInstance());
    engine.rootContext()->setContextProperty("Testparm",          &Testparm::getInstance());
    engine.rootContext()->setContextProperty("FirewalldManager",  &FirewalldManager::getInstance());
    engine.rootContext()->setContextProperty("fileSelectDialog",  &FileSelectDialog::getInstance());
    engine.rootContext()->setContextProperty("sambaConfigReader", &SambaConfigReader::getInstance());
    engine.rootContext()->setContextProperty("validUserManager",  &ValidUserManager::getInstance());

    // Register the SambaUsersModel as a QML type
    // qmlRegisterType<SambaUsersModel>("SambaUsersModel", 1, 0, "SambaUsersModel");
    // Alternatively, if you want to use it as a singleton:
    // SambaUsersModel *model = new SambaUsersModel(&app);
    // engine.rootContext()->setContextProperty("sambaUsersModel", model);

    // Register the SambaModel as a QML type
    qmlRegisterType<SambaModel>("SambaModel", 1, 0, "SambaModel");

    /// Register Qt version macros in QML context
    engine.rootContext()->setContextProperty("Qt_VERSION_MAJOR", Qt_VERSION_MAJOR);
    engine.rootContext()->setContextProperty("Qt_VERSION_MINOR", Qt_VERSION_MINOR);
    engine.rootContext()->setContextProperty("Qt_VERSION_PATCH", Qt_VERSION_PATCH);

    /// Load main screen
    const QUrl url(QStringLiteral("qrc:/qt/qml/Main/ScreenQML/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    /// Set variables
    const auto &rootObjects = engine.rootObjects();
    if (!rootObjects.isEmpty()) {
        QObject *rootObject = rootObjects.first();

        // Set window x position.
        rootObject->setProperty("x", ApplicationState::getInstance().getMainWindowX());

        // Set window y position.
        rootObject->setProperty("y", ApplicationState::getInstance().getMainWindowY());

        // Set window width.
        rootObject->setProperty("width", ApplicationState::getInstance().getMainWindowWidth());

        // Set window height.
        rootObject->setProperty("height", ApplicationState::getInstance().getMainWindowHeight());

        // Set visibility.
        rootObject->setProperty("visibility", ApplicationState::getInstance().getMainWindowMaximized() ?
                                              "Window.Maximized" : "Window.Windowed");

        // Load font size settings.
        auto fontCheck = ApplicationState::getInstance().getFontSize();
        rootObject->setProperty("fontCheck", fontCheck);

        auto fontPadding = fontCheck == 0 ? -3 : fontCheck == 1 ? 0 : 3;
        rootObject->setProperty("fontPadding", fontPadding);
    }

    return app.exec();
}
