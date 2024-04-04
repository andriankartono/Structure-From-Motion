function GrayImages = images2GrayScale(Images)
%IMAGES2GRAYSCALE Converts the (RGB) images in a containers.Map to gray scale images. 

    %% Input Parser
    p = inputParser;
    p.FunctionName = 'images2GrayScale';
    % required arguments
    addRequired(p, 'Images', @(x) isa(x, 'containers.Map'));
    % parse
    parse(p, Images);

    
    %% Converte RGB Images to GrayScale
    ImageKeys = keys(Images);
    nImages = length(ImageKeys);
    GrayImagesCell = cell(nImages, 1);
    for i = 1:nImages
        GrayImagesCell{i} = rgb2gray(Images(ImageKeys{i}));
    end
    GrayImages = containers.Map(ImageKeys, GrayImagesCell);

end
