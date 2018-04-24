function buildClassesTable()

loadDataset();

% classNames = getLeafClasses();
classNames = unique([clustersTable.Type]);
nClasses = length(classNames);

classesTable = struct(  'name',     cell(1, nClasses), ...
                        'size',     cell(1, nClasses), ...
                        'avgSTD',  cell(1, nClasses), ...
                        'somaMEAN', cell(1, nClasses), ...
                        'somaSTD', 	cell(1, nClasses), ...
                        'fluoMEAN', cell(1, nClasses), ...
                        'fluoSTD',	cell(1, nClasses), ...
                        'indexes',  cell(1, nClasses) ...
                     );
sumI = 0;
for iClass = 1:numel(classNames)
    name = classNames(iClass);
    indexes = classIndexes(name);
    sumI = indexes + sumI;
    
    setResponses = eulerResponsesMatrix(indexes, :);
    stdResponse = std(setResponses, [], 1);
    avgSTD = mean(stdResponse);

    classesTable(iClass).name = classNames(iClass);
    classesTable(iClass).size = sum(indexes);
    classesTable(iClass).avgSTD = avgSTD;
    classesTable(iClass).somaMEAN = round(mean([cellsTable(indexes).soma]));
    classesTable(iClass).somaSTD = std([cellsTable(indexes).soma]);
    classesTable(iClass).fluoMEAN = round(mean([cellsTable(indexes).fluo]));
    classesTable(iClass).fluoSTD = std([cellsTable(indexes).fluo]);
    classesTable(iClass).indexes = indexes;

end
save(getDatasetMat, 'classesTable', '-append');    
