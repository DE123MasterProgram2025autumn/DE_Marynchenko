
# Лабраторна робота № 5 ---------------------------------------------------

# У заключному уроці цього курсу ми познайомимося з найбільш просунутим інтерфєйсом 
# паралельного програмування мовою R, яка надає пакет future.



# Багатопоточність на R --------------------------------------------------------------

# За матеріалами

# https://selesnow.github.io/iterations_in_r/%D0%BF%D0%B0%D0%BA%D0%B5%D1%82-future.html


# furrr - багатопоточна реалізація функцій пакета purrr

library(future)
library(dplyr)

# явне і неявне об'явлення ф'ючерсів ------------------------------------

# звичайний вираз
v <- {
  cat("Hello world!\n")
  3.14
}

# неявне об'явлення ф'ючерса
v %<-% {
  cat("Hello world!\n")
  3.14
}

# явное об'явлення ф'ючерса
f <- future({
  cat("Hello world!\n")
  3.14
})

v <- value(f)

# Чи виконався наш ф'ючерс?
resolved(f)

# ф'ючерс виконує всі обчислення у власному оточенні -----------------
a <- 1

x %<-% {
  a <- 2
  2 * a
}

x

a

# змінюємо план виконання ф'ючерса ---------------------------------------
## послідовне виконання

plan(sequential)
pid <- Sys.getpid()
pid

a %<-% {
  pid <- Sys.getpid()
  cat("Future 'a' ...\n")
  3.14
}

b %<-% {
  cat("Future 'b' ...\n")
  Sys.getpid()
}

c %<-% {
  cat("Future 'c' ...\n")
  2 * a
}

b
c
a
pid

## асинхронне виконнання
### режим параллельно запущених сеансів R

plan(multisession)
pid <- Sys.getpid()
pid

a %<-% {
  pid <- Sys.getpid()
  cat("Future 'a' ...\n")
  cat('pid: ', pid)
  3.14
}

b %<-% {
  cat("Future 'b' ...\n")
  Sys.getpid()
}

c %<-% {
  cat("Future 'c' ...\n")
  2 * a
}

b

c

a

pid

plan(sequential)

# перегляд доступної кількості потоків
availableCores()

### кластерне розгортання

library(parallel)

cl <- parallel::makeCluster(3)
plan(cluster, workers = cl)

pid <- Sys.getpid()
pid

a %<-% {
  pid <- Sys.getpid()
  cat("Future 'a' ...\n")
  cat('pid: ', pid)
  3.14
}

b %<-% {
  cat("Future 'b' ...\n")
  Sys.getpid()
}

c %<-% {
  cat("Future 'c' ...\n")
  2 * a
}

b

c

a

pid

parallel::stopCluster(cl)


# вкладені ф'ючерси -------------------------------------------------------

plan(list(multisession, sequential))
# plan(list(sequential, multisession))

# вказуємо кількість ядер для кожного процесу
# plan(list(tweak(multisession, workers = 2), tweak(multisession, workers = 2)))

pid <- Sys.getpid()

a %<-% {
  cat("Future 'a' ...\n")
  Sys.getpid()
}

b %<-% {
  cat("Future 'b' ...\n")
  b1 %<-% {
    cat("Future 'b1' ...\n")
    Sys.getpid()
  }
  b2 %<-% {
    cat("Future 'b2' ...\n")
    Sys.getpid()
  }
  c(b.pid = Sys.getpid(), b1.pid = b1, b2.pid = b2)
}

pid

a
b

plan(sequential)



# обробка похибок у ф'ючерсах --------------------------------------------

plan(sequential)

b <- "hello"

a %<-% {
  cat("Future 'a' ...\n")
  log(b)
} %lazy% TRUE

a

# дивимося, де саме була похибка
backtrace(a)

# використовуємо ітерування у паралельних процесах ------------------------

# тестова функцsя
manual_pause <- function(x) {
  Sys.sleep(x)
  out <- list(pid = Sys.getpid(), pause = x)
  return(out)
} 

# паузи
pauses <- c(0.5, 2, 3, 2.5) 

# тест
manual_pause(2)

# активуємо паралельні обчислення
plan("multisession", workers = 4)

# итерируемся
futs <- lapply(pauses, function(i) future({ manual_pause(i) }))

# проверяем статус выполнения фьючерсов
sapply(futs, resolved) 

# собираем результаты
res <- lapply(futs, value)    

dplyr::bind_rows(res)


# використовуємо future сумісно з promises ----------------------------------

library(cli)

options(cli.progress_show_after = 0, 
        cli.spinner = "dots")

# паузи
pauses.1 <- sample(1:5, 4, replace = T)
pauses.2 <- sample(2:3, 4, replace = T)
pauses.3 <- sample(3:6, 4, replace = T)

# перше тривале обчислення
plan(list(
  tweak(multisession, workers = 3), 
  tweak(multisession, workers = 4)
)
)

val1 <- future(
  {
    futs <- lapply(pauses.1, function(i) future({ manual_pause(i) }))
    res  <- lapply(futs, value) 
    res  <- dplyr::bind_rows(res)
  }
) 

val2 <- future(
  {
    futs <- lapply(pauses.2, function(i) future({ manual_pause(i) }))
    res  <- lapply(futs, value) 
    res  <- dplyr::bind_rows(res)
  }
) 

val3 <- future(
  {
    futs <- lapply(pauses.3, function(i) future({ manual_pause(i) }))
    res  <- lapply(futs, value) 
    res  <- dplyr::bind_rows(res)
  }
) 

# чекаємо на виконання усіх ф'ючерсів
cli_progress_bar("Waiting")

while ( ! (resolved(val1) | resolved(val2) | resolved(val3)) ) {
  cli_progress_update()
}

cli_progress_update(force = TRUE)

# result table
lapply(list(val1, val2, val3), value) %>% 
  bind_rows() %>%  
  mutate(main_pid = Sys.getpid()) %>% 
  print() %>%
  pull(pause) %>% 
  sum()  %>% 
  cat("\n", "Sum of all pauses: ", ., "\n")

plan(sequential)
