function x = isImageFile(filename)
    %ISIMAGEFILE checks if the file has an image like extension
    %   filename : the path to the file to be checked
    %   rtype : bool
    %   returns true if file exists with image extension else false

    imageExtensions = {'.jpg'; '.jpeg'; '.png'; '.tif'; '.tiff'}; % extend if new image type are used
    [~,~,extension] = fileparts(filename);
    x = isfile(filename) && any(strcmpi(extension, imageExtensions));

end

