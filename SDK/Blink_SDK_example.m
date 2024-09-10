% Example usage of Blink_C_wrapper.dll
% Meadowlark Optics Spatial Light Modulators
% last updated: Jan. 4, 2024

% Load the DLL
% Blink_C_wrapper.dll, Blink_SDK.dll, ImageGen.dll, FreeImage.dll and wdapi1021.dll
% should all be located in the same directory as the program referencing the
% library
if ~libisloaded('Blink_C_wrapper')
    loadlibrary('Blink_C_wrapper.dll', 'Blink_C_wrapper.h');
end

% This loads the image generation functions
if ~libisloaded('ImageGen')
    loadlibrary('ImageGen.dll', 'ImageGen.h');
end

% Basic parameters for calling Create_SDK
num_boards_found = libpointer('uint32Ptr', 0);
constructed_okay = libpointer('int32Ptr', 0);

wait_For_Trigger = 0; % This feature turns on or off listening for an external trigger, use 1 for 'on' or 0 for 'off'
flip_immediate = 0; % Only supported on the 1024, interrupts an image refresh to start loading new data
OutputPulseImageFlip = 0; % This feature enables the hardware to generate an output pulse when a new image begins loading to the SLM
timeout_ms = 5000;
RGB = 0;

% Call the constructor
calllib('Blink_C_wrapper', 'Create_SDK', num_boards_found, constructed_okay);

% constructed okay return of 1 is success
if constructed_okay.value ~= 1  
    disp(calllib('Blink_C_wrapper', 'Get_last_error_message'));
end

if num_boards_found.value > 0  
    board_number = 1;
    disp('Blink SDK was successfully constructed');
    fprintf('Found %u SLM controller(s)\n', num_boards_found.value);
    
	height = calllib('Blink_C_wrapper', 'Get_image_height', board_number);
    width = calllib('Blink_C_wrapper', 'Get_image_width', board_number);
	depth = calllib('Blink_C_wrapper', 'Get_image_depth', board_number); %bits per pixel
	Bytes = depth/8;
	
    %allocate arrays for our images
	ImageOne = libpointer('uint8Ptr', zeros(width*height*Bytes,1));
    ImageTwo = libpointer('uint8Ptr', zeros(width*height*Bytes,1));
    WFC = libpointer('uint8Ptr', zeros(width*height*Bytes,1));
	
    %***you should replace *_linearVoltage.LUT with your custom LUT file***
	%but for now open a generic LUT that linearly maps input graylevels to output voltages
	%***Using *_linearVoltage.LUT does NOT give a linear phase response***
    if width == 1920
		calllib('Blink_C_wrapper', 'Load_LUT_file', board_number, 'C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\1920x1152_linearVoltage.LUT');
    end
    if width == 1024
		calllib('Blink_C_wrapper', 'Load_LUT_file', board_number, 'C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\1024x1024_linearVoltage.LUT');
    end
    
	% Start the SLM with a blank image
	calllib('Blink_C_wrapper', 'Write_image', board_number, ImageOne, wait_For_Trigger, flip_immediate, OutputPulseImageFlip, timeout_ms);
	calllib('Blink_C_wrapper', 'ImageWriteComplete', board_number, timeout_ms);

    % Generate a fresnel lens
    CenterX = width/2;
    CenterY = height/2;
    Radius = height/2;
    Power = 1;
    cylindrical = true;
    horizontal = false;
    calllib('ImageGen', 'Generate_FresnelLens', ImageOne, WFC, width, height, depth, CenterX, CenterY, Radius, Power, cylindrical, horizontal, RGB);

    % Generate a blazed grating
    Period = 128;
    Increasing = 1;
    calllib('ImageGen', 'Generate_Grating', ImageTwo, WFC, width, height, depth, Period, Increasing, horizontal, RGB);

      
    % Loop between our two images
    for n = 1:5
	
		%write image returns on DMA complete, ImageWriteComplete returns when the hardware
		%image buffer is ready to receive the next image. Breaking this into two functions is 
		%useful for external triggers. It is safe to apply a trigger when Write_image is complete
		%and it is safe to write a new image when ImageWriteComplete returns
        calllib('Blink_C_wrapper', 'Write_image', board_number, ImageOne, wait_For_Trigger, flip_immediate, OutputPulseImageFlip, timeout_ms);
		calllib('Blink_C_wrapper', 'ImageWriteComplete', board_number, timeout_ms);
        pause(1.0) % This is in seconds - IF USING EXTERNAL TRIGGERS, SET THIS TO 0
        calllib('Blink_C_wrapper', 'Write_image', board_number, ImageTwo, wait_For_Trigger, flip_immediate, OutputPulseImageFlip, timeout_ms);
		calllib('Blink_C_wrapper', 'ImageWriteComplete', board_number, timeout_ms);
        pause(1.0) % This is in seconds - IF USING EXTERNAL TRIGGERS, SET THIS TO 0
    end
    
    % Always call Delete_SDK before exiting
    calllib('Blink_C_wrapper', 'Delete_SDK');
end

%destruct
if libisloaded('Blink_C_wrapper')
    unloadlibrary('Blink_C_wrapper');
end

if libisloaded('ImageGen')
    unloadlibrary('ImageGen');
end