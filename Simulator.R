install.packages(c("dplyr", "tidyr", "ggplot2"))

library(dplyr)
library(tidyr)
library(ggplot2)


xg_data <- data.frame(
  Team = c("Arsenal", "Aston Villa", "Bournemouth", "Brentford", "Brighton", "Chelsea", 
           "Crystal Palace", "Everton", "Fulham", "Ipswich", "Leicester", "Liverpool", 
           "Man City", "Man Utd", "Newcastle", "Nottingham Forest", 
           "Southampton", "Tottenham", "West Ham", "Wolves"),
# these are for all 38 games in season
xG_2022_2023 = c(73.72, 52.44, 44.84, 53.96, 73.72, 61.18, 50.92, 52.82, 53.96, 37.24, 50.92,
                 71.82, 74.48, 67.26, 67.26, 44.84, 50.16, 61.56, 57.38, 50.16),
xGA_2022_2023 = c(45.98, 55.86, 74.48, 67.26, 48.26, 56.24, 58.90, 66.50, 62.70, 71.44, 62.70,
                  49.02, 37.62, 56.62, 50.16, 66.88, 60.80, 62.32, 60.80, 64.60),
xG_2023_2024 = c(69.54, 55.48, 57.38, 52.82, 60.42, 60.80, 50.16, 54.34, 54.72, 45.32, 45.60,
                 79.04, 77.14, 57.38, 59.66, 48.64, 47.03, 65.74, 49.40, 48.26),
xGA_2023_2024 = c(34.96, 52.44, 58.52, 61.56, 50.54, 57.38, 52.44, 55.86, 59.28, 67.26, 63.84,
                  46.74, 35.34, 65.74, 57.38, 57.76, 65.55, 52.44, 70.30, 62.70),
# this is for games played so far (12)
xG_2024_2025 = c(23.53, 23.97, 23.17, 20.79, 20.56, 23.56, 17.31, 14.83, 22.39, 15.26, 14.29,
                 27.81, 26.04, 20.31, 17.53, 18.12, 15.71, 26.45, 18.05, 13.14),
xGA_2024_2025 = c(14.91, 18.01, 18.53, 21.48, 20.32, 18.28, 22.93, 20.45, 13.73, 29.45, 28.61,
                  12.36, 18.68, 21.13, 19.09, 14.84, 28.41, 16.52, 22.86, 22.22)
)

# home advantage data frame
home_advantages <- data.frame(
  Team = c("Arsenal", "Aston Villa", "Bournemouth", "Brentford", "Brighton",
           "Chelsea", "Crystal Palace", "Everton", "Fulham", "Ipswich",
           "Leicester", "Liverpool", "Man City", "Man Utd", "Newcastle",
           "Nottingham Forest", "Southampton", "Tottenham", "West Ham", "Wolves"),
  home_ppg_diff = c(1.00, -0.17, 0.84, 2.50, 0.19,
                    -0.67, 0.33, 0.17, 0.34, -0.16,
                    0.00, -0.17, 0.50, 0.67, 0.34,
                    -0.50, 0.53, 0.83, -0.16, -0.16)
)

# finding weighted xG and xGA
xg_data <- xg_data %>%
  mutate(
    weighted_xG = (xG_2022_2023 * 0.15) + (xG_2023_2024 * 0.35) + (xG_2024_2025 * 0.50),
    weighted_xGA = (xGA_2022_2023 * 0.15) + (xGA_2023_2024 * 0.35) + (xGA_2024_2025 * 0.50)
  )

simulate_match <- function(xG1, xGA1, xG2, xGA2, home_ppg_diff) {
  # added a small boost to home team's xG based on PPG difference
  # we are using a smaller factor for scale (0.25) so it doesn't inflate the difference
  home_boost <- max(0, home_ppg_diff * 0.25)
  
  adjusted_xG1 <- xG1 + home_boost
  
  goals_team1 <- rpois(1, adjusted_xG1)
  goals_team2 <- rpois(1, xG2)
  
  if (goals_team1 > goals_team2) return(3)
  else if (goals_team1 < goals_team2) return(0)
  else return(1)
}

actual_results <- read.csv('/Users/ryandhawan/Desktop/PL_Results_24_25.csv')
# make results dataframe with actual played games so far this season
simulation_results <- data.frame(
  Home_Team = actual_results$Home.Team,
  Away_Team = actual_results$Away.Team,
  Points_Home = ifelse(actual_results$HT.Score > actual_results$AT.Score, 3,
                      ifelse(actual_results$HT.Score == actual_results$AT.Score, 1, 0)),
  Points_Away = ifelse(actual_results$AT.Score > actual_results$HT.Score, 3,
                      ifelse(actual_results$HT.Score == actual_results$AT.Score, 1, 0))
)
# function to check from the csv file
has_fixture_been_played <- function(home_team, away_team, played_fixtures) 
{
  return(any((played_fixtures$Home_Team == home_team & 
              played_fixtures$Away_Team == away_team)))
}

# data frame to store results from all simulations
all_simulations <- data.frame(Team = character(), Simulation = numeric(), 
                             Points = numeric(), stringsAsFactors = FALSE)
n_simulations <- 1000
for(sim in 1:n_simulations) 
{
  # reset simulation_results to only the actual games for each new simulation
  simulation_results <- data.frame(
    Home_Team = actual_results$Home.Team,
    Away_Team = actual_results$Away.Team,
    Points_Home = ifelse(actual_results$HT.Score > actual_results$AT.Score, 3,
                        ifelse(actual_results$HT.Score == actual_results$AT.Score, 1, 0)),
    Points_Away = ifelse(actual_results$AT.Score > actual_results$HT.Score, 3,
                        ifelse(actual_results$HT.Score == actual_results$AT.Score, 1, 0))
  )
  
  # simulation loop for remaining matches to be played
  for (i in 1:nrow(xg_data)) 
  {
    for (j in 1:nrow(xg_data)) 
    {
      if (i != j) 
      {
        if (!has_fixture_been_played(xg_data$Team[i], xg_data$Team[j], simulation_results)) 
        {
          match_result <- simulate_match(
            xg_data$weighted_xG[i], xg_data$weighted_xGA[i], xg_data$weighted_xG[j], xg_data$weighted_xGA[j],
            home_advantages$home_ppg_diff[which(home_advantages$Team == xg_data$Team[i])]
          )
          
          if (match_result == 3) 
          {
            points_home <- 3
            points_away <- 0
          } else if (match_result == 0) 
          {
            points_home <- 0
            points_away <- 3
          } else 
          {
            points_home <- 1
            points_away <- 1
          }
          
          simulation_results <- rbind(simulation_results, data.frame(
            Home_Team = xg_data$Team[i], Away_Team = xg_data$Team[j],
            Points_Home = points_home, Points_Away = points_away
          ))
        }
      }
    }
  }
  
  # calculate pts for this simulation
  sim_points <- simulation_results %>%
    group_by(Home_Team) %>%
    summarise(Home_Points = sum(Points_Home)) %>%
    left_join(
      simulation_results %>%
        group_by(Away_Team) %>%
        summarise(Away_Points = sum(Points_Away)),
      by = c("Home_Team" = "Away_Team")
    ) %>%
    mutate(Total_Points = Home_Points + Away_Points) %>%
    rename(Team = Home_Team)
  
  # add simulation results to all_simulations
  all_simulations <- rbind(all_simulations,
    data.frame(Team = sim_points$Team, Simulation = sim, Points = sim_points$Total_Points)
  )
}
# avg points across all simulations
final_points <- all_simulations %>%
  group_by(Team) %>%
  summarise(Expected_Points = mean(Points))
# visualises points
ggplot(final_points, aes(x = reorder(Team, Expected_Points), y = Expected_Points)) +
  geom_bar(stat = "identity", fill = "#2b6b9a") + coord_flip() + theme_minimal() +
  labs(title = "Premier League 2024/25 Projected Final Points (1000 Simulations Average)",
  x = "Team", y = "Expected Points") +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 12)
  )
