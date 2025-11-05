
# Лабраторна робота № 5 ---------------------------------------------------



# Функціональне програмування. Пакет purrr --------------------------------------------------------------


# https://selesnow.github.io/iterations_in_r/%D0%BF%D0%B0%D0%BA%D0%B5%D1%82-purrr.html

# Урок 4 Пакет purr

# install.packages('purrr')
library(purrr)
library(dplyr)

# функції map_*------------------------------------------------------------


## Генеруємо випадкові вибірки з нормальним розподіленням 
# (приклад оператора, на виході дата фрейм)
v_sizes <- c(5, 12, 20, 30)

v_sizes %>% 
  map(rnorm)

# використовуємо додакові аргументи
rnd_list <- map(v_sizes, runif, min = 10, max = 25)

# Отримуємо вектори (приклад оператора, на виході вектор)
map_dbl(rnd_list, mean)
map(rnd_list, mean)

# аналог у циклі
for ( i in rnd_list ) cat(mean(i), " ")

# приклад з таблицями
# У прикладі генерується певна кількість тразакцій
products <- tibble(
  product_id = 1:10,
  name = c('Notebook',
           'Smarthphone',
           'Smart watch',
           'PC',
           'Playstation',
           'TV',
           'XBox',
           'Wifi router',
           'Air conditioning',
           'Tablet'),
  price = c(1000, 850, 380, 1500, 1000, 700, 870, 80, 500, 150)
)

managers <- c("Svetlana", "Andrey", "Ivan")

clients  <- paste0('client ', 1:30)

# Функція генерації транзакції
create_transaction <- function(
    transaction_id,
    products_number = 3,
    product_dict,
    counts = c(1, 3),
    dates = c(Sys.Date() - 30, Sys.Date()),
    managers,
    clients
) {
  # випадковим чином генеруємо транзакцію
  transaction <- sample_n(product_dict, size = products_number, replace = F) %>%
    mutate(date = sample( seq(dates[1], dates[2], by = 'day'), size = 1 ),
           manager  = sample(managers, 1),
           clients  = sample(clients, 1),
           count    = sample(seq(counts[1], counts[2]), products_number, replace = T),
           sale_sum = price * count,
           transaction_id)
  
  return(transaction)
  
}

# генерируємо 5 транзакцій (вихідні таблиці об'єднані функцією bindrows(), map_dfc() - bindcols())
map_dfr(1:5,
        create_transaction,
        products_number = sample(1:10, 1),
        product_dict = products,
        counts = c(1, 3),
        dates = c(Sys.Date() - 30, Sys.Date()),
        managers = managers,
        clients = clients,
        .id = 'transaction_id') # Генерує стовпчик з id транзаrції



# Ітерування по декількох об'єктах одночасно ------------------------------


# функції pmap_* ----------------------------------------------------------
# для ітерування по двох об'ектах можна використовувати функції map2_*
x <- list(1, 1, 1)
y <- list(10, 20, 30)

map2(x, y, ~ .x + .y)

# map2(x, y, ~ '+')
# map2_int(x, y, ~ .x + .y)
# map2_dbl(x, y, ~ .x + .y)
# map2(x, y, sum)


# Якщо потрібно ітерувати більш ніж по двох об'єктах використовуємо pmap_*
params <- tibble(
  transaction_id  = 1:3,
  products_number = c(4, 2, 6),
  product_dict    = list(products[1:8, ], products[3:10, ], products),
  counts          = list(c(1, 3), c(7, 10), c(2, 7)),
  dates           = list(c(as.Date('2021-11-01'), as.Date('2021-11-04')),
                         c(as.Date('2021-11-05'), as.Date('2021-11-08')),
                         c(as.Date('2021-11-09'), as.Date('2021-11-14'))),
  managers        = list(managers, managers, managers),
  clients         = list(clients, clients, clients)
)

tranaction_df <- pmap_df(params, create_transaction)



# функції walk ------------------------------------------------------------

# генеруємо 7 транзакцій і хочемо їх зберегти в 7 різних файлів
transactions <- map(1:7,
                    create_transaction,
                    products_number = sample(1:10, 1),
                    product_dict = products,
                    counts = c(1, 3),
                    dates = c(Sys.Date() - 30, Sys.Date()),
                    managers = managers,
                    clients = clients)

file_names <- paste0('transaction_', 1:7, ".csv")

walk2(
  .x = transactions,
  .y = file_names,
  write.csv
)

getwd()

# функції keep і discard (фільтрація отриманих результатів за заданою умовою) --------------------------------------------------

# переглядаємо суму продажів  у кожній з транзакцій
transactions %>% 
  map_dbl(~ sum(.x$sale_sum))

# залишити транзакції з сумою більше, ніж 3000
transactions %>%
  keep(~ sum(.x$sale_sum) >= 3000)

# виключити транзакції з сумою менш, ніж 4000
transactions %>%
  discard(~ sum(.x$sale_sum) <= 2000)
install.packages('rio')
library(rio)

# тепер використовуємо у конвеєрі функції keep і walk
transactions %>%
  keep(~ sum(.x$sale_sum) >= 10000) %>%
  walk2(
    .x = .,
    .y = paste0('transaction_3k_', seq_along(.), ".csv"),
    write.csv
  )

# застосовуємо декілька функцій до об'єкту invoke (дозволяють застосовувати декілька функцій до об'єктів) ----------------------------

# вектор функцій, які ми хочемо застосувати
fun <- c('mean', 'sum', 'length') 

# вектор параметрів, які ми будемо передавати у функції
params <- list(
  list(x   = tranaction_df$sale_sum),
  list(... = tranaction_df$sale_sum),
  list(x   = tranaction_df$sale_sum)
)

invoke_map_dbl(fun, params)

# Ще приклад
df <- tibble::tibble(
  f = c("runif", "rpois", "rnorm"),
  params = list(
    list(n = 10),
    list(n = 5, lambda = 10),
    list(n = 10, mean = -3, sd = 10)
  )
)


invoke_map(df$f, df$params)


# функції reduce и accumulate ---------------------------------------------


# reduce() - застосовує функцію з двома основними вхідними змінними
# і повторно застосовує її до списку до тих пир, доки не залишиться хочаб один елемент

# accumulate() - аналогічне reduce(), але утримує всі проміжні результати


# Припустимо, що у нас кожен менеджер має індивідуальний відсоток від продажів,
# а кожен клієнт персональну знижку за договором

managers_dict <- tibble(
  manager = managers,
  department = c('Sale', 'Sale', 'Marketing'),
  salary_percent = c(0.1, 0.12, 0.2)
)

clients_dict <- tibble(
  clients = clients,
  discount = runif(length(clients), min = 0, max = 0.4)
)

data_model <- list(tranaction_df, managers_dict, clients_dict)

# ефективно мерджимо таблиці і обчислюємо додаткові поля
reduce(data_model, left_join) %>%
  mutate(manager_bonus = sale_sum * salary_percent,
         total_sum = sale_sum - (sale_sum * discount),
         cumulate_minuses = accumulate(sale_sum - total_sum + manager_bonus, sum))

# еэквівалент на чистому dplyr
tranaction_df %>%
  left_join(managers_dict) %>%
  left_join(clients_dict) %>%
  mutate(manager_bonus = sale_sum * salary_percent,
         total_sum = sale_sum - (sale_sum * discount),
         cumulate_minuses = cumsum(sale_sum - total_sum + manager_bonus))

