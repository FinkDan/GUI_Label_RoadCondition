%% Update 04/25/19: Images are not saved in flipped form anymore !!!

function Auto_ExtractFramesVideo()
close all
clear all
clc

%% read files in folder videos

% set path
addpath('data_training')

global frameSaved skipVid labelCnt enableRot autoLabeling rotImg imgCnt Ext ImgShift isVideoFolder DataSetName width rect path Pic Pic_inSq Pic_outSq Pic_wrap img names BeginCut IntervalCut FrameRate EndCut VidObj VidIdx category CropFrame CropPos

% Default interval value to extract video frames
IntervalCut = 2;
ImgShift = 0;
width = 299;
rotImg = 0;
enableRot = 1;
BayerPattern = 0;
autoLabeling = 0;

Asphalt_dry = size(dir([pwd, '\data_training\originalImg\Asphalt_dry']));
Asphalt_wet = size(dir([pwd, '\data_training\originalImg\Asphalt_wet']));
Cobblestone_dry = size(dir([pwd, '\data_training\originalImg\Cobblestone_dry']));
Cobblestone_wet = size(dir([pwd, '\data_training\originalImg\Cobblestone_wet']));
Snow = size(dir([pwd, '\data_training\originalImg\Snow']));

labelCnt.Asphalt_dry = Asphalt_dry(1)-2;
labelCnt.Asphalt_wet = Asphalt_wet(1)-2;
labelCnt.Cobblestone_dry = Cobblestone_dry(1)-2;
labelCnt.Cobblestone_wet = Cobblestone_wet(1)-2;
labelCnt.Snow = Snow(1)-2;

BG_col = [0.9 0.9 0.9];
Start_col = [127 255 148]/255;
Stop_col = [255 127 148]/255;

panelCol = [134 134 134]/255;
CropFig = figure('Position', [600 200 1280 680],...
    'Name',    'GUI zur Extraktion der ROI',...
    'Unit',    'Pixels',...
    'ToolBar', 'none',...
    'MenuBar', 'none',...  
    'Resize',  'off',...
    'WindowKeyPressFcn', @KeyPress,...
    'WindowButtonDownFcn', @MouseClick,...
    'Color', BG_col);

movegui(CropFig,'center')

browseBut= uicontrol('Style', 'pushbutton',...
    'String',   'Browse',...
    'FontSize', 10,...
    'Parent',   CropFig,...
    'Callback', @cb_browse,...
    'Position', [20 620 60 30]);

browseEdit=uicontrol('Style','edit',...
    'Parent',CropFig,...
    'Position',[100 620 880 30],...
    'String', '',...
    'HorizontalAlignment', 'left',...
    'FontSize', 10,...
    'Enable', 'off',...
    'Callback',@setPath);

CropAxes = axes('Parent', CropFig,...
    'Unit', 'Pixels',...
    'Position', [20 20 960 540],...
    'Box', 'on',...
    'XTick', [],...
    'YTick', []);


reshapeTxt = uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 9,...
    'BackgroundColor', BG_col,...
    'HorizontalAlignment', 'center',...
    'Position',[485 561 495 20],...
    'String','');

Cnt_col = [0.75 0.75 0.75];

CntTxt = uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 9,...
    'FontWeight', 'bold',...
    'ForegroundColor', 'w',...
    'BackgroundColor', Cnt_col,...
    'HorizontalAlignment', 'center',...
    'Position',[0 658 1280 20],...
    'String','');

UpdateLabelCnt();

uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 9,...
    'BackgroundColor', panelCol,...
    'HorizontalAlignment', 'left',...
    'Position',[19 560 240 29],...
    'String','');

AutoLabelBut = uicontrol('Style', 'pushbutton',...
    'String',   'START',...
    'FontSize', 10,...%     'BackgroundColor', Start_col,...
    'Parent',   CropFig,...
    'Callback', @cb_autoLabel,...
    'Enable', 'off',...
    'Position', [25 564 60 20]);

uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 10,...
    'ForegroundColor', 'w',...
    'FontWeight', 'bold',...
    'BackgroundColor', panelCol,...
    'HorizontalAlignment', 'left',...
    'Position',[95 562 160 20],...
    'String','AUTOMATED LABELING');

uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 9,...
    'BackgroundColor', panelCol,...
    'HorizontalAlignment', 'left',...
    'Position',[265 560 210 29],...
    'String','');

SkipImgTxt = uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 10,...
    'ForegroundColor', 'w',...
    'FontWeight', 'bold',...
    'BackgroundColor', panelCol,...
    'HorizontalAlignment', 'right',...
    'Position',[270 561 55 20],...
    'String','SKIP');

SkipImgUnit = uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 10,...
    'ForegroundColor', 'w',...
    'FontWeight', 'bold',...
    'BackgroundColor', panelCol,...
    'HorizontalAlignment', 'left',...
    'Position',[385 561 65 20],...
    'String','IMAGES');

SkipImgEdit = uicontrol('Style', 'edit',...
    'Parent', CropFig,...
    'String', num2str(ImgShift),...
    'Position', [330 563 50 20],...
    'Callback', @setImgShift,...
    'Enable', 'off');

ROIAxes = axes('Parent', CropFig,...
    'Unit', 'Pixels',...
    'Position', [1010 350 224 224],...
    'XTick', [],...
    'YTick', [],...
    'Box', 'off',...
    'Color', BG_col);

ROIAxes.XAxis.Visible = 'off';
ROIAxes.YAxis.Visible = 'off';


WrapAxes = axes('Parent', CropFig,...
    'Unit', 'Pixels',...
    'Position', [1010 70 224 224],....
    'Box', 'on',...
    'XTick', [],...
    'YTick', []);


WrapAxes.XAxis.LineWidth= 2;
WrapAxes.YAxis.LineWidth= 2;
WrapAxes.XAxis.Color= 'k';
WrapAxes.YAxis.Color= 'k';

txt = uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 9,...
    'BackgroundColor', BG_col,...
    'HorizontalAlignment', 'left',...
    'Position',[1010 20 242 40],...
    'String','Press ´W´ to skip Image or press ´E´ to');

txt2 = uicontrol('Parent',CropFig,...
    'Style','text',...
    'FontSize', 9,...
    'BackgroundColor', BG_col,...
    'HorizontalAlignment', 'left',...
    'Position',[1010 15 242 20],...
    'String','label current ROI as:');

CatPop = uicontrol('Parent',CropFig,...
    'Style','popupmenu',...
    'HorizontalAlignment', 'left',...
    'Position',[1125 10 127 30],...
    'FontSize',10,...
    'Enable', 'off',...
    'String',{'Asphalt_dry'; 'Asphalt_wet'; 'Cobblestone_dry'; 'Cobblestone_wet'; 'Snow'},...
    'Callback', @selectCategory);


% Default Fahrbahnzustand
category = 'Asphalt_dry';
DataSetName = 'Datensatz_1';
img=[];
im_i= [];
% path = 'X:\public\dcnn_classification\Datensatz\ExtractFramesVideo\videos';
% isVideoFolder = 1;
% startCropping(path, isVideoFolder)


    function startCropping(path)
       
        % Check if Bayer Format (e.g. in RobotCar Dataset)
        if strfind(path,'RobotCar')
            BayerPattern = 1;
        end
        
        % CropFrame= impoly(CropAxes);
        files = dir(path);
        
        % Set default Dataset name
        slash=strfind(path,'/');
        lastSlash=max(slash);
        
        DataSetName = path(lastSlash+1:end);
        DataSetHead = path(lastSlash+1:end);
        
        names = {files.name};
        VidIdx=3;
        
        firstname = names{VidIdx};
        if strcmp(firstname(end-3:end), '.jpg')|| strcmp(firstname(end-3:end), '.png') || strcmp(firstname(end-3:end), 'tiff')
            isVideoFolder = 0;
        else
            isVideoFolder = 1;
        end
        
        
        
        %% ExtractFrames
        
        numOfFiles = size(names);
        browseEdit.String = [path, '/',names{VidIdx}];
                
        if isVideoFolder
            [dum, DataSetName, Ext] = fileparts(names{3});

            
            SkipImgTxt.String = 'FRAME /';
            SkipImgUnit.String = 'second';
            ImgShift = 1;
            SkipImgEdit.String = ImgShift;
            
            if exist([DataSetHead, '_log.txt']) ==2
                
                fid= fopen([DataSetHead, '_log.txt'],'r');
                
                while ~feof(fid)
                    tline = fgetl(fid);
                end
                
                if tline~=-1
                    VidIdx = str2double(tline(1:6))+3;
                else
                    VidIdx =3;
                end
                fclose(fid);
            else
                % Input dataset Name
%                 d = DatasetName();
%                 uiwait;
                VidIdx =3;
            end
            
            if VidIdx >numOfFiles(2)
                reshapeTxt.String = ['Dataset has already been labeled. Again? >> Rename Log-File ( ', 'DataSetName', '_log.txt',' )'];
            end
            
            while VidIdx <=numOfFiles(2)
                cla(ROIAxes)
                cla(WrapAxes)
                cla(CropAxes)
                AutoLabelBut.Enable = 'off';
                autoLabeling=0;
                
                IntervalCut = 2;
                VidObj = VideoReader(names{VidIdx});
                                
                if VidIdx >3
                    [dum, DataSetName, Ext] = fileparts(names{VidIdx});
%                     d = DatasetName();
%                     uiwait;
                end
% ____________________________________________________                
                % Video Cutting (disabled for BDD100k)                
%                 CutFig = openCutGUI();
%                 uiwait;
%                 close(CutFig);
%_____________________________________________________

                hold(CropAxes, 'off')
                
                % new method
                VidObj.CurrentTime = 1;
                Pic = readFrame(VidObj);
                
                % old method
%                 Pic = read(VidObj, round(BeginCut*VidObj.FrameRate));
                
                RotPic = imrotate(Pic, rotImg);
                im_i = image(RotPic, 'Parent', CropAxes);
                                
                CropAxes.XTick = [];
                CropAxes.YTick = [];
                
                enableRot = 1;
                reshapeTxt.String = '|     "R"  -  Rotate Video      |      "S"  -  Skip Video      |      ´Click´ or ´RETURN´  to  Continue      |';
                imgCnt= 0;
                
                skipVid = 0;
                uiwait

                if ~skipVid
                enableRot = 0;
                reshapeTxt.String = ' Select ROI - trapeze with 5 clicks  (  Start bottom left  |   Close ROI with last click  )';
                CropFrame = impoly(CropAxes);
                CropPos=getPosition(CropFrame);
                addNewPositionCallback(CropFrame, @NewCropPos);
                
                reshapeFrame();
                reshapeTxt.String = '|          ´SPACE´  -  Parallelize ROI                 |                   "S"  -  Skip Video              |';
                hold(CropAxes, 'on')
                
                NewCropPos('','')
                plotROI(ROIAxes,BG_col)
                
                % Enable Fields
                SkipImgEdit.Enable = 'on';
%                 browseEdit.Enable = 'on';
                CatPop.Enable = 'on';
                
                
                %% ExtractFrames
                % Create an object to read the sample file
                VidObj = VideoReader(names{VidIdx});
                
%                 img = (BeginCut*VidObj.FrameRate-1)+1;
                
                img = 1;
                VidObj.CurrentTime = img;
                
                % Old method
%                 while img <= EndCut*VidObj.FrameRate
                AutoLabelBut.Enable = 'on';
                while img < VidObj.Duration

                    VidObj.CurrentTime = img;
                    Pic = readFrame(VidObj);
                    
                    RotPic = imrotate(Pic, rotImg);
                    
                    % Old access method
%                     Pic = read(VidObj, round(img));
                    
                    delete(im_i)
                    delete(rect)
                    
                    im_i=image(RotPic, 'Parent', CropAxes);
                    
                    CropAxes.XTick = [];
                    CropAxes.YTick = [];
                    
%                     CropAxes.DataAspectRatioMode = 'manual';
                    
                    
                    h=CropAxes.Children;
                    CropAxes.Children = [h(2) h(1)];
                    %     CropFrame = impoly(CropAxes, CropPos);
                    
                    NewCropPos('','')
                    plotROI(ROIAxes,BG_col)
                    
                    fixedPoints = [1 width; 1 1; width 1; width width];
                    
                    movingPoints = CropPos;
                    tform = fitgeotrans(movingPoints, fixedPoints, 'Projective');
                    
                    RA = imref2d([width width], [1 width], [1 width]);
                    [Pic_wrap,r] = imwarp(Pic, tform, 'OutputView', RA);
                    
                    if ~autoLabeling
                        uiwait(gcf)
                    else
                        if ~enableRot
                            WrapAxes.XAxis.Color= 'g';
                            WrapAxes.YAxis.Color= 'g';
                            CropPos = getPosition(CropFrame);
                            
                            RotPic = imrotate(Pic, rotImg);
                            saveImage(RotPic,CropPos)
                            
                            WrapAxes.XAxis.Color= 'k';
                            WrapAxes.YAxis.Color= 'k';
                            
                            frameSaved = 1;
                        end
                    end
                    
                    if ~skipVid                   
                        img = img+ImgShift;
                    else
                        break;
                    end
                end
                
                end

                fid= fopen([DataSetHead, '_log.txt'],'a');
                fprintf(fid,'%6.0f %30s %3.0f %9s\r\n', VidIdx-2, [DataSetName, Ext], imgCnt, ' Frames processed');
                
                fclose(fid);
                
                delete(CropAxes)
                CropAxes = axes('Parent', CropFig,...
                    'Unit', 'Pixels',...
                    'Position', [20 20 960 540],...
                    'Box', 'on',...
                    'XTick', [],...
                    'YTick', []);
                
                VidIdx=VidIdx+1;
            end
            
            
            
            % Disable Fields
            ImgShift = 1;
            SkipImgEdit.String = num2str(ImgShift);
            
            % Disable Fields
            SkipImgEdit.Enable = 'off';
            browseEdit.Enable = 'off';
            CatPop.Enable = 'off';
        
            
        
        else % Image folder
            enableRot = 0;
            rotImg = 0;
            
            %% Work On : Log file bei Bilddatensätzen
            
            if exist([DataSetName, '_log.txt']) ==2
                
                fid= fopen([DataSetName, '_log.txt'],'r');
                
                while ~feof(fid)
                    tline = fgetl(fid);
                end
                
                if tline~=-1
                    VidIdx = str2double(tline(1:6))+3;
                else
                    VidIdx =3;
                end
                fclose(fid);
            else
                % Input dataset Name
                %                 d = DatasetName();
                %                 uiwait;
                VidIdx =3;
            end
            
            SkipImgTxt.String = 'Skip';
            SkipImgUnit.String = 'Images';
            ImgShift = 0;
            SkipImgEdit.String = ImgShift;
            
            if VidIdx >numOfFiles(2)
                reshapeTxt.String = ['Dataset has already been labeled. Again? >> Rename Log-File ( ', 'DataSetName', '_log.txt',' )'];
            end
            
            
            while VidIdx <=numOfFiles(2)
                %                 [path,'\',names{VidIdx}]
                delete(im_i)              
                
                
                if BayerPattern
                    Pic= demosaic(imread(names{VidIdx}), 'gbrg');
                else
                    Pic= imread(names{VidIdx});
                end
                
                img=VidIdx-2;
                im_i=image(Pic, 'Parent', CropAxes);
                
                CropAxes.XTick = [];
                CropAxes.YTick = [];
                
                CropAxes.DataAspectRatioMode = 'manual';

%                 if VidIdx == 3 
                if  numel(CropAxes.Children) == 1
                    CropFrame = impoly(CropAxes);
                    CropPos=getPosition(CropFrame);
                    addNewPositionCallback(CropFrame, @NewCropPos);
                    reshapeFrame();
                    hold(CropAxes, 'on')
                else
                        h=CropAxes.Children;
                        CropAxes.Children = [h(3) h(2) h(1)];
                end
                
                NewCropPos('','')
                plotROI(ROIAxes,BG_col)
                CropPos=getPosition(CropFrame);
                
                
                AutoLabelBut.Enable = 'on';
                SkipImgEdit.Enable = 'on';
                CatPop.Enable = 'on';
                frameSaved = [];
                
                
                if ~autoLabeling
                    uiwait(gcf)
                else
                    pause(0.001)
                    if ~enableRot
                        WrapAxes.XAxis.Color= 'g';
                        WrapAxes.YAxis.Color= 'g';
                        CropPos = getPosition(CropFrame);
                        
                        RotPic = imrotate(Pic, rotImg);
                        saveImage(RotPic,CropPos)
                        
                        WrapAxes.XAxis.Color= 'k';
                        WrapAxes.YAxis.Color= 'k';
                        
                        frameSaved = 1;
                    end
                end
                
                
                fid= fopen([DataSetName, '_log.txt'],'a');
                if ~isempty(frameSaved)
                    fprintf(fid,'%6.0f %30s %6.0f\r\n', VidIdx-2, names{VidIdx}, frameSaved);
                end
                fclose(fid);
                VidIdx = VidIdx+1+ImgShift;
                
            end
            
%             CropAxes.DataAspectRatioMode = 'manual';
            %             daspect(CropAxes, 'auto')
            %             CropAxes.DataAspectRatio
            
            delete(CropAxes)
            CropAxes = axes('Parent', CropFig,...
                'Unit', 'Pixels',...
                'Position', [20 20 960 540],...
                'Box', 'on',...
                'XTick', [],...
                'YTick', []);
            
            
            % Disable Fields
            ImgShift = 0;
            SkipImgEdit.String = num2str(ImgShift);
            SkipImgEdit.Enable = 'off';
            browseEdit.Enable = 'off';
            CatPop.Enable = 'off';
        end
        
        cla(ROIAxes)
        cla(WrapAxes)
        cla(CropAxes)
        
        browseEdit.String = '';
        
    end


% imcrop(b,rect)
%
% ImageStruct(1:(EndCut-BeginCut)/IntervalCut)=struct('Image', []);

% Create an axes. Then, read video frames until no more frames are available to read.
% currAxes = axes;
% % vidFrame=zeros(1);
% i=1;j=1;
% while hasFrame(xyloObj)
%     vidFrame = readFrame(xyloObj);
%     image(vidFrame, 'Parent', currAxes);
%     currAxes.Visible = 'off';
%     pause(1/xyloObj.FrameRate);
%
%     if i>=BeginCut*FrameRate && i<=EndCut*FrameRate && i==IntervalCut*FrameRate
%     ImageStruct(j)=vidFrame;
%     j=j+1;
%     end
%     i=i+1;
% end
%
%
% % for i=BeginCut*FrameRate:IntervalCut*FrameRate:EndCut*FrameRate
% %     vidFrame = readFrame(xyloObj);
% %     image(vidFrame, 'Parent', currAxes);
% %     imwrite(A,filename)
% %     currAxes.Visible = 'off';
% %     pause(1/xyloObj.FrameRate);
% % end
%
% % vidWidth = xyloObj.Width;
% vidHeight = xyloObj.Height;

    function CutFig = openCutGUI()
        CutFig = figure('Position', [600 200 1150 600],...
            'Unit', 'Pixels',...
            'ToolBar','none',...
            'MenuBar','none',...
            'Resize','off');
        
        movegui(CutFig,'center')
        
        axStart = axes(CutFig,...
            'Unit', 'Pixels',...
            'Position', [50 50 500 350],...
            'XTick',[],...
            'YTick',[],...
            'Box', 'On');
        
        axEnd = axes(CutFig,...
            'Unit', 'Pixels',...
            'Position', [600 50 500 350],...
            'XTick',[],...
            'YTick',[],...
            'Box', 'on');
        
        % Editfield to set interval to cut videos
        intEdit = uicontrol('Style', 'edit',...
            'Parent', CutFig,...
            'String', num2str(IntervalCut),...
            'Position', [50 520 50 20],...
            'Callback', @setInterval);
        
        % Start slider
        sliderStart = uicontrol('Style', 'slider',...
            'Parent', CutFig,...
            'Min',1,'Max',50,'Value',41,...
            'Position', [100 480 1000 20],...
            'Callback', @selectStart);
        
        % Start slider
        sliderEnd = uicontrol('Style', 'slider',...
            'Parent', CutFig,...
            'Min',1,'Max',50,'Value',41,...
            'Position', [100 430 1000 20],...
            'Callback', @selectEnd);
        
        
        startCrop = uicontrol('Parent',CutFig,...
            'Position',[260 20 70 25],...
            'String','Weiter',...
            'Callback','uiresume(gcbf)');
        
        BeginCut = 1;
        FrameRate = VidObj.FrameRate;
        EndCut = round(VidObj.Duration-.5);
        
        setSlider(sliderStart, BeginCut, BeginCut, EndCut);
        setSlider(sliderEnd, EndCut, BeginCut, EndCut);
        VidObj
        
        loadFrame(axStart, VidObj, BeginCut)
        loadFrame(axEnd, VidObj, EndCut)
        
        function selectStart(hObj, event)
            BeginCut=hObj.Value;
            if BeginCut > EndCut & BeginCut < hObj.Max-IntervalCut
                EndCut= BeginCut+IntervalCut;
                sliderEnd = setSlider(sliderEnd, EndCut);
                loadFrame(axEnd, VidObj, EndCut)
            elseif BeginCut > EndCut-IntervalCut & BeginCut < EndCut+IntervalCut
                BeginCut= BeginCut-IntervalCut;
                sliderStart = setSlider(sliderStart, BeginCut);
                loadFrame(axStart, VidObj, BeginCut)
            elseif BeginCut > hObj.Max-IntervalCut
                BeginCut = hObj.Max-IntervalCut;
                EndCut   = hObj.Max;
                sliderStart = setSlider(sliderStart, BeginCut);
                sliderEnd = setSlider(sliderEnd, EndCut);
            end
            loadFrame(axStart, VidObj, BeginCut)
        end
        
        function selectEnd(hObj, event)
            EndCut=hObj.Value;
            if EndCut < BeginCut & EndCut > hObj.Min+IntervalCut
                BeginCut= EndCut-IntervalCut;
                sliderStart = setSlider(sliderStart, BeginCut);
                loadFrame(axStart, VidObj, BeginCut)
            elseif EndCut > BeginCut-IntervalCut & EndCut < BeginCut+IntervalCut
                EndCut = BeginCut + IntervalCut;
                sliderEnd = setSlider(sliderEnd, EndCut);
                loadFrame(axEnd, VidObj, EndCut)
            elseif EndCut < hObj.Min+IntervalCut
                EndCut = hObj.Min+IntervalCut;
                BeginCut = hObj.Min;
                sliderStart = setSlider(sliderStart, BeginCut);
                sliderEnd = setSlider(sliderEnd, EndCut);
            end
            loadFrame(axEnd, VidObj, EndCut)
        end
        
        
        function loadFrame(axes, hVid, idx)
            if idx == 0
                startIm = read(hVid, 1);
            else
                round(idx*hVid.FrameRate)
                startIm = read(hVid, round(idx*hVid.FrameRate));
            end
            
            image(startIm, 'Parent', axes);
            axes.XTick = [];
            axes.YTick = [];
        end
    end

    function reshapeFrame()
        CropPos = getPosition(CropFrame);
        
        CropPos(1,2) = max(CropPos(1,2), CropPos(4,2));
        CropPos(4,2) = max(CropPos(1,2), CropPos(4,2));
        
        CropPos(2,2) = min(CropPos(2,2), CropPos(3,2));
        CropPos(3,2) = min(CropPos(2,2), CropPos(3,2));
        delete(CropFrame)
        CropFrame = impoly(CropAxes, CropPos);
        addNewPositionCallback(CropFrame, @NewCropPos);
        NewCropPos('','');
    end

    function NewCropPos(hObj, event)
        
        CropPos = getPosition(CropFrame);

        plotROI(ROIAxes,BG_col)
        
        movingPoints = CropPos;
        
        fixedPoints = [1 width; 1 1; width 1; width width];
        
        tform = fitgeotrans(movingPoints, fixedPoints, 'Projective');
        
        RA = imref2d([width width], [1 width], [1 width]);
        
        RotPic = imrotate(Pic, rotImg);
        [wrapedIm,r] = imwarp(RotPic, tform, 'OutputView', RA);
        
        image(wrapedIm, 'Parent', WrapAxes);
        WrapAxes.XTick = [];
        WrapAxes.YTick = [];
        WrapAxes.XAxis.LineWidth= 2;
        WrapAxes.YAxis.LineWidth= 2;
        WrapAxes.XAxis.Color= 'k';
        WrapAxes.YAxis.Color= 'k';
        
        m = (CropPos(2,1)-CropPos(1,1))/(CropPos(2,2)-CropPos(1,2));
        n = (CropPos(4,1)-CropPos(3,1))/(CropPos(4,2)-CropPos(3,2));
        
        k = CropPos(1,1)-m*CropPos(1,2);
        p = CropPos(3,1)-n*CropPos(3,2);
        
        M=[ 1  0 -1  0  0  0  0  0;
            0  1  0  0  0  0  0  0;
            0  1  0  0  0  0  0 -1;
            0  0  0 -1  0  1  0  0;
            0  0  0  0 -1  0  1  0;
            0 -1 -1  1  1  0  0  0;
            0  0  1 -m  0  0  0  0;
            0  0  0  0  1 -n  0  0];
        
        t = [0; CropPos(1,2); 0; 0; 0; 0; k; p];
        
        Sq_vec=inv(M)*t;
        
        if Sq_vec(4)<CropPos(2,2) || Sq_vec(4)<CropPos(3,2)
            
            
            a= min(CropPos(1,2),CropPos(1,2))-max(CropPos(2,2),CropPos(3,2));
            Sq_vec(1)=(CropPos(3,1)+CropPos(2,1)-a)/2;
            Sq_vec(2)=CropPos(1,2);
            Sq_vec(3)= Sq_vec(1);
            Sq_vec(4)=Sq_vec(2)-a;
            Sq_vec(5)=Sq_vec(3)+a;
            Sq_vec(6)=Sq_vec(4);
            Sq_vec(7)=Sq_vec(5);
            Sq_vec(8)=Sq_vec(6)+a;
            
            Sq = [(Sq_vec(5)+Sq_vec(3)-a)/2, Sq_vec(4), a,a];
        else
            Sq = [Sq_vec(3), Sq_vec(4), Sq_vec(8)-Sq_vec(4), Sq_vec(7)-Sq_vec(3)];
            
        end
        delete(rect)
        rect = rectangle('Position',Sq, 'EdgeColor', [0 0 1]);
                
    end

    function UpdateLabelCnt()
        CntTxtStr = ['  Asphalt (dry):  '    , num2str(labelCnt.Asphalt_dry),      '                         |                          ',...
             'Asphalt (wet):  '      , num2str(labelCnt.Asphalt_wet),      '                         |                          ',...
             'Cobblestone (dry):  '  , num2str(labelCnt.Cobblestone_dry),  '                         |                          ',...
             'Cobblestone (wet):  '  , num2str(labelCnt.Cobblestone_wet),  '                         |                          ',...
             'Snow:  '               , num2str(labelCnt.Snow)];
        CntTxt.String = CntTxtStr; 
    end

    function MouseClick(hObj, event)
        if enableRot
            uiresume(gcbf)
        end
    end
    function KeyPress(hObj, event)
        
        key = event.Key;

        switch 1
            case strcmp(key, 's')
                if isVideoFolder
                    skipVid = 1;
                    uiresume(gcbf)
                end
            case strcmp(key, 'e')
                if ~enableRot
                WrapAxes.XAxis.Color= 'g';
                WrapAxes.YAxis.Color= 'g';
                pause(0.01)
                CropPos = getPosition(CropFrame);
                
                RotPic = imrotate(Pic, rotImg);
                saveImage(RotPic,CropPos)
                
                WrapAxes.XAxis.Color= 'k';
                WrapAxes.YAxis.Color= 'k';
                
                frameSaved = 1;
                
                uiresume(gcbf)
                end
            case strcmp(key, 'w')
                if ~enableRot
                WrapAxes.XAxis.Color= 'r';
                WrapAxes.YAxis.Color= 'r';
                pause(0.01)
                WrapAxes.XAxis.Color= 'k';
                WrapAxes.YAxis.Color= 'k';
                
                
                frameSaved = 0;
                uiresume(gcbf)
                end
                
            case strcmp(key, 'r')
                if enableRot
                    rotImg = rotImg+90;
                    RotPic = imrotate(Pic, rotImg);
                    im_i = image(RotPic, 'Parent', CropAxes);
                    CropAxes.XTick = [];
                    CropAxes.YTick = [];
                end
            case strcmp(key, 'return')
                if enableRot
                    uiresume(gcbf)
                end
            case strcmp(key, 'f1')
                CatPop.Value=1;
                category = CatPop.String{1};
            case strcmp(key, 'f2')
                CatPop.Value=2;
                category = CatPop.String{2};
            case strcmp(key, 'f3')
                CatPop.Value=3;
                category = CatPop.String{3};
            case strcmp(key, 'f4')
                CatPop.Value=4;
                category = CatPop.String{4};
            case strcmp(key, 'f5')
                CatPop.Value=5;
                category = CatPop.String{5};
            case strcmp(key, 'space')
                reshapeFrame();
        end
    end

    function plotROI(ax,FBC)
        ROI_mask = createMask(CropFrame);
        
        maxXY = max(CropPos);
        minXY = min(CropPos);
        RotPic = imrotate(Pic, rotImg);
        a=double(RotPic);
        
        c(:,:,1)=a(:,:,1).*ROI_mask+(ROI_mask-ones(size(ROI_mask)))*FBC(1)*255*(-1);
        c(:,:,2)=a(:,:,2).*ROI_mask+(ROI_mask-ones(size(ROI_mask)))*FBC(1)*255*(-1);
        c(:,:,3)=a(:,:,3).*ROI_mask+(ROI_mask-ones(size(ROI_mask)))*FBC(1)*255*(-1);
        
        
        ax.Position(4)=224*(maxXY(2)-minXY(2))/(maxXY(1)-minXY(1));
        c=c(round(minXY(2):maxXY(2)),round(minXY(1):maxXY(1)),:);
        c=c/255;
        
        image(c, 'Parent', ax);
        
        ax.XTick = [];
        ax.YTick = [];
        ax.Box = 'off';
        ax.XAxis.Visible = 'off';
        ax.YAxis.Visible = 'off';
    end

    function hSlider = setSlider(hSlider, varargin)
        if length(varargin) > 2
            hSlider.Min = varargin{2};
            hSlider.Max = varargin{3};
        end
        hSlider.Value = varargin{1};
        
        hSlider.SliderStep = [IntervalCut/(hSlider.Max-hSlider.Min), IntervalCut/(hSlider.Max-hSlider.Min)];
    end

%%
    function saveImage(Pic, CropPos)
        %         name=names{1,VidIdx};
        %         name=name(1:end-4);
        
        
        if isVideoFolder
            imgNum = round(10*img);
            name = DataSetName;
        else
            imgNum = [];
            name = names{VidIdx};
        end
        
        % Update 04/25/19: Images are not saved in flipped form anymore !!!
        
        filenameImg=strcat(pwd,'\data_training\originalImg\',category, '\',name,'_',num2str(imgNum),'.jpg');
        
        filenameW=strcat(pwd,'\data_training\warpedROI\',category, '\',name,'_',num2str(imgNum),'.jpg');
        filenameWf=strcat(pwd,'\data_training\warpedROI\',category, '\',name,'_',num2str(imgNum),'f','.jpg'); %defined but unused
        
        filenameO=strcat(pwd,'\data_training\outerBox\',category, '\',name,'_',num2str(imgNum),'.jpg');
        filenameOf=strcat(pwd,'\data_training\outerBox\',category, '\',name,'_',num2str(imgNum),'f','.jpg'); %defined but unused
        
        filenameI=strcat(pwd,'\data_training\innerBox\',category, '\',name,'_',num2str(imgNum),'.jpg');
        filenameIf=strcat(pwd,'\data_training\innerBox\',category, '\',name,'_',num2str(imgNum),'f','.jpg'); %defined but unused
        
        % Adapt paths for Linux distubutions 
        idx=strfind(filenameImg,'\');
        filenameImg(idx) = '/';
        
        idx=strfind(filenameW,'\');
        filenameW(idx) = '/';
        idx=strfind(filenameWf,'\');
        filenameWf(idx) = '/';
        
        idx=strfind(filenameO,'\');
        filenameO(idx) = '/';
        idx=strfind(filenameOf,'\');
        filenameOf(idx) = '/';
        
        idx=strfind(filenameI,'\');
        filenameI(idx) = '/';
        idx=strfind(filenameIf,'\');
        filenameIf(idx) = '/';
        
        
        % Save original Image
        imwrite(Pic,filenameImg);
        
        % Crop ROI and save Image
        movingPoints = CropPos;
        
        fixedPoints = [1 width; 1 1; width 1; width width];
        
        tform = fitgeotrans(movingPoints, fixedPoints, 'Projective');
        
        RA = imref2d([width width], [1 width], [1 width]);
        [warpedIm,r] = imwarp(Pic, tform, 'OutputView', RA);
        
        imwrite(warpedIm,filenameW);
%         imwrite(fliplr(warpedIm),filenameWf);
        
        outerColor = [0 0 0]; %RGB
        a = [];
        a=double(Pic);
        ROI_mask = createMask(CropFrame);
        maxXY = max(CropPos);
        minXY = min(CropPos);
        
        outSq = [];
        outSq(:,:,1)=a(:,:,1).*ROI_mask+(ROI_mask-ones(size(ROI_mask)))*outerColor(1)*255*(-1);
        outSq(:,:,2)=a(:,:,2).*ROI_mask+(ROI_mask-ones(size(ROI_mask)))*outerColor(1)*255*(-1);
        outSq(:,:,3)=a(:,:,2).*ROI_mask+(ROI_mask-ones(size(ROI_mask)))*outerColor(1)*255*(-1);
        outSq = outSq/255;
        outSq=outSq(round(minXY(2):maxXY(2)),round(minXY(1):maxXY(1)),:);
        
        sz_outSq = size(outSq);
        
        outSq_pt = [sz_outSq(2) sz_outSq(1);
            sz_outSq(2)           1;
            1            1;
            1  sz_outSq(1)];
        
        tform = fitgeotrans(outSq_pt, fixedPoints, 'Projective');
        
        RA = imref2d([width width], [1 width], [1 width]);
        [Pic_outSq,r] = imwarp(outSq, tform, 'OutputView', RA);
        
        imwrite(Pic_outSq,filenameO);
%         imwrite(fliplr(Pic_outSq),filenameOf);
        
        % Quadrat in Trapez fitten
        m = (CropPos(2,1)-CropPos(1,1))/(CropPos(2,2)-CropPos(1,2));
        n = (CropPos(4,1)-CropPos(3,1))/(CropPos(4,2)-CropPos(3,2));
        
        k = CropPos(1,1)-m*CropPos(1,2);
        p = CropPos(3,1)-n*CropPos(3,2);
        
        M= [1  0 -1  0  0  0  0  0;
            0  1  0  0  0  0  0  0;
            0  1  0  0  0  0  0 -1;
            0  0  0 -1  0  1  0  0;
            0  0  0  0 -1  0  1  0;
            0 -1 -1  1  1  0  0  0;
            0  0  1 -m  0  0  0  0;
            0  0  0  0  1 -n  0  0];
        
        t = [0; CropPos(1,2); 0; 0; 0; 0; k; p];
        
        Sq_vec=inv(M)*t;
        
        if Sq_vec(4)<CropPos(2,2) || Sq_vec(4)<CropPos(3,2)
            
            a= min(CropPos(1,2),CropPos(1,2))-max(CropPos(2,2),CropPos(3,2));
            Sq_vec(1)=(CropPos(3,1)+CropPos(2,1)-a)/2;
            Sq_vec(2)=CropPos(1,2);
            Sq_vec(3)= Sq_vec(1);
            Sq_vec(4)=Sq_vec(2)-a;
            Sq_vec(5)=Sq_vec(3)+a;
            Sq_vec(6)=Sq_vec(4);
            Sq_vec(7)=Sq_vec(5);
            Sq_vec(8)=Sq_vec(6)+a;
        end
        
        Sq = [Sq_vec(1) Sq_vec(2);
            Sq_vec(3) Sq_vec(4);
            Sq_vec(5) Sq_vec(6);
            Sq_vec(7) Sq_vec(8)];
        
        tform = fitgeotrans(Sq, fixedPoints, 'Projective');
        
        RA = imref2d([width width], [1 width], [1 width]);
        [Pic_inSq,r] = imwarp(Pic, tform, 'OutputView', RA);
        
        imwrite(Pic_inSq,filenameI);
%         imwrite(fliplr(Pic_inSq),filenameIf);
        
        switch 1
            case strcmp(category, 'Asphalt_dry')
                labelCnt.Asphalt_dry = labelCnt.Asphalt_dry+1;
            case strcmp(category, 'Asphalt_wet')
                labelCnt.Asphalt_wet = labelCnt.Asphalt_wet+1;
            case strcmp(category, 'Cobblestone_dry')
                labelCnt.Cobblestone_dry = labelCnt.Cobblestone_dry+1;
            case strcmp(category, 'Cobblestone_wet')
                labelCnt.Cobblestone_wet = labelCnt.Cobblestone_wet+1;
            case strcmp(category, 'Snow')
                labelCnt.Snow = labelCnt.Snow+1;
        end
        UpdateLabelCnt();
        imgCnt = imgCnt+1;
    end




%% Dialogfenster

    function selectCategory(hObj, event)
        val = hObj.Value;
        category = hObj.String{val};
    end

    function cb_browse(hObj, event)
        path = uigetdir(pwd);
        
        idx=strfind(path, '\');
        path(idx)= '/';
        
        setPath(path);
    end



    function cb_autoLabel(hObj, event)
        % Switch Autolabeling
        if autoLabeling
            autoLabeling=0;
        else
            autoLabeling=1;
            if ~enableRot
                WrapAxes.XAxis.Color= 'g';
                WrapAxes.YAxis.Color= 'g';
                CropPos = getPosition(CropFrame);
                
                RotPic = imrotate(Pic, rotImg);
                saveImage(RotPic,CropPos)
                
                WrapAxes.XAxis.Color= 'k';
                WrapAxes.YAxis.Color= 'k';
                
                frameSaved = 1;
            end
            uiresume(gcbf)
        end
    end

    function setPath(varargin)
        
        if ischar(varargin{1})
            path = varargin{1};
        else
            path = varargin{1}.String;
        end
        
        addpath(path)
        
        startCropping(path);
    end

    function setInterval(hObj, event)
        IntervalCut = num2str(hObj.String);
    end

    function setImgShift(hObj, event)
        
        if ~isnan(str2double(hObj.String))
            ImgShift = str2double(hObj.String);
        else
            SkipImgEdit.String = ImgShift;
        end
    
    
    end

    function d= DatasetName()
        d = figure('Position', [400 400 350 120],...
            'Unit', 'Pixels',...
            'ToolBar','none',...
            'MenuBar','none',...
            'Resize','off',...
            'Name','Datensatzbezeichnung');
        %             'WindowKeyPressFcn', @KeyPressDiag,...
        
        
        movegui(d, 'center')
        
        txt = uicontrol('Parent',d,...
            'Style','text',...
            'HorizontalAlignment', 'left',...
            'Position',[20 70 180 40],...
            'String','Name des gewählten Datensatzes:');
        
        NameEdit = uicontrol('Parent',d,...
            'Style','edit',...
            'HorizontalAlignment', 'left',...
            'Position',[20 60 200 25],...
            'String',DataSetName,...
            'Callback', @setDatasetName);
        
        
        CloseBut = uicontrol('Parent',d,...
            'Position',[260 20 70 25],...
            'String', 'Fortfahren',...
            'Callback', 'close(gcf)');
        
        
        function setDatasetName(hObj, event)
            DataSetName = hObj.String;
        end
        
        function KeyPressDiag(hObj, event)
            if strcmp(event.Key, 'return')
                DataSetName = NameEdit.String;
                close(gcf)
            end
        end
    end



end
