function varargout = SemiAutoROIgui(varargin)
% SEMIAUTOROIGUI MATLAB code for SemiAutoROIgui.fig
%      SEMIAUTOROIGUI, by itself, creates a new SEMIAUTOROIGUI or raises the existing
%      singleton*.
%
%      H = SEMIAUTOROIGUI returns the handle to a new SEMIAUTOROIGUI or the handle to
%      the existing singleton*.
%
%      SEMIAUTOROIGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEMIAUTOROIGUI.M with the given input arguments.
%
%      SEMIAUTOROIGUI('Property','Value',...) creates a new SEMIAUTOROIGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SemiAutoROIgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SemiAutoROIgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SemiAutoROIgui

% Last Modified by GUIDE v2.5 27-Feb-2018 16:47:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SemiAutoROIgui_OpeningFcn, ...
                   'gui_OutputFcn',  @SemiAutoROIgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SemiAutoROIgui is made visible.
function SemiAutoROIgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SemiAutoROIgui (see VARARGIN)

% Choose default command line output for SemiAutoROIgui
handles.output = hObject;

fileRoot = varargin{2};
block_id = varargin{3};

handles.fileRoot = fileRoot;

set(handles.BlockNumber,'String',int2str(block_id));

% Load file and 
handles.filename = [fileRoot int2str(block_id) '.tif'];
handles.ROIfile  = [fileRoot 'roi.mat'];

s = imfinfo(handles.filename);
for i=1:length(s)
    mov(:,:,i) = double(imread(handles.filename,'Index',i));
end

handles.mov = mov;

if length(varargin)<4 
    map = std(mov,0,3);
    % map = max(mov,[],3);

else
    map = double(imread(varargin{4}));%,'Index',1));
    set(handles.BlockNumber,'String','-1');
    
    if size(map,1) ~= size(mov,1)
        %Resample map
        [X1,Y1] = meshgrid((1:size(map,1)));
        [X2,Y2] = meshgrid((1:size(mov,1)));
        X1 = X1 / max(X1(:));
        Y1 = Y1 / max(Y1(:));
        X2 = X2 / max(X2(:));
        Y2 = Y2 / max(Y2(:));
        
        map = interp2(X1,Y1,double(map),X2,Y2);
    end
end

handles.map = map/max(map(:));

handles.ImageRef = map;

% map = map.^0.5;

[handles.Gmag,handles.Gangle] = imgradient(handles.map);


if exist(handles.ROIfile,'file')
    load(handles.ROIfile,'-mat')
    handles.Contour = Contour;
    handles.MapId = MapId;
    handles.Centers = Centers;
    
    handles.CellToPlot = length(Centers);%Plot the last one by default
else
    handles.Contour = [];
    handles.MapId = [];
    handles.Centers = [];

    handles.CellToPlot = 0;%Plot the last one by default
end
handles.Xmin = 0;
handles.Ymin = 0;
handles.Xmax = size(handles.map,2);
handles.Ymax = size(handles.map,1);

if exist([fileRoot int2str(block_id) '.stim'],'file')
    load([fileRoot int2str(block_id) '.stim'],'-mat')
    handles.StimTrace = stim;
    handles.StimFq = StimFq;
    handles.ImFq = ImFq;
end

RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SemiAutoROIgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function RefreshPlot(handles)

axes(handles.FOV);

imshow(handles.map,'Parent', handles.FOV)
% imshow(Gmag)
colormap(handles.FOV,'gray')
hold(handles.FOV,'on')
for ROIcount=1:length(handles.Contour)
    plot(handles.Contour{ROIcount}([(1:size(handles.Contour{ROIcount},1)) 1],1),handles.Contour{ROIcount}([(1:size(handles.Contour{ROIcount},1)) 1],2),'r','LineWidth',2);
end

if ~isempty(handles.Centers)
    for i=1:size(handles.Centers,1)
        text(handles.Centers(i,1),handles.Centers(i,2),int2str(i),'color','r','FontSize',15)
        plot(handles.Centers(i,1),handles.Centers(i,2),'y.')
    end
end

hold(handles.FOV,'off')

set(handles.FOV,'Xlim',[handles.Xmin handles.Xmax])
set(handles.FOV,'Ylim',[handles.Ymin handles.Ymax])

if handles.CellToPlot>0
    for i=1:size(handles.mov,3)
        trace(i) = sum(sum(sum(handles.mov(:,:,i).*handles.MapId(:,:,handles.CellToPlot))));
    end
    
    axes(handles.TraceFig);

    plot(trace,'b')
    
    if isfield(handles,'StimTrace')
        Xtrace = (1:length(trace))/handles.ImFq;
        Xstim = (1:length(handles.StimTrace))/handles.StimFq;
        plot(Xstim,handles.StimTrace*max(trace)/max(handles.StimTrace),'r')
        hold(handles.TraceFig,'on')
        plot(Xtrace,trace,'b')
        hold(handles.TraceFig,'off')
    end
    
end


% --- Outputs from this function are returned to the command line.
function varargout = SemiAutoROIgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in ZoomInBtn.
function ZoomInBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomInBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.FOV);
[x,y] = ginput(2);

handles.Xmin = x(1);
handles.Ymin = y(1);
handles.Xmax = x(2);
handles.Ymax = y(2);

RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ZoomOutBtn.
function ZoomOutBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOutBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Xmin = 0;
handles.Ymin = 0;
handles.Xmax = size(handles.map,2);
handles.Ymax = size(handles.map,1);

RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in DefineROIbtn.
function DefineROIbtn_Callback(hObject, eventdata, handles)
% hObject    handle to DefineROIbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.FOV);

[xc,yc] = ginput(1);

hold(handles.FOV,'on')

plot(handles.FOV,xc,yc,'r.')


ROIcount = length(handles.Contour);

NbDivAngle = str2num(get(handles.NbDiv,'String'));

% PossibleAngles = 2*3.14*linspace(0,1,NbDivAngle+1);
% PossibleAngles = PossibleAngles(1:end-1);

MeanRprior = str2num(get(handles.RadiusMean,'String'));
StdPrior = str2num(get(handles.RadiusStd,'String'));
MaxR = str2num(get(handles.RadiusMax,'String'));
PriorWeight = str2num(get(handles.PriorWeight,'String'));
DevTol = str2num(get(handles.DevTol,'String'));

Xcoor = ones(size(handles.map,1),1)*(1:size(handles.map,2));
Ycoor = (1:size(handles.map,1))'*ones(1,size(handles.map,2));

while ~isnan(xc)
    ROIcount = ROIcount + 1;
    
    handles.Centers(ROIcount,1) = xc;
    handles.Centers(ROIcount,2) = yc;
    
    handles.Contour{ROIcount} = GetContour(xc,yc,handles.map,handles.Gmag,NbDivAngle,MeanRprior,StdPrior,MaxR,PriorWeight,DevTol);
% 
%     for iangle=1:NbDivAngle
%         r = (0:MaxR);
%         xr = xc + r*cos(PossibleAngles(iangle));
%         yr = yc + r*sin(PossibleAngles(iangle));
%         xr = round(xr);
%         yr = round(yr);
%         for ir=1:length(r)
%             if yr(ir)>0 & yr(ir)<size(handles.Gmag,1) & xr(ir)>0 & xr(ir)<size(handles.Gmag,2)
%                 score(ir) = handles.Gmag(yr(ir),xr(ir));%*abs(cos(pi*handles.Gangle(yr(ir),xr(ir))/180-(PossibleAngles(iangle)-pi)));
%             else
%                 score(ir) = 0;
%             end
%         end
%         score = score - PriorWeight*((r-MeanRprior)/StdPrior).^2;
%         [m,GoodR] = max(score);
%         
%         ChosenRadius(iangle) = GoodR;
%         
%         handles.Contour{ROIcount}(iangle,1) = xr(GoodR);
%         handles.Contour{ROIcount}(iangle,2) = yr(GoodR);
%     end
%     clear cr
%     
%     cr(2:length(ChosenRadius)+1) = ChosenRadius;
%     cr(1) = ChosenRadius(end);
%     cr(end+1) = ChosenRadius(1);
%     
%     d = cr(2:end-1) - (cr(1:end-2) + cr(3:end))/2;
%     d = d - mean(d);
%     d = d / std(d);
%     Dev = find(abs(d)>DevTol);
%     
%     handles.Contour{ROIcount}(Dev,:) = [];
%     
% %     mapid(:,:,ROIcount)(find( (Xcoor(:)-xc).^2 + (Ycoor(:)-yc).^2 <= Radius^2 )) = 1;
%     
% %     Contour{ROIcount}(:,1) = xc + Radius*cos(2*3.14*linspace(0,1,100));
% %     Contour{ROIcount}(:,2) = yc + Radius*sin(2*3.14*linspace(0,1,100));

    hold(handles.FOV,'on')
    plot(handles.FOV,handles.Contour{ROIcount}(:,1),handles.Contour{ROIcount}(:,2),'r','LineWidth',2);
    

    handles.MapId(:,:,ROIcount) = inpolygon(Xcoor,Ycoor,handles.Contour{ROIcount}(:,1),handles.Contour{ROIcount}(:,2));

    [xc,yc] = ginput(1);
end

% figure;
% imshow(handles.MapId{ROIcount})
% colormap('gray')
% hold on
% plot(handles.Contour{ROIcount}(:,1),handles.Contour{ROIcount}(:,2),'r','LineWidth',2)

hold(handles.FOV,'off')

handles.CellToPlot = size(handles.Centers,1);

guidata(hObject, handles);

RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in ShowCirclePriorBtn.
function ShowCirclePriorBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ShowCirclePriorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.FOV);

NbDivAngle = str2num(get(handles.NbDiv,'String'))

MeanRprior = str2num(get(handles.RadiusMean,'String'))
StdPrior = str2num(get(handles.RadiusStd,'String'))
MaxR = str2num(get(handles.RadiusMax,'String'))

[xc,yc] = ginput(1);

xm = xc + MeanRprior*cos(2*3.14*linspace(0,1,NbDivAngle));
ym = yc + MeanRprior*sin(2*3.14*linspace(0,1,NbDivAngle));

xminus = xc + (MeanRprior - StdPrior)*cos(2*3.14*linspace(0,1,NbDivAngle));
yminus = yc + (MeanRprior - StdPrior)*sin(2*3.14*linspace(0,1,NbDivAngle));

xplus = xc + (MeanRprior + StdPrior)*cos(2*3.14*linspace(0,1,NbDivAngle));
yplus = yc + (MeanRprior + StdPrior)*sin(2*3.14*linspace(0,1,NbDivAngle));

xmax = xc + MaxR*cos(2*3.14*linspace(0,1,NbDivAngle));
ymax = yc + MaxR*sin(2*3.14*linspace(0,1,NbDivAngle));

hold(handles.FOV,'on')
plot(handles.FOV,xm,ym,'y','LineWidth',2);
plot(handles.FOV,xminus,yminus,'y','LineWidth',1);
plot(handles.FOV,xplus,yplus,'y','LineWidth',1);
plot(handles.FOV,xmax,ymax,'y','LineWidth',2);
hold(handles.FOV,'off')
pause
RefreshPlot(handles)


% --- Executes on button press in CorrectROIbtn.
function CorrectROIbtn_Callback(hObject, eventdata, handles)
% hObject    handle to CorrectROIbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.FOV);

Xcoor = ones(size(handles.map,1),1)*(1:size(handles.map,2));
Ycoor = (1:size(handles.map,1))'*ones(1,size(handles.map,2));

[xc,yc] = ginput(1);

while ~isnan(xc)
    dmax = inf;
    ROIid = 1;
    PtId = 1;
    for i=1:length(handles.Contour)
        d = (handles.Contour{i}(:,1) - xc).^2 + (handles.Contour{i}(:,2) - yc).^2;
        [m,id] = min(d);
        if m<dmax
            dmax = m;
            ROIid = i;
            PtId = id;
        end
    end
    
    [xc,yc] = ginput(1);
    
    handles.Contour{ROIid}(PtId,1) = xc;
    handles.Contour{ROIid}(PtId,2) = yc;
    
    handles.MapId(:,:,ROIid) = inpolygon(Xcoor,Ycoor,handles.Contour{ROIid}(:,1),handles.Contour{ROIid}(:,2));

    handles.CellToPlot = ROIid;

    RefreshPlot(handles)
    
    [xc,yc] = ginput(1);
end


% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in SaveBtn.
function SaveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Contour = handles.Contour;
MapId = handles.MapId;
Centers = handles.Centers;

save(handles.ROIfile,'Contour','MapId','Centers','-mat')


% --- Executes on button press in KillBtn.
function KillBtn_Callback(hObject, eventdata, handles)
% hObject    handle to KillBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.FOV);

[xc,yc] = ginput(1);

d = (handles.Centers(:,1) - xc).^2 + (handles.Centers(:,2) - yc).^2;
[m,id] = min(d);

NewId = [(1:id-1) (id+1:size(handles.Centers,1))];
        
handles.Contour = handles.Contour(NewId);
handles.MapId = handles.MapId(:,:,NewId);
handles.Centers = handles.Centers(NewId,:);

handles.CellToPlot=0;

RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);



function NbDiv_Callback(hObject, eventdata, handles)
% hObject    handle to NbDiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NbDiv as text
%        str2double(get(hObject,'String')) returns contents of NbDiv as a double


% --- Executes during object creation, after setting all properties.
function NbDiv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NbDiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RadiusMean_Callback(hObject, eventdata, handles)
% hObject    handle to RadiusMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RadiusMean as text
%        str2double(get(hObject,'String')) returns contents of RadiusMean as a double


% --- Executes during object creation, after setting all properties.
function RadiusMean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RadiusMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RadiusStd_Callback(hObject, eventdata, handles)
% hObject    handle to RadiusStd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RadiusStd as text
%        str2double(get(hObject,'String')) returns contents of RadiusStd as a double


% --- Executes during object creation, after setting all properties.
function RadiusStd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RadiusStd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RadiusMax_Callback(hObject, eventdata, handles)
% hObject    handle to RadiusMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RadiusMax as text
%        str2double(get(hObject,'String')) returns contents of RadiusMax as a double


% --- Executes during object creation, after setting all properties.
function RadiusMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RadiusMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DevTol_Callback(hObject, eventdata, handles)
% hObject    handle to DevTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DevTol as text
%        str2double(get(hObject,'String')) returns contents of DevTol as a double


% --- Executes during object creation, after setting all properties.
function DevTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DevTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PriorWeight_Callback(hObject, eventdata, handles)
% hObject    handle to PriorWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PriorWeight as text
%        str2double(get(hObject,'String')) returns contents of PriorWeight as a double


% --- Executes during object creation, after setting all properties.
function PriorWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PriorWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowTrace.
function ShowTrace_Callback(hObject, eventdata, handles)
% hObject    handle to ShowTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.FOV);

[xc,yc] = ginput(1);

d = (handles.Centers(:,1) - xc).^2 + (handles.Centers(:,2) - yc).^2;

[m,ROIid] = min(d);

handles.CellToPlot = ROIid;
RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);
% 
% for i=1:size(handles.mov,3)
%     trace(i) = sum(sum(sum(handles.mov(:,:,i).*handles.MapId(:,:,ROIid))));
% end
% 
% figure;
% plot(trace)


% --- Executes on button press in ManualRoi.
function ManualRoi_Callback(hObject, eventdata, handles)
% hObject    handle to ManualRoi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.FOV);

[xc,yc] = ginput(1);
hold(handles.FOV,'on')
plot(xc,yc,'r.')

CenterNew = [xc,yc];

[xc,yc] = ginput(1);

PtId = 1;

ROIid = length(handles.Contour) + 1;

while ~isnan(xc)

    handles.Contour{ROIid}(PtId,1) = xc;
    handles.Contour{ROIid}(PtId,2) = yc;
    
    if PtId>1
        plot([handles.Contour{ROIid}(PtId-1,1) handles.Contour{ROIid}(PtId,1)],[handles.Contour{ROIid}(PtId-1,2) handles.Contour{ROIid}(PtId,2)],'r','LineWidth',2)
    else
        plot(handles.Contour{ROIid}(PtId,1),handles.Contour{ROIid}(PtId,2),'r.')
    end
    
    PtId = PtId + 1;
    
    [xc,yc] = ginput(1);
end

handles.Centers(ROIid,1) = CenterNew(1);
handles.Centers(ROIid,2) = CenterNew(2);

hold(handles.FOV,'off')

Xcoor = ones(size(handles.map,1),1)*(1:size(handles.map,2));
Ycoor = (1:size(handles.map,1))'*ones(1,size(handles.map,2));

handles.MapId(:,:,ROIid) = inpolygon(Xcoor,Ycoor,handles.Contour{ROIid}(:,1),handles.Contour{ROIid}(:,2));

handles.CellToPlot = size(handles.Centers,1);

RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);



function Xshift_Callback(hObject, eventdata, handles)
% hObject    handle to Xshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xshift as text
%        str2double(get(hObject,'String')) returns contents of Xshift as a double


% --- Executes during object creation, after setting all properties.
function Xshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Yshift_Callback(hObject, eventdata, handles)
% hObject    handle to Yshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Yshift as text
%        str2double(get(hObject,'String')) returns contents of Yshift as a double


% --- Executes during object creation, after setting all properties.
function Yshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShiftBtn.
function ShiftBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ShiftBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.FOV);

Xshift = str2double(get(handles.Xshift,'String'));
Yshift = str2double(get(handles.Yshift,'String'));

Contour = handles.Contour;
MapId = handles.MapId;
Centers = handles.Centers;

[handles.Contour,handles.MapId,handles.Centers] = ShiftROI(Contour,MapId,Centers,Xshift,Yshift);

RefreshPlot(handles)

guidata(hObject, handles);


% --- Executes on button press in CancelShiftBtn.
function CancelShiftBtn_Callback(hObject, eventdata, handles)
% hObject    handle to CancelShiftBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.FOV);

Xshift = str2double(get(handles.Xshift,'String'));
Yshift = str2double(get(handles.Yshift,'String'));

Contour = handles.Contour;
MapId = handles.MapId;
Centers = handles.Centers;

[handles.Contour,handles.MapId,handles.Centers] = ShiftROI(Contour,MapId,Centers,-1*Xshift,-1*Yshift);

RefreshPlot(handles)

guidata(hObject, handles);


function [ContourNew,MapIdNew,CentersNew] = ShiftROI(Contour,MapId,Centers,Xshift,Yshift)

Xcoor = ones(size(MapId,1),1)*(1:size(MapId,2));
Ycoor = (1:size(MapId,1))'*ones(1,size(MapId,2));

CentersNew(:,1) = Centers(:,1) + Xshift;
CentersNew(:,2) = Centers(:,2) + Yshift;

for ROIid=1:length(Contour)
    ContourNew{ROIid}(:,1) = Contour{ROIid}(:,1) + Xshift;
    ContourNew{ROIid}(:,2) = Contour{ROIid}(:,2) + Yshift;
    MapIdNew(:,:,ROIid) = inpolygon(Xcoor,Ycoor,ContourNew{ROIid}(:,1),ContourNew{ROIid}(:,2));
end


% --- Executes on button press in RedoContours.
function RedoContours_Callback(hObject, eventdata, handles)
% hObject    handle to RedoContours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



NbDivAngle = str2num(get(handles.NbDiv,'String'));

% PossibleAngles = 2*3.14*linspace(0,1,NbDivAngle+1);
% PossibleAngles = PossibleAngles(1:end-1);

MeanRprior = str2num(get(handles.RadiusMean,'String'));
StdPrior = str2num(get(handles.RadiusStd,'String'));
MaxR = str2num(get(handles.RadiusMax,'String'));
PriorWeight = str2num(get(handles.PriorWeight,'String'));
DevTol = str2num(get(handles.DevTol,'String'));

Xcoor = ones(size(handles.map,1),1)*(1:size(handles.map,2));
Ycoor = (1:size(handles.map,1))'*ones(1,size(handles.map,2));

for ROIcount = 1:length(handles.Contour)
    m(:,:) = handles.MapId(:,:,ROIcount);

    MeanRadius = sqrt(length(find(m(:)>0))/pi);
    handles.Contour{ROIcount} = GetContour(handles.Centers(ROIcount,1),handles.Centers(ROIcount,2),handles.map,handles.Gmag,NbDivAngle,MeanRadius,StdPrior,MaxR,PriorWeight,DevTol);
end

guidata(hObject, handles);

RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);



function BlockNumber_Callback(hObject, eventdata, handles)
% hObject    handle to BlockNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BlockNumber as text
%        str2double(get(hObject,'String')) returns contents of BlockNumber as a double

BlockNb = str2double(get(hObject,'String'));
if BlockNb>=0
    if exist([handles.fileRoot int2str(BlockNb) '.tif'],'file')

        disp(['Loading ' handles.fileRoot int2str(BlockNb) '.tif'])
        
        handles.filename = [handles.fileRoot int2str(BlockNb) '.tif'];

        s = imfinfo(handles.filename);
        for i=1:length(s)
            mov(:,:,i) = double(imread(handles.filename,'Index',i));
        end

        handles.mov = mov;

        map = std(mov,0,3);
        % map = max(mov,[],3);

        handles.map = map;

        handles.map = map/max(map(:));

        [handles.Gmag,handles.Gangle] = imgradient(handles.map);

        RefreshPlot(handles)

        % Update handles structure
        guidata(hObject, handles);
    else
        disp('File does not exist')
    end
else
    if BlockNb==-1
        handles.map = handles.ImageRef;

        [handles.Gmag,handles.Gangle] = imgradient(handles.map);

        RefreshPlot(handles)

        % Update handles structure
        guidata(hObject, handles);
    else
        disp('Invalid block number')
    end
end

% --- Executes during object creation, after setting all properties.
function BlockNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlockNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DisplaceROIbtn.
function DisplaceROIbtn_Callback(hObject, eventdata, handles)
% hObject    handle to DisplaceROIbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



Xcoor = ones(size(handles.map,1),1)*(1:size(handles.map,2));
Ycoor = (1:size(handles.map,1))'*ones(1,size(handles.map,2));

axes(handles.FOV);

[xc,yc] = ginput(1);

d = (handles.Centers(:,1) - xc).^2 + (handles.Centers(:,2) - yc).^2;

[m,ROIid] = min(d);

[xc,yc] = ginput(1);

dx = xc - handles.Centers(ROIid,1);
dy = yc - handles.Centers(ROIid,2);

handles.Contour{ROIid}(:,1) = handles.Contour{ROIid}(:,1) + dx;
handles.Contour{ROIid}(:,2) = handles.Contour{ROIid}(:,2) + dy;

handles.Centers(ROIid,1) = handles.Centers(ROIid,1) + dx;
handles.Centers(ROIid,2) = handles.Centers(ROIid,2) + dy;

handles.MapId(:,:,ROIid) = inpolygon(Xcoor,Ycoor,handles.Contour{ROIid}(:,1),handles.Contour{ROIid}(:,2));

RefreshPlot(handles)

% Update handles structure
guidata(hObject, handles);

