//
//:  Blink_SDK_C_wrapper for programming languages that can interface with DLLs
//
//   (c) Copyright Meadowlark Optics 2017, All Rights Reserved.


#ifndef BLINK_C_WRAPPER_H_
#define BLINK_C_WRAPPER_

#ifdef BLINK_C_WRAPPER_EXPORTS
#define BLINK_C_WRAPPER_API __declspec(dllexport)
#else
#define BLINK_C_WRAPPER_API __declspec(dllimport)
#endif


#ifdef __cplusplus
extern "C" { /* using a C++ compiler */
#endif

  BLINK_C_WRAPPER_API void Create_SDK(unsigned int* n_boards_found, int *constructed_ok);

  BLINK_C_WRAPPER_API void Delete_SDK();

  BLINK_C_WRAPPER_API
  const char* Get_last_error_message();

  BLINK_C_WRAPPER_API
  int Load_linear_LUT(int board);

  BLINK_C_WRAPPER_API
  const char* Get_version_info();

  BLINK_C_WRAPPER_API
  int Write_image(int board,
                  unsigned char* image,
                  int wait_for_trigger,
                  int flip_immediate,
                  int output_pulse,
                  unsigned int trigger_timeout_ms);

  BLINK_C_WRAPPER_API int ImageWriteComplete(int board, unsigned int trigger_timeout_ms);

  BLINK_C_WRAPPER_API
  int Load_sequence(int board, 
      unsigned char* image_array,
      int ListLength,
      int wait_for_trigger,
      int flip_immediate,
      int output_pulse,
      unsigned int trigger_timeout_ms);

  BLINK_C_WRAPPER_API 
  int Select_image(int board,
    int frame,
    int wait_for_trigger,
    int flip_immediate,
    int output_pulse,
    unsigned int flip_timeout_ms);

  BLINK_C_WRAPPER_API int Load_LUT_file(int board, char* LUT_file);

  BLINK_C_WRAPPER_API int SetRampDelay(int board, unsigned int ramp_delay);

  BLINK_C_WRAPPER_API int SetPreRampSlope(int board, unsigned int preRampSlope);

  BLINK_C_WRAPPER_API int SetPostRampSlope(int board, unsigned int postRampSlope);

  BLINK_C_WRAPPER_API double Read_SLM_temperature(int board);

  BLINK_C_WRAPPER_API int Get_image_width(int board);

  BLINK_C_WRAPPER_API int Get_image_height(int board);

  BLINK_C_WRAPPER_API int Get_image_depth(int board);

  BLINK_C_WRAPPER_API int Read_Serial_Number(int board);

  BLINK_C_WRAPPER_API double Get_pixel_pitch(int board);

  BLINK_C_WRAPPER_API double Get_cover_voltage(int board);

  BLINK_C_WRAPPER_API int Set_cover_voltage(int board, double Voltage);


#ifdef __cplusplus
}
#endif

#endif //BLINK_C_WRAPPER_