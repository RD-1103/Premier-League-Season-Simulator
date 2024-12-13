Repository for Premier League Season Simulator

Data for the model:
	• I used data from the 2021/2022, 2022/2023, 2023/2024, and 2024/2025 seasons
	• Used stats from previous years to understand how teams perform, but I gave more weight to recent seasons because I want current performance to be given the most importance

What stats to use
	1. xG For and Against will adjust the model's scoring rate
	2. Home and Away splits

Weighting of seasons
	• 2024/2025 (current season): 50% weight.
	• 2023/2024: 30% weight.
	• 2022/2023: 15% weight.
	• 2021/2022: 5% weight.
For a stat like xG For, the weighted value will look like: xGweighted = (50% x xG2024/25) + (30% x xG2023/24) + …

Model:
	• Poisson Distribution: Find the average goals a team scores and lets in (using data above). That will give the variables λhome​ and λaway​.
	• Create formula that includes all the statistics above to turn it into a percentage of winning against the other team,
   and then run 1000 bernoulli trials to see how many times they'd actually win
