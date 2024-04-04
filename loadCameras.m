function Cameras = loadCameras(configFileName)
    %LOADCAMERAS loads the camera parameters (i.e. calibration parameters)
    %from a specified config file. The return value is a map that maps a
    %camera ID to the camera parameters.
    
    
    %% Input Parser
    p = inputParser;
    p.FunctionName = 'loadCameras';
    % required arguments
    addRequired(p,'configFileName', @isTextFile);
    % parse args
    parse(p, configFileName);


    %% get cameras from file
    % open the file
    fid = fopen(configFileName, 'r');

    % prepare variables
    cams = {};
    camIDs = {};
    % read lines and process their content
    line = fgetl(fid);
    while ischar(line)
        % split at every space
        vals = strsplit(line, ' ');
        % process only lines that contain camera parameters
        if vals{1} ~= '#' 
            % the file contains lines with the following values:
            % CAMERA_ID, MODEL, WIDTH, HEIGHT, PARAMS[]
            id = str2double(vals{1});
            cam = struct;
            cam.model = vals{2};
            if strcmp(cam.model, 'PINHOLE')
                % camera parameters: ID, Model, Width, Height, Parameters[]
                % i.e.: 0 PINHOLE 6211 4137 3410.34 3409.98 3121.33 2067.07
                % for a Pinhole camera the parameters are as follows:
                image_size = [str2double(vals{4}), str2double(vals{3})];
                focal_lengths = [str2double(vals{5}), str2double(vals{6})];
                principal_point = [str2double(vals{7}), str2double(vals{8})];
                cam.intrinsics = cameraIntrinsics(focal_lengths, principal_point, image_size);
            elseif strcmp(cam.model, 'THIN_PRISM_FISHEYE')
                % camera parameters: ID, Model, Width, Height, Parameters[] %fx fy cx cy k1 k2 p1 p2 k3 k4 sx1 sy1
                % i.e.: 0 THIN_PRISM_FISHEYE 6048 4032 3408.35 3408.8 3033.92 2019.32 0.21167 0.20864 0.00053 -0.00015 -0.16568 0.4075 0.00048 0.00028
                image_size = [str2double(vals{4}), str2double(vals{3})]; %Height, WIDTH
                focal_lengths = [str2double(vals{5}), str2double(vals{6})]; %fx, sfy
                principal_point = [str2double(vals{7}), str2double(vals{8})]; %cx, cy
                k_coefficients = [str2double(vals{9}), str2double(vals{10}),str2double(vals{13}), str2double(vals{14})]; %k1, k2, k3, k4
                p_coefficients = [str2double(vals{11}), str2double(vals{12})]; %p1, p2
                s_coefficients = [str2double(vals{15}), str2double(vals{16})]; %sx1, sx2
                
                cam.intrinsics = cameraIntrinsics(focal_lengths, principal_point, image_size, k_coefficients, p_coefficients, s_coefficients);

                %for calculation open link below
                %https://github.com/ETH3D/camera-model-implementations/blob/master/matlab-octave/benchmark_camera_model.m

            else
                error('Invalid camera! The camera might not be implemented yet!');
            end
            camIDs{end+1} = id;
            cams{end+1} = cam;
        end
        % read next line
        line = fgetl(fid);
    end

    % close the file
    fclose(fid);


    %% create return value
    Cameras = containers.Map(camIDs, cams);

end
