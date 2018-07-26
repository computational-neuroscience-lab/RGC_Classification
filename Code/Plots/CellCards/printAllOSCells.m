function printAllOSCells()
close all;

datasetMat = getDatasetMat;
load(datasetMat, 'cellsTable');
cd(strcat(projectPath(), '/CellCards/OsCells'));

dsLabels = cellsTable([cellsTable(:).OS] == 1);

for iLabel = 1 : numel(dsLabels)
    plotCell(char(dsLabels(iLabel).experiment), dsLabels(iLabel).N);
    
    title = strcat('Exp', dsLabels(iLabel).experiment, '_Cell#', int2str(dsLabels(iLabel).N));
    saveas(gcf, title,'png')
    close;
end
cd(strcat(projectPath(), '/Code/Matlab_processing'));
        