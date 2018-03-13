function printAllOSCells()
close all;
datasetMat = strcat(projectPath(), '/Dataset/dataSetMatrix.mat');
load(datasetMat, 'osLabels');


for iLabel = 1 : numel(osLabels)
    plotCell(osLabels(iLabel).experiment, osLabels(iLabel).nCell);
    
    cd(strcat(projectPath(), '/CellCards/OsCells'));
    title = strcat('Exp', osLabels(iLabel).experiment, '_Cell#', int2str(osLabels(iLabel).nCell));
    saveas(gcf, title,'png')
    close;
end
cd(strcat(projectPath(), '/Code/Matlab_processing'));
