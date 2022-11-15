library(tidyverse)
library(nycflights13)

flights %>%
  select(origin, dest, distance) %>%
  arrange(origin, dest) %>%
  pivot_wider(names_from = origin,
              values_from = distance,
              values_fn = mean) %>%
  arrange(dest)

flights %>%
  filter(arr_delay < 300,
         dep_delay < 300) %>%
  ggplot(aes(x = dep_delay,
             y = arr_delay,
             colour = origin)) +
  geom_point(size = 1,
             alpha = 0.5)

long_crisp <- crisp_data %>%
  pivot_longer(cols = packet_appearance:texture,
               names_to = 'category',
               values_to = 'rating')

write.csv(long_crisp, 'week-02.75-tidy-data-and-ggplot/bacon_flavoured_crisps_final.csv')

flights %>%
  select(where(is.numeric)) %>%
  pivot_longer(cols = -flight,
               names_to = 'stat',
               values_to = 'value') %>%
  filter(stat != 'year') %>%
  ggplot(aes(x = value,
             fill = stat)) +
  geom_histogram(colour = 'black') +
  facet_wrap(vars(stat),
             scales = 'free') +
  theme(legend.position = 'none')

View(flights) %>%
  filter(arr_delay < 300,
         dep_delay < 300) %>%
  slice_sample(prop = 0.1) %>%
  ggplot(aes(x = dep_delay,
             y = arr_delay,
             colour = origin)) +
  geom_point(size = 0.5,
             alpha = 0.5)

# pivot_wider 

flights %>%
  select(flight, carrier, dest, distance) %>%
  pivot_wider(values_from = distance,
              values_fn = 'max',
              names_from = dest)


