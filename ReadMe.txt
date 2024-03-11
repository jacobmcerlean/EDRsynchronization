Implementation of EDR synchronization algorithm, from 
"Unsupervised Ensembling of Multiple Software Sensors with Phase Synchronization: 
A Robust Approach For Electrocardiogram-derived Respiration."

Repo includes:

  example.m: example file to demonstrate algorithm
  tradEDR.m, dmEDR.m, pcaEDR.m, qrsEDR.m: individual EDR estimates
  getRQI_total_signal: returns RQI of an EDR estimate signal
  synchEDR.m: phase aligns a collection of EDR estimates
  ensemble.m: produces an ensemble signal from (phase-aligned) EDR estimates
  EDR_Regression.m: returns gamma-score, otd, and earr metrics for EDR against reference signal
  CHMH database: ecg, cflow, tho, and abd signals from CGMH dataset. The dataset is not loaded to 
                GitHub due to file size constraints, but can be obtained by download at the following link:
                https://duke.box.com/s/94paegobuv4bxzkgb467avdggciuabw4
  Please email jacob.mcerlean@duke.edu with any questions.
  SHHS database: Request data access at https://sleepdata.org/datasets/shhs


Repo Author: Jacob McErlean 16 January, 2024

In collaboration with John Malik, Yu-Ting Lin, Ronen Talmon, and Hau-Tieng Wu
