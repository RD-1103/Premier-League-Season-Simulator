Premier League Season Simulator

Description:
This project simulates the Premier League season using historical data and statistical models to predict outcomes.

Data Sources:
	• Seasons: 2021/2022, 2022/2023, 2023/2024, 2024/2025
	• Emphasis on recent performance with weighted statistics.
 
Model Overview:
	Statistics Used:
	• Expected Goals (xG) For and Against
	• Home and Away splits
	Weighting:
	• 2024/2025: 50%
	• 2023/2024: 30%
	• 2022/2023: 15%
	• 2021/2022: 5%
	Methodology:
	• Poisson Distribution for goal prediction
	• Bernoulli trials for match outcome simulation


Installation:
git clone https://github.com/RD-1103/Premier-League-Season-Simulator.git
cd Premier-League-Season-Simulator

// Ensure these packages are installed and then loaded in your R environment.
install.packages(c("dplyr", "tidyr", "ggplot2"))

library(dplyr)
library(tidyr)
library(ggplot2)

// Ensure the file `PL_results_24_25.csv` is your directory and update the file path in the script.
