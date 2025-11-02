
# Лабораторна робота №3.  -------------------------------------------------

# Більш детально див. статтю: https://habr.com/ru/post/444622/

# Частина ІІ. Пакет tidyr. Перетворенння таблиць з широкого формату у довгий і навпаки --------


# Функції pivot_longer, pivot_wider ---------------------------------------

library(tidyr)
library(dplyr)
library(readxl)
library(readr)

# скачуємо файл
# скачуємо файл з Інтернету
# download.file("https://github.com/selesnow/r4excel_users/blob/master/lesson_9/sales.xlsx?raw=true", 
#               destfile = "data\\sales.xlsx", 
#               mode = "wb")

# завантаження даних
data <- read_excel('data\\sales.xlsx', 
                   sheet = 'data')

# ==================
# Задача: порівняти середньомісячні продажі між регіонами
# у першому кварталі 2019 і 2020 років
# ==================

# заповнюємо стовпчик region
data <- fill(data, region, .direction = 'down')

# приводимо таблицу до охайного вигляду
data <- pivot_longer(
  data, 
  cols = `january 2019`:`march 2020`, 
  names_to  = 'month', 
  values_to = 'sales')

# розділимо стовпчик month на рік і місяць
data <- separate(data, 
                 col = 'month', 
                 into = c('month', 'year'), 
                 remove = TRUE, sep = " ")

# нагадуємо умову задачі: 
# Задача: порівняти середньомісячні продажі між регіонами
# у першому кварталі 2019 і 2020 років

# фінальні розрахунки
data <-
  data %>%
  filter(month %in% c('january', 'february', 'march')) %>%
  group_by(region, year) %>%
  summarise(sales = mean(sales))

# переводимо підсумковий результат з довгого у широкий
data %>%
  pivot_wider(names_from = year, 
              values_from  = sales) %>%
  mutate(grow = (`2020` - `2019`) / `2020` * 100) %>%
  arrange(desc(grow))

# запишемо все через пайплайни
read_excel('data\\sales.xlsx', 
           sheet = 'data') %>%
  fill(region, 
       .direction = 'down') %>%
  pivot_longer(
    cols = `january 2019`:`march 2020`, 
    names_to  = 'month', 
    values_to = 'sales') %>%
  separate(col = 'month', 
           into = c('month', 'year'), 
           remove = TRUE, sep = " ") %>%
  filter(month %in% c('january', 'february', 'march')) %>%
  group_by(region, year) %>%
  summarise(sales = mean(sales)) %>%
  pivot_wider(names_from = year, 
              values_from  = sales) %>%
  mutate(grow = (`2020` - `2019`) / `2020` * 100) %>%
  arrange(desc(grow))


# ###############################
# Специфікації
# Задача: обчислити % повернень від суми продажів
# ###############################

shop_data_2019 <- read_delim(
  'https://raw.githubusercontent.com/selesnow/r4excel_users/master/lesson_9/shop_data_2019.csv',
  delim = ';', locale = locale(decimal_mark = ",") )

# будуємо специфікацію
wild_spec <- build_wider_spec(shop_data_2019, 
                              names_from = 'key', 
                              values_from = 'value')

# застососвуємо специфікацію
pivot_wider_spec(shop_data_2019, spec = wild_spec) %>%
  mutate(refund_rate = refund / ( sale + upsale )) %>%
  arrange(desc(refund_rate))

# читаємо дані аналогичної структури
shop_data_2020 <- read_delim(
  'https://raw.githubusercontent.com/selesnow/r4excel_users/master/lesson_9/shop_data_2020.csv',
  delim = ';', locale = locale(decimal_mark = ","))

# применяем спецификацию
shop_data_2020 %>%
  pivot_wider_spec(spec = wild_spec) %>%
  mutate(refund_rate = refund / ( sale + upsale )) %>%
  arrange(desc(refund_rate))

# зберегти  специфікацію
saveRDS(object = wild_spec, file = 'data\\spec.rds')

# завантажити специфікацію
new_wild_spec <- readRDS('data\\spec.rds')

# застосовуємо
pivot_wider_spec(shop_data_2019, spec = new_wild_spec) %>%
  mutate(refund_rate = refund / ( sale + upsale )) %>%
  arrange(desc(refund_rate))

# посилання на статтю (детально про специфікації)

# https://habr.com/ru/post/444622/
  
  

