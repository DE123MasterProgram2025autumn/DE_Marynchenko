
# Лабораторна робота №3.  -------------------------------------------------


# Обробка JSON та XML-структур --------------------------------------------

# Пакет tidyr: Робота з вкладеними стовпчиками ----------------------------

library(tidyr)
library(dplyr)
library(jsonlite)

# #################
# задача 1:
# маємо json файл зі списком співробітником
# 1. необхідно отримати список співробітників, яким передбачені бонуси


download.file("https://raw.githubusercontent.com/selesnow/r4excel_users/52ce5604b653ee0490c299907b7184992d5a5107/lesson_10/simple.json",
              destfile = "data\\simple.json")

download.file("https://raw.githubusercontent.com/selesnow/r4excel_users/52ce5604b653ee0490c299907b7184992d5a5107/lesson_10/hard_data.json",
              destfile = "data\\hard_data.json")


# читаємо json-файл
staff_dict <- read_json('https://raw.githubusercontent.com/selesnow/r4excel_users/master/lesson_10/simple.json')

# трасформуємо json у tibble frame
staff_dict <- tibble(employee = staff_dict)

# 2. Порахувати середню зарплату по відділах

# розгортаємо кожен json вузол у вигляді окремого рядка
# фільтруємо таблицю, залишаючи тільки тих співробітників, у яких є бонуси.

staff_dict %>%
  unnest_wider(employee) %>%
  filter(bonus > 0)

# считаем среднюю зарплату по отделам
staff_dict %>%
  unnest_wider(employee) %>%
  group_by(department) %>%
  summarise(average_salary = mean(salary))


# ##########################
# Завдання 3:

# є json файл зі списком співробітників
# вивести список співробітників із їх зоною відповідальності

# тут маємо складнішу JSON-структуру з глибшою ієрархією, яку не можна за один крок привести до датафрейму.
# якце зробити? зробимо це покроково
staff_dict <- read_json('https://raw.githubusercontent.com/selesnow/r4excel_users/master/lesson_10/hard_data.json')

# трансформуємо json у tibble frame
staff_dict <- tibble(employee = staff_dict)

## варіант розв'язання #1 
staff_dict %>%
  unnest_wider(employee) %>%
  select(name, department, salary, skills) %>%
  unnest_wider(skills) %>%
  select(name, department, salary, practics) %>% 
  unnest_longer(practics) %>%
  group_by(name, department, salary) %>%
  summarise(practics = paste(practics, collapse = ", "))

## варіант розв'язання #2 (простіший варіант)
staff_dict %>%
  hoist(employee, 
        name = "name",
        department = "department",
        salary = "salary",
        practics = c("skills", "practics")) %>%
  select(-employee) %>%
  group_by(name, department, salary) %>%
  mutate(practics = paste(unlist(practics), collapse = ", "))

# ##########################
# задача 4:
# є json файл зі списком співробітників
# підняти на 20% зарплату співробітникам мовою R

staff_dict %>%
  hoist(employee, 
        name = "name",
        salary = "salary",
        langs = c("skills", "lang")) %>% 
  select(-employee) %>%
  unnest_longer(langs) %>%
  filter(langs == 'R') %>%
  mutate(new_salary = salary * 1.2)

# задача 5:
# є json файл зі списком співробітників
# підняти на 30% зарплату співробітникам, які володіють більш ніж однією мовою програмування

staff_dict %>%
  hoist(employee, 
        name = "name",
        salary = "salary",
        langs = c("skills", "lang")) %>% 
  select(-employee) %>%
  group_by(name) %>%
  unnest_longer(langs) %>%
  filter( ! is.na(langs) ) %>%
  group_by( name, salary ) %>%
  summarise( langs_num = length(langs) ) %>%
  filter(langs_num > 1) %>%
  mutate( new_salary =  salary * 1.3 )

