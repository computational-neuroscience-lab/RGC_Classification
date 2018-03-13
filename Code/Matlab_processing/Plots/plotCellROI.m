function plotCellROI(expID, nCell)

experimentsPath = strcat(projectPath(), '/Experiments/');
h5RelativePath = '/traces/TracesData.h5';
videoRelativePath = '/traces/block_10.tif';

h5Path = strcat(experimentsPath, expID, h5RelativePath);
videoPath = strcat(experimentsPath, expID, videoRelativePath);

masks = hdf5read(h5Path, '/masks');

videoInfo = imfinfo(videoPath);
movieW = videoInfo.Width;
movieH = videoInfo.Height;
videoSize = size(videoInfo);

nSlice = videoSize(1);
movie = zeros(movieW, movieH, nSlice);
for i=1:nSlice
    movie(:,:,i) = double(imread(videoPath,'Index',i));
end

stdImage = std(movie,[],3)*0.255;
image(stdImage);

hold on  
mask = masks(:,:,nCell);
boundaries = bwboundaries(mask,'noholes');
visboundaries(boundaries);
hold off

set(gca,'YTick',[])
set(gca,'XTick',[])
pbaspect([1 1 1]);

title('Cell ROI');