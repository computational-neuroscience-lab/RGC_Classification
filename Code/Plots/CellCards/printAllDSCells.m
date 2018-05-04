function printAllDSCells()
close all;

datasetMat = getDatasetMat;
load(datasetMat, 'cellsTable');
cd(strcat(projectPath(), '/CellCards/DsCells'));

dsLabels = cellsTable([cellsTable(:).DS] == 1);

for iLabel = 1 : numel(dsLabels)
    plotCell(dsLabels(iLabel).experiment, dsLabels(iLabel).N);
    
    title = strcat('Exp', dsLabels(iLabel).experiment, '_Cell#', int2str(dsLabels(iLabel).N));
    saveas(gcf, title,'png')
    close;
end
cd(strcat(projectPath(), '/Code/Matlab_processing'));
        