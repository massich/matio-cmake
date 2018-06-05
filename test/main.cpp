#include <iostream>
#include <matio.h>

int main(int argc, char* argv[])
{
    int major, minor, patch;
    Mat_GetLibraryVersion(&major, &minor, &patch);
    std::cout << "Using matio " << major << "." << minor << "." << patch << std::endl;
    return 0;
}

