@ECHO OFF

::----------------------------------------------------------------------
:: PhpStorm startup script.
::----------------------------------------------------------------------

:: ---------------------------------------------------------------------
:: Locate a JDK installation directory which will be used to run the IDE.
:: Try (in order): WEBIDE_JDK, ..\jre, JDK_HOME, JAVA_HOME.
:: ---------------------------------------------------------------------
IF EXIST "%WEBIDE_JDK%" SET JDK=%WEBIDE_JDK%
IF NOT "%JDK%" == "" GOTO jdk
IF EXIST "%~dp0\..\jre" SET JDK=%~dp0\..\jre
IF NOT "%JDK%" == "" GOTO jdk
IF EXIST "%JDK_HOME%" SET JDK=%JDK_HOME%
IF NOT "%JDK%" == "" GOTO jdk
IF EXIST "%JAVA_HOME%" SET JDK=%JAVA_HOME%
IF "%JDK%" == "" GOTO error

:jdk
SET JAVA_EXE=%JDK%\bin\java.exe
IF NOT EXIST "%JAVA_EXE%" SET JAVA_EXE=%JDK%\jre\bin\java.exe
IF NOT EXIST "%JAVA_EXE%" GOTO error

SET JRE=%JDK%
IF EXIST "%JRE%\jre" SET JRE=%JDK%\jre
SET BITS=
IF EXIST "%JRE%\lib\amd64" SET BITS=64

:: ---------------------------------------------------------------------
:: Ensure IDE_HOME points to the directory where the IDE is installed.
:: ---------------------------------------------------------------------
SET IDE_BIN_DIR=%~dp0
SET IDE_HOME=%IDE_BIN_DIR%\..

SET MAIN_CLASS_NAME=%WEBIDE_MAIN_CLASS_NAME%
IF "%MAIN_CLASS_NAME%" == "" SET MAIN_CLASS_NAME=com.intellij.idea.Main

IF NOT "%WEBIDE_PROPERTIES%" == "" SET IDE_PROPERTIES_PROPERTY="-Didea.properties.file=%WEBIDE_PROPERTIES%"

:: ---------------------------------------------------------------------
:: Collect JVM options and properties.
:: ---------------------------------------------------------------------
SET VM_OPTIONS_FILE=%WEBIDE_VM_OPTIONS%
IF "%VM_OPTIONS_FILE%" == "" SET VM_OPTIONS_FILE=%IDE_BIN_DIR%\PhpStorm%BITS%.exe.vmoptions
SET ACC=
FOR /F "usebackq delims=" %%i IN ("%VM_OPTIONS_FILE%") DO CALL "%IDE_BIN_DIR%\append.bat" "%%i"
IF EXIST "%VM_OPTIONS_FILE%" SET ACC=%ACC% -Djb.vmOptionsFile="%VM_OPTIONS_FILE%"

SET COMMON_JVM_ARGS="-XX:ErrorFile=%USERPROFILE%\java_error_in_WEBIDE_%%p.log" "-Xbootclasspath/a:%IDE_HOME%/lib/boot.jar" -Didea.paths.selector=WebIde80 %IDE_PROPERTIES_PROPERTY%
SET IDE_JVM_ARGS=-Didea.platform.prefix=PhpStorm -Didea.no.jre.check=true
SET ALL_JVM_ARGS=%ACC% %COMMON_JVM_ARGS% %IDE_JVM_ARGS% %REQUIRED_JVM_ARGS%

SET CLASS_PATH=%IDE_HOME%\lib\bootstrap.jar
SET CLASS_PATH=%CLASS_PATH%;%IDE_HOME%\lib\extensions.jar
SET CLASS_PATH=%CLASS_PATH%;%IDE_HOME%\lib\util.jar
SET CLASS_PATH=%CLASS_PATH%;%IDE_HOME%\lib\jdom.jar
SET CLASS_PATH=%CLASS_PATH%;%IDE_HOME%\lib\log4j.jar
SET CLASS_PATH=%CLASS_PATH%;%IDE_HOME%\lib\trove4j.jar
SET CLASS_PATH=%CLASS_PATH%;%IDE_HOME%\lib\jna.jar
IF NOT "%WEBIDE_CLASS_PATH%" == "" SET CLASS_PATH=%CLASS_PATH%;%WEBIDE_CLASS_PATH%

:: ---------------------------------------------------------------------
:: Run the IDE.
:: ---------------------------------------------------------------------
SET OLD_PATH=%PATH%
SET PATH=%IDE_BIN_DIR%;%PATH%

"%JAVA_EXE%" %ALL_JVM_ARGS% -cp "%CLASS_PATH%" %MAIN_CLASS_NAME% %*

SET PATH=%OLD_PATH%
GOTO end

:error
ECHO ERROR: cannot start PhpStorm.
ECHO No JDK found. Please validate either WEBIDE_JDK, JDK_HOME or JAVA_HOME points to valid JDK installation.
ECHO
PAUSE

:end
