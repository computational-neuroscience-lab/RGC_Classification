% check out the README file for detailed instructions (and extra options)
addpath('.') % add the path to your make_db file

% overwrite any of these default options in your make_db file for individual experiments
make_db; % RUN YOUR OWN MAKE_DB SCRIPT TO RUN HERE

ops0.toolbox_path = '/home/pierre/github/Suite2P';
if exist(ops0.toolbox_path, 'dir')
    addpath(genpath(ops0.toolbox_path)) % add local path to the toolbox
else%
    error('toolbox_path does not exist, please change toolbox_path');
end

% add path to OASIS matlab repository, https://github.com/zhoupc/OASIS_matlab
addpath('/home/pierre/github/OASIS/oasis')
%%
% mex -largeArrayDims SpikeDetection/deconvL0.c (or .cpp) % MAKE SURE YOU COMPILE THIS FIRST FOR DECONVOLUTION

ops0.useGPU                 = 0; % if you can use an Nvidia GPU in matlab this accelerates registration approx 3 times. You only need the Nvidia drivers installed (not CUDA).
ops0.fig                    = 0; % turn off figure generation with 0

% root paths for files and temporary storage (ideally an SSD drive. my SSD is C:/)
ops0.RootStorage            = fullfile(pwd, ''); % Suite2P assumes a folder structure, check out README file
ops0.temp_tiff              = []; % copies each remote tiff locally first, into this file
ops0.RegFileRoot            = '';  % location for binary file
ops0.DeleteBin              = 1; % set to 1 for batch processing on a limited hard drive
ops0.ResultsSavePath        = fullfile(pwd, '.'); % a folder structure is created inside
ops0.RegFileTiffLocation    = []; %'D:/DATA/'; % leave empty to NOT save registered tiffs (slow)

% registration options
ops0.doRegistration         = 1; % skip (0) if data is already registered
ops0.showTargetRegistration = 1; % shows the image targets for all planes to be registered
ops0.PhaseCorrelation       = 1; % set to 0 for non-whitened cross-correlation
ops0.SubPixel               = Inf; % 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
ops0.NimgFirstRegistration  = 1000; % number of images to include in the first registration pass 
ops0.dobidi                 = 1; % infer and apply bidirectional phase offset

% cell detection options
ops0.ShowCellMap            = 1; % during optimization, show a figure of the clusters
ops0.sig                    = 1;  % spatial smoothing length in pixels; encourages localized clusters
ops0.nSVDforROI             = 50; % how many SVD components for cell clustering
ops0.NavgFramesSVD          = 1000; % how many (binned) timepoints to do the SVD based on
ops0.signalExtraction       = 'surround'; % how to extract ROI and neuropil signals: 

%  'raw' (no cell overlaps), 'regression' (allows cell overlaps), 
%  'surround' (no cell overlaps, surround neuropil model)

% neuropil options (if 'surround' option)
% all are in measurements of pixels
ops0.innerNeuropil  = 1; % padding around cell to exclude from neuropil
ops0.outerNeuropil  = Inf; % radius of neuropil surround
% if infinity, then neuropil surround radius is a function of cell size
if isinf(ops0.outerNeuropil)
    ops0.minNeuropilPixels = 400; % minimum number of pixels in neuropil surround
    ops0.ratioNeuropil     = 5; % ratio btw neuropil radius and cell radius
    % radius of surround neuropil = ops0.ratioNeuropil * (radius of cell)
end


% spike deconvolution and neuropil subtraction options
ops0.imageRate              = 7.8;   % imaging rate (cumulative over planes!). Approximate, for initialization of deconvolution kernel.
ops0.sensorTau              = 2; % decay half-life (or timescale). Approximate, for initialization of deconvolution kernel.
ops0.maxNeurop              = 1; % for the neuropil contamination to be less than this (sometimes good, i.e. for interneurons)


% red channel options
% redratio = red pixels inside / red pixels outside
% redcell = redratio > mean(redratio) + redthres*std(redratio)
% notred = redratio < mean(redratio) + redmax*std(redratio)
ops0.redthres               = 1.5; % the higher the thres the less red cells
ops0.redmax                 = 1; % the higher the max the more NON-red cells

db0 = db;
%% RUN THE PIPELINE HERE

for iexp = 1 %8:-1:1
    db = db0(iexp)
%     db.BiDiPhase = 0;
    run_pipeline(db, ops0);

%     run_pipeline;
    
    % deconvolved data into st, and neuropil subtraction coef in stat
    add_deconvolution(ops0, db);
    
    % add red channel information (if it exists)
    if isfield(db,'expred') && ~isempty(db.expred)
        % creates mean red channel image aligned to green channel
        run_REDaddon_sourcery(db, ops0) ; 
        
        % identify red cells in mean red channel image
        % fills dat.stat.redcell, dat.stat.notred, dat.stat.redprob
        identify_redcells_sourcery(db, ops0); 
        
    end
    
end

clear all
close all
