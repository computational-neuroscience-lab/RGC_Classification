function printAllClassesCells()
close all;

loadDataset;
load(getDatasetMat, 'cellsTable', 'classesTable');



for class = classesTable

    dirClass = char(strcat(projectPath(), '/CellCards/Classes/', class.name));
    mkdir(dirClass);
    cd(dirClass);

    cellsIndexes = find(class.indexes);
    for cellIndex = cellsIndexes
        plotCell(char(cellsTable(cellIndex).experiment), cellsTable(cellIndex).N);
        title = strcat('Exp', cellsTable(cellIndex).experiment, '_Cell#', int2str(cellsTable(cellIndex).N));
        saveas(gcf, title,'png')
        close;
    end
end
        