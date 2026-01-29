#include <iostream>
#include <iomanip>
#include <thread>
#include <chrono>

// opencv2
#include <opencv2/opencv.hpp>

// boost
#include <boost/asio.hpp>


using namespace boost::asio;


int main(int argc, char* argv[]) {
    constexpr int WIDTH = 220;
    constexpr int HEIGHT = 220;

    std::string input = argv[1];
    io_service io;
    serial_port serial(io, "/dev/tangnano9k");

    serial.set_option(serial_port_base::baud_rate(115200));
    serial.set_option(serial_port_base::character_size(8));
    serial.set_option(serial_port_base::parity(serial_port_base::parity::none));
    serial.set_option(serial_port_base::stop_bits(serial_port_base::stop_bits::one));

    cv::Mat img = cv::imread(input, cv::IMREAD_COLOR);

    cv::resize(img, img, cv::Size(WIDTH, HEIGHT));

    cv::Mat rgb332(img.rows, img.cols, CV_8UC1);
    for (int y = 0; y < img.rows; y++) {
        for (int x = 0; x < img.cols; x++) {
            cv::Vec3b bgr = img.at<cv::Vec3b>(y, x);
            uint8_t b = bgr[0] >> 6;
            uint8_t g = bgr[1] >> 5;
            uint8_t r = bgr[2] >> 5;
            uint8_t id = (r << 5) | (g << 2) | b;
            rgb332.at<uint8_t>(y, x) = id;
        }
    }
    cv::Mat rgb332_flipped(img.rows, img.cols, CV_8UC1);;
    cv::flip(rgb332, rgb332_flipped, 1); 

    boost::system::error_code ec;

    std::cout << "UART送信開始（総ピクセル: " << rgb332_flipped.total() << "）" << std::endl;

    size_t count = 0;
    size_t totalPixels = rgb332_flipped.total();
    for (int y = 0; y < rgb332_flipped.rows; y++) {
        for (int x = 0; x < rgb332_flipped.cols; x++) {
            uint8_t value = rgb332_flipped.at<uint8_t>(y, x);
            if (value == 0x41) {
                value = 0x42;
            }
            write(serial, buffer(&value, 1), ec);
            if (ec) {
                std::cerr << "送信エラー: " << ec.message() << std::endl;
                return 1;
            }

            std::this_thread::sleep_for(std::chrono::microseconds(200));

            if (++count % 500 == 0) {
                double p = (double)count / (double)totalPixels;
                std::cout << "TX:" << p << std::endl;
            }
        }
    }
    double p = (double)count / (double)totalPixels;
    std::cout << "TX:" << p << std::endl;

    std::cout << "全データ送信完了（" << count << " バイト）" << std::endl;

    uint8_t A = 'A';
    write(serial, buffer(&A, 1), ec);
    write(serial, buffer(&A, 1), ec);
    std::this_thread::sleep_for(std::chrono::milliseconds(100));

    const unsigned char b3to8lookup[8] = { 0, 36, 73, 109, 146, 182, 219, 255 };
    const unsigned char b2to8lookup[8] = { 0, 85, 170, 255 };
    cv::Mat img2(HEIGHT, WIDTH, CV_8UC3);

    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            uint8_t v = rgb332.at<uint8_t>(y, x);
            uint8_t r3 = (v >> 5) & 0x07;
            uint8_t g3 = (v >> 2) & 0x07;
            uint8_t b2 = v & 0x03;

            uint8_t r8 = b3to8lookup[r3];
            uint8_t g8 = b3to8lookup[g3];
            uint8_t b8 = b2to8lookup[b2];

            img2.at<cv::Vec3b>(y, x) = cv::Vec3b(b8, g8, r8);
        }
    }

    cv::imwrite("../tmp/tmp.png", img2);

    return 0;
}
