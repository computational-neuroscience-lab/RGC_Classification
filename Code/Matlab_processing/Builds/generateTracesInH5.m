
function addTrace_h5(name, videoPath)

fileID = H5F.open('TracesData.h5','H5F_ACC_RDWR','H5P_DEFAULT');
masks = hdf5read('TracesData.h5', '/masks');

videoInfo = imfinfo(videoPath);
movieW = videoInfo.Width;
movieH = videoInfo.Height;
videoSize = size(videoInfo);
nSlice = videoSize(1);
movie = zeros(movieW, movieH, nSlice);
for i=1:nSlice
    movie(:,:,i) = double(imread(videoPath,'Index',i));
end

nRoi = size(masks, 3);
Traces = zeros(nRoi, nSlice);
for iROI = 1:nRoi
    for iSlice = 1:nSlice
        logicMask = logical(masks(:, :, iROI));
        slice = movie(:, :, iSlice);
        Traces(iROI, iSlice) = mean(slice(logicMask));
    end
end

groupId = H5G.create(fileID, name, 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');

dimTraces = size(Traces);
datatypeID = H5T.copy('H5T_NATIVE_DOUBLE');
dataspacePatterns = H5S.create_simple(2, fliplr(dimTraces), []);
datasetPatterns = H5D.create(groupId, 'patterns', datatypeID, dataspacePatterns, 'H5P_DEFAULT');

H5D.write(datasetPatterns,'H5ML_DEFAULT','H5S_ALL','H5S_ALL', 'H5P_DEFAULT', Traces);

H5D.close(datasetPatterns);
H5S.close(dataspacePatterns);
H5G.close(groupId);
H5F.close(fileID);