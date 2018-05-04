function [newMapId, newCenters] = filterBadROIs(MapId, Centers)
% Filters out not unique or empty ROIs

nROIs = size(MapId, 3);
ROIsIndexes = true(1, nROIs);

for iROI = 1:nROIs
    
    % check if the ROI is empty
    if sum(sum(MapId(:,:,iROI))) == 0
        ROIsIndexes(iROI) = false;
        fprintf('\t%d is empty', iROI);
    else
        
        % check if the ROI is not unique
        for iROI_2 = 1:nROIs
            if(iROI ~= iROI_2)
                if isequal(MapId(:,:,iROI), MapId(:,:,iROI_2)) &&  (ROIsIndexes(iROI_2) == true)
                    ROIsIndexes(iROI) = false;
                    fprintf('\t%d is not unique', iROI);
                end
            end
        end
        
    end
end
fprintf('\n');
newMapId = MapId(:, :, ROIsIndexes);
newCenters = Centers(ROIsIndexes, :);