function pcaTest(nComponents)

load(strcat(projectPath, '/Dataset/dataSetMatrix.mat'), 'eulerResponsesMatrix', 'cellsLabels');
[nCells, nDimensions] = size(eulerResponsesMatrix);

meanER = mean(eulerResponsesMatrix, 1);
normER = eulerResponsesMatrix - ones(nCells,1) * meanER;

[coeff,score,latent,tsquared,explained,mu] = pca(normER);

[~, ~, coeff] = svd(normER);

reductionCoeff = [coeff(:, 1:nComponents), zeros(nDimensions, nDimensions - nComponents)];
reductionScore = normER * reductionCoeff;

reductedNormER = reductionScore / coeff;
reductedEulerResponseMatrix = reductedNormER + ones(nCells,1) * meanER;

% Example Plot
close all;

figure('Name', 'Normal Traces vs Reduced components Traces')
plotRows = 5;
plotCols = 2;
for iPlot = 1:(plotRows * plotCols)
    subplot(plotRows, plotCols, iPlot)
    plot(eulerResponsesMatrix(iPlot,:));
    hold on
    plot(reductedEulerResponseMatrix(iPlot,:));
    hold off
end

figure('Name', 'First 3 principal components')
subplot(2,1,1)
plotSingleEulerStim();
subplot(2,1,2)
plot(coeff(:, 1))
xlim([0 594])
subplot(2,1,1)
hold on
subplot(2,1,2)
hold on
plot(coeff(:, 2))
plot(coeff(:, 3))
title('First 3 principal components');