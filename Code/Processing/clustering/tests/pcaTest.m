function pcaTest()

close all
nComponents = 10;

load(getDatasetMat, 'stepResponsesMatrix', 'cellsLabels');

input = stepResponsesMatrix;
[nCells, nDimensions] = size(input);

meanER = mean(input, 1);
normER = input - ones(nCells,1) * meanER;

[coeff,score,latent,tsquared,explained,mu] = pca(normER);

[~, ~, coeff] = svd(normER);

reductionCoeff = [coeff(:, 1:nComponents), zeros(nDimensions, nDimensions - nComponents)];
reductionScore = normER * reductionCoeff;

reductedNormER = reductionScore / coeff;
reductedEulerResponseMatrix = reductedNormER + ones(nCells,1) * meanER;


% Get variance percentages
[coeff,score,latent,tsquared,explained,mu] = pca(input);

% Example Plot
close all;

figure('Name', 'Normal Traces vs Reduced components Traces')
plotRows = 5;
plotCols = 2;
for iPlot = 1:(plotRows * plotCols)
    subplot(plotRows, plotCols, iPlot)
    plot(input(iPlot,:));
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
plot([0 594], [0 0], 'k');
title('First 3 principal components');

figure('Name', '4, 5, 6 principal components')
subplot(2,1,1)
plotSingleEulerStim();
subplot(2,1,2)
plot(coeff(:, 4))
xlim([0 594])
subplot(2,1,1)
hold on
subplot(2,1,2)
hold on
plot(coeff(:, 5))
plot(coeff(:, 6))
plot([0 594], [0 0], 'k');
title('4, 5, 6 principal components');

figure('Name', 'First 7, 8, 9 principal components')
subplot(2,1,1)
plotSingleEulerStim();
subplot(2,1,2)
plot(coeff(:, 7))
xlim([0 594])
subplot(2,1,1)
hold on
subplot(2,1,2)
hold on
plot(coeff(:, 8))
plot(coeff(:, 9))
plot([0 594], [0 0], 'k');
title('First 7, 8, 9 principal components');

figure('Name', 'First 10, 11, 12 principal components')
subplot(2,1,1)
plotSingleEulerStim();
subplot(2,1,2)
plot(coeff(:, 10))
xlim([0 594])
subplot(2,1,1)
hold on
subplot(2,1,2)
hold on
plot(coeff(:, 11))
plot(coeff(:, 12))
plot([0 594], [0 0], 'k');
title('First 10, 11, 12 principal components');

figure('Name', 'last 3 principal components')
subplot(2,1,1)
plotSingleEulerStim();
subplot(2,1,2)
plot(coeff(:, end-2))
xlim([0 594])
hold on
subplot(2,1,2)
hold on
plot(coeff(:, end-1))
plot(coeff(:, end))
plot([0 594], [0 0], 'k');
title('last 3 principal components');