function points3D = load3DPoints(configFileName)
    %LOAD3DPOINTS loads the information from a 'points3D.txt' file into a
    %struct that contains all the necessary information.


    %% Input Parser
    p = inputParser;
    p.FunctionName = 'load3DPoints';
    % required arguments
    addRequired(p,'configFileName', @isTextFile);
    % parse args
    parse(p, configFileName);
    
    %% get points from file
    % open the file
    fid = fopen(configFileName, 'r');
    % skip header lines
    header_lines = {};
    line = fgetl(fid);
    while ischar(line) && line(1) == '#'
        header_lines{end + 1} = line;
        line = fgetl(fid);
    end
    % prepare variables
    points3D = struct;
    n_points_str = strsplit(header_lines{3});
    n_points = str2double(n_points_str{5});
    point3DIDs = zeros(1, n_points);
    points3DRaw = zeros(3, n_points);
    colors = zeros(3, n_points);
    errors = zeros(1, n_points);
    imageIDs = cell(1, n_points);
    point2DIndices = cell(1, n_points);
    % extract the data
    % POINT3D_ID, X, Y, Z, R, G, B, ERROR, TRACK[] as (IMAGE_ID, POINT2D_IDX)
    i = 1;
    while ischar(line)
        vals = strsplit(line, ' ');
        points3D.point3DIDs(1, i) = str2double(vals{1});
        points3D.points3DRaw(:, i) = [str2double(vals{2}); str2double(vals{3}); str2double(vals{4})];
        points3D.colors(:, i) = [str2double(vals{5}); str2double(vals{6}); str2double(vals{7})];
        points3D.errors(1, i) = str2double(vals{8});
        points3D.imageIDs{i} = cellfun(@(v) str2double(v), vals(9:2:end));
        points3D.point2DIndices{i} = cellfun(@(v) str2double(v), vals(10:2:end));
        % next line
        i = i + 1;
        line = fgetl(fid);
    end
    % close the file
    fclose(fid);
end
