mkdir build
cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G "Visual Studio 14 2015 Win64" ^
  -DCMAKE_BUILD_TYPE=%CMAKE_CONFIG%         ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%      ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%   ^
  ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
