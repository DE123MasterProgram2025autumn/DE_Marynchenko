
# Лабраторна робота № 4 ---------------------------------------------------


# Оптимізація коду. Цикли і функціонали на R ------------------------

# https://selesnow.github.io/iterations_in_r/%D1%86%D0%B8%D0%BA%D0%BB%D1%8B-for-while-%D0%B8-repeat.html

# Урок 1 Циклы for, while и repeat

# циклы в базовому синтаксисі R


# for ---------------------------------------------------------------------
## виконувати до тих піл,
## доки в об'єкті, що піддається ітеруванню не буде перебрано
## всі елементи

## ітерування по вектору
week <- c('Sunday', 
          'Monday', 
          'Tuesday', 
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday')


for ( day in week ) {
  
  print(day)
  Sys.sleep(0.25)
  
}

## ітерування по списку
persons <- list(
  list(name = "Alexey", age = 36), 
  list(name = "Justin", age = 27),
  list(name = "Piter",  age = 22),
  list(name = "Sergey", age = 39))

str(persons)
persons[[1]][[1]]

## оператор next дозволяє переходити на наступну ітерацію
for ( person in persons ) {
  
  if ( person$age < 30 ) next
  
  print( paste0( person$name, " is ", person$age, " years old"))
  
} 

## ітерування по таблицях
for ( col in mtcars ) {
  print(mean(col))
}

?mtcars

## ітерування по рядках таблиці
for ( row in 1:nrow(mtcars) ) {
  print(mtcars[row, c('cyl', 'gear')])
}

## вкладені цикли for
x <- 1:5
y <- letters[1:5]

for ( int in x ) {
  
  for ( let in y ) {
    
    print(paste0(int, ": ", let))
    
  }
  
}

## як вчинити, якщо мені потрібно на кожнй ітерації об'єднувати таблиці

setwd('data')

files <- dir()
result <- list()

for ( file in files ) {
  
  temp_df <- read.csv(file, sep = "\t")
  
  result <- append(result, list(temp_df))
  
}

str(result)

append(1:5, 0:1, after = 3)
append(1:5, 0:1)

# об'єднуєм результати в одну таблицю
result <- do.call('rbind', result)


# while -------------------------------------------------------------------
## ітерується до тих пір,
## поки є істинною задана умова
x <- 1

while ( x < 10 ) {
  
  print(x)
  x <- x + 1
  
}

# оператор break
x <- 1

while ( x < 20 ) {
  
  print(x)
  
  if ( x / 2 == 5 ) break
  
  x <- x + 1
  
}

# repeate -----------------------------------------------------------------

## ітерується до их пір,
## поки не зустріне break
x <- 1

repeat {
  
  print(x)
  
  if (x / 2 == 5) break
  
  x <- x + 1
}



# !!! Завдання на самостійну роботу ---------------------------------------

# Розібрати самостійно з конструкціями try() і tryCatch(),
# які дозволяють перехоплювати і обробляти помилки в R.

# Джерело: https://selesnow.github.io/iterations_in_r/%D0%BE%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0-%D0%BE%D1%88%D0%B8%D0%B1%D0%BE%D0%BA-%D0%BA%D0%BE%D0%BD%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%86%D0%B8%D0%B8-try-%D0%B8-trycatch.html


