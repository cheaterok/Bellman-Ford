; vim: set syntax=clojure:
(import csv)
(import math)
(import time)
(import [collections [namedtuple]])
(import [functools [partial]])


#_("Подготовка данных для работы алгоритма")

(setv Edge (namedtuple "Edge" "a b cost"))

(defn edges-for-nodes [nodes-num edges]
    "Список граней для каждой вершины"
    (defn edges-for-node [node-index]
        "Список граней, входящих в вершину с указанным индексом"
        ; Замыкаем edges
        (filter
            (fn [edge]
                (= edge.b node-index))
            edges))
    
    (->> (range nodes-num) (map edges-for-node) (map list) list))

#_("Код самого алгоритма")

(defn relax-nodes [edges-list nodes]
    "В nodes пары (список длин до каждой вершины из нулевой, 
    предыдущие вершины в коротком пути для каждой вершины"
    
    (defn calc-cost [edge]
        "Возвращает путь до ноды (старый, если новый длиннее)"
        ; Замыкаем nodes
        (setv [start-cost _] (get nodes edge.a))
        (setv [end-cost old-parent] (get nodes edge.b))
        (if (< (+ start-cost edge.cost) end-cost)
            [(+ start-cost edge.cost) edge.a]
            [end-cost old-parent]))

    (defn relax-each [node edges-for-node]
        "Пытается удешевить путь до вершины на основе граней,
        входящих в эту вершину"
        ; Пропускаем путь до начальной вершины
        (if (zero? (first node))
            [0 0]
            (min (map calc-cost edges-for-node))))

    (->> (zip nodes edges-list) (*map relax-each) list))

(defn bellman-ford [nodes-num start-node edges-list]
    "Алгоритм Беллмана-Форда"
    (setv inf-src (repeat math.inf)) ; Бесконечный генератор бесконечности
    (with [(Timer)]
        (->>
            ; Список путей (0 до первой вершины и бесконечности для остальных
            (zip
                [#*(take start-node inf-src) 0 #*(take (- nodes-num start-node) inf-src)]
                (take nodes-num (repeat 0)))
            list
            (iterate (partial relax-nodes edges-list))
            (take (- nodes-num 1))
            last
            list)))

#_("Получение результата алгоритма")

(defn restore-shortest-path [paths start-node end-node]
    "Восстанавливает кратчайший путь от начальной до конечной вершины"
    (defn get-next [path-list]
        (setv next-val (get paths (last path-list)))
        ; Охтыжгосподимутабельность
        (.append path-list next-val)
        (if (= next-val start-node)
            path-list
            (get-next path-list)))
    ; Формируем список путей и не забываем добавить финишную ноду в конец
    [#*(-> [(get paths end-node)] get-next reversed) end-node])

#_("Утилитарные штуки")

(defn read-graph [filename]
    "Считывает граф из .csv файла (см. формат в README)"
    (with [f (open filename "rt" :newline "")]
        (as-> (csv.reader f) it 
            (map (fn [row] (list (map int row))) it)
            [#*(first it) (->> (rest it) (*map Edge) list)])))

(defclass Timer []
    (defn --enter__ [self]
        (setv self.start (time.monotonic)))

    (defn --exit-- [self &rest args]
        (print "Time passed:" (- (time.monotonic) self.start))))

(defmain [&rest args]
    (setv [nodes-num _ start-node end-node edges] (read-graph (get args 1)))
    ; Список граней для каждой вершины
    (setv edges-list (edges-for-nodes nodes-num edges))

    (setv result (bellman-ford nodes-num start-node edges-list))
    
    (setv [nodes-cost paths] [(list (map first result)) (list (map second result))])

    (setv shortest-path-cost (get nodes-cost end-node))
    (setv shortest-path (restore-shortest-path paths start-node end-node))

    (print (.format "Shortest path from {} to {} is:" start-node end-node))
    (print shortest-path)
    (print (.format "Shortest path cost = {}" shortest-path-cost)))

