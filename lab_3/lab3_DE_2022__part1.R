
# Лабораторна робота №3.  -------------------------------------------------


# Віконні фінкції в R ------------------------------------------------------

library(readr)
library(dplyr)

# завантаження даних
salary <- read_csv("data\\salary_analysis.csv")

# структура таблиці; дані щодо заплатні, як у попередньому кейсі, але за 15 міс
str(salary)

# Типи віконних функцій ---------------------------------------------------

# агрегуючі
# ранжуючі
# зсувні
# накопичувальне агрегування


# ######################
# Прості віконні функції
# ######################

# добавляємо сумарну зарплату по відділу
salary <- salary %>% 
  group_by(departmen, month) %>%
  mutate(total_dep = sum(total))

# який відсоток зп отримує кожен співробітник в рамках відділу
salary <- salary %>%
  mutate(staff_rate = total / total_dep)

# вивести по кожному співробітнику різницю від средньої зарплатні по відділу
# в рамках місяца
salary %>%
  group_by(departmen, month) %>%
  mutate(from_dep_avg = total / mean(total))


# ######################
# Ранжуючі віконні функції
# ######################

# співробітники, які мають найбільшу частку від ФОТ свого відділу по місяцях
rating_by_dap_rate <- 
  salary %>%
  group_by(month) %>%
  mutate(rank = min_rank(staff_rate)) %>%
  filter(rank ==  max(rank)) %>%
  arrange(month)


# співробітники, які отримали максимальний бонус в рамках кожного місяця
salary %>%
  group_by(month) %>%
  mutate(rank = dense_rank(bonus)) %>%
  filter(rank ==  max(rank)) %>%
  arrange(month) -> maxbonus

# співробітники, які отримали максимальні бонуси за 2019 рік
# по відділах
salary %>%
  filter(grepl("^2019", month)) %>%    # фильтр по року
  group_by(name_dep, name_emploee) %>% # групування по відділу і співробітнику
  summarise(bonus = sum(bonus)) %>%    # агрегація даних
  group_by(name_dep) %>%               # створення вікна по відділу
  mutate(max_bonus = max(bonus)) %>%   # ррозрахунок максимального бонуса в рамках відділу
  filter(bonus == max_bonus)           # залишаємо тих, чий бонус дорівнює максимальному

# ######################
# Зсувні віконні функції
# ######################

# Вивести зростання зарплатні кожного спіробітника відносно минулого місяця
salary_grow <-
  salary %>%
  arrange(month) %>%      # задаємо сортування по місяцях
  group_by(id) %>%        # разбиваємо таблицю на вікна по співробітниках
  mutate(total_grow_rate = ( total - lag(total, order_by = month) ) / total ) # розрахунок зростання

# вивести співробітників з максимальним зростанням зарплат
# в кожному місяцю
salary %>%
  group_by(id) %>%        # розбиваємо таблицю на вікна по співробітниках
  mutate(total_grow_rate = ( total - lag(total, order_by = month) ) / total  ) %>%  # розрахунок зростання
  group_by(month) %>%
  filter(total_grow_rate == max(total_grow_rate, na.rm = T))


# Накопичувальне агрегування ----------------------------------------------

cum_salary <- 
  salary %>% 
  filter(grepl("^2019", month)) %>% 
  group_by(id) %>% 
  arrange(month) %>% 
  mutate(cum_salary = cumsum(total)) %>% 
  arrange(id)


?dnorm()









