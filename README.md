# Bellman-Ford

## Формат входных данных:

        Первая строка:

                        * кол-во вершин
                        * кол-во рёбер
                        * номер начальной вершины
                        * номер конечной вершины

        Следующие строки:
                        * номер вершины a
                        * номер вершины b
                        * цена пути из a в b

Формат данных - CSV.


## Реализации

- [C++](https://github.com/cheaterok/Bellman-Ford/blob/master/src/bellman_ford.cpp)

**g++ bellman_ford.cpp** для последовательной реализации

**g++ bellman_ford.cpp -fopenmp** для параллельной

- [Hy](https://github.com/cheaterok/Bellman-Ford/blob/master/src/bellman_ford.hy)

Последовательная реализация запускается как есть.

Для параллельной нужно перегнать Hy в Python и чуть-чуть пошаманить.

- [Clojure](https://github.com/cheaterok/Bellman-Ford/blob/master/src/bellman_ford.clj)

Всё через [Inlein](http://inlein.org/). 

Последовательная реализация запускается как есть.

Для параллельной нужно вызов **map** в *relax-nodes* заменить на **pmap**.
