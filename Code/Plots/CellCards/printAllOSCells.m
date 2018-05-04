function printAllOSCells()
close all;

datasetMat = strcat(projectPath(), '/Dataset/dataSetMatrix.mat');
load(datasetMat, 'cellsLabels');
cd(strcat(projectPath(), '/CellCards/OsCells'));

dsLabels = cellsLabels([cellsLabels(:).OS] == 1);

for iLabel = 1 : numel(dsLabels)
    plotCell(dsLabels(iLabel).experiment, dsLabels(iLabel).N);
    
    title = strcat('Exp', dsLabels(iLabel).experiment, '_Cell#', int2str(dsLabels(iLabel).N));
    saveas(gcf, title,'png')
    close;
end
cd(strcat(projectPath(), '/Code/Matlab_processing'));
        