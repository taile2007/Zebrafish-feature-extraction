# The project's goal
To denoise electrocardiogram (ECG) signals collected on zebrafish and dectect P, QRS, T wave and classify if the signal has sinus arrest.

## Algorithms in detail
Due to uncertainties in measurement, such as unexpected strong movement of fish or electrode dislocation, there are some parts of the ECG data dominated by noise. For real-time recording and processing, first, ECG data are checked to look for non-ECG periods. The following illustrates the algorithm I came up with to deal with that.

<img src = "https://github.com/taile2007/Zebrafish-feature-extraction/blob/master/09.PNG" width="400" height="400">
Specifically, the maximum and minimum values of each interval will be detected (red and dashed orange lines in the above figure), then two thresholds (black lines) will be set up by taking the average of all maximum points and minimum points in each interval. Therefore, those meaningless points which are higher than the threshold could be found. Then, the distance between two such successive points would be found. If it is greater than 1000 samples, the data will be partitioned into different sub-segments (1st, 2nd and 3rd segments).
