function x = isTextFile(filename)
    %ISTextFILE checks if the file has an image like extension
    %   filename : the path to the file to be checked
    %   rtype : bool
    %   returns true if file exists and text extension else false

    [~,~,extension] = fileparts(filename);
    x = isfile(filename) && strcmpi(extension, '.txt');

end