#include <iostream>
#include "opencv2/core.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/videoio.hpp"

int main()
{
    cv::Mat image;
    cv::VideoCapture vc(0);
    int key = 0;

    while(key != 32)
    {
        vc.read(image);
        if (image.empty())
        {
            continue;
        }
        cv::imshow("window", image);
        key = cv::waitKey(33);
    }
    
    std::cout << "hello world" << std::endl;
    return 0;
}