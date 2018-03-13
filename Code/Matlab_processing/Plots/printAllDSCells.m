function printAllDSCells()
close all;

datasetMat = strcat(projectPath(), '/Dataset/dataSetMatrix.mat');
load(datasetMat, 'dsLabels');


for iLabel = 1 : numel(dsLabels)
    plotCell(dsLabels(iLabel).experiment, dsLabels(iLabel).nCell);
    
    cd(strcat(projectPath(), '/CellCards/DsCells'));
    title = strcat('Exp', dsLabels(iLabel).experiment, '_Cell#', int2str(dsLabels(iLabel).nCell));
    saveas(gcf, title,'png')
    close;
end
cd(strcat(projectPath(), '/Code/Matlab_processing'));
        