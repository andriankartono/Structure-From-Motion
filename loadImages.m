function [ImagesDS, Params, orderedKeys, LoadedI] = loadImages(imagePath, ...
    imageConfigFilePath, varargin)
%LOADIMAGES returns a ImageDataStorage and the a map that maps the 
%image path to the image parameters from the specified config file.
%
%Required Arguments:
%  imagePath ............. path to the folder with images
%  imageConfigFilePath ... path to 'images.txt'
%
%Optional Arguments:
%  isDebugFile ........... logical, 'images.txt' has debug parameters if true
%  loadNow ............... logical, images are loaded in this function if true, 
%                          otherwise a imageDatastore is provided
%  imageNames ............ cellstr, if nonempty: only the images with the names 
%                          that are listed in this cell are loaded
%
%Output:
%  ImagesDS ...... imageDatastore, contains all image information to load
%  Params ........ containers.Map, contains additional parameters that are
%                  provided in the config file, i.e. 'images.txt.; 
%                  keys are the image paths that are stored in ImageDS.Files
%  orderedKeys ... ordered cell array with keys for all the other outputs;
%                  the order is specified by the configuration file
%  LoadedI ....... containers.Map, contains all loaded images; 
%                  empty by default or if the flad 'loadNow' is set to false
    
    %% Input Parser
    p = inputParser;
    p.FunctionName = 'loadImages';
    % required arguments
    addRequired(p,'imagePath', @(path) isfolder(path));
    addRequired(p,'imageConfigFilePath', @isTextFile);
    % optional arguments
    addParameter(p, 'isDebugFile', false, ...
        @(x)validateattributes(x, {'logical'}, {'nonempty'}));
    addParameter(p, 'loadNow', false, ...
        @(x)validateattributes(x, {'logical'}, {'nonempty'}));
    addParameter(p, 'imageNames', [], @iscellstr);
    % parse and create variables
    parse(p, imagePath, imageConfigFilePath, varargin{:});    
    isDebugFile = p.Results.isDebugFile; 
    loadNow = p.Results.loadNow;
    imageNames = p.Results.imageNames;


    %% Load Images
    % image data store
    ImagesDS = imageDatastore(imagePath);
    % filter images
    if ~isempty(imageNames)
        indices = contains(ImagesDS.Files, imageNames);
        ImagesDS = subset(ImagesDS, indices);
    end
    % number of images
    nImages = length(ImagesDS.Files);
    % load images if wanted
    LoadedI = containers.Map;
    if loadNow
        for i = 1:nImages
            imageFilePath = ImagesDS.Files{i};
            LoadedI(imageFilePath) = readimage(ImagesDS, i); 
        end
    end

    %% Load Additional Information from Config File
    % read text file
    lines = readlines(imageConfigFilePath);
    % get information from text file
    imageIds = cell(nImages, 1);
    parametersCell = cell(nImages, 1);
    orderedKeys = cell(nImages, 1);
    if isDebugFile
        for i = 1:nImages
            % find line with a specific filename
            [~, name, ext] = fileparts(ImagesDS.Files{i});
            nLine = find(contains(lines, strcat(name, ext)));

            % ordered keys
            orderedKeys{i} = ImagesDS.Files{i};
            
            % extract the information from first line
            % IMAGE_ID, QW, QX, QY, QZ, TX, TY, TZ, CAMERA_ID, NAME
            vals = strsplit(lines(nLine), ' ');
            param = struct;
            % image id
            imageIds{i} = str2double(vals{1});
            % rotation matrix
            param.R = quat2rotm(quaternion( ...
                                    str2double(vals{2}), ...
                                    str2double(vals{3}), ...
                                    str2double(vals{4}), ...
                                    str2double(vals{5})));
            % translation vector 6:8
            param.t = arrayfun(@str2double, reshape(vals(6:8), [3 1]));
            % respective camera ID
            param.camera_id = str2double(vals{9});

            % extract information from second line
            % POINTS2D[] as (X, Y, POINT3D_ID)
            nPoints = length(strsplit(lines(nLine + 1)))/3;
            p = reshape(sscanf(lines(nLine + 1), '%f %f %d'), [3, nPoints]);
            param.point2D = p(1:2, :);
            param.point3DIDs = p(3, :);
            % add parameter to cell
            parametersCell{i} = param;
        end
    else
        for i = 1:nImages
            % find line with a specific filename
            [~, name, ext] = fileparts(ImagesDS.Files{i});
            lineIndex = contains(lines, strcat(name, ext));

            % ordered keys
            orderedKeys{i} = ImagesDS.Files{i};

            % extract the information from the line
            % IMAGE_ID, V1, V2, V3, CAMERA_ID, NAME
            vals = strsplit(lines(lineIndex), ' ');
            param = struct;
            % image id
            imageIds{i} = str2double(vals{1});
            % camera position in world coordinates
            param.camera_position = arrayfun(@str2double, ...
                                        reshape(vals(2:4), [3 1]));
            % respective camera ID
            param.camera_id = str2double(vals{5});

            % add parameter to cell
            parametersCell{i} = param;
        end
    end

    %% create parameters return value as a containers.Map
    Params = containers.Map(ImagesDS.Files, parametersCell);
end
