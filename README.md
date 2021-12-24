# The project's goal
To denoise electrocardiogram (ECG) signals collected on zebrafish and dectect P, QRS, T wave and classify if the signal has sinus arrest.

## Algorithms in detail
Due to uncertainties in measurement, such as unexpected strong movement of fish or electrode dislocation, there are some parts of the ECG data dominated by noise. For real-time recording and processing, first, ECG data are checked to look for non-ECG periods. The following illustrates the algorithm I came up with to deal with that.
<img src = "https://github.com/taile2007/Zebrafish-feature-extraction/blob/master/09.PNG" width="300" height="300">
