
# Лабраторна робота № 5 ---------------------------------------------------



# Багатопоточність на R --------------------------------------------------------------

# За матеріалами
# https://selesnow.github.io/iterations_in_r/%D0%BC%D0%BD%D0%BE%D0%B3%D0%BE%D0%BF%D0%BE%D1%82%D0%BE%D1%87%D0%BD%D0%BE%D1%81%D1%82%D1%8C-%D0%B2-r.html

# Урок 5 Багатопоточність у R

# багатопоточні0 цикли -----------------------------------------------------
# install.packages("doSNOW")
library(doSNOW)
library(doParallel)
library(doFuture) # один з варіантів бекенда для конструкції foreach

# функція довготоривалого виконання
pause <- function(min = 1, max = 3) {
  ptime <- runif(1, min, max)
  
  Sys.sleep(ptime)
  
  out <- list(
    pid = Sys.getpid(),
    pause_sec = ptime
  )
}

test <- pause()


# використовуємо foreach 
# іиеруємся одночасно по двох об'єктах
system.time (
  {test2 <- foreach(min = 1:3, max = 2:4) %do% pause(min, max)}
)

test2


# сума тривалості пауз
sum(sapply(test2, '[[', i = 'pause_sec'))

# змінюємо функцію, що збирає результати кожної ітерації (кастомізуємо вивод)
test3 <- foreach(min = 1:3, max = 2:4, .combine = dplyr::bind_rows) %do% pause(min, max)


# Паралельний режим виконання ---------------------------------------------


# створюємо кластер з чотирьох ядер
# cl <- makeCluster(4)
# registerDoSNOW(cl)

options(future.rng.onMisuse = "ignore")
registerDoFuture()
plan('multisession', workers = 3)

# выполняем тот же код но в параллельном режиме
system.time (
  {
    par_test1 <- 
      foreach(min = 1:3, max = 2:4, .combine = dplyr::bind_rows) %dopar% {
        pause(min, max)
      }
  }
)

# зупиняємо кластер
plan('sequential')

par_test1


# багатопоточний варіант функцій apply -------------------------------------

library(pbapply)
library(parallel)

# створюємо кластер з трьох ядер
cl <- makeCluster(3)

# приклад с pbapply
par_test2 <- pblapply(rep(1, 3), FUN = pause, max = 3, cl = cl)

# пример с parallel
par_test3 <- parLapply(rep(1, 3), fun = pause, max = 3, cl = cl)

# останавливаем кластер
stopCluster(cl)

# багатопоточний purrr -----------------------------------------------------
library(furrr)
library(purrr)

plan('multisession', workers = 3)

par_test4 <- future_map2(1:3, 2:4, pause)

# зупиняємо кластер
plan('sequential')

