

# Лабраторна робота № 4 ---------------------------------------------------


# Оптимізація коду. Цикли, функціонали і оператори на R ------------------------

# https://selesnow.github.io/iterations_in_r/%D1%86%D0%B8%D0%BA%D0%BB%D1%8B-for-while-%D0%B8-repeat.html


# Урок 2 Функції сімейства aplly

## Зауваження щодо "функціоналів": насправді ми маємо справу не тільки з функціоналами, а й з операторами

# Розглянемо базові функціонали і оператори сімейства apply

x <- 1:10

mean(x)
sum(x)
# apply family

# приклад з циклом ---------------------------------------------------------
# рядки (сумуємо по рядках)
for ( x in seq_along(1:nrow(mtcars)) ) {
  cat(rownames(mtcars[x, ]), ":", sum(mtcars[x, ]), "\n")
}

# стовпці (сумуємо по стовпцях)
col_num <- 1

for ( x in mtcars ) {
  cat(names(mtcars)[col_num], ":", sum(x), "\n")
  col_num <- col_num + 1
}

# apply -------------------------------------------------------------------
# перебирає таблицю або матрицю по рядках чи стовпчиках
# 1 - рядкики
# 2 - стовпці
apply(mtcars, 1, sum)
apply(mtcars, 2, sum)

sum(mtcars[2, ])
sum(mtcars[, 2])
#  ...

# row operation -----------------------------------------------------------
rowSums(mtcars)
rowMeans(mtcars)
colMeans(mtcars)
colSums(mtcars)

# передача додаткових аргументів --------------------------------------
# через кому ми можемо передавати довільну кількість потрібних функції аргументів
apply(mtcars, 2, quantile, probs = 0.25)

quantile(mtcars[, 1], probs = 0.25)
quantile(mtcars[, 2], probs = 0.25)
# ...

?quantile()


# lapply ------------------------------------------------------------------
# перебирає елементи вхідного об'єкта, застосовуючи до кожного з них функцію Fun і ЗАВЖДИ повертає список
values <- list(
  x = c(4, 6, 1),
  y = c(5, 10, 1, 23, 4),
  z = c(2, 5, 6, 7)
)

lapply(values, sum)
sapply(values, sum) # повертає вектор
sapply(values, sum)
vapply(values, sum, FUN.VALUE = 4) # швидка функція, повертає вектор

?vapply()

# lapply з самописною функцією --------------------------------------------
# функція повертає суму першого і останнього аргументів
fl <- function(x) {
  num_elements <- length(x)
  return(x[1] + x[num_elements])
}

lapply(values, fl)

getwd()

# приклад читання файлів ----------------------------------------------------
# зчитуємо список файлів і поєднуємо його в одну таблицю
directory <- "data/"
files <- dir(path = directory, pattern = '\\.csv$')
all_data <- list()

# цикл 
for ( file in files ) {
  data <- read.csv(paste0(directory, file), sep = "\t")
  all_data <- append(all_data, list(data))
}

dplyr::bind_rows(all_data)

# lapply
file_paths <- paste0(directory, files)
all_data <- lapply(file_paths, read.csv, sep = "\t")
dplyr::bind_rows(all_data)


# mapply ------------------------------------------------------------------
# дозволяє перебирати відразу декілька об'єктів
rep(1, 5)

mapply(rep, 1:4, times=4:1)
mapply(rep, times = 1:4, x = 4:1)




