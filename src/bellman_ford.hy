; vim: set syntax=clojure:
(import math)
(import [collections [namedtuple]])

(setv Edge (namedtuple "Edge" "a b cost"))

; Кол-во вершин, начальная и конечная вершины
(setv [nodes-num start-node end-node] [6 0 3])

; Список вершин
(setv edges
    (list-comp (Edge #* row) [row
    [[0 1 10]
     [0 5 8]
     [1 3 2]
     [2 1 1]
     [3 2 -2]
     [4 1 -4]
     [4 3 -1]
     [5 4 1]]]))

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

; Список граней для каждой вершины
(setv edges-list (edges-for-nodes nodes-num edges))

(defn relax-nodes [nodes]
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

(defn bellman-ford []
    "Алгоритм Беллмана-Форда"
    ; Функция на самом деле чистая, хоть и зависит от глобальных переменных
    ; Просто эти переменные - константы, которые мне лень пробрасывать внутрь
    (setv inf-src (repeat math.inf)) ; Бесконечный генератор бесконечности
    (->>
        ; Список путей (0 до первой вершины и бесконечности для остальных
        (zip
            [#*(take start-node inf-src) 0 #*(take (- nodes-num start-node) inf-src)]
            (take nodes-num (repeat 0)))
        list
        (iterate relax-nodes)
        (take (- nodes-num 1))
        last
        list))

(defn restore-shortest-path [nodes]
    "Восстанавливает кратчайший путь от начальной до конечной вершины"
    (setv paths (list (map second nodes)))
    
    (defn get-next [path-list]
        (setv next-val (get paths (last path-list)))
        ; Охтыжгосподимутабельность
        (.append path-list next-val)
        (if (= next-val start-node)
            path-list
            (get-next path-list)))
    
    (-> [(get paths end-node)] get-next reversed))

(defmain [&rest args]
    (-> (bellman-ford) restore-shortest-path list print))

