
# Лабраторна робота № 5 ---------------------------------------------------



# Функціональне програмування. Пакет purrr --------------------------------------------------------------


# https://selesnow.github.io/iterations_in_r/%D0%BF%D0%B0%D0%BA%D0%B5%D1%82-purrr.html

# Урок 5 Багатопоточність у R

# У всіх попередніх уроках ми виконували ітерування елементів об'єктів у послідовному режимі, 
# Це прийнятний спосіб ітерування, але не найефективніший. У цьому уроці ми розберемося з тим, 
# як виконувати ітерації в паралельному багатопоточному режимі.
# Так само ми можемо зробити цей процес ще більш ефективним, якщо не рандомно роздаватимемо завдання, а
# розподілимо їх, це балансування навантаження, її ми теж торкнемося в цьому уроці.

# Який інструментарій?

# foreach - просунута реалізація цикла for, яка надає можливість паралельного виконання

# pbapplay - пакет, який реаліху. можливість паралельного запуску функцій сімейства applay
# з підтримкою вбудованого прогресбара

# furrr - багатопоточна реаліхація функцій пакета purrr

# багатопоточні цикли -----------------------------------------------------
# install.packages("doSNOW")
# install.packages('doParallel')
# install.packages('doFuture')
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


# використовуємо foreach у послідовному режимі
# ітерується одночасно за двома об'ектами
system.time (
  {test2 <- foreach(min = 1:3, max = 2:4) %do% pause(min, max)}
)

# сума тривалості пауз
sum(sapply(test2, '[[', i = 'pause_sec'))

# міняємо функцію, яка збирає результати кожної ітерації
test3 <- foreach(min = 1:3, max = 2:4, .combine = dplyr::bind_rows) %do% pause(min, max)

# паралельний режим виконання
# створюємо кластер з чотирьох ядер
# cl <- makeCluster(4)
# registerDoSNOW(cl)

options(future.rng.onMisuse = "ignore")
registerDoFuture()
plan('multisession', workers = 3)

# виконуємо тот самий код, але не у паралельному режимі
system.time (
  {
    par_test1 <- 
      foreach(min = 1:3, max = 2:4, .combine = dplyr::bind_cols) %dopar% {
        pause(min, max)
      }
  }
)

# останавлюємо кластер
plan('sequential')

par_test1


# багатопоточний варіант функцій apply -------------------------------------

library(pbapply)
library(parallel)

# створюємо кластер з трьох ядер
cl <- makeCluster(3)

# приклад с pbapply (з прогресбаром)
par_test2 <- pblapply(rep(1, 3), FUN = pause, max = 3, cl = cl)

# приклад з parallel
par_test3 <- parLapply(rep(1, 3), fun = pause, max = 3, cl = cl)

# останавливаем кластер
stopCluster(cl)


# багатопоточний purrr -----------------------------------------------------
library(furrr)

plan('multisession', workers = 3) # перехід у багатопоточний режим

par_test4 <- future_map2(1:3, 2:4, pause)

# останавлюємо кластер
plan('sequential')

