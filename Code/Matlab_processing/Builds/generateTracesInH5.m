function generateTracesInH5(experimentFolder)

expPath = strcat(projectPath(), '/Experiments/', experimentFolder, '/traces');
tracesH5 = strcat(expPath, '/TracesData.h5');

fileID = H5F.open(tracesH5,'H5F_ACC_RDWR','H5P_DEFAULT');
masks = hdf5read(tracesH5, '/masks');


% SELECT AVAILABLE STIM RESPONSES

% Files these title will be considered for trace extraction
stims{1}.type = 'EulerStim';
stims{2}.type = 'MovingBars';

for iStim = 1:numel(stims)
    
    % Explore files and find the movies for trace extraction
    files = dir(expPath);
    for iFile = 3:numel(files)
         % checks if the file name starts by the stimulus name
        if strfind(files(iFile).name, stims{iStim}.type) == 1
            [~, fileName, ~] = fileparts(files(iFile).name);
            fileNameParts = strsplit(fileName, '_');   
            
            if numel(fileNameParts) >= 2
                attribute = fileNameParts{2};
            else
                attribute = '';
            end
            
            stims{iStim}.source = strcat(files(iFile).folder, '/', files(iFile).name);
            stims{iStim}.attribute = attribute;
        end
    end
end


% EXTRACT AND SAVE STIM RESPONSES

for iStim = 1:numel(stims)
    try 
        fprintf(strcat('\tgenerating ', stims{iStim}.type, '...'));
        % extract movie into matrix
        videoInfo = imfinfo(stims{iStim}.source);
        nSlices = size(videoInfo, 1);
        movie = zeros(videoInfo(1).Width, videoInfo(1).Height, nSlices);
        for iSlice = 1:nSlices
            movie(:,:,iSlice) = imread(stims{iStim}.source, 'Index', iSlice);
        end

        % calculate traces as average luminescence in time over each ROI
        nRoi = size(masks, 3);
        traces = zeros(nRoi, nSlices);
        for iROI = 1:nRoi
            for iSlice = 1:nSlices
                logicMask = logical(masks(:, :, iROI));
                slice = movie(:, :, iSlice);
                traces(iROI, iSlice) = mean(slice(logicMask));
            end
        end
        
        try
            % write the track
            groupId = H5G.create(fileID, stims{iStim}.type, 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');
            dimTraces = size(traces);
            datatypeID = H5T.copy('H5T_NATIVE_DOUBLE');
            dataspacePatterns = H5S.create_simple(2, fliplr(dimTraces), []);
            datasetPatterns = H5D.create(groupId, 'patterns', datatypeID, dataspacePatterns, 'H5P_DEFAULT');
            H5D.write(datasetPatterns,'H5ML_DEFAULT','H5S_ALL','H5S_ALL', 'H5P_DEFAULT', traces);

            % write attribute
            fileattrib(tracesH5, '+w');
            h5writeatt(tracesH5, strcat('/', stims{iStim}.type, '/patterns'), 'subtype', stims{iStim}.attribute);

            % close
            H5D.close(datasetPatterns);
            H5S.close(dataspacePatterns);
            H5G.close(groupId);
        catch
            %fprintf('\tERROR: traces already exist');
        end
         
    catch
        %fprintf('\tERROR: traces UNAVAILABLE');
    end
    fprintf('\n')
end
fprintf('\n\n')
H5F.close(fileID);