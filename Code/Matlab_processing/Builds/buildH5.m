function buildH5(experimentFolder)

expPath = strcat(projectPath(), '/Experiments/', experimentFolder, '/traces');
tracesH5 = strcat(expPath, '/TracesData.h5');
roisMat = strcat(expPath, '/block_roi.mat');

load(roisMat, 'Centers', 'MapId');

% Create h5
fileID = H5F.create(tracesH5, 'H5F_ACC_TRUNC','H5P_DEFAULT','H5P_DEFAULT');
datatypeID = H5T.copy('H5T_NATIVE_DOUBLE');

dimCenters = size(Centers);
dimMapId = size(MapId);
dataspaceCentroids = H5S.create_simple(2, fliplr(dimCenters), []);
dataspaceMasks = H5S.create_simple(3, fliplr(dimMapId), []);
datasetCentroids = H5D.create(fileID, 'centroids', datatypeID, dataspaceCentroids, 'H5P_DEFAULT');
datasetMasks = H5D.create(fileID, 'masks', datatypeID, dataspaceMasks, 'H5P_DEFAULT');

% Write ROIs
H5D.write(datasetCentroids,'H5ML_DEFAULT','H5S_ALL','H5S_ALL', 'H5P_DEFAULT', Centers);
H5D.write(datasetMasks,'H5ML_DEFAULT','H5S_ALL','H5S_ALL', 'H5P_DEFAULT', MapId);

% Close h5
H5D.close(datasetCentroids);
H5D.close(datasetMasks);
H5S.close(dataspaceCentroids);
H5S.close(dataspaceMasks);
H5T.close(datatypeID);
H5F.close(fileID);

% Generate and write traces
generateTracesInH5(experimentFolder);
