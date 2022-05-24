# CLUSTERING RESULTS

## Methods and Taxonomy:

- Cells **responding consistently** to the Euler Stimulus are first divided in 4 macro sets according to the gradient of their response to the step in the Euler Stimulus: `ON`, `OFF`, `ON-OFF`, `OTHERS`

  - *Direction Selective* cells are then identified, labeled accordingly (example: `ON.DS` or `OTHERS.DS`), and removed from the macro sets.

  - Each set is iteratively sub-divided in different subsets. Sets are subdivided multiple times. For each subdivision, an integer ID is added to the sub set label (example: `OFF.4.2`, `ON-OFF.3`)

  - After the clustering process, the sub-set that did not meet my classification requirements have been removed. These sub-sets are labeled with the `_PRUNED` suffix, and should not  be considered as consistent classes (example: `ON.1.1_PRUNED`,  `OTHERS_PRUNED`)

    ​

- The remaining cells are divided in the following macro clusters, and no they are not further subdivided.

  - `NO-RESP`: cells not responding consistently neither to Euler Stimulus, neither to Bars
  - `ONLY-BARS`: cells responding consistently only to bars
  - `ONLY-BARS.DS`: cells responding consistently only to bars and direction selective
  - `NO-AVAIL`: cells not responding consistently to Euler Stimulus; response to Bars not available.

In the following I explain how to interpret the tables and the graphs representing the results of my clustering work.



## Tables:

1. ***cellsTable***: table summing up all the info relative to each single cell.

   1. *Experiment*: ID code of the experiment (typically date in yymmdd format).

   2. *N*: ID number of the cell (relative to the experiment).

   3. *Soma*: Size of the cell soma (the cell ROI) in pixels.

   4. *Fluo*: The average fluorescence of the cell's response to the Euler Stimulus

   5. *eulerQI*:  Quality index of the cell's response to Euler Stimulus, computed as std_over_time(mean_over_repetitions(EulerResponse)) / mean_over_repetitions(std_over_time(EulerResponse))

   6. *barsQI*:   Quality index of the cell's response to Bars Stimulus, computed as

      std_over_time(mean_over_repetitions(BarsResponse)) / mean_over_repetitions(std_over_time(BarsResponse))

   7. *eulerQT*: Quality test of the cell's response to Euler Stimulus. 

      Value is 1 if eulerQI is above the quality threshold, 0 otherwise.

   8. *barsQT*:  Quality test of the cell's response to Bars Stimulus. 

      Value is 1 if barsQI is above the quality threshold, 0 otherwise.

   9. *EulerON*:  Value is 1 if the cell responds to the positive edge of the first step in the Euler Stimulus, 0 otherwise.

   10. *EulerOFF*: Value is 1 if the cell responds to the negative edge of the first step in the Euler Stimulus, 0 otherwise.

   11. *BarsON*:  Value is 1 if the cell responds to the positive edge of the bar movement in the Bars Stimulus, 0 otherwise.

   12. *BarsOFF*: Value is 1 if the cell responds to the negative edge of the bar movement in the Bars Stimulus, 0 otherwise.

   13. *DS*: Value is 1 if the cell is direction selective, 0 otherwise.

   14. *OS*: Value is 1 if the cell is orientation selective, 0 otherwise.

   15. *DS_K*: An index of the magnitude of the direction selectivity of the cell

   16. *OS_K*: An index of the magnitude of orientation selectivity of the cell

   17. *DS_angle*: (for direction selective cells) the angle representing the direction to which the cell is selective.

   18. *OS_angle*: (for orientation selective cells) the angle representing the orientation to which the cell is selective

   ​

2. ***clustersTable***: table mapping each cell to its class.

   1. *Experiment*: ID code of the experiment (typically date in yymmdd format).

   2. *N*: ID number of the cell (relative to the experiment).

   3. *Type*: Class ID to which the cell belongs (see explanation above in *paragraph .1*).

   4. *Prob*: Array of "class membership probabilities" `[p1, p2, ..., pN]`  where:

      - `p1 = P(cell belongs to [C1])`
      - `p2 = P(cell belongs to [C1].[C2] / cell belongs to [C1])`
      - ...
      - `pN = P(cell belongs to [C1].[C2]...[CN] / cell belongs to [C1].[C2]...[CN-1])`

   ​

3. ***classesTable***: table summarizing the info of each cell class.

   1. *Name*: Class ID (see explanation above in *paragraph .1*).

   2. *Size*: Number of cells belonging to this class.

   3. *AvgSTD*: Indicator of the class consistency. Computed as mean_over_time(std_over_cells(Cell_by_EulerResponse_Matrix)).

   4. *SomaMean*: Mean of the soma size over the class members.

   5. *SomaSTD*: STD of the soma size over the class members

   6. *FluoMean*: Mean of the average Fluorescence over the class members.

   7. *FluoSTD*: STD of the average Fluorescence over the class members

   8. *Indexes*: Logical Indexing, consistent with the way cells are listed in the `clusterTable` table, representing the cells belonging to the class.



## Plots:

1. ***MacroClusters***:  the 4 macro classes `ON`, `OFF`, `ON-OFF` and `OTHER` plotted in the 3 Principal Components Space
   ​
2. ***LeafClusters:***   all the final classes plotted in the 3 Principal Components Space. `PRUNED`, `NOT RESPONDING` and `DS` are excluded.
   ​
3. ***ClassResponses***: for each final class (. `PRUNED`, `NOT RESPONDING` and `DS` are excluded), I plot a graph representing:
   1. In red - the mean of the response of all the cells belonging to the class
   2. In gray - the STD of the response of all the cells belonging to the class