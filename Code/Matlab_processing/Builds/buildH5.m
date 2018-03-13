function buildH5()

load('block_roi.mat')

fileID = H5F.create('TracesData.h5','H5F_ACC_TRUNC','H5P_DEFAULT','H5P_DEFAULT');

datatypeID = H5T.copy('H5T_NATIVE_DOUBLE');

dimCenters = size(Centers);
dimMapId = size(MapId);
dataspaceCentroids = H5S.create_simple(2, fliplr(dimCenters), []);
dataspaceMasks = H5S.create_simple(3, fliplr(dimMapId), []);

datasetCentroids = H5D.create(fileID, 'centroids', datatypeID, dataspaceCentroids, 'H5P_DEFAULT');
datasetMasks = H5D.create(fileID, 'masks', datatypeID, dataspaceMasks, 'H5P_DEFAULT');

H5D.write(datasetCentroids,'H5ML_DEFAULT','H5S_ALL','H5S_ALL', 'H5P_DEFAULT', Centers);
H5D.write(datasetMasks,'H5ML_DEFAULT','H5S_ALL','H5S_ALL', 'H5P_DEFAULT', MapId);

H5D.close(datasetCentroids);
H5D.close(datasetMasks);

H5S.close(dataspaceCentroids);
H5S.close(dataspaceMasks);

H5T.close(datatypeID);
H5F.close(fileID);

try
    fprintf('\tgenerating Euler Traces...');
    generateTracesInH5('EulerStim', 'block_10.tif');
catch
    fprintf('\tERROR: traces UNAVAILABLE');
end
fprintf('\n')
try
    fprintf('\tgenerating Bars Traces...');
    generateTracesInH5('MovingBars', 'block_20.tif');
catch
    fprintf('\tERROR: traces UNAVAILABLE');
end
fprintf('\n\n')