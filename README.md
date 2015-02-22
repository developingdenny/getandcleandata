## Get and Clean Data
Provides a script to produce tidy data set from data captured during a Human Activity Recognition project. 

The Human Activity Recognition project collected accelerometer data from a Samsung Galaxy S smartphone.  Full information regarding the project can be found at:
 
[Human Activity Recognition Project](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones] "Human Activity Recognition Project")

# Source data

Available at: 
[Source Data Files](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "Compressed source data")

# Contents

run_analysis.R: a script that converts the source data files into a tidy data set providing just mean and standard deviation measurements along with Activity labels for improved legibility.


# Usage

All source data input files must be contained within the same directory as script's working directory at the time of its execution.

- obtain source data
- unzip source data
- move all zip data files to working directory
- execute script
