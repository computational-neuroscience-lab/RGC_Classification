function [osK, osAngle, dsK, dsAngle, directionModules] = directionSelectivity(directions, avgBarResponses)

[nCells, nSteps, nDirections] = size(avgBarResponses);

dsK = zeros(nCells, 1);
osK = zeros(nCells, 1);

dsAngle = zeros(nCells, 1);
osAngle = zeros(nCells, 1);

dirVectors = zeros(nCells, nDirections);
orVectors = zeros(nCells, nDirections);

directionModules = zeros(nCells, nDirections);
for iCell = 1:nCells
    cellBarResponses = squeeze(avgBarResponses(iCell, :, :));
    [~, d, dirComponents] = svd(cellBarResponses);
    directionModules(iCell, :) = dirComponents(:,1)';
    
    % TODO solve sign ambiguity of SVD
    if (directionModules(iCell,:)<0) > (directionModules(iCell,:)>=0) 
        directionModules(iCell,:) = -directionModules(iCell,:);
    end
    
    orVectors(iCell, :) = directionModules(iCell, :) .* exp(directions * 1i);
    dirVectors(iCell, :) = directionModules(iCell, :) .* exp(directions * 2i);
    
    osK(iCell) = abs(sum(orVectors(iCell, :)));
    dsK(iCell) = abs(sum(dirVectors(iCell, :))) / 2;

    osAngle(iCell) = angle(sum(orVectors(iCell, :)));
    dsAngle(iCell) = mod(angle(sum(dirVectors(iCell, :))), 2 * pi) / 2;
end
