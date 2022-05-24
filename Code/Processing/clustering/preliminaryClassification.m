function [preliminaryClasses, typesToCluster] = preliminaryClassification(cellsTable)


% DEFINE CELLS CATEGORIES

% Responsive Cells
RESP =      [cellsTable(:).eulerQT] == 1 | [cellsTable(:).barsQT] == 1; 
NO_RESP =   [cellsTable(:).eulerQT] == 0 & [cellsTable(:).barsQT] == 0;
NO_AVAIL =  ~RESP & ~NO_RESP;

% Direction Selective
DSs =       RESP & [cellsTable(:).DS] == 1;
STANDARD =  RESP & ~DSs;                   

% Clusterizable
VALIDS =    STANDARD & [cellsTable(:).eulerQT] == 1;
ONLY_BARS = STANDARD & ~VALIDS;

% among VALIDS, 4 functional macrotypes (based on Euler Response)
ONs =       and(and([cellsTable(:).EulerON] == 1, [cellsTable(:).EulerOFF] == 0), VALIDS);
OFFs =      and(and([cellsTable(:).EulerON] == 0, [cellsTable(:).EulerOFF] == 1), VALIDS);
ON_OFFs =	and(and([cellsTable(:).EulerON] == 1, [cellsTable(:).EulerOFF] == 1), VALIDS);
FLAT =      and(and([cellsTable(:).EulerON] == 0, [cellsTable(:).EulerOFF] == 0), VALIDS);

% among ONLY_BARS, 4 functional macrotypes (based on Bars Response)
ONLY_BARS_ONs =     and(and([cellsTable(:).BarsON] == 1, [cellsTable(:).BarsOFF] == 0), ONLY_BARS);
ONLY_BARS_OFFs =	and(and([cellsTable(:).BarsON] == 0, [cellsTable(:).BarsOFF] == 1), ONLY_BARS);
ONLY_BARS_ON_OFFs =	and(and([cellsTable(:).BarsON] == 1, [cellsTable(:).BarsOFF] == 1), ONLY_BARS);
ONLY_BARS_FLAT =    and(and([cellsTable(:).BarsON] == 0, [cellsTable(:).BarsOFF] == 0), ONLY_BARS);

% among DSs, 4 functional macrotypes (based on Bars Response)
DS_ONs =        and(and([cellsTable(:).BarsON] == 1, [cellsTable(:).BarsOFF] == 0), DSs);
DS_OFFs =       and(and([cellsTable(:).BarsON] == 0, [cellsTable(:).BarsOFF] == 1), DSs);
DS_ON_OFFs =	and(and([cellsTable(:).BarsON] == 1, [cellsTable(:).BarsOFF] == 1), DSs);
DS_FLAT =       and(and([cellsTable(:).BarsON] == 0, [cellsTable(:).BarsOFF] == 0), DSs);

% DEFINE PRELIMINARY CELL TYPES
preliminaryClasses = containers.Map;

preliminaryClasses('NO-RESP') = NO_RESP;
preliminaryClasses('NO-AVAIL') = NO_AVAIL;

preliminaryClasses('ON') = ONs;
preliminaryClasses('OFF') = OFFs;
preliminaryClasses('ON-OFF') = ON_OFFs;
preliminaryClasses('FLAT') = FLAT;

preliminaryClasses('ON.ONLY-BARS') = ONLY_BARS_ONs;
preliminaryClasses('OFF.ONLY-BARS') = ONLY_BARS_OFFs;
preliminaryClasses('ON-OFF.ONLY-BARS') = ONLY_BARS_ON_OFFs;
preliminaryClasses('FLAT.ONLY_BARS') = ONLY_BARS_FLAT;

preliminaryClasses('ON.DS') = DS_ONs;
preliminaryClasses('OFF.DS') = DS_OFFs;
preliminaryClasses('ON-OFF.DS') = DS_ON_OFFs;
preliminaryClasses('FLAT.DS') = DS_FLAT;

% Choose which types to clusterize
typesToCluster = {'ON', 'OFF', 'ON-OFF', 'FLAT'};  






