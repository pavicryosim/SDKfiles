//
//:  C++ interface to Blink_SDK DLL.
//
//   (c) Copyright Boulder Nonlinear Systems 2014 - 2014, All Rights Reserved.
//   (c) Copyright Meadowlark Optics 2015-2017, All Rights Reserved.

#ifndef BLINK_SDK_H_
#define BLINK_SDK_H_

#ifdef BLINK_SDK_EXPORTS
#define BLINK_SDK_API __declspec(dllexport)
#else
#define BLINK_SDK_API
#endif

#include <cstddef>
class Blink_SDK_impl;



class BLINK_SDK_API Blink_SDK
{
public:
  Blink_SDK(unsigned int* n_boards_found,
            bool *constructed_ok);
  ~Blink_SDK();

  int Get_image_height(int board) const;
  int Get_image_width(int board) const;
  float Get_pixel_pitch(int board) const;
  bool Is_image_size_supported(int board, int width, int height) const;
  size_t Get_bits_per_pixel() const;
  const char* Get_version_info() const;

  bool Write_image(int board,
      const unsigned char* image,
      bool wait_for_trigger = false,
      bool flip_immediate = false,
      bool output_pulse_image_flip = false,
      unsigned int trigger_timeout_ms = 0.0);
  bool ImageWriteComplete(int board, unsigned int trigger_timeout_ms = 0.0);

  bool Load_sequence(int board,
      const unsigned char* image_array,
      int ListLength,
      bool wait_for_trigger = false,
      bool flip_immediate = false,
      bool output_pulse_image_flip = false,
      unsigned int trigger_timeout_ms = 0.0);

  bool Select_image(int board,
      int frame,
      bool wait_for_trigger = false,
      bool flip_immediate = false,
      bool output_pulse_image_flip = false,
      unsigned int flip_timeout_ms = 0.0);

  bool Load_LUT_file(int board, char* LUT_file);
  bool Load_linear_LUT(int board); // AML properly implement...

  //1920 x 1152 only
  bool SetRampDelay(int board, unsigned int ramp_delay);
  bool SetPreRampSlope(int board, unsigned int preRampSlope);
  bool SetPostRampSlope(int board, unsigned int postRampSlope);

  double Read_SLM_temperature(int board);
  int Read_Serial_Number(int board);
  double Read_cover_voltage(int board);
  bool Set_cover_voltage(int board, double v);

  const char* Get_last_error_message() const;


private:

  Blink_SDK_impl* m_sdk_pimpl;

  // Copy constructor and assignment operator are declared private so that
  // they cannot be used outside the class.
  Blink_SDK(const Blink_SDK& r);
  const Blink_SDK& operator=(const Blink_SDK& r);

}; //lint !e1712  No use for default constructor.

#endif   // #ifndef BLINK_SDK_H_
