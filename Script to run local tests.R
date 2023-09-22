# Script to run tests
db <- read_excel("../Random_data_withNA_and_blanks.xlsx",
                 na = c("",NA))

db2 <- db %>% 
  select("FG_01":"FG_10") %>% 
  # Remove rows with NA and empty cells (All empty cells are assigned as NA when importing)
  na.omit() %>% 
  mutate(FGDS = rowSums(.[1:10]),
         MDDW = ifelse(FGDS > 4, 1, 0))


ggplot(db2, aes(x=FGDS)) +
    geom_histogram(binwidth = 1, color="#207cb4", fill="#a8cce4") +
    scale_x_continuous(breaks=0:10) +
    labs(title = "Food Group Diversity Score",
         subtitle = "Histogram",
         caption = "Juan Pablo Parraguez") +
    theme_minimal()


db3 <- db2 %>% 
  pivot_longer(cols=c("FG_01":"FG_10"),
               names_to= "FG",
               values_to= "consumed") %>% 
  group_by(FG) %>% 
  summarise(Consumption = round(mean(consumed),4)*100)

ggplot(db3) +
  aes(x = FG, y = Consumption, fill = FG) +
  geom_col() +
  geom_text(aes(label = Consumption), hjust = -0.25, size = 3) +
  scale_fill_brewer(palette = "Paired", direction = 1) +
  ylim(0,100) +
  labs(
    x = "Food groups",
    y = "Consumption of food group",
    title = "Percentage of women consuming different food groups",
    subtitle = "MDD_W Main food groups",
    caption = "Juan Pablo Parraguez"
  ) +
  coord_flip() +
  theme_minimal() +
  theme(legend.position = "none")
  