mkdir build
cd build

set CMAKE_CONFIG="Release"

cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%CMAKE_CONFIG% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	..
	
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1