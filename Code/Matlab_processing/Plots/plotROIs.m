function plotROIs(expID)

experimentsPath = strcat(projectPath(), '/Experiments/');
dataRelativePath = '/traces/TracesData.h5';
movieRelativePath = '/traces/block_10.tif';
dataPath = strcat(experimentsPath, expID, dataRelativePath);
videoPath = strcat(experimentsPath, expID, movieRelativePath);
masks = hdf5read(dataPath, '/masks');
centroids = hdf5read(dataPath, '/centroids');


videoInfo = imfinfo(videoPath);
movieW = videoInfo.Width;
movieH = videoInfo.Height;
videoSize = size(videoInfo);
nSlice = videoSize(1);
movie = zeros(movieW, movieH, nSlice);
for i=1:nSlice
    movie(:,:,i) = double(imread(videoPath,'Index',i));
end

figure('Name', strcat('All cell ROIs from experiment n_', expID));
stdImage = std(movie,[],3).*0.255;
image(stdImage); 
hold on  
[~, ~, nMasks] = size(masks);
for i = 1:nMasks
    mask = masks(:,:,i);
    boundaries = bwboundaries(mask,'noholes');
    visboundaries(boundaries);
end
[nCentroids, ~] = size(centroids);
for i = 1:nCentroids
    plot(centroids(i, 1), centroids(i, 2), 'r*', 'LineWidth', 2, 'MarkerSize', 5);
end
hold off
pbaspect([1 1 1])




