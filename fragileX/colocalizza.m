%{ 
give the number of colocalized staining
need a threshold for what is signal and what not
may need to cluster nearby pixel to a single blob
in this case decide if just one pixel sovrapposition is enough or need more
%}
addpath(genpath('/Users/stefanovarani/Documents/MATLAB'));

%% variables to assign
firstChannel=1; % first channel to compare
secondChannel=2; %second channel to compare
% get aspecific values from negative controls

% get the pixel size of your images and the dimension (es 512x512)
pixelSize=1/5.0487;
% the "background" value to subtract
negCtrl=1;
if ~negCtrl
    % get aspecific values from negative controls
    negCtrlCh1Max=19929;
    negCtrlCh1999prctl=1011;
    negCtrlCh199prctl=609;
    negCtrlCh2Max=1862;
    negCtrlCh2999prctl=888;
    negCtrlCh299prctl=673;
    thresholdFirstChannel=negCtrlCh1999prctl; % for the first channel
thresholdSecondChannel=negCtrlCh2999prctl; % for the second channel
end

%thresholdFirstChannel=negCtrlCh1999prctl; % for the first channel
%thresholdSecondChannel=negCtrlCh2999prctl; % for the second channel

pixelSizeBloob=10;

test=1;



%% import the figures

[figureFiles,figurePath]=uigetfile('*.*','select the first image',MultiSelect='on');

if ischar(figureFiles)
        figureFiles={figureFiles};
end
for iFile=1:size(figureFiles,2)
    
    figureName=split(figureFiles{iFile},'.');
    figureName=figureName{1};
    img1=bfopen([figurePath,figureFiles{iFile}]);
    img1=img1{1, 1}(:,1);
    % change folder to the folder
    %cd (figurePath)
    %get the second figure
    %[figureFile2,figurePath]=uigetfile(,'select the second image');
    %img2=imread([figurePath,figureFile2]);
    
    %% binarize the figures
    %bw1 = imbinarize(img1{firstChannel},thresholdFirstChannel);
    %bw2 = imbinarize(img1{secondChannel},thresholdSecondChannel);
    %alternativa
    bw1=img1{firstChannel}>=thresholdFirstChannel;
    %imshow(bw1)
    %figure
    bw2=img1{secondChannel}>=thresholdSecondChannel ;
    %imshow(bw2)
    %% find the colocalization
    % one possibility is add the two binarized images, set everything below 2
    % to 0 and then everything = 2 to 1
    colocalizedImage=bw1+bw2; % this way colocalized pixel value is 2 (1+1)
    colocalizedImage=colocalizedImage ==2; % binarize the image selecting only coloc pixels
    totalPixelColoc=sum(colocalizedImage,'all'); % get the total number of coloc pixels
    %% calculate some image stuff
    imgAreaMm=size(colocalizedImage,1)*2*pixelSize/1000; % the area of the image in mm
    %% plot the results
    figuraFinale=figure;
    cornice=tiledlayout("horizontal",'TileSpacing','tight','Padding','tight');
    title(cornice,sprintf('%s \n pixel totali colocalizzati %u/%.3f mm^2 ',...
        figureName,totalPixelColoc,imgAreaMm))
    nexttile
    imshow(img1{firstChannel});
    title(sprintf('channel %u',firstChannel));
    nexttile
    imshow(img1{secondChannel});
    title(sprintf('channel %u',secondChannel));
    nexttile
    imshow(colocalizedImage);
    title('colocalized');
    figuraFinale.WindowState="maximized";
    pause(1)
    saveas(figuraFinale,sprintf('%s%s_Colocalization',figurePath,figureName),'png')
    close(figuraFinale)
    % altra cosa da fare, sull'immagine colocalizedImage
    % raggruppare i puncta e analizzare la cross section e il numero
    % Ozlem Bozdagi, Weisong Shan, Hidekazu Tanaka, Deanna L. Benson, George W. Huntley,
    % Increasing Numbers of Synaptic Puncta during Late-Phase LTP: N-Cadherin
    % Is Synthesized, Recruited to Synaptic Sites, and Required for Potentiation,
    % Neuron,
    %% tests
    if negCtrl
        negCtrlCh1Max=max(img1{1},[],'all');
        negCtrlCh1999prctl=prctile(img1{1},99.9,'all');
        negCtrlCh199prctl=prctile(img1{1},99,'all');
        negCtrlCh198prctl=prctile(img1{1},98,'all');
        negCtrlCh197prctl=prctile(img1{1},97,'all');
        negCtrlCh195prctl=prctile(img1{1},95,'all');
        negCtrlCh190prctl=prctile(img1{1},90,'all');

        negCtrlCh2Max=max(img1{2},[],'all');
        negCtrlCh2999prctl=prctile(img1{2},99.9,'all');
        negCtrlCh299prctl=prctile(img1{2},99,'all');
        negCtrlCh298prctl=prctile(img1{2},98,'all');
        negCtrlCh297prctl=prctile(img1{2},97,'all');
        negCtrlCh295prctl=prctile(img1{2},95,'all');
        negCtrlCh290prctl=prctile(img1{2},90,'all');

    end
    if test
        %% elimino le aree composte da < pixelSizeBloob per eliminare noise
        figuraFiltered=figure;
        binaryImage=colocalizedImage;
        %binaryImage= imfill(binaryImage, 'holes');% remove holes inside a box
        connectedComponents = bwconncomp(binaryImage,8);% get connected pixels info
        % remove small areas or single pixels
        imageComponentsStats = regionprops("table",connectedComponents,"Area","BoundingBox");
        selection = (imageComponentsStats.Area >= pixelSizeBloob);% use also "BoundingBox" for better control
        %this is the filtered image
        binaryImageFiltered= cc2bw(connectedComponents,ObjectsToKeep=selection);       
      
        totalPixelColocFiltered=sum(binaryImageFiltered,'all'); % get the total number of coloc pixels
        totalPuncta=sum(imageComponentsStats.Area>pixelSizeBloob);

        imshow(binaryImageFiltered)
        title(sprintf('Filtered %s \n Colocalized Pixel %u/%.3f mm^2 , Number of puncta %u',...
            figureName,totalPixelColocFiltered,imgAreaMm,totalPuncta))
        figuraFiltered.WindowState="maximized";
        pause(1)
        saveas(figuraFiltered,sprintf('%s%s_ColocalizationFiltered',figurePath,figureName),'png')
        close(figuraFiltered)




    end
end