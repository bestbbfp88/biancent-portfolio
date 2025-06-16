@echo off

title PERFORMANCE TASK

:Main
cls
COLOR 2
echo Option
echo.
echo 1.) Segregate Files from Downloads
echo 2.) Open Google Classroom
echo 3.) Open Gateway IP Address
echo 4.) Stop Executing
echo.
:C1
set /P input="Choice>> "

if %input%==1 (
     goto Segregate_Downloads
) else if %input%==2 (
    goto Open_Google_class
) else if %input%==3 (
    goto Open_Gateway
) else if %input%==4 (
    exit
) else (
    cls
    echo Your choice is incorrect
    echo Please Try Again...
    echo.
    pause
    goto Main
    )


:Segregate_Downloads
cls
CD C:\Users\Biancent\Downloads
echo Download is now the current Directory
pause
move C:\Users\Biancent\Downloads\*.docx FILES\DocumentFILES
move C:\Users\Biancent\Downloads\*.doc FILES\DocumentFILES
echo ALL Document FILES HAS MOVED TO DocumentFILES FOLDER
pause

move C:\Users\Biancent\Downloads\*.pdf FILES\PDF
echo ALL .PDF FILES HAS MOVED TO PDF FOLDER
pause

move C:\Users\Biancent\Downloads\*.jpg FILES\PICTURES
move C:\Users\Biancent\Downloads\*.jpeg FILES\PICTURES
move C:\Users\Biancent\Downloads\*.png FILES\PICTURES
move C:\Users\Biancent\Downloads\*.gif FILES\PICTURES
echo ALL Picture FILES HAS MOVED TO PICTURES FOLDER
pause

move C:\Users\Biancent\Downloads\*.pptx FILES\PowerpointS
move C:\Users\Biancent\Downloads\*.ppt FILES\PowerpointS
echo ALL Presentation FILES HAS MOVED TO Powerpoints FOLDER
pause

move C:\Users\Biancent\Downloads\*.exe FILES\Application
echo ALL .exe FILES HAS MOVED TO Application FOLDER
pause

move C:\Users\Biancent\Downloads\*.mp4 FILES\Videos
move C:\Users\Biancent\Downloads\*.MOV FILES\Videos
echo ALL Video FILES HAS MOVED TO Videos FOLDER
pause

move C:\Users\Biancent\Downloads\*.mp3 FILES\Music
move C:\Users\Biancent\Downloads\*.wma FILES\Music
move C:\Users\Biancent\Downloads\*.m4a FILES\Music
echo ALL Music FILES HAS MOVED TO Music FOLDER
pause

move C:\Users\Biancent\Downloads\*.zip FILES\zip
move C:\Users\Biancent\Downloads\*.rar FILES\zip
echo ALL ZIP and rar FILES HAS MOVED TO ZIP FOLDER
pause

goto Main

:Open_Google_class
cls
echo Google Classroom is Opening
pause
start chrome https://classroom.google.com/u/0/a/not-turned-in/all
goto Main

:Open_Gateway
cls
echo Gateway Opening
pause
start chrome http://192.168.8.1/html/home.html 
goto Main

