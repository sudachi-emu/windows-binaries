C:\Qt\5.5\Src\configure -prefix %CD%\output ^
        -debug-and-release -opensource -opengl desktop -mp -c++11 -ltcg ^
        -nomake examples ^
        -skip qtdeclarative -skip qtdoc -skip qtmultimedia ^
        -skip qttools -skip qtwebkit -skip qtwebkit-examples ^
        -skip qtxmlpatterns

nmake
nmake install

del output\bin\*.pdb
del output\lib\*.pdb
REM This library is huge and doesn't seem to be required to compile applications
del output\lib\Qt5Bootstrap.*
