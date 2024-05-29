% load an image and gives back the xth percentile for each channels
% need bfopen that you can find here 
% https://docs.openmicroscopy.org/bio-formats/5.8.2/users/matlab/index.html

% parameters
whichprctl=[95,99,99.9,100];

%load 1 or more images 
addpath(genpath('/Users/stefanovarani/Documents/MATLAB'));


[figureFiles,figurePath]=uigetfile('*.*','select the first image',MultiSelect='on');

if ischar(figureFiles)
        figureFiles={figureFiles};
end

% allocate a secchio of values
secchioPrctl=[];

% do the things
for iFile=1:size(figureFiles,2)
    figureName=split(figureFiles{iFile},'.');
    figureName=figureName{1};
    img1=bfopen([figurePath,figureFiles{iFile}]);
    img1=img1{1, 1}(:,1);
    % change folder to the folder
    cd (figurePath)
    for ichannels=1:size(img1,1)
        for iprctl=1:size(whichprctl,2)
                secchioPrctl=[secchioPrctl, prctile(img1{ichannels},whichprctl(iprctl),'all')];
        end
    end
end

secchioPrctl=reshape(secchioPrctl,size(img1,1),[]);
