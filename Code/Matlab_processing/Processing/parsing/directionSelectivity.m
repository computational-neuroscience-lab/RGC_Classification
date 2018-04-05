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
    
    dirVectors(iCell, :) = directionModules(iCell, :) .* exp(directions * 1i);
    orVectors(iCell, :) = directionModules(iCell, :) .* exp(directions * 2i);

    dsK(iCell) = abs(sum(dirVectors(iCell, :)));
    osK(iCell) = abs(sum(orVectors(iCell, :)));

    dsAngle(iCell) = angle(sum(dirVectors(iCell, :)));
    osAngle(iCell) = mod(angle(sum(orVectors(iCell, :))), 2 * pi) / 2;
end
