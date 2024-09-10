% Example usage of Blink_SDK_C.dll
% Meadowlark Optics Spatial Light Modulators
% last updated: September 10 2020

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
wait_For_Trigger = 0; % hold off on loading an image to the SLM until an external trigger is received; use 1 for 'on' or 0 for 'off'
flip_immediate = 0; % Only supported on the 1024
OutputPulseImageFlip = 0; %generate an output pulse when a new image is loaded to the SLM
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
    
	% set some dimensions
	height = calllib('Blink_C_wrapper', 'Get_image_height', board_number);
    width = calllib('Blink_C_wrapper', 'Get_image_width', board_number);
	depth = calllib('Blink_C_wrapper', 'Get_image_depth', board_number); %bits per pixel
	Bytes = depth/8;
    NumDataPoints = 256;
    NumRegions = 1;
	
    % To measure the raw optical response we want to linearly increment the voltage on the pixels by using a linear LUT
    if width == 1920
		calllib('Blink_C_wrapper', 'Load_LUT_file', board_number, 'C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\1920x1152_linearVoltage.LUT');
    end
    if width == 1024
		calllib('Blink_C_wrapper', 'Load_LUT_file', board_number, 'C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\1024x1024_linearVoltage.LUT');
    end
     
    %allocate arrays for our images
    Image = libpointer('uint8Ptr', zeros(width*height*Bytes,1));
	
	% ***ALWAYS*** use a blank wavefront correction when calibrating a LUT
	WFC = libpointer('uint8Ptr', zeros(width*height*Bytes,1));

    % Create an array to hold measurements from the analog input (AI) board
    AI_Intensities = zeros(NumDataPoints,2);
    
	% begin with the SLM blank
    calllib('Blink_C_wrapper', 'Write_image', board_number, Image, wait_For_Trigger, flip_immediate, OutputPulseImageFlip, timeout_ms);
	calllib('Blink_C_wrapper', 'ImageWriteComplete', board_number, timeout_ms);
	
    % Use a high frequency grating to separate the 0th and 1st orders, a
    % period of 8 is generally good
    PixelsPerStripe = 8;
    
    %When calibrating you write a series of stripes to the SLM. Use the
    %summary below to set the reference, the variable grayscale, and the
    %value you step the variable grayscale by.
    
    %1920x1152, reference = 0, variable = 0 to 255 in steps of +1
    %512x512 8-bit, reference = 255, variable = 255 to 0 in steps of -1
    %512x512 16-bit, reference = 63353, variable = 63353 to 0 in steps of -256
    %1024x1024, reference = 255, variable = 255 to 0 in steps of -1
    Reference = 0;
    Variable = 0;
    StepBy = 1;
    bVertical = 0;
    %loop through each region
    for Region = 0:(NumRegions-1)
      
        AI_Index = 1;
        %loop through each graylevel
        for TestPoint = 0:(NumDataPoints-1)
            %Generate the stripe pattern and mask out current region
            calllib('ImageGen', 'Generate_Stripe', Image, WFC, width, height, depth, Reference, Variable, PixelsPerStripe, bVertical, RGB);
            calllib('ImageGen', 'Mask_Image', Image, width, height, depth, Region, NumRegions, RGB);
            
            %Step the variable grayscale
            Variable = Variable + StepBy;
            
            %write the image
            calllib('Blink_C_wrapper', 'Write_image', board_number, Image, wait_For_Trigger, flip_immediate, OutputPulseImageFlip, timeout_ms);
            
            %let the SLM settle for 10 ms
            pause(0.01);
            
            %YOU FILL IN HERE...FIRST: read from your specific AI board, note it might help to clean up noise to average several readings
            %SECOND: store the measurement in your AI_Intensities array
            AI_Intensities(AI_Index, 1) = TestPoint; %This is the varable graylevel you wrote to collect this data point
            AI_Intensities(AI_Index, 2) = 0; % HERE YOU NEED TO REPLACE 0 with YOUR MEASURED VALUE FROM YOUR ANALOG INPUT BOARD
 
            AI_Index = AI_Index + 1;
        
        end
        
        % dump the AI measurements to a csv file
        filename = ['Raw' num2str(Region) '.csv'];
        csvwrite(filename, AI_Intensities);  
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