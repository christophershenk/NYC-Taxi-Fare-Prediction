# NYC Taxi Fare Prediction and Analysis

## Description
This project conducts a detailed exploration and analysis of the New York City Taxi fares dataset to answer pivotal questions and predict taxi fare amounts. Utilizing R programming, the project employs various statistical and machine learning models, including linear models, generalized additive models, random forests, and gradient boosting trees, to derive insights and make predictions based on different features of the dataset.

### Objectives
- To identify the location with the most pickups.
- To determine which weekday and which hour have the highest average trip fare.
- To analyze the effect of the number of passengers on the fare amount.
- To predict the fare amount using various predictive models and compare their performances.

### Questions Answered
1. Which location has the most pickups?
2. Which weekday has the highest average trip fare?
3. Which hour has the highest average trip fare?
4. Does the number of passengers significantly affect the fare amount?

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Technologies and Skills Used](#technologies-and-skills-used)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Installation
This project is implemented in R. Ensure that R is installed on your machine. If not, download and install it from [The R Project for Statistical Computing](https://www.r-project.org/).

### Required R Packages
The project requires the following R packages:
- ggplot2
- mgcv
- ranger
- caret
- gbm
- xgboost

Install these packages in R using the following command:
```R
install.packages(c("ggplot2", "mgcv", "ranger", "caret", "gbm", "xgboost"))
